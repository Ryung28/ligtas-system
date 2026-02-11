import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/loan_model.dart';
import '../repositories/loan_repository.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/errors/app_exceptions.dart';

// Repository provider - using centralized DI
final loanRepositoryProvider = AppProviders.loanRepositoryProvider;

// State notifier for user's borrowed items (not all loans)
class MyBorrowedItemsNotifier extends StateNotifier<AsyncValue<List<LoanModel>>> {
  MyBorrowedItemsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMyBorrowedItems();
  }

  final LoanRepository _repository;

  Future<void> loadMyBorrowedItems() async {
    state = const AsyncValue.loading();
    try {
      final loans = await _repository.getMyBorrowedItems();
      state = AsyncValue.data(loans);
    } on AppException catch (error, stackTrace) {
      // Handle known app exceptions
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      // Handle unknown exceptions
      final appError = ExceptionHandler.fromException(error as Exception);
      state = AsyncValue.error(appError, stackTrace);
    }
  }

  Future<void> submitBorrowRequest(CreateLoanRequest request) async {
    try {
      await _repository.createLoan(request);
      await loadMyBorrowedItems(); // Refresh user's items
    } on AppException {
      rethrow; // Let the UI handle app exceptions
    } catch (error) {
      throw ExceptionHandler.fromException(error as Exception);
    }
  }

  Future<void> refresh() async {
    await loadMyBorrowedItems();
  }
}

// Main provider for user's borrowed items
final myBorrowedItemsProvider = StateNotifierProvider<MyBorrowedItemsNotifier, AsyncValue<List<LoanModel>>>((ref) {
  final repository = ref.watch(loanRepositoryProvider);
  return MyBorrowedItemsNotifier(repository);
});

// Computed providers for user's items by status
final myActiveItemsProvider = Provider<List<LoanModel>>((ref) {
  final borrowedItemsAsync = ref.watch(myBorrowedItemsProvider);
  
  return borrowedItemsAsync.when(
    data: (loans) => loans.where((loan) => 
      loan.status == LoanStatus.active
    ).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final myOverdueItemsProvider = Provider<List<LoanModel>>((ref) {
  final borrowedItemsAsync = ref.watch(myBorrowedItemsProvider);
  
  return borrowedItemsAsync.when(
    data: (loans) => loans.where((loan) => 
      loan.status == LoanStatus.active && loan.daysOverdue > 0
    ).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final myReturnedItemsProvider = Provider<List<LoanModel>>((ref) {
  final borrowedItemsAsync = ref.watch(myBorrowedItemsProvider);
  
  return borrowedItemsAsync.when(
    data: (loans) => loans.where((loan) => 
      loan.status == LoanStatus.returned
    ).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Search providers for user's items
final filteredMyActiveItemsProvider = Provider.family<List<LoanModel>, String>((ref, searchQuery) {
  final activeItems = ref.watch(myActiveItemsProvider);
  
  if (searchQuery.isEmpty) return activeItems;
  
  final query = searchQuery.toLowerCase();
  return activeItems.where((loan) {
    return loan.itemName.toLowerCase().contains(query) ||
           loan.itemCode.toLowerCase().contains(query) ||
           loan.purpose.toLowerCase().contains(query);
  }).toList();
});

final filteredMyOverdueItemsProvider = Provider.family<List<LoanModel>, String>((ref, searchQuery) {
  final overdueItems = ref.watch(myOverdueItemsProvider);
  
  if (searchQuery.isEmpty) return overdueItems;
  
  final query = searchQuery.toLowerCase();
  return overdueItems.where((loan) {
    return loan.itemName.toLowerCase().contains(query) ||
           loan.itemCode.toLowerCase().contains(query) ||
           loan.purpose.toLowerCase().contains(query);
  }).toList();
});

final filteredMyReturnedItemsProvider = Provider.family<List<LoanModel>, String>((ref, searchQuery) {
  final returnedItems = ref.watch(myReturnedItemsProvider);
  
  if (searchQuery.isEmpty) return returnedItems;
  
  final query = searchQuery.toLowerCase();
  return returnedItems.where((loan) {
    return loan.itemName.toLowerCase().contains(query) ||
           loan.itemCode.toLowerCase().contains(query) ||
           loan.purpose.toLowerCase().contains(query);
  }).toList();
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

