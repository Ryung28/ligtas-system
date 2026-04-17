import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionIconBadge — squircle icon tile with optional item-count bubble
// Uses semantic icons per EventType (no generic arrows).
// ─────────────────────────────────────────────────────────────────────────────
class SessionIconBadge extends StatelessWidget {
  final EventType type;
  final int itemCount;

  const SessionIconBadge({
    super.key,
    required this.type,
    this.itemCount = 1,
  });

  Color get _color {
    switch (type) {
      case EventType.assetOut:
        return const Color(0xFF3B82F6);
      case EventType.assetIn:
        return const Color(0xFF10B981);
      case EventType.requisitionApproved:
        return const Color(0xFF10B981);
      case EventType.maintenance:
        return const Color(0xFFF59E0B);
      case EventType.requisitionDenied:
      case EventType.requisitionRejected:
        return const Color(0xFFEF4444);
      case EventType.securityTrigger:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData get _icon {
    switch (type) {
      case EventType.assetOut:
        // "Item leaving the inventory" — outbox tray
        return Icons.outbox_rounded;
      case EventType.assetIn:
        // "Item coming back" — move-to-inbox
        return Icons.move_to_inbox_rounded;
      case EventType.requisitionApproved:
        return Icons.verified_rounded;
      case EventType.maintenance:
        return Icons.construction_rounded;
      case EventType.requisitionDenied:
      case EventType.requisitionRejected:
        return Icons.do_not_disturb_on_rounded;
      case EventType.securityTrigger:
        return Icons.shield_moon_rounded;
      default:
        return Icons.sync_lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isMulti = itemCount > 1;

    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        children: [
          // Squircle background tile
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.15), width: 1),
            ),
            child: Icon(_icon, size: 22, color: color),
          ),
          // Count bubble — top-right corner, only for multi-item sessions
          if (isMulti)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$itemCount',
                  style: GoogleFonts.lexend(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
