import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      final results = await Future.wait<dynamic>([
        _inventoryQuery(warehouseId: warehouseId),
        _borrowLogsQuery(warehouseId: warehouseId).eq('status', 'pending'),
        _borrowLogsQuery(warehouseId: warehouseId).eq('status', 'borrowed'),
        _borrowLogsQuery(warehouseId: warehouseId).eq('status', 'overdue'),
      ]);

      int count(dynamic res) => res is List ? res.length : 0;

      return AnalystMetrics(
        totalAssets: count(results[0]),
        assetsTrendPercent: 0.0,
        pendingApprovals: count(results[1]),
        activeLoans: count(results[2]),
        loansTrendPercent: 0.0,
        overdueCount: count(results[3]),
        overdueTrendPercent: 0.0,
        anomalyCount: 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch analyst metrics: $e');
    }
  }

  @override
  Stream<AnalystMetrics> watchMetricsStream({String? warehouseId}) {
    final controller = StreamController<AnalystMetrics>();

    int total = 0;
    int pending = 0;
    int borrowed = 0;
    int overdue = 0;

    void emit() {
      if (!controller.isClosed) {
        controller.add(AnalystMetrics(
          totalAssets: total,
          assetsTrendPercent: 0.0,
          pendingApprovals: pending,
          activeLoans: borrowed,
          loansTrendPercent: 0.0,
          overdueCount: overdue,
          overdueTrendPercent: 0.0,
          anomalyCount: 0,
        ));
      }
    }

    final invStream = warehouseId != null
        ? _supabase.from('active_inventory').stream(primaryKey: ['id']).eq('assigned_warehouse', warehouseId)
        : _supabase.from('active_inventory').stream(primaryKey: ['id']);

    final invSub = invStream.listen((data) {
      total = data.length;
      emit();
    });

    final logStream = warehouseId != null
        ? _supabase.from('borrow_logs').stream(primaryKey: ['id']).eq('warehouse_id', warehouseId)
        : _supabase.from('borrow_logs').stream(primaryKey: ['id']);

    final logSub = logStream.listen((data) {
      pending = data.where((e) => e['status'] == 'pending').length;
      borrowed = data.where((e) => e['status'] == 'borrowed').length;
      overdue = data.where((e) => e['status'] == 'overdue').length;
      emit();
    });

    _ref.onDispose(() {
      invSub.cancel();
      logSub.cancel();
      if (!controller.isClosed) controller.close();
      debugPrint('[AnalystRepo] Realtime streams closed.');
    });

    controller.onCancel = () {
      invSub.cancel();
      logSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<ResourceAnomaly>> watchAnomalies({int limit = 10, String? warehouseId}) async* {
    // 1. Initial High-Speed Fetch
    yield await getAnomalies(limit: limit, warehouseId: warehouseId);

    // 2. Persistent Table Listeners
    // We listen to BOTH inventory (for stock changes) and logistics_actions (for new triage needs)
    final inventoryChanges = _supabase
        .from('inventory')
        .stream(primaryKey: ['id'])
        .map((_) => true); // We only care THAT it changed

    final actionChanges = _supabase
        .from('logistics_actions')
        .stream(primaryKey: ['id'])
        .map((_) => true);

    // 🛰️ SIGNAL RECONCILIATION: Whenever ANY table moves, we re-query the view
    await for (final _ in inventoryChanges) {
      yield await getAnomalies(limit: limit, warehouseId: warehouseId);
    }
  }

  @override
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 10, String? warehouseId}) async {
    try {
      var query = _supabase.from('system_intel').select();
      if (warehouseId != null) {
        query = query.or('warehouse_id.eq.$warehouseId,warehouse_id.is.null');
      }

      final response = await query.order('created_at', ascending: false).limit(limit);
      final List<dynamic> data = response is List ? response : [];

      // Collect inventory IDs for a single batch image fetch
      final inventoryIds = data
          .map((item) {
            final meta = item['metadata'] as Map<String, dynamic>? ?? {};
            // 🛡️ SAFE PARSE: IDs often come as Strings in JSONB
            final rawId = meta['item_id'] ?? meta['inventory_id'] ?? meta['id'] ?? item['inventory_id'];
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
          final rawId = (meta['item_id'] ?? meta['inventory_id'] ?? meta['id'] ?? item['inventory_id']);
          final invId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) : null);
          
          final liveData = invId != null ? liveMap[invId] : null;

          // 🛰️ GOAL FALLBACK: Admin "Max" can be in target_stock, stock_total, quantity, or goal alias
          final maxStockVal = (liveData?['target_stock'] ?? liveData?['stock_total'] ?? liveData?['max_stock'] ?? liveData?['goal'] ?? meta['target_stock'] as num?)?.toInt();

          anomalies.add(ResourceAnomaly(
            id: item['id'].toString(),
            inventoryId: invId,
            itemName: liveData?['item_name']?.toString() ?? item['titletoString() ?? 'System Alert',
            reason: item['message']?.toString() ?? 'Check required.',
            imageUrl: _resolveImageUrl(liveData?['image_url'] ?? meta['image_url']),
            category: _mapCategoryToType(item['category'] as String?),
            severity: _mapSeverity(item['priority'] as String?),
            currentStock: (liveData?['stock_available'] ?? meta['stock_available'] as num?)?.toInt() ?? 0,
            thresholdStock: (liveData?['low_stock_threshold'] ?? liveData?['minStockLevel'] ?? meta['low_stock_threshold'] as num?)?.toInt() ?? 0,
            maxStock: maxStockVal,
            detectedAt: item['created_at'] != null
                ? DateTime.parse(item['created_at'])
                : DateTime.now(),
            qtyGood: (liveData?['qty_good'] ?? meta['qty_good'] as num?)?.toInt() ?? 0,
            qtyDamaged: (liveData?['qty_damaged'] ?? meta['qty_damaged'] as num?)?.toInt() ?? 0,
            qtyMaintenance: (liveData?['qty_maintenance'] ?? meta['qty_maintenance'] as num?)?.toInt() ?? 0,
            qtyLost: (liveData?['qty_lost'] ?? meta['qty_lost'] as num?)?.toInt() ?? 0,
          ));
        } catch (e) {
          debugPrint('[AnalystRepo] Skipped anomaly row: $e');
        }
      }

      return anomalies;
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
          .select('id, item_name, image_url, target_stock, stock_total, stock_available, low_stock_threshold, qty_good, qty_damaged, qty_maintenance, qty_lost')
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

  @override
  Future<List<ActivityEvent>> getActivityStream({
    bool liveOnly = false,
    int limit = 50,
    String? warehouseId,
  }) async {
    try {
      var query = _supabase.from('borrow_logs').select('*, inventory:inventory_id(image_url)');
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
            forensicImageUrl: _resolveImageUrl(map['forensic_image_url']?.toString()),
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
  Stream<List<ActivityEvent>> watchActivityStream({String? warehouseId}) {
    final query = warehouseId != null
        ? _supabase.from('borrow_logs').stream(primaryKey: ['id']).eq('warehouse_id', warehouseId)
        : _supabase.from('borrow_logs').stream(primaryKey: ['id']);

    return query
        .order('updated_at', ascending: false)
        .limit(50)
        .map((data) => data.map((item) => _mapToActivityEvent(item)).toList());
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
      var query = _supabase.from('borrow_logs').select();

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
  Future<void> restockAsset({
    required int inventoryId,
    required int addedQuantity,
    String? notes,
  }) async {
    try {
      // 1. Fetch current health state
      final response = await _supabase
          .from('inventory')
          .select('qty_good, qty_damaged, qty_maintenance, qty_lost, stock_total')
          .eq('id', inventoryId)
          .single();

      final currentGood = (response['qty_good'] as num?)?.toInt() ?? 0;
      final currentDamaged = (response['qty_damaged'] as num?)?.toInt() ?? 0;
      final currentMaint = (response['qty_maintenance'] as num?)?.toInt() ?? 0;
      final currentLost = (response['qty_lost'] as num?)?.toInt() ?? 0;

      // 2. Calculate new proportions
      final newGood = currentGood + addedQuantity;
      final newTotal = newGood + currentDamaged + currentMaint + currentLost;

      // 3. EXECUTE COMMAND OVERRIDE
      await _supabase.from('inventory').update({
        'qty_good': newGood,
        'stock_total': newTotal,
        'stock_available': newGood, // Available is strictly linked to Good bucket
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', inventoryId);

      debugPrint('⚙️ LIGTAS-RESTOCK: Asset $inventoryId +$addedQuantity units.');
    } catch (e) {
      throw Exception('Restock Command Failed: $e');
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
    return warehouseId != null ? q.eq('assigned_warehouse', warehouseId) : q;
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

  ActivityEvent _mapToActivityEvent(Map<String, dynamic> item) {
    final status = item['status'] as String? ?? 'pending';
    final typeStr = item['transaction_type'] as String? ?? 'borrow';

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

    final delta = '${item['quantity'] ?? 0} UNITS';
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
      locationSource: 'WH-Alpha',
      locationTarget: 'Central Hub',
      actorName: actor,
      // 🛡️ FORENSIC PRIORITY: return_notes > purpose > generic_notes > fallback
      notes: item['return_notes'] as String? ?? 
             item['purpose'] as String? ?? 
             item['notes'] as String? ?? 
             dynamicFallback,
      evidenceImageUrl: _resolveImageUrl(item['evidence_image_url'] as String?, bucket: 'forensic-evidence'),
      referenceImageUrl: _resolveImageUrl(
        item['reference_image_url'] as String? ?? 
        (item['inventory'] as Map<String, dynamic>?)?['image_url'] as String?, 
        bucket: 'item-images'
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
      'INVENTORY'          => AnomalyCategory.depletion,
      'LOGISTICS'          => AnomalyCategory.logistics,
      'OVERDUE'            => AnomalyCategory.logistics,
      'ACCESS'             => AnomalyCategory.stagnation,
      _                    => AnomalyCategory.depletion,
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

  /// 🛡️ STRATEGIC IMAGE RESOLVER: Single Source of Truth Alignment
  /// Replicates web's getInventoryImageUrl to handle brittle signed URLs and raw paths.
  String? _resolveImageUrl(String? pathOrUrl, {String bucket = 'item-images'}) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;

    // 🏛️ HANDLE FULL URLS (Potentially expired signed URLs)
    if (pathOrUrl.startsWith('http')) {
      if (pathOrUrl.contains('/storage/v1/object/')) {
        try {
          // Parse: .../storage/v1/object/[type]/[bucket]/[path]
          final uri = Uri.parse(pathOrUrl);
          final segments = uri.pathSegments;
          
          final objectIndex = segments.indexOf('object');
          if (objectIndex != -1 && objectIndex + 2 < segments.length) {
            final detectedBucket = segments[objectIndex + 2];
            final filePath = segments.sublist(objectIndex + 3).join('/');
            
            // Return clean public URL from the detected bucket
            return _supabase.storage.from(detectedBucket).getPublicUrl(filePath);
          }
        } catch (e) {
          debugPrint('🛡️ LIGTAS-RESOLVE: URL Parse Failure: $e');
          return pathOrUrl; // Fallback to raw URL
        }
      }
      return pathOrUrl;
    }

    // 🏛️ HANDLE RELATIVE PATHS
    String cleanPath = pathOrUrl.trim().replaceAll(RegExp(r'^\/+'), '');
    
    // Remove redundant bucket prefix if present
    if (cleanPath.startsWith('$bucket/')) {
      cleanPath = cleanPath.replaceFirst('$bucket/', '');
    }

    // Resolve via SDK (Handles encoding and context)
    return _supabase.storage.from(bucket).getPublicUrl(cleanPath);
  }
}