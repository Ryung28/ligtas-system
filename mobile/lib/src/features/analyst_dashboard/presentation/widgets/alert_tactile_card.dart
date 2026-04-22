import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_theme.dart';
import '../../../../features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import '../../domain/entities/resource_anomaly.dart';
import 'alert_metric_pill.dart';

const double kAlertCardHeight = 118;
/// Full-queue list (`LogisticalQueueScreen`): compact row — dashboard strip uses [AnomalyCard] instead.
const double kAlertQueueListCardHeight = kAlertCardHeight;

class AlertTactileCard extends StatelessWidget {
  final ResourceAnomaly anomaly;
  final int index;
  final LigtasColors sentinel;
  final bool entryComplete;
  final VoidCallback? onTap;

  const AlertTactileCard({
    super.key,
    required this.anomaly,
    required this.index,
    required this.sentinel,
    required this.entryComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = anomaly.severity == AnomalySeverity.critical;
    final isOut =
        anomaly.category == AnomalyCategory.depletion &&
        anomaly.currentStock == 0;

    String statusLabel = 'STABLE';
    Color statusColor = AppTheme.emeraldGreen;
    if (isCritical) {
      statusLabel = 'CRITICAL';
      statusColor = AppTheme.errorRed;
    } else if (isOut) {
      statusLabel = 'OUT OF STOCK';
      statusColor = AppTheme.errorRed;
    } else if (anomaly.category == AnomalyCategory.depletion) {
      statusLabel = 'LOW STOCK';
      statusColor = Colors.orangeAccent;
    }

    // 🎨 THEME SYNC: Reverted to Original Strategic Palette
    Color categoryBgColor;
    Color categoryTextColor;
    switch (anomaly.categoryTheme) {
      case AnomalyCategoryTheme.amber:
        categoryBgColor = AppTheme.warningOrange.withOpacity(0.08);
        categoryTextColor = AppTheme.warningOrange;
        break;
      case AnomalyCategoryTheme.blue:
        categoryBgColor = AppTheme.primaryBlue.withOpacity(0.08);
        categoryTextColor = AppTheme.primaryBlue;
        break;
      case AnomalyCategoryTheme.red:
        categoryBgColor = AppTheme.errorRed.withOpacity(0.08);
        categoryTextColor = AppTheme.errorRed;
        break;
      case AnomalyCategoryTheme.purple:
        categoryBgColor = const Color(0xFF7C3AED).withOpacity(0.08);
        categoryTextColor = const Color(0xFF7C3AED);
        break;
    }

    const navyBlue = Color(0xFF001A33);

    final isInventory = anomaly.category == AnomalyCategory.depletion;
    final thumb = 88.0;

    // Fixed compact height for scroll list; content is top-aligned (no spaceBetween gap).
    final card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: kAlertQueueListCardHeight,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: sentinel.tactile.card,
              ),
              child: ClipRect(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: thumb,
                      child: TacticalAssetImage(
                        path: anomaly.imageUrl,
                        assetId: anomaly.inventoryId,
                        width: thumb,
                        height: kAlertQueueListCardHeight,
                        size: thumb,
                        borderRadius: 0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: categoryBgColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      anomaly.serviceStatus.toUpperCase(),
                                      style: GoogleFonts.lexend(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: categoryTextColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withOpacity(0.4),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              if (isInventory) ...[
                                Text(
                                  anomaly.itemName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: navyBlue,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(4),
                                Text(
                                  statusLabel,
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(6),
                                Row(
                                  children: [
                                    AlertMetricPill(
                                      label: 'CURRENT STOCK',
                                      value: '${anomaly.currentStock}',
                                      sentinel: sentinel,
                                    ),
                                    const Gap(10),
                                    AlertMetricPill(
                                      label: 'FIXED STOCK',
                                      value: '${anomaly.thresholdStock}',
                                      sentinel: sentinel,
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: sentinel.onSurfaceVariant.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  anomaly.itemName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: navyBlue,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(3),
                                Expanded(
                                  child: Text(
                                    anomaly.reason,
                                    style: GoogleFonts.lexend(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.neutralGray600,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: categoryBgColor.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'VIEW DETAILS',
                                        style: GoogleFonts.lexend(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: navyBlue,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: sentinel.onSurfaceVariant.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                    ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: card
          .animate()
          .fadeIn(
            duration: entryComplete ? 0.ms : 400.ms,
            delay: entryComplete ? 0.ms : (index * 30).ms,
          )
          .slideY(begin: 0.08, end: 0, duration: entryComplete ? 0.ms : 400.ms),
    );
  }
}
