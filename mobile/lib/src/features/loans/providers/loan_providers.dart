import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/loan_model.dart';
import '../repositories/loan_repository.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/loan_filter.dart';
import 'loan_filter_provider.dart';

// Repository provider - using centralized DI
final loanRepositoryProvider = AppProviders.loanRepositoryProvider;

// Main provider for user's borrowed items - using StreamProvider for real-time offline-first support
final myBorrowedItemsProvider = StreamProvider<List<LoanModel>>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return repository.watchActiveLoans();
});

// Centralized filtered and sorted provider
final sortedFilteredLoansProvider = Provider<List<LoanModel>>((ref) {
  final rawLoansAsync = ref.watch(myBorrowedItemsProvider);
  final filter = ref.watch(loanFilterProvider);

  return rawLoansAsync.when(
    data: (loans) {
      // Create a growable copy for sorting
      var filtered = List<LoanModel>.from(loans);

      // 1. Filter by search query
      if (filter.query.isNotEmpty) {
        final query = filter.query.toLowerCase();
        filtered = filtered.where((loan) {
          return loan.itemName.toLowerCase().contains(query) ||
                 loan.itemCode.toLowerCase().contains(query) ||
                 loan.purpose.toLowerCase().contains(query);
        }).toList();
      }

      // 2. Sort (Senior Dev: Always sort by Newest by default) - Use borrowDate for accuracy
      switch (filter.sortBy) {
        case LoanSortOption.newest:
          filtered.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
          break;
        case LoanSortOption.oldest:
          filtered.sort((a, b) => a.borrowDate.compareTo(b.borrowDate));
          break;
        case LoanSortOption.alphabetical:
          filtered.sort((a, b) => a.itemName.compareTo(b.itemName));
          break;
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Controller for handling loan-related actions (submit, update, etc.)
class LoanController extends StateNotifier<AsyncValue<void>> {
  LoanController(this._repository) : super(const AsyncValue.data(null));

  final LoanRepository _repository;

  Future<void> submitBorrowRequest(CreateLoanRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createLoan(request);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final loanControllerProvider = StateNotifierProvider<LoanController, AsyncValue<void>>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return LoanController(repository);
});

// Computed providers for user's items by status (Now using the sorted list)
final myActiveItemsProvider = Provider<List<LoanModel>>((ref) {
  final loans = ref.watch(sortedFilteredLoansProvider);
  return loans.where((loan) => loan.status == LoanStatus.active).toList();
});

final myOverdueItemsProvider = Provider<List<LoanModel>>((ref) {
  final loans = ref.watch(sortedFilteredLoansProvider);
  return loans.where((loan) => 
    loan.status == LoanStatus.active && loan.daysOverdue > 0
  ).toList();
});

final myReturnedItemsProvider = Provider<List<LoanModel>>((ref) {
  final loans = ref.watch(sortedFilteredLoansProvider);
  return loans.where((loan) => loan.status == LoanStatus.returned).toList();
});

final myPendingItemsProvider = Provider<List<LoanModel>>((ref) {
  final loans = ref.watch(sortedFilteredLoansProvider);
  return loans.where((loan) => loan.status == LoanStatus.pending).toList();
});

// User statistics provider
final myBorrowStatsProvider = Provider<LoanStatistics>((ref) {
  final borrowedItemsAsync = ref.watch(myBorrowedItemsProvider);
  
  return borrowedItemsAsync.when(
    data: (loans) {
      final activeCount = loans.where((l) => l.status == LoanStatus.active && l.daysOverdue == 0).length;
      final overdueCount = loans.where((l) => l.daysOverdue > 0).length;
      final returnedCount = loans.where((l) => l.status == LoanStatus.returned).length;
      final totalItems = loans.fold<int>(0, (sum, loan) => sum + loan.quantityBorrowed);
      
      return LoanStatistics(
        totalActiveLoans: activeCount,
        totalOverdueLoans: overdueCount,
        totalReturnedToday: returnedCount,
        totalItemsBorrowed: totalItems,
        averageLoanDuration: 0.0,
      );
    },
    loading: () => const LoanStatistics(),
    error: (_, __) => const LoanStatistics(),
  );
});

