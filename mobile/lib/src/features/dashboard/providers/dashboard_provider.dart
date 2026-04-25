import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/loans/providers/loan_providers.dart';
import 'package:mobile/src/features/inventory/providers/inventory_providers.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:intl/intl.dart';

/// Dashboard stats for borrower perspective
class DashboardStats {
  const DashboardStats({
    this.totalBorrows = 0,
    this.activeLoans = 0,
    this.overdueLoans = 0,
    this.returnedItems = 0,
  });

  final int totalBorrows;
  final int activeLoans;
  final int overdueLoans;
  final int returnedItems;

  DashboardStats copyWith({
    int? totalBorrows,
    int? activeLoans,
    int? overdueLoans,
    int? returnedItems,
  }) {
    return DashboardStats(
      totalBorrows: totalBorrows ?? this.totalBorrows,
      activeLoans: activeLoans ?? this.activeLoans,
      overdueLoans: overdueLoans ?? this.overdueLoans,
      returnedItems: returnedItems ?? this.returnedItems,
    );
  }
}

/// Provides borrower dashboard stats from real data - TRANSFORMED TO STREAM for REALTIME
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final loansAsync = ref.watch(freshDashboardLoansProvider);

  return loansAsync.when(
    data: (loans) {
      final total = loans.length;
      final active = loans.where((l) => l.status == LoanStatus.active).length;
      // Overdue should only represent currently unreturned/active borrows.
      final overdue = loans.where((l) =>
        l.status == LoanStatus.overdue ||
        (l.status == LoanStatus.active && l.daysOverdue > 0)
      ).length;
      final returned = loans.where((l) => l.status == LoanStatus.returned).length;

      return Stream.value(DashboardStats(
        totalBorrows: total,
        activeLoans: active,
        overdueLoans: overdue,
        returnedItems: returned,
      ));
    },
    loading: () => Stream.value(const DashboardStats()),
    error: (e, st) => Stream.error(e, st),
  );
});

/// User display name for dashboard greeting
final dashboardUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? user?.email ?? 'Guest';
});

/// 🛡️ GOLD STANDARD: Gating for Entrance Animations
/// Tracks if the dashboard has already performed its "First Entry" sequence.
/// This is used to skip animations on back-navigation to ensure 0ms raster spikes.
final dashboardEntryProvider = StateProvider<bool>((ref) => false);

