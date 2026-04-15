import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/manager_metrics.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/repositories/i_manager_repository.dart';
import '../../data/repositories/manager_repository_impl.dart';

part 'manager_dashboard_controller.g.dart';

@riverpod
class ManagerDashboardController extends _$ManagerDashboardController {
  @override
  Future<ManagerDashboardState> build() async {
    final repository = ref.watch(managerRepositoryProvider);
    
    // Parallel fetch for speed & performance (The LIGTAS Standard)
    final results = await Future.wait([
      repository.getMetrics(),
      repository.getAnomalies(limit: 10),
      repository.getActivityStream(limit: 50),
    ]);

    return ManagerDashboardState(
      metrics: results[0] as ManagerMetrics,
      anomalies: results[1] as List<ResourceAnomaly>,
      activityStream: results[2] as List<ActivityEvent>,
    );
  }

  /// Action: Approve Request (Refresh state after completion)
  /// Pattern: Pessimistic UI with explicit invalidation
  Future<void> approveRequest(String requestId) async {
    final repository = ref.read(managerRepositoryProvider);
    await repository.approveRequest(requestId);
    ref.invalidateSelf(); // Triggers a re-fetch of all dashboard data
  }

  /// Action: Decline Request (Refresh state after completion)
  Future<void> declineRequest(String requestId, String reason) async {
    final repository = ref.read(managerRepositoryProvider);
    await repository.declineRequest(requestId, reason);
    ref.invalidateSelf();
  }

  /// Lightweight Refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

class ManagerDashboardState {
  final ManagerMetrics metrics;
  final List<ResourceAnomaly> anomalies;
  final List<ActivityEvent> activityStream;

  const ManagerDashboardState({
    required this.metrics,
    required this.anomalies,
    required this.activityStream,
  });

  ManagerDashboardState copyWith({
    ManagerMetrics? metrics,
    List<ResourceAnomaly>? anomalies,
    List<ActivityEvent>? activityStream,
  }) {
    return ManagerDashboardState(
      metrics: metrics ?? this.metrics,
      anomalies: anomalies ?? this.anomalies,
      activityStream: activityStream ?? this.activityStream,
    );
  }
}
