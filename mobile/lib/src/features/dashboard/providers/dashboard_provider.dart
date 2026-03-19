import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/loans/providers/loan_providers.dart';
import 'package:mobile/src/features/inventory/providers/inventory_providers.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';

/// Dashboard stats for borrower perspective
class DashboardStats {
  const DashboardStats({
    this.activeLoans = 0,
    this.overdueLoans = 0,
    this.totalReturnedItems = 0,
  });

  final int activeLoans;
  final int overdueLoans;
  final int totalReturnedItems;

  DashboardStats copyWith({
    int? activeLoans,
    int? overdueLoans,
    int? totalReturnedItems,
  }) {
    return DashboardStats(
      activeLoans: activeLoans ?? this.activeLoans,
      overdueLoans: overdueLoans ?? this.overdueLoans,
      totalReturnedItems: totalReturnedItems ?? this.totalReturnedItems,
    );
  }
}

/// Provides borrower dashboard stats from real data - TRANSFORMED TO STREAM for REALTIME
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final loansAsync = ref.watch(myBorrowedItemsProvider);

  return loansAsync.when(
    data: (loans) {
      final active = loans.where((l) => l.status == LoanStatus.active).length;
      final overdue = loans.where((l) => l.status == LoanStatus.overdue).length;
      // Returned today check
      final now = DateTime.now();
      final returnedToday = loans.where((l) => 
        l.status == LoanStatus.returned && 
        l.actualReturnDate != null &&
        l.actualReturnDate!.day == now.day &&
        l.actualReturnDate!.month == now.month &&
        l.actualReturnDate!.year == now.year
      ).length;

      return Stream.value(DashboardStats(
        activeLoans: active,
        overdueLoans: overdue,
        totalReturnedItems: returnedToday,
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
      final lowStock = items.where((i) => i.available < 5).length;
      
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

/// Senior Dev: Use FutureProvider for fresh dashboard data (Force fresh fetch from remote)
final freshDashboardLoansProvider = FutureProvider<List<LoanModel>>((ref) async {
  final repository = ref.read(loanRepositoryProvider);
  return repository.getMyBorrowedItems();
});
