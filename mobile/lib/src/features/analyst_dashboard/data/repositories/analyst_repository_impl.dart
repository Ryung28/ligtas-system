import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:async/async.dart';
import 'package:mobile/src/core/extensions/supabase_client_extension.dart';
import 'package:mobile/src/core/utils/storage_location_labels.dart';
import '../../domain/entities/analyst_metrics.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/entities/logistics_action.dart';
import '../../domain/repositories/i_analyst_repository.dart';

class AnalystRepositoryImpl implements IAnalystRepository {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  AnalystRepositoryImpl(this._ref);

  @override
  Future<AnalystMetrics> getMetrics({String? warehouseId}) async {
    try {
      // Client-side counts (avoids `get_analyst_metrics` RPC, which assumed
      // `assigned_warehouse` on views that only expose `location` / RLS scoping).
      var invQ = _supabase.from('active_inventory').select('id');
      if (warehouseId != null) {
        invQ = invQ.eq('location', warehouseId);
      }

      Future<List<dynamic>> borrowByStatus(String status) async {
        var q = _supabase.from('borrow_logs').select('id').eq('status', status);
        if (warehouseId != null) {
          q = q.eq('warehouse_id', warehouseId);
        }
        final rows = await q;
        return List<dynamic>.from(rows as List);
      }

      final inv = await invQ;
      final pending = await borrowByStatus('pending');
      final borrowed = await borrowByStatus('borrowed');
      final overdue = await borrowByStatus('overdue');

      return AnalystMetrics(
        totalAssets: inv.length,
        assetsTrendPercent: 0.0,
        pendingApprovals: pending.length,
        activeLoans: borrowed.length,
        loansTrendPercent: 0.0,
        overdueCount: overdue.length,
        overdueTrendPercent: 0.0,
        anomalyCount: 0,
      );
    } catch (e) {
      debugPrint('🚨 [AnalystRepo] Metrics Error: $e');
      throw Exception('Failed to fetch analyst metrics: $e');
    }
  }

