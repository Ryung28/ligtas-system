import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../loans/providers/loan_providers.dart';

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
