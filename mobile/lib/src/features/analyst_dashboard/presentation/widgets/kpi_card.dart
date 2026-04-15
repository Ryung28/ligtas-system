import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../../core/design_system/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final double? trendPercent;
  final Color? backgroundColor;
  final Color? valueColor;
  final IconData? backgroundIcon;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;
  final bool isFullWidth;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.trendPercent,
    this.backgroundColor,
    this.valueColor,
    this.backgroundIcon,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final isPositiveTrend = trendPercent != null && trendPercent! >= 0;
    final trendColor = isPositiveTrend 
        ? AppTheme.emeraldGreen 
        : AppTheme.errorRed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isFullWidth ? 18 : 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFAFAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: backgroundColor != null 
                ? Colors.white.withOpacity(0.2)
                : AppTheme.neutralGray900.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: backgroundColor != null 
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Background Icon Watermark
            if (backgroundIcon != null)
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  backgroundIcon,
                  size: isFullWidth ? 110 : 80,
                  color: (backgroundColor != null 
                      ? Colors.white 
                      : AppTheme.neutralGray900).withOpacity(0.04),
                ),
              ),
            
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: isFullWidth ? 10 : 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: backgroundColor != null 
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.neutralGray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AppTheme.warningOrange).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: GoogleFonts.lexend(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: badgeColor ?? AppTheme.warningOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Gap(isFullWidth ? 10 : 8),
                
                // Value
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isFullWidth ? 38 : 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.0,
                    color: valueColor ?? 
                        (backgroundColor != null 
                            ? Colors.white 
                            : AppTheme.neutralGray900),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(isFullWidth ? 8 : 6),
                
                // Trend or Subtitle
                if (trendPercent != null && trendPercent != 0.0)
                  Row(
                    children: [
                      Icon(
                        isPositiveTrend 
                            ? Icons.trending_up_rounded 
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: trendColor,
                      ),
                      const Gap(5),
                      Text(
                        '${isPositiveTrend ? '+' : ''}${trendPercent!.toStringAsFixed(1)}%',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: trendColor,
                        ),
                      ),
                      const Gap(5),
                      Flexible(
                        child: Text(
                          'vs last month',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: backgroundColor != null 
                                ? Colors.white.withOpacity(0.6)
                                : AppTheme.neutralGray500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.lexend(
                      fontSize: isFullWidth ? 12 : 10,
                      fontWeight: FontWeight.w600,
                      color: backgroundColor != null 
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.neutralGray600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
