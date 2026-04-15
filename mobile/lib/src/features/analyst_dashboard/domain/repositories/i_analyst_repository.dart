import '../entities/analyst_metrics.dart';
import '../entities/resource_anomaly.dart';
import '../entities/activity_event.dart';
import '../entities/logistics_action.dart';

/// Abstract Repository Interface (Domain Layer)
/// Optimized for Sentinel Real-Time Logistical Awareness
abstract class IAnalystRepository {
  /// Fetch aggregated KPI metrics for the analyst dashboard
  Future<AnalystMetrics> getMetrics({String? warehouseId});

  /// 🛰️ SENTINEL PULSE: Real-time stream for metrics aggregation
  Stream<AnalystMetrics> watchMetricsStream({String? warehouseId});

  /// Fetch resource anomalies (low stock, critical operational failures)
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 10, String? warehouseId});

  /// 🛰️ SENTINEL PULSE: Real-time stream for resource anomalies
  Stream<List<ResourceAnomaly>> watchAnomalies({int limit = 10, String? warehouseId});

  /// 🛡️ ACTIVE TRIAGE: Fetch pending logistics actions (Dispense, Dispose, Returns)
  Future<List<LogisticsAction>> getLogisticsQueue({String? warehouseId});

  /// 🛡️ ACTIVE TRIAGE: Resolve a specific logistics action with forensic evidence
  Future<void> resolveLogisticsAction({
    required String actionId,
    required ActionStatus status,
    String? forensicNote,
    String? forensicImageUrl,
  });

  /// Fetch activity stream events (Logistical History)
  Future<List<ActivityEvent>> getActivityStream({
    bool liveOnly = false,
    int limit = 50,
    String? warehouseId,
  });

  /// 🛡️ SENTINEL PULSE: Real-time socket stream for logistical events
  Stream<List<ActivityEvent>> watchActivityStream({String? warehouseId});

  /// 🛡️ FORENSIC AUDIT: Verify a specific activity event with forensic evidence
  Future<void> verifyActivityEvent({
    required String eventId,
    required String analystId,
    String? forensicNote,
  });

  /// ⚙️ COMMAND OVERRIDE: Administratively restock an asset
  Future<void> restockAsset({
    required int inventoryId,
    required int addedQuantity,
    String? notes,
  });

  /// ⚙️ COMMAND OVERRIDE: Triage asset health buckets (Good, Damaged, Maintenance, Lost)
  Future<void> updateAssetHealth({
    required int inventoryId,
    int? qtyGood,
    int? qtyDamaged,
    int? qtyMaintenance,
    int? qtyLost,
    String? notes,
  });

  /// Fetch paginated activity logs for forensic audit ledger
  Future<List<ActivityEvent>> getPaginatedActivity({
    required int offset,
    required int limit,
    String? searchQuery,
    String? status, // Forensic Status Filter (e.g., 'pending', 'returned')
    String? warehouseId,
  });
}
