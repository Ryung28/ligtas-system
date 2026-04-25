import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/loan_item.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../data/repositories/supabase_loan_repository.dart';
import '../../data/sources/loan_local_source.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';

part 'loan_provider.g.dart';

@riverpod
ILoanRepository loanRepository(LoanRepositoryRef ref) {
  final client = Supabase.instance.client;
  final local = LoanLocalDataSource();
  return SupabaseLoanRepository(client, local);
}

/// Reactive Loan List Provider
  @riverpod
class MyLoansNotifier extends _$MyLoansNotifier {
  late ILoanRepository _repository;

  @override
  Stream<List<LoanItem>> build() async* {
    final currentUser = ref.watch(currentUserProvider);
    _repository = ref.watch(loanRepositoryProvider);
    final resolvedUserId = currentUser?.id ?? Supabase.instance.client.auth.currentUser?.id;

    // Ensure this provider is identity-bound: user switch/login/logout forces rebuild.
    if (resolvedUserId == null) {
      yield const <LoanItem>[];
      return;
    }
    
    // 1. Await initial sync to populate Isar
    try {
      final fetched = await _repository.fetchMyLoans(userId: resolvedUserId);
      // Ensure UI gets immediate user-bound data on hot restart/user switch
      // even before local watch stream emits its next frame.
      yield fetched;
    } catch (e) {
      // Background sync failed, we'll rely on existing local data
    }

    // 🚀 NEW: Auto-Sync Loop (Realtime)
    // Subscribe to remote changes and keep local Isar updated
    final remoteSubscription = _repository.watchRemote(userId: resolvedUserId).listen((_) {});
    ref.onDispose(() => remoteSubscription.cancel());

    // 2. Yield Local Stream
    yield* (_repository as SupabaseLoanRepository).watchLoans(userId: resolvedUserId);
  }

  Future<void> refresh() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    await _repository.fetchMyLoans(userId: currentUser.id);
  }

  // User Actions
  Future<void> returnItem(String id) async => await _repository.returnItem(id);
  Future<void> cancelLoan(String id) async => await _repository.cancelLoan(id);
}

/// 🏢 MANAGER-LEVEL PROVIDER (WMS Checklist 1.0)
/// Provides a high-density stream of ALL requests for situational awareness.
@riverpod
class ManagerLoansNotifier extends _$ManagerLoansNotifier {
  late final ILoanRepository _repository;

  @override
  Stream<List<LoanItem>> build() async* {
    _repository = ref.watch(loanRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    final warehouseId = user?.assignedWarehouse;
    
    // 1. Trigger warehouse-wide fetch (Audit Requirement 2.1)
    _repository.fetchWarehouseRequests(warehouseId);

    // 🚀 Enable Global Realtime (Checklist 4.1)
    final remoteSubscription = _repository.watchRemote(warehouseId: warehouseId).listen((_) {});
    ref.onDispose(() => remoteSubscription.cancel());

    // 2. Yield Local Stream from All Users
    // This allows Managers to see "Situational Dashboard" even offline
    yield* (_repository as SupabaseLoanRepository).watchLoans(isManager: true);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    await _repository.fetchWarehouseRequests(user?.assignedWarehouse);
  }

  /// 1.1 Pending Approvals Workflow
  Future<void> approveRequest(String id) async {
    final manager = ref.read(currentUserProvider);
    final managerName = manager?.displayName ?? 'Manager';
    await _repository.approveLoan(id, managerName);
    await refresh();
  }

  /// 1.4 Handoff Completion Workflow
  Future<void> confirmHandoff(String id) async {
    final manager = ref.read(currentUserProvider);
    final staffName = manager?.displayName ?? 'Staff';
    await _repository.confirmHandoff(id, staffName);
    await refresh();
  }

  /// 1.5 Returns & Condition Notes Workflow
  Future<void> confirmReturn(String id, String condition, String? notes) async {
    final manager = ref.read(currentUserProvider);
    final staffName = manager?.displayName ?? 'Staff';
    await _repository.confirmReturn(id, staffName: staffName, condition: condition, notes: notes);
    await refresh();
  }

  /// 1.6 Release Reservation Workflow (Reserve-to-Borrow Handover)
  Future<void> releaseReservation(int logId) async {
    final inventoryRepo = ref.read(inventoryRepositoryProvider);
    await inventoryRepo.releaseReservedItem(logId);
    await refresh();
  }
}

/// 📋 Manager Queue Filters (Checklist 1.0)
@riverpod
List<LoanItem> managerPendingQueue(ManagerPendingQueueRef ref) {
  final loans = ref.watch(managerLoansNotifierProvider).valueOrNull ?? [];
  return loans.where((l) => l.status == LoanStatus.pending).toList();
}

@riverpod
List<LoanItem> managerStagedQueue(ManagerStagedQueueRef ref) {
  final loans = ref.watch(managerLoansNotifierProvider).valueOrNull ?? [];
  // Status is approved but not yet 'active/borrowed'
  return loans.where((l) => 
    l.status.name.toLowerCase() == 'approved' || 
    (l.status == LoanStatus.active && l.handedBy == null)
  ).toList();
}

@riverpod
List<LoanItem> managerActiveQueue(ManagerActiveQueueRef ref) {
  final loans = ref.watch(managerLoansNotifierProvider).valueOrNull ?? [];
  return loans.where((l) => l.status == LoanStatus.active && l.handedBy != null).toList();
}

@riverpod
class LoanSearchQuery extends _$LoanSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class LoanSelectedTabIndex extends _$LoanSelectedTabIndex {
  @override
  int build() => 1; // Default to 'Active'

