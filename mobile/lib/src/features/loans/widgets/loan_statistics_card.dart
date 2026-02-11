import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/app_card.dart';
import '../providers/loan_providers.dart';

/// Statistics card showing loan overview
class LoanStatisticsCard extends ConsumerWidget {
  const LoanStatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(myBorrowStatsProvider);
    final borrowedItemsAsync = ref.watch(myBorrowedItemsProvider);

    return borrowedItemsAsync.when(
      data: (_) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.schedule_rounded,
              label: 'Active',
              value: stats.totalActiveLoans.toString(),
              color: AppTheme.primaryBlue,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.warning_rounded,
              label: 'Overdue',
              value: stats.totalOverdueLoans.toString(),
              color: AppTheme.errorRed,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.check_circle_rounded,
              label: 'Returned',
              value: stats.totalReturnedToday.toString(),
              color: AppTheme.successGreen,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.inventory_rounded,
              label: 'Total',
              value: stats.totalItemsBorrowed.toString(),
              color: AppTheme.warningAmber,
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: [
          Expanded(child: _buildLoadingStatCard()),
          const Gap(AppSpacing.sm),
          Expanded(child: _buildLoadingStatCard()),
          const Gap(AppSpacing.sm),
          Expanded(child: _buildLoadingStatCard()),
          const Gap(AppSpacing.sm),
          Expanded(child: _buildLoadingStatCard()),
        ],
      ),
      error: (error, stack) => Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.1),
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: AppTheme.errorRed.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.errorRed,
              size: AppSizing.iconSm,
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: Text(
                'Failed to load statistics',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () => ref.read(myBorrowedItemsProvider.notifier).refresh(),
              icon: Icon(
                Icons.refresh_rounded,
                color: AppTheme.errorRed,
                size: AppSizing.iconSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppSizing.iconMd,
            color: color,
          ),
          const Gap(AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.neutralGray100,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: [
          Container(
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            decoration: BoxDecoration(
              color: AppTheme.neutralGray200,
              borderRadius: AppRadius.allSm,
            ),
          ),
          const Gap(AppSpacing.xs),
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.neutralGray200,
              borderRadius: AppRadius.allSm,
            ),
          ),
          const Gap(AppSpacing.xs),
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.neutralGray200,
              borderRadius: AppRadius.allSm,
            ),
          ),
        ],
      ),
    );
  }
}