  @override
  Stream<AnalystMetrics> watchMetricsStream({String? warehouseId}) async* {
    int total = 0;
    int pending = 0;
    int borrowed = 0;
    int overdue = 0;

    AnalystMetrics currentMetrics() => AnalystMetrics(
      totalAssets: total,
      assetsTrendPercent: 0.0,
      pendingApprovals: pending,
      activeLoans: borrowed,
      loansTrendPercent: 0.0,
      overdueCount: overdue,
      overdueTrendPercent: 0.0,
      anomalyCount: 0,
    );

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _supabase.checkConnection();

        final invStream = warehouseId != null
            ? _supabase.from('active_inventory').stream(primaryKey: ['id']).eq('location', warehouseId)
            : _supabase.from('active_inventory').stream(primaryKey: ['id']);

        final logStream = warehouseId != null
            ? _supabase.from('borrow_logs').stream(primaryKey: ['id']).eq('warehouse_id', warehouseId)
            : _supabase.from('borrow_logs').stream(primaryKey: ['id']);

        // Combined stream for metrics
        yield* StreamGroup.merge([
          invStream.map((data) {
            total = data.length;
            return currentMetrics();
          }),
          logStream.map((data) {
            pending = data.where((e) => e['status'] == 'pending').length;
            borrowed = data.where((e) {
              final isBorrowed = e['status'] == 'borrowed';
              final dueDateStr = e['expected_return_date'] as String?;
              if (!isBorrowed || dueDateStr == null) return false;
              try {
                return DateTime.parse(dueDateStr).isAfter(DateTime.now());
              } catch (_) { return true; }
            }).length;
            overdue = data.where((e) {
              final isBorrowed = e['status'] == 'borrowed';
              final dueDateStr = e['expected_return_date'] as String?;
              if (!isBorrowed || dueDateStr == null) return false;
              try {
                return DateTime.parse(dueDateStr).isBefore(DateTime.now());
              } catch (_) { return false; }
            }).length;
            return currentMetrics();
          }),
        ]).handleError((error) {
          debugPrint('[Analyst-Metrics] Stream Error: $error');
          throw error;
        });

        break;
      } catch (e) {
        retryCount++;
        debugPrint('[Analyst-Metrics] Reconnecting (Attempt $retryCount/$maxRetries)...');
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  @override
  Stream<List<ResourceAnomaly>> watchAnomalies({int limit = 200, String? warehouseId}) async* {
    // 1. Initial High-Speed Fetch
    yield await getAnomalies(limit: limit, warehouseId: warehouseId);

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _supabase.checkConnection();

        final inventoryChanges = _supabase
            .from('inventory')
            .stream(primaryKey: ['id'])
            .map((_) => true);

        final actionChanges = _supabase
            .from('logistics_actions')
            .stream(primaryKey: ['id'])
            .map((_) => true);

        await for (final _ in StreamGroup.merge([inventoryChanges, actionChanges])) {
          yield await getAnomalies(limit: limit, warehouseId: warehouseId);
        }
        break;
      } catch (e) {
        retryCount++;
        debugPrint('[Analyst-Anomalies] Reconnecting (Attempt $retryCount/$maxRetries)...');
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  @override
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 200, String? warehouseId}) async {
    try {
      var query = _supabase.from('system_intel').select();
      if (warehouseId != null) {
        query = query.or('warehouse_id.eq.$warehouseId,warehouse_id.is.null');
      }

      // Newest signals first within the fetch window (matches alert queue / filters).
      final response = await query.order('created_at', ascending: false).limit(limit);
      final List<dynamic> data = response is List ? response : [];

      // Collect inventory IDs for a single batch image fetch
      final inventoryIds = data
          .map((item) {
            final meta = item['metadata'] as Map<String, dynamic>? ?? {};
            // 🛡️ SAFE PARSE: IDs often come as Strings in JSONB
        final rawId = meta['inventory_id'] ?? meta['id'] ?? item['inventory_id'] ?? meta['item_id'];
        if (rawId is int) return rawId;
        if (rawId is String) return int.tryParse(rawId);
        return null;
          })
          .whereType<int>()
          .toList();

      // 🛡️ LIVE LINK: Scoped fetch from the inventory ledger
      final liveMap = await _fetchLiveInventoryMap(inventoryIds, warehouseId: warehouseId);

      final anomalies = <ResourceAnomaly>[];
      for (final item in data) {
        try {
          final meta = item['metadata'] as Map<String, dynamic>? ?? {};
          final rawId = (meta['inventory_id'] ?? meta['id'] ?? item['inventory_id'] ?? meta['item_id']);
          final invId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) : null);
          
          final liveData = invId != null ? liveMap[invId] : null;

          // 🛰️ GOAL FALLBACK: Admin "Max" can be in target_stock, stock_total, quantity, or goal alias
          final maxStockVal = (liveData?['target_stock'] ?? liveData?['stock_total'] ?? liveData?['max_stock'] ?? liveData?['goal'] ?? meta['target_stock'] as num?)?.toInt();

          anomalies.add(ResourceAnomaly(
            id: item['id'].toString(),
            inventoryId: invId,
            itemId: (liveData?['item_id'] as num?)?.toInt() ?? (meta['item_id'] as num?)?.toInt(),
            locationRegistryId: (liveData?['location_registry_id'] as num?)?.toInt(),
            itemName: liveData?['item_name']?.toString() ?? item['title']?.toString() ?? 'System Alert',
            reason: item['message']?.toString() ?? 'Check required.',
            imageUrl: _resolveRawPath(liveData?['image_url'] ?? meta['image_url']),
            category: _mapCategoryToType(item['category'] as String?),
            severity: _mapSeverity(item['priority'] as String?),
            currentStock: (liveData?['stock_available'] ?? meta['stock_available'] as num?)?.toInt() ?? 0,
            thresholdStock: (liveData?['low_stock_threshold'] ?? liveData?['minStockLevel'] ?? meta['low_stock_threshold'] as num?)?.toInt() ?? 0,
            maxStock: maxStockVal,
            detectedAt: item['created_at'] != null
                ? DateTime.parse(item['created_at'])
                : DateTime.now(),
            // 🛰️ MAP OVERDUE CONTEXT (now fully enriched by system_intel view)
            borrowId: (meta['borrow_id'] as num?)?.toInt(),
            borrowerName: meta['borrower_name']?.toString(),
            borrowerContact: meta['borrower_contact']?.toString(),
            borrowerEmail: meta['borrower_email']?.toString(),
            borrowerOrg: meta['borrower_organization']?.toString(),
            borrowedQty: (meta['quantity'] as num?)?.toInt() ?? 0,
            dueDate: meta['due_date'] != null ? DateTime.tryParse(meta['due_date'].toString()) : null,
            borrowedAt: meta['borrowed_at'] != null ? DateTime.tryParse(meta['borrowed_at'].toString()) : null,
            approvedByName: meta['approved_by_name']?.toString(),
            releasedByName: meta['released_by_name']?.toString(),
            platformOrigin: meta['platform_origin']?.toString(),
            qtyGood: (liveData?['qty_good'] ?? meta['qty_good'] as num?)?.toInt() ?? 0,
            qtyDamaged: (liveData?['qty_damaged'] ?? meta['qty_damaged'] as num?)?.toInt() ?? 0,
            qtyMaintenance: (liveData?['qty_maintenance'] ?? meta['qty_maintenance'] as num?)?.toInt() ?? 0,
            qtyLost: (liveData?['qty_lost'] ?? meta['qty_lost'] as num?)?.toInt() ?? 0,
          ));
        } catch (e) {
          debugPrint('[AnalystRepo] Skipped anomaly row: $e');
        }
      }

