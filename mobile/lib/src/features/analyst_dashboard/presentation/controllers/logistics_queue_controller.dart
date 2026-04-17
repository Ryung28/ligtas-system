import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/logistics_action.dart';
import 'analyst_dashboard_controller.dart';
import '../../../auth/providers/auth_provider.dart';

part 'logistics_queue_controller.g.dart';

@riverpod
class LogisticsQueueController extends _$LogisticsQueueController {
  @override
  Future<List<LogisticsAction>> build() async {
    final repository = ref.watch(analystRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
  }

  Future<void> resolveAction({
    required String actionId,
    required ActionStatus status,
    String? forensicNote,
    String? forensicImageUrl,
  }) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await repository.resolveLogisticsAction(
        actionId: actionId,
        status: status,
        forensicNote: forensicNote,
        forensicImageUrl: forensicImageUrl,
      );
      return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
    });
    
    ref.read(analystDashboardControllerProvider.notifier).refresh();
  }

  Future<void> approveBorrow(String logId, {bool isInstant = false}) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final userName = user?.fullName ?? 'SYSTEM ANALYST';

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.approveRequest(
        logId: logId,
        approvedBy: userName,
        isInstant: isInstant,
      );
      return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
    });
    ref.read(analystDashboardControllerProvider.notifier).refresh();
  }

  Future<void> rejectBorrow(String logId) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.rejectRequest(logId: logId);
      return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
    });
    ref.read(analystDashboardControllerProvider.notifier).refresh();
  }

  Future<void> completeHandoffBorrow(String logId) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final userName = user?.fullName ?? 'SYSTEM ANALYST';

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.completeHandoff(
        logId: logId,
        handedBy: userName,
      );
      return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
    });
    ref.read(analystDashboardControllerProvider.notifier).refresh();
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(analystRepositoryProvider).getLogisticsQueue(warehouseId: user?.assignedWarehouse));
  }
}
