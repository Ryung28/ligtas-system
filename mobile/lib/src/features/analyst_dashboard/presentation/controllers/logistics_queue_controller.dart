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
      // Refresh the queue after resolution
      return repository.getLogisticsQueue(warehouseId: user?.assignedWarehouse);
    });
    
    // Refresh the master dashboard to reflect changes in metrics/activity
    ref.read(analystDashboardControllerProvider.notifier).refresh();
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(analystRepositoryProvider).getLogisticsQueue(warehouseId: user?.assignedWarehouse));
  }
}
