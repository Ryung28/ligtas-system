import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/loan_item.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../../core/design_system/widgets/tactical_image_viewer.dart';
import '../../../../core/design_system/widgets/tactical_forensic_card.dart';

/// 🛡️ LOAN CARD: MISSION LOADOUT MANIFEST (V4)
/// A high-density forensic row representing an active equipment assignment.
/// Refactored to use the unified TacticalForensicCard component.
class LoanCardGlass extends StatelessWidget {
  final LoanItem loan;
  final VoidCallback onTap;
  final VoidCallback? onReturn;

  const LoanCardGlass({
    super.key,
    required this.loan,
    required this.onTap,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 ACCENT LOGIC: Mapping status to tactical colors
    Color accentColor = AppTheme.primaryBlue;
    String statusLabel = 'ACTIVE';
    String timeLabel = 'ISSUED';

    if (loan.status == LoanStatus.returned) {
      accentColor = AppTheme.emeraldGreen;
      statusLabel = 'RETURNED';
      timeLabel = 'RETURNED';
    } else if (loan.status == LoanStatus.pending) {
      accentColor = AppTheme.warningOrange;
      statusLabel = 'PENDING';
      timeLabel = 'REQUESTED';
    } else if (loan.status == LoanStatus.overdue) {
      accentColor = AppTheme.errorRed;
      statusLabel = 'OVERDUE';
      timeLabel = 'ISSUED';
    } else if (loan.status == LoanStatus.cancelled) {
      accentColor = AppTheme.neutralGray500;
      statusLabel = 'CANCELLED';
      timeLabel = 'LOGGED';
    }

    return TacticalForensicCard(
      id: loan.id,
      title: loan.itemName,
      referenceId: loan.id,
      statusLabel: statusLabel,
      accentColor: accentColor,
      imageUrl: loan.imageUrl,
      timestampLabel: timeLabel,
      timestampValue: _calculateDeploymentText(loan.borrowDate),
      secondaryLabel: 'QUANTITY',
      secondaryValue: '${loan.quantityBorrowed} UNITS',
      onTap: onTap,
      onThumbnailTap: loan.imageUrl != null && loan.imageUrl!.isNotEmpty
          ? () => TacticalImageViewer.show(
                context,
                url: loan.imageUrl!,
                title: loan.itemName,
                heroTag: 'loan_icon_${loan.id}',
              )
          : null,
      onActionTap: onReturn != null && (loan.status == LoanStatus.active || loan.status == LoanStatus.overdue)
          ? onReturn
          : null,
      actionLabel: 'RETURN',
      heroTagPrefix: 'inv',
      decisionHub: _buildDecisionHub(context),
    );
  }

  Widget _buildDecisionHub(BuildContext context) {
    final bool isPending = loan.status == LoanStatus.pending;
    final bool isRejected = loan.status == LoanStatus.cancelled;
    final bool isStaged = loan.status == LoanStatus.staged;
    final bool isApprovedReady = isStaged || (loan.status == LoanStatus.active && loan.handedBy == null);

    // 🛡️ RECLAIM SPACE: Pending status is now handled by the top-right tag
    if (isPending || (!isRejected && !isApprovedReady)) return const SizedBox.shrink();

    Color stripColor = AppTheme.warningOrange;
    String label = 'ACTION REQUIRED';
    String subtext = '';
    IconData icon = Icons.timer_outlined;

    if (isRejected) {
      stripColor = AppTheme.errorRed;
      label = 'NOT APPROVED';
      subtext = 'Item unavailable at this time';
      icon = Icons.info_outline_rounded;
    } else if (isApprovedReady) {
      stripColor = AppTheme.emeraldGreen;
      label = 'READY FOR PICKUP';
      subtext = loan.pickupScheduledAt != null 
          ? 'SCHEDULED: ${DateFormat('MMM dd, hh:mm a').format(loan.pickupScheduledAt!)}'
          : 'You can now claim this equipment';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: stripColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stripColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: stripColor),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: stripColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtext,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: stripColor.withOpacity(0.8),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          if (isPending)
            _buildPulseIndicator(stripColor),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  String _calculateDeploymentText(DateTime borrowDate) {
    final diff = DateTime.now().difference(borrowDate);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
