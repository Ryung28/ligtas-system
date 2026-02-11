import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../providers/dashboard_provider.dart';

/// Overview stats card (reference: BanPeriodCard / MarineConditions style)
class DashboardStatsCard extends StatelessWidget {
  const DashboardStatsCard({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.allLg,
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutralGray900.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconContainer(Icons.analytics_rounded, AppTheme.primaryBlue),
              const SizedBox(width: 10),
              Text(
                'Overview',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutralGray900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.list_alt_rounded,
                  label: 'My Active',
                  value: '${stats.activeLoans}',
                  color: AppTheme.primaryBlue,
                  onTap: () => context.go('/loans'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.warning_rounded,
                  label: 'Overdue',
                  value: '${stats.overdueLoans}',
                  color: AppTheme.errorRed,
                  onTap: () => context.go('/loans'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_rounded,
                  label: 'Returned',
                  value: '${stats.totalReturnedItems}',
                  color: AppTheme.successGreen,
                  onTap: () => context.go('/loans'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadius.allMd,
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.neutralGray600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
