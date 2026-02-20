import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/design_system/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../loans/providers/loan_providers.dart';
import '../../loans/models/loan_model.dart';

/// Small horizontal ribbon for equipment categories - iOS Glass Style
class EquipmentRibbon extends ConsumerWidget {
  const EquipmentRibbon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryStatsProvider);

    if (categoriesAsync.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categoriesAsync.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          final cat = categoriesAsync[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.35),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(cat['icon'] as IconData, size: 14, color: AppTheme.neutralGray700),
                    const Gap(8),
                    Text(
                      cat['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralGray900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cat['count'].toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }
}

/// Compact grid for system health and telemetry - iOS Glass Style
class SystemTelemetryGrid extends ConsumerWidget {
  const SystemTelemetryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(inventorySummaryProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final stats = statsAsync.valueOrNull;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.3,
      children: [
        _buildGlassTelemetryTile(
          Icons.inventory_rounded,
          'AVAILABLE NOW',
          '${summary['total_assets'] ?? 0} ITEMS',
          AppTheme.primaryBlue,
        ),
        _buildGlassTelemetryTile(
          Icons.warning_rounded,
          'DUE',
          '${stats?.overdueLoans ?? 0} OVERDUE',
          const Color(0xFFEF4444),
        ),
        _buildGlassTelemetryTile(
          Icons.layers_rounded,
          'ACTIVE',
          '${stats?.activeLoans ?? 0} ITEMS',
          const Color(0xFF10B981),
        ),
        _buildGlassTelemetryTile(
          Icons.check_circle_rounded,
          'DONE',
          '${stats?.totalReturnedItems ?? 0} RETURNED',
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildGlassTelemetryTile(IconData icon, String label, String value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.neutralGray500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.neutralGray900,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live Operation Feed for Team Activity - iOS Glass Style
/// Senior Dev: Now with TWO SECTIONS - PENDING and ACTIVE
class OperationFeedSection extends ConsumerWidget {
  const OperationFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(myBorrowedItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT BORROWED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All', 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
              ),
            ],
          ),
        ),
        activityAsync.when(
          data: (loans) {
            // Separate pending and active/overdue
            final pendingLoans = loans.where((l) => l.status == LoanStatus.pending).toList();
            final activeLoans = loans.where((l) => 
              l.status == LoanStatus.active || l.daysOverdue > 0
            ).toList();

            // Sort each by borrow date (most recent first)
            pendingLoans.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
            activeLoans.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));

            // Take top 2 from each
            final recentPending = pendingLoans.take(2).toList();
            final recentActive = activeLoans.take(2).toList();

            if (pendingLoans.isEmpty && activeLoans.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: const Text('No recent activity', 
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: PENDING (Purple) with counter badge
                  if (pendingLoans.isNotEmpty) ...[
                    _buildSectionHeader('PENDING', const Color(0xFF8B5CF6), Icons.hourglass_empty_rounded, pendingLoans.length),
                    const Gap(8),
                    ...recentPending.map((loan) => _buildLoanCard(loan, const Color(0xFF8B5CF6))),
                    const Gap(16),
                  ],
                  
                  // SECTION 2: ACTIVE (Green/Blue) with counter badge
                  if (activeLoans.isNotEmpty) ...[
                    _buildSectionHeader('ACTIVE', const Color(0xFF10B981), Icons.outbound_rounded, activeLoans.length),
                    const Gap(8),
                    ...recentActive.map((loan) {
                      final isOverdue = loan.daysOverdue > 0;
                      return _buildLoanCard(loan, isOverdue ? const Color(0xFFEF4444) : const Color(0xFF10B981));
                    }),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          )),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const Gap(6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanCard(LoanModel loan, Color statusColor) {
    final isPending = loan.status == LoanStatus.pending;
    final isOverdue = loan.daysOverdue > 0;
    
    String actionText;
    if (isPending) {
      actionText = 'pending approval';
    } else if (isOverdue) {
      actionText = 'overdue';
    } else {
      actionText = 'borrowed';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(
                    isPending ? Icons.hourglass_empty_rounded : 
                    isOverdue ? Icons.warning_rounded : Icons.check_circle_rounded,
                    size: 12, 
                    color: statusColor,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.itemName,
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w800, 
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        actionText,
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.w500, 
                          color: AppTheme.neutralGray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  // Use timeago package for reliable timestamp formatting (same as recent_activity_section)
                  timeago.format(loan.borrowDate),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
