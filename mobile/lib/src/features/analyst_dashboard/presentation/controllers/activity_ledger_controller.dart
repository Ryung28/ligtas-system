import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'analyst_dashboard_controller.dart';
import '../../../auth/providers/auth_provider.dart';

part 'activity_ledger_controller.g.dart';

@riverpod
class ActivityLedger extends _$ActivityLedger {
  static const int _pageSize = 20;

  String? _currentQuery;
  String? _currentStatus;

  @override
  Future<List<ActivityEvent>> build() async {
    _currentQuery = null;
    _currentStatus = 'all'; // Default: System-wide audit
    return _fetch(0);
  }

  Future<List<ActivityEvent>> _fetch(int offset) async {
    final repository = ref.read(analystRepositoryProvider);
    final user = ref.read(currentUserProvider);
    return repository.getPaginatedActivity(
      offset: offset,
      limit: _pageSize,
      searchQuery: _currentQuery,
      status: _currentStatus,
      warehouseId: user?.assignedWarehouse,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasValue) return;

    final currentData = state.value!;
    state = const AsyncLoading<List<ActivityEvent>>().copyWithPrevious(state);

    try {
      final moreData = await _fetch(currentData.length);
      if (moreData.isNotEmpty) {
        state = AsyncData([...currentData, ...moreData]);
      } else {
        state = AsyncData(currentData);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> search(String? query) async {
    _currentQuery = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }

  Future<void> filterByStatus(String? status) async {
    _currentStatus = status;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(0));
  }

  // Helper to get current status for UI chips
  String get currentStatus => _currentStatus ?? 'all';
}

@riverpod
Future<List<ActivityEvent>> itemForensics(ItemForensicsRef ref, String itemId) async {
  final repository = ref.watch(analystRepositoryProvider);
  final user = ref.read(currentUserProvider);
  // Fetch a small set of most recent events for this specific item
  final events = await repository.getPaginatedActivity(
    offset: 0,
    limit: 5,
    searchQuery: itemId, // Assuming repository filters by referenceId/itemId in search
    warehouseId: user?.assignedWarehouse,
  );
  return events;
}
