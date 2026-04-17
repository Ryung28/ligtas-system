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
    final isOut = anomaly.category == AnomalyCategory.depletion && anomaly.currentStock == 0;

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

    // 🎨 THEME SYNC: Use the entity's category-based theme
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

    final isInventory = anomaly.category == AnomalyCategory.depletion;
    final thumb = 88.0;

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: kAlertCardHeight,
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
                borderRadius: BorderRadius.circular(18),
                boxShadow: sentinel.tactile.card,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: thumb,
                    height: double.infinity,
                    child: TacticalAssetImage(
                      path: anomaly.imageUrl,
                      assetId: anomaly.inventoryId,
                      width: thumb,
                      height: kAlertCardHeight,
                      size: thumb,
                      borderRadius: 0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryBgColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      anomaly.serviceStatus.toUpperCase(),
                                      style: GoogleFonts.lexend(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: categoryTextColor,
                                        letterSpacing: 0.5,
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
                              Text(
                                anomaly.itemName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: sentinel.navy,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              Text(
                                isInventory ? statusLabel : anomaly.reason,
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isInventory ? statusColor : AppTheme.neutralGray600,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (isInventory)
                            Row(
                              children: [
                                AlertMetricPill(
                                  label: 'ON HAND',
                                  value: '${anomaly.currentStock}',
                                  sentinel: sentinel,
                                ),
                                const Gap(10),
                                AlertMetricPill(
                                  label: 'TARGET',
                                  value: '${anomaly.thresholdStock}',
                                  sentinel: sentinel,
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18,
                                    color: sentinel.onSurfaceVariant.withOpacity(0.2)),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  anomaly.shelfActionLabel.toUpperCase(),
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: categoryTextColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18,
                                    color: sentinel.onSurfaceVariant.withOpacity(0.2)),
                              ],
                            ),
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