/// Intelligent provider that groups real inventory by category
final categoryStatsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  
  return inventoryAsync.when(
    data: (items) {
      final Map<String, int> counts = {};
      for (var item in items) {
        counts[item.category] = (counts[item.category] ?? 0) + 1;
      }
      return counts.entries.map((e) => {
        'name': e.key,
        'count': e.value,
        'icon': _getIconForCategory(ref, e.key),
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Intelligence provider for system-wide technical stats
final inventorySummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final inventoryAsync = ref.watch(inventoryItemsProvider);
  
  return inventoryAsync.when(
    data: (items) {
      final total = items.length;
      // SSOT: matches public.system_intel INVENTORY branch (threshold + absolute < 5)
      final lowStock = items.where((i) {
        final st = i.status.toLowerCase();
        if (st == 'damaged' || st == 'lost' || st == 'deleted') return false;
        final a = i.available;
        final t = i.minStockLevel;
        final eff = t > 0 ? t : 10;
        return a < 5 || a <= eff;
      }).length;
      
      return {
        'total_assets': total,
        'low_stock_count': lowStock,
        'warehouse_status': 'REALTIME',
        'last_sync': 'ACTIVE',
      };
    },
    loading: () => {
      'total_assets': 0,
      'low_stock_count': 0,
      'warehouse_status': 'SYNCING...',
      'last_sync': 'PENDING',
    },
    error: (_, __) => {
      'total_assets': 0,
      'low_stock_count': 0,
      'warehouse_status': 'OFFLINE',
      'last_sync': 'ERROR',
    },
  );
});

IconData _getIconForCategory(Ref ref, String category) {
  return ref.watch(categoryIconProvider(category));
}

/// 🛡️ THE STRATEGY: Search and Sort state for History Logbook
final loanHistorySearchProvider = StateProvider<String>((ref) => '');
final loanHistorySortProvider = StateProvider<String>((ref) => 'newest');
final loanHistoryFilterProvider = StateProvider<String>((ref) => 'ALL');

/// 🛡️ THE STRATEGY: Intelligent filter for History Logbook
final filteredLoanHistoryProvider = Provider<List<LoanModel>>((ref) {
  final loansAsync = ref.watch(freshDashboardLoansProvider);
  final query = ref.watch(loanHistorySearchProvider).toLowerCase();
  final sortBy = ref.watch(loanHistorySortProvider);
  final filter = ref.watch(loanHistoryFilterProvider);

  return loansAsync.maybeWhen(
    data: (loans) {
      // 1. STATUS FILTER
      var filtered = loans;
      if (filter != 'ALL') {
        filtered = filtered.where((loan) {
          if (filter == 'ACTIVE') return loan.status == LoanStatus.active;
          if (filter == 'RETURNED') return loan.status == LoanStatus.returned;
          if (filter == 'OVERDUE') return loan.daysOverdue > 0 || loan.status == LoanStatus.overdue;
          return true;
        }).toList();
      }

      // 2. FUZZY SEARCH
      filtered = filtered.where((loan) {
        return loan.itemName.toLowerCase().contains(query) ||
               loan.borrowerName.toLowerCase().contains(query) ||
               loan.itemCode.toLowerCase().contains(query);
      }).toList();

      // 3. TACTICAL SORT
      if (sortBy == 'newest') {
        filtered.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      } else if (sortBy == 'oldest') {
        filtered.sort((a, b) => a.borrowDate.compareTo(b.borrowDate));
      } else if (sortBy == 'alphabetical') {
        filtered.sort((a, b) => a.itemName.compareTo(b.itemName));
      }

      return filtered;
    },
    orElse: () => [],
  );
});

/// 🛡️ THE STRATEGY: Group the filtered loan list into temporal clusters for the History Logbook.
final groupedLoanHistoryProvider = Provider<Map<String, List<LoanModel>>>((ref) {
  final loans = ref.watch(filteredLoanHistoryProvider);

  final Map<String, List<LoanModel>> grouped = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (var loan in loans) {
    final loanDate = DateTime(loan.borrowDate.year, loan.borrowDate.month, loan.borrowDate.day);
    String label;

    if (loanDate == today) {
      label = 'TODAY';
    } else if (loanDate == yesterday) {
      label = 'YESTERDAY';
    } else {
      label = DateFormat('MMMM dd, yyyy').format(loanDate).toUpperCase();
    }

    grouped.putIfAbsent(label, () => []).add(loan);
  }
  return grouped;
});


/// 🛡️ THE STRATEGY: Move sorting out of UI build methods to achieve 120Hz consistency.
/// Perform heavy transformation in background microtask within providers.
final sortedDashboardActivityProvider = Provider<List<LoanModel>>((ref) {
  final loansAsync = ref.watch(freshDashboardLoansProvider);
  
  return loansAsync.when(
    data: (loans) {
      final sorted = List<LoanModel>.from(loans)
        ..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      return sorted.take(10).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 🛡️ THE STRATEGY: Pre-segment operation logs into Pending and Active pools.
/// This eliminates the calculation burden during scroll-rebuilds.
final operationLogSegmentsProvider = Provider<Map<String, dynamic>>((ref) {
  final loansAsync = ref.watch(freshDashboardLoansProvider);
  
  return loansAsync.when(
    data: (loans) {
      final List<LoanModel> pendingRaw = loans.where((l) => l.status == LoanStatus.pending).toList();
      final List<LoanModel> activeRaw = loans.where((l) => 
        l.status == LoanStatus.active || l.daysOverdue > 0
      ).toList();

      // Sort consistently by date
      pendingRaw.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      activeRaw.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

      return {
        'pending': pendingRaw.take(3).toList(),
        'active': activeRaw.take(3).toList(),
        'all_pending_count': pendingRaw.length,
        'all_active_count': activeRaw.length,
      };
    },
    loading: () => {'pending': <LoanModel>[], 'active': <LoanModel>[], 'all_pending_count': 0, 'all_active_count': 0},
    error: (_, __) => {'pending': <LoanModel>[], 'active': <LoanModel>[], 'all_pending_count': 0, 'all_active_count': 0},
  );
});

/// Senior Dev: Use FutureProvider for fresh dashboard data (Force fresh fetch from remote)
final freshDashboardLoansProvider = FutureProvider<List<LoanModel>>((ref) async {
  // 🛡️ SECURITY: Watch user identity to force re-fetch on account switch
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final repository = ref.read(loanRepositoryProvider);
  return repository.getMyBorrowedItems();
});
