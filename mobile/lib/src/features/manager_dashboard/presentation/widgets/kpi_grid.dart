import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../../core/design_system/app_theme.dart';

class KPIGrid extends StatelessWidget {
  final String totalAssets;
  final String assetsTrend;
  final String activeLoans;
  final String loansTrend;
  final String overdueCount;
  final String overdueTrend;
  final String pendingApprovals;

  const KPIGrid({
    super.key,
    required this.totalAssets,
    required this.assetsTrend,
    required this.activeLoans,
    required this.loansTrend,
    required this.overdueCount,
    required this.overdueTrend,
    required this.pendingApprovals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SentinelGlassCard(
                label: 'TOTAL ASSETS',
                value: totalAssets,
                trend: assetsTrend,
                icon: Icons.inventory_2_rounded,
                primaryColor: AppTheme.primaryBlue,
              ),
            ),
            const Gap(16),
            Expanded(
              child: _SentinelGlassCard(
                label: 'ACTIVE LOANS',
                value: activeLoans,
                trend: loansTrend,
                icon: Icons.handshake_rounded,
                primaryColor: AppTheme.primaryBlue,
                isAlt: true,
              ),
            ),
          ],
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _SentinelGlassCard(
                label: 'OVERDUE',
                value: overdueCount,
                trend: overdueTrend,
                icon: Icons.timer_rounded,
                primaryColor: AppTheme.destructiveRed,
                isCritical: true,
              ),
            ),
            const Gap(16),
            Expanded(
              child: _SentinelGlassCard(
                label: 'PENDING',
                value: pendingApprovals,
                icon: Icons.pending_actions_rounded,
                primaryColor: AppTheme.amberAccent,
                badge: 'ACTION',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SentinelGlassCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData icon;
  final Color primaryColor;
  final bool isAlt;
  final bool isCritical;
  final String? badge;

  const _SentinelGlassCard({
    required this.label,
    required this.value,
    this.trend,
    required this.icon,
    required this.primaryColor,
    this.isAlt = false,
    this.isCritical = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isAlt ? const Color(0xFF001A33) : AppTheme.neutralGray900;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isAlt ? 0.9 : 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCritical 
                  ? AppTheme.destructiveRed.withValues(alpha: 0.3) 
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Tactical Watermark
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 60,
                  color: primaryColor.withValues(alpha: 0.05),
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.lexend(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(12),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isCritical ? AppTheme.destructiveRed : Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                  if (trend != null) ...[
                    const Gap(4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 12,
                          color: isCritical ? AppTheme.destructiveRed : AppTheme.successGreen,
                        ),
                        const Gap(4),
                        Text(
                          trend!,
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCritical ? AppTheme.destructiveRed : AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
