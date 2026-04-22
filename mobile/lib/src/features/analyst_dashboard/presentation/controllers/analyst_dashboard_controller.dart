import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/analyst_metrics.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/repositories/i_analyst_repository.dart';
export '../../domain/repositories/i_analyst_repository.dart' show ForceReturnResult;
import '../../data/repositories/analyst_repository_impl.dart';
import 'package:mobile/src/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/station_manifest.dart';


part 'analyst_dashboard_controller.g.dart';

final analystTerminalEntryProvider = StateProvider<bool>((ref) => false);

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
        repository.getAnomalies(limit: 200, warehouseId: warehouseId),
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

  /// ⚙️ COMMAND OVERRIDE: Administratively restock an asset
  Future<void> restockAsset({
    required int inventoryId,
    int qtyGood = 0,
    int qtyDamaged = 0,
    int qtyMaint = 0,
    int qtyLost = 0,
    String? notes,
  }) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    
    try {
      await repository.restockAsset(
        inventoryId: inventoryId,
        addedGood: qtyGood,
        addedDamaged: qtyDamaged,
        addedMaintenance: qtyMaint,
        addedLost: qtyLost,
        notes: notes ?? 'Terminal Restock by ${user?.fullName ?? "Analyst"}',
      );
      
      // Force refresh to update stock numbers globally
      await refresh();
    } catch (e) {
      throw AnalystDashboardException('Restock command failed for inventory ID: $inventoryId', originalError: e);
    }
  }

  /// ⚙️ FORCE RETURN: Admin close-out of an overdue borrow (mirrors web returnItem)
  /// Returns [ForceReturnResult]; caller handles error display.
  Future<ForceReturnResult> forceReturn({
    required int borrowId,
    required int inventoryId,
    required int quantity,
    required String receivedByName,
    required String receivedByUserId,
    String returnCondition = 'good',
    String? returnNotes,
  }) async {
    final repository = ref.read(analystRepositoryProvider);
    final result = await repository.forceReturn(
      borrowId: borrowId,
      inventoryId: inventoryId,
      quantity: quantity,
      receivedByName: receivedByName,
      receivedByUserId: receivedByUserId,
      returnCondition: returnCondition,
      returnNotes: returnNotes,
    );
    if (result.success) await refresh();
    return result;
  }

  /// ⚙️ COMMAND OVERRIDE: Triage asset health buckets
  Future<void> updateAssetHealth(
    int inventoryId, {
    int? qtyGood,
    int? qtyDamaged,
    int? qtyMaintenance,
    int? qtyLost,
    String? notes,
  }) async {
    final repository = ref.read(analystRepositoryProvider);

    try {
      await repository.updateAssetHealth(
        inventoryId: inventoryId,
        qtyGood: qtyGood,
        qtyDamaged: qtyDamaged,
        qtyMaintenance: qtyMaintenance,
        qtyLost: qtyLost,
        notes: notes,
      );

      await refresh();
    } catch (e) {
      throw AnalystDashboardException(
        'Health triage failed for inventory ID: $inventoryId',
        originalError: e,
      );
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
  return repository.watchAnomalies(limit: 200, warehouseId: user?.assignedWarehouse);
}
// 🛡️ DEPRECATED: Standardizing on Streams
@riverpod
Future<List<ResourceAnomaly>> resourceAnomalies(ResourceAnomaliesRef ref) async {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repository.getAnomalies(limit: 200, warehouseId: user?.assignedWarehouse);
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

/// 🛰️ HUB SNAPSHOT PROVIDER: Surgical lookup of a specific hub's stock distribution
@riverpod
Future<Map<String, int>> hubStockSnapshot(
  HubStockSnapshotRef ref, {
  required int itemId,
  required int warehouseId,
}) async {
  final supabase = Supabase.instance.client;
  
  // Same product across hubs: variant rows point at master via parent_id; masters use id.
  // DB has no inventory.item_id — match parent_id OR id at the target registry.
  final response = await supabase
      .from('inventory')
      .select('qty_good, qty_damaged, qty_maintenance, qty_lost')
      .eq('location_registry_id', warehouseId)
      .or('parent_id.eq.$itemId,id.eq.$itemId')
      .maybeSingle();

  if (response == null) return {};
  
  return {
    'good': (response['qty_good'] as num?)?.toInt() ?? 0,
    'damaged': (response['qty_damaged'] as num?)?.toInt() ?? 0,
    'maintenance': (response['qty_maintenance'] as num?)?.toInt() ?? 0,
    'lost': (response['qty_lost'] as num?)?.toInt() ?? 0,
  };
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

@riverpod
Stream<List<StationManifestItem>> stationManifest(StationManifestRef ref, {required String stationId}) {
  final repository = ref.watch(analystRepositoryProvider);
  return repository.watchStationManifest(stationId: stationId);
}

