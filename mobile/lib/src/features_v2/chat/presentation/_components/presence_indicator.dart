import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobile/src/features_v2/chat/presentation/_components/pulsing_dot.dart';

// =============================================================================
// PresenceIndicator
// ─────────────────────────────────────────────────────────────────────────────
// Extracted from chat_screen.dart to enforce Atomic Design.
// Molecule: PulsingDot (atom) + status text.
// Priority 1: Realtime channel → Priority 2: Heartbeat fallback.
// =============================================================================

class PresenceIndicator extends StatelessWidget {
  final DateTime? lastSeen;
  final bool isRealtimeOnline;

  const PresenceIndicator({
    super.key,
    required this.lastSeen,
    required this.isRealtimeOnline,
  });

  @override
  Widget build(BuildContext context) {
    // ── Priority 1: Realtime Channel ──
    if (isRealtimeOnline) {
      return Row(
        children: [
          const PulsingDot(color: Color(0xFF10B981), isPulsing: true),
          const Gap(6),
          Text(
            'ONLINE NOW',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF10B981),
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }

    if (lastSeen == null) {
      return Row(
        children: [
          const PulsingDot(color: Colors.grey, isPulsing: false),
          const Gap(6),
          Text(
            'OFFLINE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }

    // ── Priority 2: Heartbeat Fallback — 120 Second Window ──
    final diff = DateTime.now().toUtc().difference(lastSeen!.toUtc());
    final isOnline = diff.inMinutes < 2;

    final color = isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8);
    final statusText =
        isOnline ? 'ONLINE' : 'OFFLINE • ${timeago.format(lastSeen!, allowFromNow: true)}';

    return Row(
      children: [
        PulsingDot(color: color, isPulsing: isOnline),
        const Gap(6),
        Flexible(
          child: Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
