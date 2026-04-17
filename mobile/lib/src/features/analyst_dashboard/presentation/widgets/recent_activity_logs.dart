import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/_components/session_card.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/widgets/models/activity_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RecentActivityLogs — orchestrator widget
// Delegates grouping to activity_session.dart and rendering to SessionCard.
// ─────────────────────────────────────────────────────────────────────────────
class RecentActivityLogs extends StatelessWidget {
  final List<ActivityEvent> events;

  const RecentActivityLogs({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final sessions = buildActivitySessions(events, cap: 10);
    final grouped = groupSessionsByDate(sessions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            if (sessions.length >= 8)
              _SeeAllButton(
                totalCount: events.length,
                onTap: () => context.go('/manager/activity'),
              )
            else
              const Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: Color(0xFFCBD5E1),
              ),
          ],
        ),
        const Gap(20),

        // ── Body ────────────────────────────────────────────────────────────
        if (events.isEmpty)
          const _EmptyState()
        else
          ...grouped.entries.map(
            (entry) => _DateGroup(label: entry.key, sessions: entry.value),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateGroup — one date bucket: label + card container
// ─────────────────────────────────────────────────────────────────────────────
class _DateGroup extends StatelessWidget {
  final String label;
  final List<ActivitySession> sessions;

  const _DateGroup({required this.label, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date label row
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF475569),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        // Card container
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children:
                  sessions.asMap().entries.map((e) {
                    final isLast = e.key == sessions.length - 1;
                    return Column(
                      children: [
                        SessionCard(session: e.value),
                        if (!isLast)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            height: 1,
                            color: const Color(0xFFF1F5F9),
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeeAllButton — slim right-side "SEE ALL →" CTA
// ─────────────────────────────────────────────────────────────────────────────
class _SeeAllButton extends StatelessWidget {
  final int totalCount;
  final VoidCallback onTap;

  const _SeeAllButton({required this.totalCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'SEE ALL ($totalCount)',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState — shown when there are no events yet
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 36,
              color: AppTheme.neutralGray300,
            ),
            const Gap(12),
            Text(
              'No activity yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralGray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