  void update(int index) => state = index;
}

@riverpod
class LoanSortBy extends _$LoanSortBy {
  @override
  String build() => 'newest';

  void update(String sortBy) => state = sortBy;
}

@riverpod
List<LoanItem> filteredLoans(FilteredLoansRef ref) {
  final loansAsync = ref.watch(myLoansNotifierProvider);
  final searchQuery = ref.watch(loanSearchQueryProvider).toLowerCase();
  final selectedTabIndex = ref.watch(loanSelectedTabIndexProvider);
  final sortBy = ref.watch(loanSortByProvider);

  final type = ['pending', 'active', 'overdue', 'history'][selectedTabIndex];
  
  final statusMap = {
    'pending': LoanStatus.pending,
    'active': LoanStatus.active,
    'overdue': LoanStatus.overdue,
    'history': LoanStatus.returned,
  };

  final targetStatus = statusMap[type];

  return loansAsync.maybeWhen(
    data: (loans) {
      // 1. Filter by Status
      var filtered = loans.where((l) {
        if (targetStatus == LoanStatus.pending) {
          return l.status == LoanStatus.pending || l.status == LoanStatus.staged;
        }
        return l.status == targetStatus;
      }).toList();

      // 2. Search
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((l) => 
          l.itemName.toLowerCase().contains(searchQuery) ||
          l.itemCode.toLowerCase().contains(searchQuery)
        ).toList();
      }

      // 3. Sort
      final sorted = List<LoanItem>.from(filtered);
      if (sortBy == 'newest') sorted.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      if (sortBy == 'oldest') sorted.sort((a, b) => a.borrowDate.compareTo(b.borrowDate));
      if (sortBy == 'alphabetical') sorted.sort((a, b) => a.itemName.compareTo(b.itemName));
      
      return sorted;
    },
    orElse: () => [],
  );
}

/// Filtered and Status-Split Providers
@riverpod
List<LoanItem> myPendingItems(MyPendingItemsRef ref) {
  final loans = ref.watch(myLoansNotifierProvider).value ?? [];
  return loans.where((l) => l.status == LoanStatus.pending || l.status == LoanStatus.staged).toList();
}

@riverpod
List<LoanItem> myActiveItems(MyActiveItemsRef ref) {
  final loans = ref.watch(myLoansNotifierProvider).value ?? [];
  return loans.where((l) => l.status == LoanStatus.active).toList();
}

@riverpod
List<LoanItem> myOverdueItems(MyOverdueItemsRef ref) {
  final loans = ref.watch(myLoansNotifierProvider).value ?? [];
  return loans.where((l) => l.status == LoanStatus.overdue).toList();
}

@riverpod
List<LoanItem> myReturnedHistory(MyReturnedHistoryRef ref) {
  final loans = ref.watch(myLoansNotifierProvider).value ?? [];
  return loans.where((l) => l.status == LoanStatus.returned).toList();
}
