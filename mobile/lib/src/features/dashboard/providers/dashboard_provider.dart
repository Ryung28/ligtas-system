import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loans/providers/loan_providers.dart';
import '../../inventory/providers/inventory_providers.dart';
import '../../loans/models/loan_model.dart';

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

/// Provides borrower dashboard stats from real data
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  try {
    // Get real stats from loan repository
    final repository = ref.read(loanRepositoryProvider);
    final stats = await repository.getLoanStatistics();
    
    return DashboardStats(
      activeLoans: stats.totalActiveLoans,
      overdueLoans: stats.totalOverdueLoans,
      totalReturnedItems: stats.totalReturnedToday,
    );
  } catch (e) {
    // Fallback to empty stats if there's an error
    return const DashboardStats(
      activeLoans: 0,
      overdueLoans: 0,
      totalReturnedItems: 0,
    );
  }
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
      final totalValue = items.fold<int>(0, (sum, i) => sum + (i.available * 100)); // Mocking value or using quantity
      
      return {
        'total_assets': total,
        'low_stock_count': lowStock,
        'warehouse_status': 'ALIVE',
        'last_sync': 'JUST NOW',
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
