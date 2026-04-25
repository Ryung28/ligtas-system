import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/activity_event.dart';
import '../../../../core/design_system/app_theme.dart';

class ActivityEventTile extends StatelessWidget {
  final ActivityEvent event;
  final VoidCallback? onTap;

  const ActivityEventTile({
    super.key,
    required this.event,
    this.onTap,
  });

  Color get _statusColor {
    switch (event.status) {
      case EventStatus.transit:
        return AppTheme.primaryBlue;
      case EventStatus.verified:
        return AppTheme.emeraldGreen;
      case EventStatus.critical:
        return AppTheme.errorRed;
      case EventStatus.synced:
        return AppTheme.neutralGray500;
      case EventStatus.pending:
        return AppTheme.warningOrange;
      case EventStatus.offline:
        return AppTheme.neutralGray600;
    }
  }

  IconData get _typeIcon {
    switch (event.type) {
      case EventType.assetOut:
        return Icons.arrow_upward_rounded;
      case EventType.assetIn:
        return Icons.arrow_downward_rounded;
      case EventType.requisitionApproved:
        return Icons.check_circle_rounded;
      case EventType.requisitionRejected:
        return Icons.cancel_rounded;
      case EventType.systemSync:
        return Icons.sync_rounded;
      case EventType.securityTrigger:
        return Icons.warning_rounded;
      case EventType.maintenance:
        return Icons.build_rounded;
      case EventType.requisitionDenied:
        return Icons.block_rounded;
      case EventType.mixed:
        return Icons.sync_problem_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.neutralGray200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Type Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _typeIcon,
                size: 16,
                color: _statusColor,
              ),
            ),
            const Gap(12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutralGray900,
                    ),
                  ),
                  if (event.subtitle != null) ...[
                    const Gap(2),
                    Text(
                      event.subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.neutralGray600,
                      ),
                    ),
                  ],
                  if (event.approvedBy != null) ...[
                    const Gap(4),
                    Row(
                      children: [
                        Text(
                          'APPROVED BY',
                          style: GoogleFonts.lexend(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppTheme.neutralGray500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          event.approvedBy!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutralGray700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Gap(12),
            
            // Status & Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event.timeDisplay,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralGray500,
                  ),
                ),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.status == EventStatus.synced ? 'RECEIVED' : event.status.name.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: _statusColor,
                    ),
                  ),
                ),
                if (event.priority != null) ...[
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.priority!,
                      style: GoogleFonts.lexend(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
