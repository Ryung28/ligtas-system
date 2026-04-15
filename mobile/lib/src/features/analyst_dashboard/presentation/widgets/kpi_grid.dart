import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/analyst_metrics.dart';
import 'kpi_card.dart';
import '../../../../core/design_system/app_theme.dart';

/// 📊 KPI GRID: A balanced, tactical display of real-time logistical health.
/// Uses IntrinsicHeight to ensure all cards in a row maintain perfect vertical symmetry.
class KpiGrid extends StatelessWidget {
  final AnalystMetrics metrics;

  const KpiGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── TOP ROW: LOGISTICAL VOLUME (Symmetric Height Locked) ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Total Assets',
                  value: metrics.totalAssets.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  trendPercent: metrics.assetsTrendPercent,
                  backgroundIcon: Icons.inventory_2_rounded,
                ),
              ),
              const Gap(16),
              Expanded(
                child: KpiCard(
                  label: 'Pending',
                  value: metrics.pendingApprovals.toString(),
                  backgroundColor: const Color(0xFF001A33),
                  valueColor: Colors.white,
                  backgroundIcon: Icons.assignment_rounded,
                  badge: 'ALERT',
                  badgeColor: const Color(0xFFFFB020),
                  onTap: () => context.push('/manager/queue'),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        
        // ── BOTTOM ROW: OPERATIONAL HEALTH (Symmetric Height Locked) ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Borrowed',
                  value: metrics.activeLoans.toString(),
                  backgroundIcon: Icons.assignment_returned_rounded,
                ),
              ),
              const Gap(16),
              Expanded(
                child: KpiCard(
                  label: 'Overdue',
                  value: metrics.overdueCount.toString().padLeft(2, '0'),
                  valueColor: AppTheme.errorRed,
                  backgroundIcon: Icons.warning_rounded,
                  badge: 'CRITICAL',
                  badgeColor: AppTheme.errorRed,
                  onTap: () => context.push('/manager/queue'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
