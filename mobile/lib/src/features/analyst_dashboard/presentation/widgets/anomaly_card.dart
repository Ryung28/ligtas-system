import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../../../core/design_system/app_theme.dart';

/// Strip height in [ResourceAnomaliesSection] horizontal list — keep in sync with list `SizedBox`.
const double kAnomalyStripCardHeight = 142;

/// Tactical Anomaly Card: Updated for Serviceability Awareness
/// 🛡️ ISOLATED KINETICS: Stateful implementation to survive parent rebuilds
class AnomalyCard extends StatefulWidget {
  final ResourceAnomaly anomaly;
  final VoidCallback? onTap;

  const AnomalyCard({super.key, required this.anomaly, this.onTap});

  @override
  State<AnomalyCard> createState() => _AnomalyCardState();
}

class _AnomalyCardState extends State<AnomalyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _peekController;
  late Animation<Offset> _peekAnimation;

  @override
  void initState() {
    super.initState();
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Balanced 4-second cycle
    );

    // ── Tactical Peek Sequence ──
    // 0.0 - 0.25: Slide Out (1s)
    // 0.25 - 0.30: Hold (0.2s)
    // 0.30 - 0.50: Slide Back (0.8s)
    // 0.50 - 1.0: Idle (2s)
    _peekAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.04, 0),
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(-0.04, 0)),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.04, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 50),
    ]).animate(_peekController);

    _peekController.repeat();
  }

  @override
  void dispose() {
    _peekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anomaly = widget.anomaly;
    final bool hasMaxStock = anomaly.maxStock != null && anomaly.maxStock! > 0;
    final int denominator =
        hasMaxStock ? anomaly.maxStock! : anomaly.thresholdStock;
    final double percentage =
        denominator > 0 ? (anomaly.currentStock / denominator) * 100 : 0;

    final isSystemicFailure = anomaly.category != AnomalyCategory.depletion;
    final isOverdue = anomaly.category == AnomalyCategory.overdue;

    // 🎨 CATEGORY-FIRST THEME: Reverted to Original Strategic Palette
    // Amber=Inventory, Blue=Logistics, Red=Overdue/Operational, Purple=Access/Security
    Color categoryColor;
    switch (anomaly.categoryTheme) {
      case AnomalyCategoryTheme.amber:
        categoryColor = AppTheme.warningOrange;
        break;
      case AnomalyCategoryTheme.blue:
        categoryColor = AppTheme.primaryBlue;
        break;
      case AnomalyCategoryTheme.red:
        categoryColor = AppTheme.errorRed;
        break;
      case AnomalyCategoryTheme.purple:
        categoryColor = const Color(0xFF7C3AED);
        break;
    }

    final Color categoryBgColor = categoryColor.withOpacity(0.1);
    const navyBlue = Color(0xFF001A33);

    // Severity still governs the progress bar fill (stock level)
    Color severityColor;
    switch (anomaly.severity) {
      case AnomalySeverity.critical:
        severityColor = AppTheme.errorRed;
        break;
      case AnomalySeverity.warning:
        severityColor = AppTheme.warningOrange;
        break;
      default:
        severityColor = AppTheme.primaryBlue;
    }

    IconData categoryIcon;
    switch (anomaly.category) {
      case AnomalyCategory.depletion:
        categoryIcon = Icons.inventory_2_rounded;
        break;
      case AnomalyCategory.logistics:
        categoryIcon = Icons.local_shipping_rounded;
        break;
      case AnomalyCategory.overdue:
        categoryIcon = Icons.schedule_rounded;
        break;
      case AnomalyCategory.access:
        categoryIcon = Icons.person_add_alt_1_rounded;
        break;
      case AnomalyCategory.operational:
        categoryIcon = Icons.build_circle_rounded;
        break;
      case AnomalyCategory.security:
        categoryIcon = Icons.policy_rounded;
        break;
      case AnomalyCategory.stagnation:
        categoryIcon = Icons.hourglass_empty_rounded;
        break;
    }

    return SlideTransition(
      position: _peekAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 320,
          height: kAnomalyStripCardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: categoryColor.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: navyBlue.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          categoryIcon,
                          size: 20,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anomaly.itemName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: navyBlue,
                              letterSpacing: -0.4,
                            ),
                            maxLines: isSystemicFailure ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isOverdue
                                ? 'OVERDUE'
                                : '${anomaly.serviceStatus.toUpperCase()} · ${_alertRelativeTime(anomaly.detectedAt)}',
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: categoryColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'OVERDUE',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                          ),
                        ),
                      )
                    else if (!isSystemicFailure)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'STOCK ALERT',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          anomaly.serviceStatus.toUpperCase(),
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: _buildBodyByCategory(
                    anomaly: anomaly,
                    isOverdue: isOverdue,
                    isSystemicFailure: isSystemicFailure,
                    hasMaxStock: hasMaxStock,
                    denominator: denominator,
                    percentage: percentage,
                    categoryColor: categoryColor,
                    severityColor: severityColor,
                    navyBlue: navyBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyByCategory({
    required ResourceAnomaly anomaly,
    required bool isOverdue,
    required bool isSystemicFailure,
    required bool hasMaxStock,
    required int denominator,
    required double percentage,
    required Color categoryColor,
    required Color severityColor,
    required Color navyBlue,
  }) {
    if (isOverdue) {
      return _buildOverdueBody(anomaly: anomaly, categoryColor: categoryColor);
    }
    if (!isSystemicFailure) {
      return _buildInventoryBody(
        anomaly: anomaly,
        hasMaxStock: hasMaxStock,
        denominator: denominator,
        percentage: percentage,
        severityColor: severityColor,
        navyBlue: navyBlue,
      );
    }
    return _buildSystemicBody(anomaly: anomaly, categoryColor: categoryColor);
  }

  Widget _buildOverdueBody({
    required ResourceAnomaly anomaly,
    required Color categoryColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Zone 1: Context
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Borrower: ${_safeBorrowerName(anomaly)}',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGray700,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Zone 2: Primary signal
        Text(
          _overdueTimingLine(anomaly),
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.neutralGray900,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Zone 3: Action rail
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTION',
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutralGray500,
                letterSpacing: 0.6,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                anomaly.shelfActionLabel.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: categoryColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryBody({
    required ResourceAnomaly anomaly,
    required bool hasMaxStock,
    required int denominator,
    required double percentage,
    required Color severityColor,
    required Color navyBlue,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F3F6),
              valueColor: AlwaysStoppedAnimation<Color>(severityColor),
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockDisplay(
                anomaly.currentStock,
                denominator,
                isMaxView: hasMaxStock,
              ),
              Text(
                anomaly.shelfActionLabel.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: navyBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemicBody({
    required ResourceAnomaly anomaly,
    required Color categoryColor,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildOperationalWarning(anomaly.reason, categoryColor),
    );
  }

  Widget _buildOperationalWarning(String reason, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.report_problem_rounded, color: color, size: 14),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reason.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray800,
                    letterSpacing: 0.2,
                  ),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.anomaly.shelfActionLabel,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockDisplay(int current, int total, {bool isMaxView = false}) {
    return RichText(
      text: TextSpan(
        children: [
          if (isMaxView) ...[
            TextSpan(
              text: current.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray900,
              ),
            ),
            TextSpan(
              text: ' / $total UNITS AVAILABLE',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGray500,
              ),
            ),
          ] else ...[
            TextSpan(
              text: '$current ${current == 1 ? "UNIT" : "UNITS"} LEFT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray900,
              ),
            ),
            TextSpan(
              text: '  •  Fixed Stock: $total',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutralGray400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _alertRelativeTime(DateTime? t) {
  if (t == null) return 'NOW';
  return timeago.format(t, allowFromNow: true, locale: 'en_short');
}

String _safeBorrowerName(ResourceAnomaly anomaly) {
  final name = anomaly.borrowerName?.trim();
  if (name == null || name.isEmpty) return 'Unknown borrower';
  return name;
}

String _overdueTimingLine(ResourceAnomaly anomaly) {
  final due = anomaly.dueDate;
  if (due == null) return 'Return date unavailable';
  final now = DateTime.now();
  final daysLate = now.difference(due).inDays;
  if (daysLate > 0) {
    return 'Overdue by ${daysLate == 1 ? '1 day' : '$daysLate days'}';
  }
  return 'Return due ${DateFormat('MMM d, yyyy').format(due)}';
}
