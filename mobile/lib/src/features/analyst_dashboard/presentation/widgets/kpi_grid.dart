import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/analyst_metrics.dart';
import 'kpi_card.dart';
import '../../../../core/design_system/app_theme.dart';

/// 📊 KPI GRID: Enterprise "Scanner" pattern. 
/// Utilizes a strict 2x2 grid to prevent cognitive overload.
/// Secondary metrics are compressed into dynamic subtitles (Dynamic Anchoring).
class KpiGrid extends StatelessWidget {
  final AnalystMetrics metrics;

  const KpiGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── TOP ROW: LOGISTICAL VOLUME ──
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
                  backgroundColor: const Color(0xFF001A33),
                  valueColor: Colors.white,
                  subtitle: '${metrics.anomalyCount > 0 ? metrics.anomalyCount : '--'} LOW STOCK',
                  backgroundIcon: Icons.inventory_2_rounded,
                ),
              ),
              const Gap(16),
              Expanded(
                child: KpiCard(
                  label: 'Pending',
                  value: '${metrics.pendingApprovals}',
                  backgroundColor: const Color(0xFF001A33),
                  valueColor: Colors.white,
                  backgroundIcon: Icons.assignment_rounded,
                  badge: metrics.pendingApprovals > 0 ? 'ACTION' : 'CLEAR',
                  badgeColor: metrics.pendingApprovals > 0 ? const Color(0xFFFFB020) : AppTheme.successGreen,
                  subtitle: metrics.pendingApprovals > 0 
                      ? '${metrics.pendingApprovals} PENDING' 
                      : 'ALL CLEAR',
                  onTap: () => context.push('/manager/queue'),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        
        // ── BOTTOM ROW: OPERATIONAL HEALTH ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Borrowed',
                  value: metrics.activeLoans.toString(),
                  backgroundIcon: Icons.assignment_returned_rounded,
                  subtitle: '${(metrics.activeLoans * 0.1).round()} DUE SOON',
                ),
              ),
              const Gap(16),
              Expanded(
                child: KpiCard(
                  label: 'Overdue',
                  value: metrics.overdueCount.toString().padLeft(2, '0'),
                  valueColor: metrics.overdueCount > 0 ? AppTheme.errorRed : AppTheme.neutralGray900,
                  backgroundIcon: Icons.warning_rounded,
                  badge: metrics.overdueCount > 0 ? 'CRITICAL' : 'SECURE',
                  badgeColor: metrics.overdueCount > 0 ? AppTheme.errorRed : AppTheme.successGreen,
                  // Removed vague "Breach" terminology
                  subtitle: metrics.overdueCount > 0 ? '${metrics.overdueCount} LATE RETURNS' : 'NO OVERDUE',
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
