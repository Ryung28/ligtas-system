import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionStatusChip — compact pill badge for an EventType
// ─────────────────────────────────────────────────────────────────────────────
class SessionStatusChip extends StatelessWidget {
  final EventType type;

  const SessionStatusChip({super.key, required this.type});

  Color get _color {
    switch (type) {
      case EventType.assetOut:
        return const Color(0xFF3B82F6);
      case EventType.assetIn:
        return const Color(0xFF10B981);
      case EventType.requisitionApproved:
        return const Color(0xFF10B981);
      case EventType.maintenance:
      case EventType.reserved:
        return const Color(0xFFF59E0B);
      case EventType.requisitionDenied:
      case EventType.requisitionRejected:
        return const Color(0xFFEF4444);
      case EventType.securityTrigger:
        return const Color(0xFFEF4444);
      case EventType.mixed:
        return const Color(0xFF64748B); // Slate-500 (Matches zinc-600 look)
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String get _label {
    switch (type) {
      case EventType.assetOut:            return 'BORROWED';
      case EventType.assetIn:             return 'RETURNED';
      case EventType.requisitionApproved: return 'VERIFIED';
      case EventType.maintenance:         return 'MAINTENANCE';
      case EventType.reserved:            return 'RESERVED';
      case EventType.requisitionDenied:   return 'DENIED';
      case EventType.requisitionRejected: return 'REJECTED';
      case EventType.securityTrigger:     return 'SECURITY';
      case EventType.mixed:               return 'MIXED';
      default:                            return 'SYNCED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: GoogleFonts.lexend(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _color,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