      return sortResourceAnomaliesLikeActionCenter(anomalies);
    } catch (e) {
      debugPrint('[AnalystRepo] getAnomalies failed: $e');
      return [];
    }
  }

  /// 🛰️ LIVE CACHE: Fetches the absolute latest inventory states for a batch of IDs 
  /// 🛡️ SECURITY: Scoping already happened at the alert level; here we fetch specific PKs.
  Future<Map<int, Map<String, dynamic>>> _fetchLiveInventoryMap(List<int> ids, {String? warehouseId}) async {
    if (ids.isEmpty) return {};
    try {
      // 🛡️ DATA TRUST: Since we have the exact IDs, we query them directly to avoid RLS-flicker
      final response = await _supabase
          .from('inventory')
          .select('id, item_id, location_registry_id, item_name, image_url, target_stock, stock_total, stock_available, low_stock_threshold, qty_good, qty_damaged, qty_maintenance, qty_lost')
          .filter('id', 'in', ids);
      
      final Map<int, Map<String, dynamic>> map = {};
      for (final item in (response as List)) {
        map[item['id'] as int] = item as Map<String, dynamic>;
      }
      return map;
    } catch (e) {
      debugPrint('🚨 [AnalystRepo] Live Sync Failure: $e');
      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // FORCE RETURN (overdue borrow — mirrors web returnItem server action)
  // ---------------------------------------------------------------------------
  @override
  Future<ForceReturnResult> forceReturn({
    required int borrowId,
    required int inventoryId,
    required int quantity,
    required String receivedByName,
    required String receivedByUserId,
    String returnCondition = 'good',
    String? returnNotes,
  }) async {
    try {
      // 1. Guard: verify not already returned
      final check = await _supabase
          .from('borrow_logs')
          .select('status')
          .eq('id', borrowId)
          .maybeSingle();

      if (check == null) {
        return const ForceReturnResult.fail('Borrow record not found.');
      }
      if (check['status'] == 'returned') {
        return const ForceReturnResult.fail('Item has already been returned.');
      }

      // 2. Update borrow_logs — same fields as web returnItem
      await _supabase.from('borrow_logs').update({
        'status': 'returned',
        'actual_return_date': DateTime.now().toUtc().toIso8601String(),
        'received_by_name': receivedByName,
        'received_by_user_id': receivedByUserId,
        'return_condition': returnCondition,
        'return_notes': returnNotes,
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      }).eq('id', borrowId);

      // 3. Increment inventory stock
      final invRow = await _supabase
          .from('inventory')
          .select('stock_available')
          .eq('id', inventoryId)
          .maybeSingle();

      if (invRow != null) {
        final current = (invRow['stock_available'] as num?)?.toInt() ?? 0;
        await _supabase
            .from('inventory')
            .update({'stock_available': current + quantity})
            .eq('id', inventoryId);
      }

      return const ForceReturnResult.ok();
    } catch (e) {
      debugPrint('[AnalystRepo] forceReturn failed: $e');
      return ForceReturnResult.fail(e.toString());
    }
  }

  @override
  Future<List<ActivityEvent>> getActivityStream({
    bool liveOnly = false,
    int limit = 50,
    String? warehouseId,
  }) async {
    try {
      // 🛡️ SSOT HYDRATION: Ensure we join inventory and select all required forensic context fields
      var query = _supabase.from('borrow_logs').select('''
        *, 
        approved_by_name,
        released_by_name,
        borrower_organization,
        borrower_contact,
        inventory:inventory_id(image_url, storage_location)
      ''');
      if (warehouseId != null) {
        query = query.eq('warehouse_id', warehouseId);
      }

      final response = await query.order('updated_at', ascending: false).limit(limit);
      final List<dynamic> data = response is List ? response : [];
      return data.map((item) => _mapToActivityEvent(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity stream: $e');
    }
  }

  @override
  Future<List<LogisticsAction>> getLogisticsQueue({String? warehouseId}) async {
    try {
      var query = _supabase.from('logistics_actions').select();
      if (warehouseId != null) {
        query = query.eq('warehouse_id', warehouseId);
      }

      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response is List ? response : [];

      final actions = <LogisticsAction>[];
      for (final item in data) {
        try {
          final map = item as Map<String, dynamic>;
          actions.add(LogisticsAction(
            id: map['id']?.toString() ?? '',
            itemName: map['item_name']?.toString() ?? 'Unknown Asset',
            itemId: map['item_id']?.toString() ?? '',
            // Support both legacy 'action_type' and current 'type' column
            type: _mapActionType(map['type'] ?? map['action_type']),
            status: _mapActionStatus(map['status']),
            quantity: (map['quantity'] ?? map['quantity_changed'] ?? 0) as int,
            requesterId: map['requester_id']?.toString(),
            requesterName: map['requester_name']?.toString(),
            recipientName: map['recipient_name']?.toString(),
            recipientOffice: map['recipient_office']?.toString(),
            warehouseId: map['warehouse_id']?.toString(),
            binLocation: map['bin_location']?.toString(),
            forensicNote: map['forensic_note']?.toString(),
            forensicImageUrl: _resolveRawPath(map['forensic_image_url']?.toString()),
            createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
          ));
        } catch (e) {
          debugPrint('[AnalystRepo] Skipped corrupt logistics_actions row: $e');
          continue;
        }
      }

      return actions;
    } catch (e) {
      throw Exception('Failed to fetch logistics queue: $e');
    }
  }

  @override
  Future<void> resolveLogisticsAction({
    required String actionId,
    required ActionStatus status,
    String? forensicNote,
    String? forensicImageUrl,
  }) async {
    try {
      await _supabase
          .from('logistics_actions')
          .update({
            'status': status.name,
            'forensic_note': forensicNote,
            'forensic_image_url': forensicImageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', actionId);
    } catch (e) {
      throw Exception('Failed to resolve logistics action: $e');
    }
  }

  @override
  Stream<List<ActivityEvent>> watchActivityStream({String? warehouseId}) async* {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _supabase.checkConnection();

        // Initial load
        yield await getActivityStream(limit: 50, warehouseId: warehouseId);

        // Listen for any movement in borrow_logs
        await for (final _ in _supabase.from('borrow_logs').stream(primaryKey: ['id'])) {
          yield await getActivityStream(limit: 50, warehouseId: warehouseId);
        }
        break;
      } catch (e) {
        retryCount++;
        debugPrint('[Analyst-Activity] Reconnecting (Attempt $retryCount/$maxRetries)...');
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  @override
  Future<List<ActivityEvent>> getPaginatedActivity({
    required int offset,
    required int limit,
    String? searchQuery,
    String? status,
    String? warehouseId,
  }) async {
    try {
      var query = _supabase.from('borrow_logs').select('''
        *,
        inventory:inventory_id(image_url, storage_location)
      ''');

      if (warehouseId != null) {
        query = query.eq('warehouse_id', warehouseId);
      }
      if (status != null && status != 'all') {
        query = query.eq('status', status.toLowerCase());
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('item_name.ilike.%$searchQuery%,borrower_name.ilike.%$searchQuery%');
      }

      final response = await query
          .order('updated_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response is List ? response : [];
      return data.map((item) => _mapToActivityEvent(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch paginated activity: $e');
    }
  }

  @override
  Future<void> verifyActivityEvent({
    required String eventId,
    required String analystId,
    String? forensicNote,
  }) async {
    try {
      await _supabase
          .from('borrow_logs')
          .update({
            'verified_at': DateTime.now().toIso8601String(),
            'verified_by': analystId,
            if (forensicNote != null) 'return_notes': forensicNote,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to verify activity event: $e');
    }
  }

  @override
  Future<void> approveRequest({
    required String logId,
    required String approvedBy,
    bool isInstant = false,
  }) async {
    try {
      final updateData = {
        'status': isInstant ? 'borrowed' : 'staged',
        'approved_by_name': approvedBy,
        'approved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
        if (isInstant) ...{
          'released_by_name': approvedBy,
          'handed_at': DateTime.now().toIso8601String(),
          'borrow_date': DateTime.now().toIso8601String(),
        }
      };

      await _supabase.from('borrow_logs').update(updateData).eq('id', logId);
    } catch (e) {
      throw Exception('Failed to approve request: $e');
    }
  }

  @override
  Future<void> rejectRequest({required String logId}) async {
    try {
      // 1. Fetch Log for restoration info
      final log = await _supabase
          .from('borrow_logs')
          .select('inventory_id, quantity, status')
          .eq('id', logId)
          .single();

      if (log['status'] != 'pending' && log['status'] != 'staged') {
        throw Exception('Only pending or staged requests can be rejected');
      }

      // 2. Mark as Rejected
      await _supabase
          .from('borrow_logs')
          .update({
            'status': 'rejected',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', logId);

      // 3. Restore Stock
      final invId = log['inventory_id'] as int;
      final qty = log['quantity'] as int;

      final item = await _supabase
          .from('inventory')
          .select('stock_available')
          .eq('id', invId)
          .single();

      await _supabase
          .from('inventory')
          .update({
            'stock_available': (item['stock_available'] as int) + qty,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invId);
    } catch (e) {
      throw Exception('Failed to reject request: $e');
    }
  }

  @override
  Future<void> completeHandoff({
    required String logId,
    required String handedBy,
  }) async {
    try {
      await _supabase.from('borrow_logs').update({
        'status': 'borrowed',
        'borrow_date': DateTime.now().toIso8601String(),
        'released_by_name': handedBy,
        'handed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      }).eq('id', logId);
    } catch (e) {
      throw Exception('Failed to complete handoff: $e');
    }
  }

  @override
  Future<void> restockAsset({
    required int inventoryId,
    int addedGood = 0,
    int addedDamaged = 0,
    int addedMaintenance = 0,
    int addedLost = 0,
    String? notes,
  }) async {
    try {
      // 1. Fetch current health state (baseline)
      final response = await _supabase
          .from('inventory')
          .select('qty_good, qty_damaged, qty_maintenance, qty_lost, stock_total')
          .eq('id', inventoryId)
          .single();

      final currentGood = (response['qty_good'] as num?)?.toInt() ?? 0;
      final currentDamaged = (response['qty_damaged'] as num?)?.toInt() ?? 0;
      final currentMaint = (response['qty_maintenance'] as num?)?.toInt() ?? 0;
      final currentLost = (response['qty_lost'] as num?)?.toInt() ?? 0;

      // 2. Calculate new proportions (Deltas)
      final newGood = currentGood + addedGood;
      final newDamaged = currentDamaged + addedDamaged;
      final newMaint = currentMaint + addedMaintenance;
      final newLost = currentLost + addedLost;
      final newTotal = newGood + newDamaged + newMaint + newLost;

      // 3. EXECUTE COMMAND OVERRIDE
      await _supabase.from('inventory').update({
        'qty_good': newGood,
        'qty_damaged': newDamaged,
        'qty_maintenance': newMaint,
        'qty_lost': newLost,
        'stock_total': newTotal,
        'stock_available': newGood, // Available is strictly linked to Good bucket
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', inventoryId);

      debugPrint('⚙️ LIGTAS-RESTOCK: Asset $inventoryId Injected. Good: +$addedGood, Damaged: +$addedDamaged');
    } catch (e) {
      throw Exception('Restock Command Failed: $e');
    }
  }

  @override
  Future<void> updateItemStrategy({
    required int inventoryId,
    required int threshold,
    required String strategyLabel,
  }) async {
    try {
      await _supabase.from('inventory').update({
        'low_stock_threshold': threshold,
        'item_type': strategyLabel.toLowerCase().contains('fixed') ? 'equipment' : 'consumable',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', inventoryId);
      
      debugPrint('⚙️ LIGTAS-STRATEGY: Asset $inventoryId defined as $strategyLabel.');
    } catch (e) {
      throw Exception('Failed to update item strategy: $e');
    }
  }

  @override
  Future<void> updateAssetHealth({
    required int inventoryId,
    int? qtyGood,
    int? qtyDamaged,
    int? qtyMaintenance,
    int? qtyLost,
    String? notes,
  }) async {
    try {
      // 1. Fetch baseline if partial update requested
      final response = await _supabase
          .from('inventory')
          .select('qty_good, qty_damaged, qty_maintenance, qty_lost')
          .eq('id', inventoryId)
          .single();

      final finalGood = qtyGood ?? (response['qty_good'] as num?)?.toInt() ?? 0;
      final finalDamaged = qtyDamaged ?? (response['qty_damaged'] as num?)?.toInt() ?? 0;
      final finalMaint = qtyMaintenance ?? (response['qty_maintenance'] as num?)?.toInt() ?? 0;
      final finalLost = qtyLost ?? (response['qty_lost'] as num?)?.toInt() ?? 0;

      // 2. Strict Reconciliation (Sum of Buckets = Total)
      final finalTotal = finalGood + finalDamaged + finalMaint + finalLost;

      // 3. EXECUTE TRIAGE COMMAND
      await _supabase.from('inventory').update({
        'qty_good': finalGood,
        'qty_damaged': finalDamaged,
        'qty_maintenance': finalMaint,
        'qty_lost': finalLost,
        'stock_total': finalTotal,
        'stock_available': finalGood,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', inventoryId);

      debugPrint('⚙️ LIGTAS-TRIAGE: Asset $inventoryId rebalanced.');
    } catch (e) {
      throw Exception('Health Triage Failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _inventoryQuery({String? warehouseId}) {
    final q = _supabase.from('active_inventory').select('id');
    return warehouseId != null ? q.eq('location', warehouseId) : q;
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _borrowLogsQuery({String? warehouseId}) {
    final q = _supabase.from('borrow_logs').select('id');
    return warehouseId != null ? q.eq('warehouse_id', warehouseId) : q;
  }

  Future<Map<int, String?>> _fetchImageMap(List<int> ids) async {
    if (ids.isEmpty) return {};
    try {
      final result = await _supabase
          .from('inventory')
          .select('id, image_url')
          .filter('id', 'in', ids.toSet().toList());

      return {
        for (final row in result as List) row['id'] as int: row['image_url'] as String?,
      };
    } catch (e) {
      debugPrint('[AnalystRepo] Image batch fetch failed: $e');
      return {};
    }
  }

  /// Matches web `transaction-detail-body`: `borrowed_from_warehouse` → `warehouse_id` → join `inventory.storage_location`.
  String? _borrowSiteLocation(Map<String, dynamic> item) {
    final borrowedFrom = item['borrowed_from_warehouse']?.toString().trim();
    if (borrowedFrom != null && borrowedFrom.isNotEmpty) {
      return formatStorageLocationLabel(borrowedFrom);
    }
    final wh = item['warehouse_id']?.toString().trim();
    if (wh != null && wh.isNotEmpty) {
      return formatStorageLocationLabel(wh);
    }
    final inv = item['inventory'];
    if (inv is Map<String, dynamic>) {
      final loc = inv['storage_location']?.toString().trim();
      if (loc != null && loc.isNotEmpty) return formatStorageLocationLabel(loc);
    }
    return null;
  }

  ActivityEvent _mapToActivityEvent(Map<String, dynamic> item) {
    final status = item['status'] as String? ?? 'pending';
    
    final eventType = switch (status) {
      'pending'   => EventType.requisitionApproved,
      'borrowed'  => EventType.assetOut,
      'returned'  => EventType.assetIn,
      'overdue'   => EventType.maintenance,
      'cancelled' => EventType.requisitionDenied,
      _           => EventType.systemSync,
    };

    final eventStatus = switch (status) {
      'pending'                    => EventStatus.transit,
      'overdue'                    => EventStatus.offline,
      'returned' || 'dispensed'    => EventStatus.synced,
      _                            => EventStatus.verified,
    };

    final delta = 'QTY: ${item['quantity'] ?? 0}';
    final actor = item['borrower_name'] as String? ?? 'Field Personnel';

    // 🏛️ DYNAMIC REASONING: Construct smart fallbacks based on event context
    final dynamicFallback = switch (eventType) {
      EventType.assetOut => 'Authorized equipment deployment.',
      EventType.assetIn => 'Equipment safely returned to hub.',
      EventType.requisitionApproved => 'Requisition verified by command.',
      EventType.maintenance => 'Asset flagged for service audit.',
      EventType.requisitionDenied => 'Requisition declined by supervisor.',
      _ => 'Logistical event recorded.',
    };

    return ActivityEvent(
      id: item['id'].toString(),
      type: eventType,
      title: item['item_name']?.toString() ?? 'Unknown Asset',
      subtitle: 'By $actor',
      referenceId: (item['inventory_id'] ?? item['id']).toString(),
      assetId: item['inventory_id'] != null ? (item['inventory_id'] as num).toInt() : null,
      status: eventStatus,
      timestamp: DateTime.parse(item['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      priority: status == 'pending' || status == 'overdue' ? 'CRITICAL' : 'ROUTINE',
      quantityDelta: delta,
      locationSource: _borrowSiteLocation(item),
      locationTarget: null,
      actorName: actor,
      // 🛰️ MAP LOGISTICS CONTEXT
      approvedByName: item['approved_by_name'] as String?,
      releasedByName: item['released_by_name'] as String?,
      borrowerOrganization: item['borrower_organization'] as String?,
      borrowerContact: item['borrower_contact'] as String?,
      createdOrigin: item['created_origin'] as String?,
      lastUpdatedOrigin: item['last_updated_origin'] as String?,
      // 🛡️ FORENSIC PRIORITY: return_notes > purpose > generic_notes > fallback
      notes: item['return_notes'] as String? ?? 
             item['purpose'] as String? ?? 
             item['notes'] as String? ?? 
             dynamicFallback,
      evidencePath: _resolveRawPath(item['evidence_image_url'] as String?),
      referencePath: _resolveRawPath(
        item['reference_image_url'] as String? ?? 
        (item['inventory'] as Map<String, dynamic>?)?['image_url'] as String?
      ),
      assetCategory: item['item_category'] as String?,
      assetCondition: item['return_condition'] as String?,
      verifiedAt: item['verified_at'] != null
          ? DateTime.parse(item['verified_at'] as String)
          : null,
      telemetry: {
        'lat': -5.9,
        'lng': -58.4,
        'device': 'LIGTAS-04-PAD',
      },
    );
  }

  AnomalyCategory _mapCategoryToType(String? category) {
    return switch (category?.toUpperCase()) {
      'INVENTORY'  => AnomalyCategory.depletion,
      'LOGISTICS'  => AnomalyCategory.logistics,
      'OVERDUE'    => AnomalyCategory.overdue,
      'ACCESS'     => AnomalyCategory.access,
      _            => AnomalyCategory.depletion,
    };
  }

  AnomalySeverity _mapSeverity(String? priority) {
    return switch (priority?.toUpperCase()) {
      'CRITICAL' => AnomalySeverity.critical,
      'WARNING'  => AnomalySeverity.warning,
      'INFO'     => AnomalySeverity.info,
      _          => AnomalySeverity.warning,
    };
  }

  ActionType _mapActionType(dynamic value) {
    if (value == null) return ActionType.unknown;
    final str = value.toString().toLowerCase();
    // 'return' is a reserved word in Dart — map it explicitly
    if (str == 'return') return ActionType.returnItem;
    return ActionType.values.firstWhere(
      (e) => e.name == str,
      orElse: () => ActionType.unknown,
    );
  }

  ActionStatus _mapActionStatus(dynamic value) {
    if (value == null) return ActionStatus.unknown;
    final str = value.toString().toLowerCase();
    return ActionStatus.values.firstWhere(
      (e) => e.name == str,
      orElse: () => ActionStatus.unknown,
    );
  }

  /// 🛡️ SSOT PATH RESOLVER: Extracts raw paths from signed/full URLs or raw inputs.
  /// This ensures the UI component TacticalAssetImage can do its own resolution.
  String? _resolveRawPath(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;

    // 🏛️ HANDLE FULL URLS (Extract path segments)
    if (pathOrUrl.startsWith('http')) {
      if (pathOrUrl.contains('/storage/v1/object/')) {
        try {
          final uri = Uri.parse(pathOrUrl);
          final segments = uri.pathSegments;
          final objectIndex = segments.indexOf('object');
          if (objectIndex != -1 && objectIndex + 3 < segments.length) {
             // segments: [... object, public, bucket, path...]
             return segments.sublist(objectIndex + 3).join('/');
          }
        } catch (_) {}
      }
      return pathOrUrl; // Fallback to raw
    }

    // 🏛️ HANDLE RELATIVE PATHS (Cleanup)
    return pathOrUrl.trim().replaceAll(RegExp(r'^\/+'), '');
  }
}
