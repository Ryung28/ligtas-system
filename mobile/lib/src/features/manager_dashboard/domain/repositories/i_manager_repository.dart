import '../entities/manager_metrics.dart';
import '../entities/resource_anomaly.dart';
import '../entities/activity_event.dart';

/// Abstract Repository Interface (Manager Dashboard Silo)
/// Enforces Feature-First decoupling: Data layer must implement this contract
abstract class IManagerRepository {
  /// Fetch aggregated KPI metrics (Total Assets, Pending, Borrowed)
  Future<ManagerMetrics> getMetrics();

  /// Fetch equipment anomalies (low stock thresholds & overdue items)
  Future<List<ResourceAnomaly>> getAnomalies({int limit = 10});

  /// Fetch activity stream events (borrows, returns, system updates)
  Future<List<ActivityEvent>> getActivityStream({
    bool liveOnly = false,
    int limit = 50,
  });

  /// Actionable command: Approve a borrow request
  Future<void> approveRequest(String requestId);

  /// Actionable command: Decline a borrow request
  Future<void> declineRequest(String requestId, String reason);

  /// Real-time equipment telemetry stream (Live monitoring)
  Stream<ActivityEvent>? watchActivityStream();
}
