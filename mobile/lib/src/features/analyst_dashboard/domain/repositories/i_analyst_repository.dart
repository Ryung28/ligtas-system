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
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 200, String? warehouseId});

  /// 🛰️ SENTINEL PULSE: Real-time stream for resource anomalies
  Stream<List<ResourceAnomaly>> watchAnomalies({int limit = 200, String? warehouseId});

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

  /// ⚙️ COMMAND OVERRIDE: Approve a borrow request (Pending -> Staged/Borrowed)
  Future<void> approveRequest({
    required String logId,
    required String approvedBy,
    bool isInstant = false,
  });

  /// ⚙️ COMMAND OVERRIDE: Reject a borrow request (Pending/Staged -> Rejected + Restore Stock)
  Future<void> rejectRequest({
    required String logId,
  });

  /// ⚙️ COMMAND OVERRIDE: Complete equipment handoff (Staged -> Borrowed)
  Future<void> completeHandoff({
    required String logId,
    required String handedBy,
  });

  /// ⚙️ COMMAND OVERRIDE: Administratively restock an asset with condition tracking
  Future<void> restockAsset({
    required int inventoryId,
    int addedGood = 0,
    int addedDamaged = 0,
    int addedMaintenance = 0,
    int addedLost = 0,
    String? notes,
  });

  /// ⚙️ COMMAND OVERRIDE: Set the logistical strategy for an item (Fixed vs Consumable)
  Future<void> updateItemStrategy({
    required int inventoryId,
    required int threshold,
    required String strategyLabel,
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

  /// ⚙️ COMMAND OVERRIDE: Force-return an overdue borrow (mirrors web returnItem).
  /// Sets borrow_logs.status = 'returned', stamps audit fields, and
  /// increments inventory.stock_available by [quantity].
  Future<ForceReturnResult> forceReturn({
    required int borrowId,
    required int inventoryId,
    required int quantity,
    required String receivedByName,
    required String receivedByUserId,
    String returnCondition = 'good',
    String? returnNotes,
  });
}

class ForceReturnResult {
  final bool success;
  final String? error;
  const ForceReturnResult.ok() : success = true, error = null;
  const ForceReturnResult.fail(this.error) : success = false;
}
