import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/analyst_metrics.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/repositories/i_analyst_repository.dart';
import '../../data/repositories/analyst_repository_impl.dart';
import '../../../auth/providers/auth_provider.dart';

part 'analyst_dashboard_controller.g.dart';

/// Master Controller: Aggregates all analyst dashboard data
/// Updated for Sentinel Real-Time Logistical Reactivity
@riverpod
class AnalystDashboardController extends _$AnalystDashboardController {
  @override
  Future<AnalystDashboardState> build() async {
    final repository = ref.watch(analystRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    final warehouseId = user?.assignedWarehouse;
    
    try {
      // Logic for initial load
      final results = await Future.wait([
        repository.getMetrics(warehouseId: warehouseId),
        repository.getAnomalies(limit: 10, warehouseId: warehouseId),
        repository.getActivityStream(limit: 50, warehouseId: warehouseId),
      ]);

      return AnalystDashboardState(
        metrics: results[0] as AnalystMetrics,
        anomalies: results[1] as List<ResourceAnomaly>,
        activityStream: results[2] as List<ActivityEvent>,
      );
    } catch (e, stack) {
      throw AnalystDashboardException(
        'Failed to load dashboard data',
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  /// 🛡️ FORENSIC SIGN-OFF: Verify a logistical event
  Future<void> verifyEvent(String eventId, {String? notes}) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    
    if (user == null) return;

    try {
      await repository.verifyActivityEvent(
        eventId: eventId,
        analystId: user.id,
        forensicNote: notes,
      );
      
      // Industrial Feedback: Refresh data to reflect verification
      await refresh();
    } catch (e) {
      // Logic for handling verification errors (e.g., connection drop)
      throw AnalystDashboardException('Verification protocol failed for event ID: $eventId', originalError: e);
    }
  }

  /// 🛰️ LOGISTICAL PUSH: Update local state with real-time stream data
  void updateActivityStream(List<ActivityEvent> events) {
    final currentState = state.value;
    if (currentState == null) return;
    
    state = AsyncValue.data(currentState.copyWith(activityStream: events));
  }

  /// 🛰️ LOGISTICAL RESET: Refresh all dashboard streams and metrics
  Future<void> refresh() async {
    // Invalidate the real-time streams to force a clean socket/subscription reconnection
    ref.invalidate(watchMetricsStreamProvider);
    ref.invalidate(watchActivityStreamProvider);
    ref.invalidate(resourceAnomaliesProvider);
    
    // Invalidate the controller state itself to trigger build()
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Refresh only metrics (lightweight)
  Future<void> refreshMetrics() async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final warehouseId = user?.assignedWarehouse;
    final currentState = state.value;
    
    if (currentState == null) return;

    try {
      final metrics = await repository.getMetrics(warehouseId: warehouseId);
      state = AsyncValue.data(currentState.copyWith(metrics: metrics));
    } catch (e) {
      // Silent fail - keep existing data
    }
  }
}

/// 🛰️ SENTINEL PULSE PROVIDER: Real-time logistical activity stream
@riverpod
Stream<List<ActivityEvent>> watchActivityStream(WatchActivityStreamRef ref) {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.watchActivityStream(warehouseId: user?.assignedWarehouse);
}

/// 🛰️ KPI PULSE PROVIDER: Real-time aggregated metrics stream
@riverpod
Stream<AnalystMetrics> watchMetricsStream(WatchMetricsStreamRef ref) {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.watchMetricsStream(warehouseId: user?.assignedWarehouse);
}

/// Individual Providers for Granular UI Control
@riverpod
Future<AnalystMetrics> analystMetrics(AnalystMetricsRef ref) async {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.getMetrics(warehouseId: user?.assignedWarehouse);
}

@riverpod
Stream<List<ResourceAnomaly>> watchResourceAnomalies(WatchResourceAnomaliesRef ref) {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.watchAnomalies(limit: 10, warehouseId: user?.assignedWarehouse);
}
// 🛡️ DEPRECATED: Standardizing on Streams
@riverpod
Future<List<ResourceAnomaly>> resourceAnomalies(ResourceAnomaliesRef ref) async {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.getAnomalies(limit: 10, warehouseId: user?.assignedWarehouse);
}

@riverpod
Future<List<ActivityEvent>> activityStream(ActivityStreamRef ref, {bool liveOnly = false}) async {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.getActivityStream(liveOnly: liveOnly, limit: 50, warehouseId: user?.assignedWarehouse);
}

/// Repository Provider (will be implemented in data layer)
@riverpod
IAnalystRepository analystRepository(AnalystRepositoryRef ref) {
  return AnalystRepositoryImpl(ref);
}

/// Aggregated State Model
class AnalystDashboardState {
  final AnalystMetrics metrics;
  final List<ResourceAnomaly> anomalies;
  final List<ActivityEvent> activityStream;

  const AnalystDashboardState({
    required this.metrics,
    required this.anomalies,
    required this.activityStream,
  });

  AnalystDashboardState copyWith({
    AnalystMetrics? metrics,
    List<ResourceAnomaly>? anomalies,
    List<ActivityEvent>? activityStream,
  }) {
    return AnalystDashboardState(
      metrics: metrics ?? this.metrics,
      anomalies: anomalies ?? this.anomalies,
      activityStream: activityStream ?? this.activityStream,
    );
  }
}

/// Custom Exception for Error Boundaries
class AnalystDashboardException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AnalystDashboardException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AnalystDashboardException: $message';
}
