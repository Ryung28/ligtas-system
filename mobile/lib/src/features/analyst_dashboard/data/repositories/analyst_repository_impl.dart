import 'dart:async';
import 'dart:convert';
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
import '../../domain/entities/station_manifest.dart';

/// Variants reference master rows via [parent_id]; standalone rows use [id]. There is no `inventory.item_id`.
int? _inventoryGroupIdFromRow(Map<String, dynamic>? row) {
  if (row == null) return null;
  final parent = (row['parent_id'] as num?)?.toInt();
  final id = (row['id'] as num?)?.toInt();
  return parent ?? id;
}

class AnalystRepositoryImpl implements IAnalystRepository {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  AnalystRepositoryImpl(this._ref);

  @override
  Future<AnalystMetrics> getMetrics({String? warehouseId}) async {
    try {
      // KPI parity lock: web/mobile must read global operational counts.
      // Do not scope by warehouse here to avoid null/mismatched warehouse fields
      // in restored/historical rows causing false-zero tiles.
      final invQ = _supabase.from('active_inventory').select('id');

      Future<List<dynamic>> borrowByStatus(String status) async {
        final q = _supabase.from('borrow_logs').select('id').eq('status', status);
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

        // KPI parity lock: global stream to match web formulas.
        final invStream = _supabase.from('active_inventory').stream(primaryKey: ['id']);
        final logStream = _supabase.from('borrow_logs').stream(primaryKey: ['id']);

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

      // 🛡️ SIBLING SYNC: Fetch all other locations for these items to enable cross-location selection.
      // 1. Get the item names from the current alert batch
      final alertItemNames = await _supabase
          .from('inventory')
          .select('item_name')
          .filter('id', 'in', inventoryIds);
      
      final uniqueNames = (alertItemNames as List)
          .map((r) => r['item_name']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      // 2. Expand inventoryIds to include ALL locations for these items
      final expandedIds = uniqueNames.isEmpty ? inventoryIds : (await _supabase
          .from('inventory')
          .select('id')
          .filter('item_name', 'in', uniqueNames)
          .then((res) => (res as List).map((r) => int.tryParse(r['id'].toString())).whereType<int>().toList()));

      // 🛡️ LIVE LINK: Scoped fetch from the inventory ledger for all relevant locations
      final liveMap = await _fetchLiveInventoryMap(expandedIds.isEmpty ? inventoryIds : expandedIds, warehouseId: warehouseId);

      final anomalies = <ResourceAnomaly>[];
      final enrichedNames = <String>{};

      for (final item in data) {
        try {
          final categoryRaw = item['category']?.toString().toUpperCase();
          if (categoryRaw == 'ACCESS') continue;

          final meta = item['metadata'] as Map<String, dynamic>? ?? {};
          final rawId = (meta['inventory_id'] ?? meta['id'] ?? item['inventory_id'] ?? meta['item_id']);
          final invId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) : null);
          final liveData = invId != null ? liveMap[invId] : null;

          // 🛰️ TACTICAL EXPLOSION FILTER: Skip the Master aggregate row.
          // Analysts handle physical containers. The master row is a virtual aggregate.
          final isMaster = liveData != null && liveData['parent_id'] == null;
          final packagingMap = _readMap(liveData?['packaging_json']);
          final itemName = liveData?['item_name']?.toString() ?? meta['item_name']?.toString() ?? 'System Alert';

          // 1. Add the primary anomaly. We add the master row so it can be exploded into batches later.
          final primary = _parseAnomaly(item, liveData, meta);
          anomalies.add(primary);

          // 2. SIBLING SYNC: Even if we skip the master, we pull in all physical siblings.
          if (itemName != 'System Alert' && !enrichedNames.contains(itemName)) {
            enrichedNames.add(itemName);
            
            // Find all rows in liveMap that share this item name but are NOT the current one
            final siblings = liveMap.values.where((l) {
              final isSiblingMaster = l['parent_id'] == null;
              final siblingPackaging = _readMap(l['packaging_json']);
              // Only pull in physical siblings (not other master rows)
              return l['item_name']?.toString() == itemName && 
                     l['id']?.toString() != invId?.toString() &&
                     !(isSiblingMaster && siblingPackaging != null && siblingPackaging['enabled'] == true);
            });

            for (final sibling in siblings) {
              final sInvId = int.tryParse(sibling['id'].toString());
              anomalies.add(ResourceAnomaly(
                id: 'sibling_${sibling['id']}',
                inventoryId: sInvId,
                itemId: _inventoryGroupIdFromRow(sibling),
                locationRegistryId: (sibling['location_registry_id'] as num?)?.toInt(),
                itemName: itemName,
                baseName: sibling['base_name']?.toString() ?? _extractBaseName(itemName),
                storageLocation: sibling['location']?.toString() ?? sibling['storage_location']?.toString(),
                reason: 'Available location',
                category: _mapCategoryToType(item['category'] as String?),
                severity: AnomalySeverity.info,
                currentStock: (sibling['stock_available'] as num?)?.toInt() ?? 0,
                thresholdStock: (sibling['low_stock_threshold'] as num?)?.toInt() ?? 0,
                maxStock: (sibling['target_stock'] ?? sibling['stock_total'] as num?)?.toInt(),
                packagingJson: _readMap(sibling['packaging_json']),
                detectedAt: DateTime.now(),
              ));
            }
          }
        } catch (e) {
          debugPrint('[AnalystRepo] Skipped anomaly row: $e');
        }
      }

      // Group depletion anomalies by base resource name
      final grouped = <String, ResourceAnomaly>{};
      final other = <ResourceAnomaly>[];

      void _addGrouped(ResourceAnomaly a) {
        final key = a.displayTitle;
        if (grouped.containsKey(key)) {
          // Deduplicate by stable ID — multiple alert rows for the same bulk item
          // can produce the same virtual box children.
          final existingIds = grouped[key]!.children.map((c) => c.id).toSet();
          if (!existingIds.contains(a.id)) {
            grouped[key] = grouped[key]!.copyWith(children: [...grouped[key]!.children, a]);
          }
        } else {
          grouped[key] = a.copyWith(children: [a]);
        }
      }

      for (final a in anomalies) {
        if (a.category == AnomalyCategory.depletion) {
          // 🛰️ TACTICAL EXPLOSION: Bulk-packaged items explode into per-box virtual anomalies.
          // ALL batches across ALL locations are included so the analyst can choose
          // which warehouse and which specific box to restock.
          final packaging = a.packagingJson;
          if (packaging != null && packaging['enabled'] == true) {
            final batches = packaging['batches'] as List?;
            if (batches != null && batches.isNotEmpty) {
              for (final batch in batches) {
                if (batch is! Map<String, dynamic>) continue;
                final label = batch['label']?.toString() ?? 'Box';
                final batchId = batch['id']?.toString();
                // Stable ID: inventoryId_batchId — survives multiple alert rows for same item.
                final stableId = '${a.inventoryId}_$batchId';
                // Each child carries its own locationRegistryId for the location picker.
                final batchLocId = int.tryParse(
                  (batch['locationId'] ?? packaging['defaultLocationId'])?.toString() ?? '',
                );
                
                String locName = 'Unknown Location';
                if (batchLocId != null) {
                  final matches = liveMap.values.where((l) => 
                    l['location_registry_id']?.toString() == batchLocId.toString() &&
                    l['item_name']?.toString() == a.itemName
                  ).toList();
                  if (matches.isNotEmpty) {
                    final rawLoc = matches.first['location']?.toString() ?? matches.first['storage_location']?.toString();
                    if (rawLoc != null && rawLoc.isNotEmpty) {
                      locName = formatStorageLocationLabel(rawLoc);
                    }
                  }
                }
                final fullLabel = '$label • $locName';

                final exploded = a.copyWith(
                  id: stableId,
                  itemName: fullLabel,
                  variantLabel: fullLabel,
                  batchId: batchId,
                  locationRegistryId: batchLocId,
                  currentStock: (batch['units'] as num?)?.toInt() ?? 0,
                  storageLocation: locName,
                );
                _addGrouped(exploded);
              }
              continue; // Skip the aggregate row
            }
          }
          _addGrouped(a);
        } else {
          other.add(a);
        }
      }

      final finalAnomalies = [...grouped.values, ...other];

      return sortResourceAnomaliesLikeActionCenter(finalAnomalies);
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
      // 🛡️ DATA TRUST: Using active_inventory to get unified aggregate counts for bulk assets.
      final response = await _supabase
          .from('active_inventory')
          .select('id, location_registry_id, item_name, location, image_url, target_stock, stock_total, stock_available, low_stock_threshold, aggregate_total, aggregate_available, qty_good, qty_damaged, qty_maintenance, qty_lost, unit')
          .filter('id', 'in', ids);
      
      final Map<int, Map<String, dynamic>> map = {};
      for (final item in (response as List)) {
        final id = int.tryParse(item['id'].toString());
        if (id != null) map[id] = item as Map<String, dynamic>;
      }

      // 🛰️ METADATA SYNC: Fetch bulk packaging info from master inventory table since it's missing from the view
      final metaResponse = await _supabase
          .from('inventory')
          .select('id, parent_id, variant_label, packaging_json')
          .filter('id', 'in', ids);
      
      if (metaResponse != null) {
        for (final meta in (metaResponse as List)) {
          final id = int.tryParse(meta['id'].toString());
          if (id != null) {
            if (map.containsKey(id)) {
              map[id]!.addAll(meta as Map<String, dynamic>);
            } else {
              map[id] = meta as Map<String, dynamic>;
            }
          }
        }
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
        'updated_at': DateTime.now().toUtc().toIso8601String(),
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
    String? batchId,
  }) async {
    try {
      // 1. Fetch current health state (baseline)
      final response = await _supabase
          .from('inventory')
          .select('qty_good, qty_damaged, qty_maintenance, qty_lost, stock_total, packaging_json')
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

      // 3. Build base update payload
      final Map<String, dynamic> updatePayload = {
        'qty_good': newGood,
        'qty_damaged': newDamaged,
        'qty_maintenance': newMaint,
        'qty_lost': newLost,
        'stock_total': newTotal,
        'stock_available': newGood,
        'updated_at': DateTime.now().toIso8601String(),
      };

      String? targetLocationId;

      // 4. SURGICAL BULK PATCH: If batchId is provided, update the specific
      // container's units inside packaging_json.batches (per-box restock).
      if (batchId != null) {
        final rawJson = response['packaging_json'];
        if (rawJson is Map<String, dynamic>) {
          final batches = (rawJson['batches'] as List?)
              ?.map((b) => Map<String, dynamic>.from(b as Map))
              .toList() ?? [];

          bool patched = false;
          for (final batch in batches) {
            if (batch['id']?.toString() == batchId) {
              final oldUnits = (batch['units'] as num?)?.toInt() ?? 0;
              batch['units'] = oldUnits + addedGood; // Good units go into the box
              targetLocationId = (batch['locationId'] ?? rawJson['defaultLocationId'])?.toString();
              patched = true;
              break;
            }
          }

          if (patched) {
            // Recompute aggregate total from all batches after the patch
            final aggregateFromBatches = batches.fold<int>(
              0, (sum, b) => sum + ((b['units'] as num?)?.toInt() ?? 0));

            final updatedJson = Map<String, dynamic>.from(rawJson)
              ..['batches'] = batches;

            updatePayload['packaging_json'] = updatedJson;
            // Sync aggregate stock_available to sum of all box units
            updatePayload['stock_available'] = aggregateFromBatches;
            updatePayload['qty_good'] = aggregateFromBatches;
            updatePayload['stock_total'] = aggregateFromBatches + newDamaged + newMaint + newLost;
          }
        }
      }

      // 5. EXECUTE COMMAND OVERRIDE (MASTER ROW)
      await _supabase.from('inventory').update(updatePayload).eq('id', inventoryId);

      // 6. DUAL-UPDATE SIBLING (PHYSICAL LOCATION)
      if (batchId != null && targetLocationId != null) {
         final siblingRes = await _supabase
             .from('inventory')
             .select('id, stock_available, qty_good, stock_total')
             .eq('parent_id', inventoryId)
             .eq('location_registry_id', targetLocationId)
             .maybeSingle();
         
         if (siblingRes != null) {
            final sibId = siblingRes['id'];
            final sGood = (siblingRes['qty_good'] as num?)?.toInt() ?? 0;
            final sAvail = (siblingRes['stock_available'] as num?)?.toInt() ?? 0;
            final sTotal = (siblingRes['stock_total'] as num?)?.toInt() ?? 0;
            
            await _supabase.from('inventory').update({
              'qty_good': sGood + addedGood,
              'stock_available': sAvail + addedGood,
              'stock_total': sTotal + addedGood,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', sibId);
         }
      }

      debugPrint('⚙️ ResQTrack-RESTOCK: Asset $inventoryId${batchId != null ? " BOX[$batchId]" : ""} Injected. Good: +$addedGood, Damaged: +$addedDamaged');
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
      
      debugPrint('⚙️ ResQTrack-STRATEGY: Asset $inventoryId defined as $strategyLabel.');
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

      debugPrint('⚙️ ResQTrack-TRIAGE: Asset $inventoryId rebalanced.');
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
    final status = (item['status'] as String? ?? 'pending').toLowerCase().trim();

    // Align with web `TransactionStatus` / `borrow_logs` so out+return rows
    // map to assetOut/assetIn — `ActivitySession.updateSessionType` can then
    // set `EventType.mixed` (vs. falling through to `systemSync` + "SYNCED" chip).
    final eventType = switch (status) {
      'pending' => EventType.requisitionApproved,
      'staged' => EventType.requisitionApproved,
      'borrowed' => EventType.assetOut,
      'dispensed' => EventType.assetOut,
      'returned' => EventType.assetIn,
      'overdue' => EventType.maintenance,
      'lost' || 'damaged' || 'maintenance' => EventType.maintenance,
      'cancelled' => EventType.requisitionDenied,
      'rejected' => EventType.requisitionDenied,
      'denied' => EventType.requisitionDenied,
      'reserved' => EventType.reserved,
      _ => EventType.systemSync,
    };

    final eventStatus = switch (status) {
      'pending' || 'staged' => EventStatus.transit,
      'overdue' || 'lost' => EventStatus.offline,
      'returned' || 'dispensed' => EventStatus.synced,
      _ => EventStatus.verified,
    };

    final delta = 'QTY: ${item['quantity'] ?? 0}';
    final actor = item['borrower_name'] as String? ?? 'Field Personnel';

    // 🏛️ DYNAMIC REASONING: Construct smart fallbacks based on event context
    final dynamicFallback = switch (eventType) {
      EventType.assetOut => 'Authorized equipment deployment.',
      EventType.assetIn => 'Equipment safely returned.',
      EventType.requisitionApproved => 'Requisition verified by command.',
      EventType.maintenance => 'Asset flagged for service audit.',
      EventType.requisitionDenied => 'Requisition declined by supervisor.',
      _ => 'Logistical event recorded.',
    };

    final String? eventTimestampRaw = status == 'returned'
        ? (item['actual_return_date'] as String? ??
            item['updated_at'] as String? ??
            item['created_at'] as String?)
        : (item['updated_at'] as String? ?? item['created_at'] as String?);

    return ActivityEvent(
      id: item['id'].toString(),
      type: eventType,
      title: item['item_name']?.toString() ?? 'Unknown Asset',
      subtitle: 'By $actor',
      referenceId: (item['inventory_id'] ?? item['id']).toString(),
      assetId: item['inventory_id'] != null ? (item['inventory_id'] as num).toInt() : null,
      status: eventStatus,
      timestamp: DateTime.parse(eventTimestampRaw ?? DateTime.now().toIso8601String()),
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
        'device': 'ResQTrack-04-PAD',
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
          // segments: [... object, public/authenticated, bucket, path...]
          if (objectIndex != -1 && objectIndex + 2 < segments.length) {
             // 🛡️ BUCKET PRESERVATION: Return 'bucket/path' for TacticalAssetImage resolution
             return segments.sublist(objectIndex + 2).join('/');
          }
        } catch (_) {}
      }
      return pathOrUrl; // Fallback to raw
    }

    // 🏛️ HANDLE RELATIVE PATHS (Cleanup)
    return pathOrUrl.trim().replaceAll(RegExp(r'^\/+'), '');
  }

  @override
  Future<List<StationManifestItem>> getStationManifest({required String stationId}) async {
    try {
      final isNumeric = int.tryParse(stationId) != null;
      
      var query = _supabase
          .from('station_manifest')
          .select('''
            station_id,
            item_id,
            inventory:item_id(
              item_name,
              category,
              image_url,
              stock_available,
              stock_total,
              target_stock,
              base_name,
              variant_label
            ),
            station:station_id!inner(
              id,
              station_code
            )
          ''');

      if (isNumeric) {
        query = query.eq('station_id', int.parse(stationId));
      } else {
        query = query.eq('station.station_code', stationId);
      }

      final List<dynamic> data = await query;
      
      return data.map((item) {
        final inv = item['inventory'] as Map<String, dynamic>? ?? {};
        final rawTarget = (inv['target_stock'] as num?)?.toInt() ?? 0;
        final total = (inv['stock_total'] as num?)?.toInt() ?? 0;
        // 🛡️ SENIOR FALLBACK: Use target_stock if configured, otherwise use physical total. Never 0.
        final target = rawTarget > 0 ? rawTarget : (total > 0 ? total : 1);
        
        final String base = inv['base_name']?.toString() ?? inv['item_name']?.toString() ?? 'Unknown Item';
        final String? variant = inv['variant_label']?.toString();
        // 🏛️ DYNAMIC NAMING: Join base + variant for the mobile list view if variant exists
        final displayName = (variant != null && variant.isNotEmpty) ? '$base ($variant)' : base;
        
        return StationManifestItem(
          id: '${item['station_id']}_${item['item_id']}',
          stationId: item['station_id'].toString(),
          inventoryId: item['item_id'] as int,
          quantityRequired: target,
          itemName: displayName,
          itemCategory: inv['category']?.toString(),
          imageUrl: _resolveRawPath(inv['image_url']?.toString()),
          currentStock: (inv['stock_available'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('🛡️ [Analyst-Repo] Manifest fetch failed: $e');
      return [];
    }
  }
  
  @override
  Stream<List<StationManifestItem>> watchStationManifest({required String stationId}) async* {
    // 1. Initial snapshot
    yield await getStationManifest(stationId: stationId);

    // 2. Listen for logistical movements that affect manifest readiness
    // We listen to borrow_logs (movement) and inventory (stock levels)
    final logStream = _supabase.from('borrow_logs').stream(primaryKey: ['id']).map((_) => true);
    final invStream = _supabase.from('inventory').stream(primaryKey: ['id']).map((_) => true);

    await for (final _ in StreamGroup.merge([logStream, invStream])) {
      yield await getStationManifest(stationId: stationId);
    }
  }

  ResourceAnomaly _parseAnomaly(Map<String, dynamic> item, Map<String, dynamic>? liveData, Map<String, dynamic> meta) {
    final rawId = (meta['inventory_id'] ?? meta['id'] ?? item['inventory_id'] ?? meta['item_id']);
    final invId = rawId is int ? rawId : (rawId is String ? int.tryParse(rawId) : null);
    final maxStockVal = (liveData?['target_stock'] ?? liveData?['stock_total'] ?? liveData?['max_stock'] ?? liveData?['goal'] ?? meta['target_stock'] as num?)?.toInt();

    // 🛡️ TYPE SAFETY: Ensure itemId is an integer cross-reference
    final rawGroupId = _inventoryGroupIdFromRow(liveData);
    final groupId = rawGroupId ?? (meta['item_id'] as num?)?.toInt();

    return ResourceAnomaly(
      id: item['id'].toString(),
      inventoryId: invId,
      itemId: groupId,
      locationRegistryId: (liveData?['location_registry_id'] as num?)?.toInt(),
      itemName: liveData?['item_name']?.toString() ?? meta['item_name']?.toString() ?? item['title']?.toString() ?? 'System Alert',
      baseName: (liveData?['base_name'] ?? meta['base_name'] ?? _extractBaseName(liveData?['item_name'] ?? meta['item_name']))?.toString(),
      storageLocation: (liveData?['storage_location'] ?? meta['storage_location'] ?? liveData?['location'] ?? meta['location'])?.toString(),
      reason: item['message']?.toString() ?? 'Check required.',
      imageUrl: _resolveRawPath(liveData?['image_url'] ?? meta['image_url']),
      category: _mapCategoryToType(item['category'] as String?),
      severity: _mapSeverity(item['priority'] as String?),
      currentStock: (liveData?['stock_available'] ?? meta['stock_available'] as num?)?.toInt() ?? 0,
      aggregateAvailable: (liveData?['aggregate_available'] ?? meta['aggregate_available'] as num?)?.toInt() ?? 0,
      aggregateTotal: (liveData?['aggregate_total'] ?? meta['aggregate_total'] as num?)?.toInt() ?? 0,
      unit: (liveData?['unit'] ?? meta['unit'] as String?) ?? 'pcs',
      thresholdStock: (liveData?['low_stock_threshold'] ?? liveData?['minStockLevel'] ?? meta['low_stock_threshold'] as num?)?.toInt() ?? 0,
      maxStock: maxStockVal,
      variantLabel: _resolveBatchLabel(
            _readMap(liveData?['packaging_json']),
            (liveData?['location_registry_id'] as num?)?.toInt(),
            (liveData?['storage_location'] ?? meta['storage_location'] ?? liveData?['location'] ?? meta['location'])?.toString(),
          ) ??
          (liveData?['variant_label'] ?? meta['variant_label'])?.toString(),
      packagingJson: _readMap(liveData?['packaging_json']),
      detectedAt: item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now(),
      borrowId: (meta['borrow_id'] as num?)?.toInt(),
      borrowerName: meta['borrower_name']?.toString(),
      borrowerContact: meta['borrower_contact']?.toString(),
      borrowerEmail: meta['borrower_email']?.toString(),
      borrowerOrg: meta['borrower_organization']?.toString(),
      borrowedQty: (meta['quantity'] as num?)?.toInt() ?? 0,
      dueDate: DateTime.tryParse((meta['due_date'] ??
              meta['expected_return_date'] ??
              meta['return_date'] ??
              item['expected_return_date'] ??
              item['due_date'])
          ?.toString() ??
          ''),
      borrowedAt: DateTime.tryParse((meta['borrowed_at'] ??
              meta['borrow_date'] ??
              meta['handed_at'] ??
              item['borrowed_at'] ??
              item['borrow_date'])
          ?.toString() ??
          ''),
      approvedByName: meta['approved_by_name']?.toString(),
      releasedByName: (meta['released_by_name'] ?? meta['handed_by'])?.toString(),
      platformOrigin: meta['platform_origin']?.toString(),
      qtyGood: (liveData?['qty_good'] ?? meta['qty_good'] as num?)?.toInt() ?? 0,
      qtyDamaged: (liveData?['qty_damaged'] ?? meta['qty_damaged'] as num?)?.toInt() ?? 0,
      qtyMaintenance: (liveData?['qty_maintenance'] ?? meta['qty_maintenance'] as num?)?.toInt() ?? 0,
      qtyLost: (liveData?['qty_lost'] ?? meta['qty_lost'] as num?)?.toInt() ?? 0,
    );
  }

  int? _inventoryGroupIdFromRow(Map<String, dynamic>? row) {
    if (row == null) return null;
    final raw = row['item_id'] ?? row['parent_id'] ?? row['group_id'];
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  /// 🛡️ LOGICAL EXTRACTOR: Strips variant suffixes (e.g. " - Carton A" or " (Large)") 
  /// to ensure consistent grouping when the base_name column is missing from the view.
  String? _extractBaseName(dynamic rawName) {
    if (rawName == null) return null;
    final name = rawName.toString();
    // Strip " - ..." or " (..." suffixes
    final regExp = RegExp(r'\s*[\-\(].*');
    return name.replaceFirst(regExp, '').trim();
  }

  /// 🛰️ BULK MATCH ENGINE: Maps a physical inventory row back to the Admin's named "Card/Box"
  /// from the web builder's packaging_json.
  /// Returns null for multi-box scenarios — the Tactical Explosion engine handles those.
  String? _resolveBatchLabel(Map<String, dynamic>? packaging, int? locationId, String? storageLocation) {
    if (packaging == null || packaging['enabled'] != true) return null;
    
    final batchesRaw = packaging['batches'];
    if (batchesRaw is! List || batchesRaw.isEmpty) return null;

    // Filter batches that align with this specific warehouse location
    final matches = batchesRaw.where((b) {
      if (b is! Map<String, dynamic>) return false;
      final bLoc = (b['locationId'] ?? packaging['defaultLocationId'])?.toString();
      return bLoc == locationId?.toString();
    }).toList();

    // Multiple boxes at same location → explosion engine takes over, don't pre-bake a label
    if (matches.isEmpty || matches.length > 1) return null;

    // 1:1 match — use the exact label (e.g. "BOX 1")
    return matches.first['label']?.toString();
  }

  Map<String, dynamic>? _readMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
