import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features/manager_dashboard/domain/entities/manager_metrics.dart';
import 'package:mobile/src/features/manager_dashboard/domain/entities/resource_anomaly.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'package:mobile/src/features/manager_dashboard/domain/repositories/i_manager_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/core/utils/storage_location_labels.dart';

part 'manager_repository_impl.g.dart';

String? _borrowSiteForLog(Map<String, dynamic> json) {
  final raw = json['borrowed_from_warehouse'] ?? json['warehouse_id'];
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  return formatStorageLocationLabel(s);
}

/// Concrete Implementation: Supabase Manager Repository Silo
/// Strictly follows ResQTrack V4 Protocol for Data-UI Separation
class ManagerRepositoryImpl implements IManagerRepository {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  ManagerRepositoryImpl(this._ref);

  @override
  Future<ManagerMetrics> getMetrics() async {
    try {
      // 🚀 REAL-TIME DATA AGGREGATION
      final inventoryCount = await _supabase.from('inventory').select('id');
      final pendingCount = await _supabase.from('borrow_logs').select('id').eq('status', 'pending');
      final activeLoans = await _supabase.from('borrow_logs').select('id').eq('status', 'borrowed');
      final overdueCount = await _supabase.from('borrow_logs').select('id').eq('status', 'overdue');

      return ManagerMetrics(
        totalAssets: (inventoryCount as List).length,
        pendingApprovals: (pendingCount as List).length,
        activeLoans: (activeLoans as List).length,
        overdueCount: (overdueCount as List).length,
        // Trends are 0.0 until historical aggregate logic is implemented
        assetsTrendPercent: 0.0,
        loansTrendPercent: 0.0,
        overdueTrendPercent: 0.0,
      );
    } catch (e) {
      throw Exception('ResQTrack-MANAGER: Failed to aggregate metrics: $e');
    }
  }

  @override
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 200}) async {
    try {
      // 1. 🛡️ UNIFIED SYSTEM INTEL (The Single Pane of Glass)
      // This ensures 1:1 parity with the Web dashboard alerts, querying the new system_intel view.
      final systemData = await _supabase
          .from('system_intel')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      // Re-sort in Dart: CRITICAL=1, WARNING=2, INFO=3 — mirrors Web dashboard logic
      final List<dynamic> sorted = List.from(systemData as List);
      final priorityRank = {'CRITICAL': 1, 'WARNING': 2, 'INFO': 3};
      sorted.sort((a, b) {
        final rankA = priorityRank[a['priority']] ?? 4;
        final rankB = priorityRank[b['priority']] ?? 4;
        if (rankA != rankB) return rankA.compareTo(rankB);
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      final List<ResourceAnomaly> anomalies = [];

      for (var item in sorted) {
        final metadata = item['metadata'] as Map<String, dynamic>? ?? {};
        
        final rawTh = (metadata['low_stock_threshold'] as num?)?.toInt();
        final effTh = (rawTh != null && rawTh > 0) ? rawTh : 10;

        anomalies.add(ResourceAnomaly(
          id: item['id'].toString(),
          itemName: item['title']?.toString() ?? 'System Alert',
          reason: item['message']?.toString() ?? 'Attention required.',
          type: _mapCategoryToType(item['category'] as String?),
          severity: _mapSeverity(item['priority'] as String?),
          currentStock: (metadata['stock_available'] as num?)?.toInt() ?? 0,
          threshold: effTh,
          detectedAt: item['created_at'] != null 
              ? DateTime.parse(item['created_at']) 
              : DateTime.now(),
          referenceId: (metadata['item_id'] ?? metadata['action_id'] ?? metadata['borrow_id'] ?? metadata['request_id'])?.toString(),
          secondaryDetail: metadata['email']?.toString() ?? (metadata['type'] != null ? metadata['type'].toString().toUpperCase() : null),
        ));
      }

      return anomalies;
    } catch (e) {
      debugPrint('ResQTrack-MANAGER: Anomaly triage failed: $e');
      return [];
    }
  }

  // 🛠️ INTERNAL MAPPERS (Aligned with system_intel View)
  AnomalyType _mapCategoryToType(String? category) {
    switch (category?.toUpperCase()) {
      case 'INVENTORY': return AnomalyType.lowStock;
      case 'LOGISTICS': return AnomalyType.dispatch;
      case 'OVERDUE': return AnomalyType.overdue;
      case 'ACCESS': return AnomalyType.audit;
      default: return AnomalyType.lowStock;
    }
  }

  AnomalySeverity _mapSeverity(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'CRITICAL': return AnomalySeverity.critical;
      case 'WARNING': return AnomalySeverity.warning;
      case 'INFO': return AnomalySeverity.info;
      default: return AnomalySeverity.warning;
    }
  }

  @override
  Future<List<ActivityEvent>> getActivityStream({
    bool liveOnly = false,
    int limit = 50,
  }) async {
    try {
      final data = await _supabase
          .from('borrow_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) {
        final typeStr = json['transaction_type'] as String? ?? 'borrow';
        final statusStr = json['status'] as String? ?? 'pending';

        final site = _borrowSiteForLog(json);
        return ActivityEvent(
          id: json['id'].toString(),
          type: typeStr == 'return' ? EventType.assetIn : EventType.assetOut,
          title: '${json['item_name']}',
          subtitle: 'Requested by: ${json['borrower_name']}',
          referenceId: json['inventory_id']?.toString(),
          status: _mapStatus(statusStr),
          timestamp: DateTime.parse(json['created_at']),
          priority: statusStr == 'pending' ? 'ACTION REQUIRED' : null,
          actorName: json['borrower_name'],
          locationSource: site,
          locationTarget: site,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> approveRequest(String requestId) async {
    await _supabase.from('borrow_logs').update({'status': 'borrowed'}).eq('id', requestId);
  }

  @override
  Future<void> declineRequest(String requestId, String reason) async {
    await _supabase.from('borrow_logs').update({'status': 'cancelled', 'notes': reason}).eq('id', requestId);
  }

  @override
  Stream<ActivityEvent>? watchActivityStream() {
    return _supabase
        .from('borrow_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => (data as List).map((json) {
              final site = _borrowSiteForLog(json);
              return ActivityEvent(
                id: json['id'].toString(),
                type: json['transaction_type'] == 'return' ? EventType.assetIn : EventType.assetOut,
                title: '${json['item_name']}',
                subtitle: 'Borrower: ${json['borrower_name']}',
                status: _mapStatus(json['status']),
                timestamp: DateTime.parse(json['created_at']),
                actorName: json['borrower_name'],
                locationSource: site,
                locationTarget: site,
              );
            }).first);
  }

  EventStatus _mapStatus(String status) {
    switch (status) {
      case 'pending':
        return EventStatus.transit; // Use transit as a placeholder for "Wait"
      case 'borrowed':
        return EventStatus.verified;
      case 'returned':
        return EventStatus.synced;
      default:
        return EventStatus.verified;
    }
  }
}

@riverpod
IManagerRepository managerRepository(ManagerRepositoryRef ref) {
  return ManagerRepositoryImpl(ref);
}
