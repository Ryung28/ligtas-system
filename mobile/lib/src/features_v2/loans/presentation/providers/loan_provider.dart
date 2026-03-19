import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/loan_item.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../data/repositories/supabase_loan_repository.dart';
import '../../data/sources/loan_local_source.dart';

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
  late final ILoanRepository _repository;

  @override
  Stream<List<LoanItem>> build() async* {
    _repository = ref.watch(loanRepositoryProvider);
    
    // 1. Trigger background sync
    _repository.fetchMyLoans();

    // 🚀 NEW: Auto-Sync Loop (Realtime)
    // Subscribe to remote changes and keep local Isar updated
    final remoteSubscription = _repository.watchRemote().listen((_) {});
    ref.onDispose(() => remoteSubscription.cancel());

    // 2. Yield Local Stream
    yield* (_repository as SupabaseLoanRepository).watchLoans();
  }

  Future<void> refresh() async {
    await _repository.fetchMyLoans();
  }
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
      var filtered = loans.where((l) => l.status == targetStatus).toList();

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
  return loans.where((l) => l.status == LoanStatus.pending).toList();
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
