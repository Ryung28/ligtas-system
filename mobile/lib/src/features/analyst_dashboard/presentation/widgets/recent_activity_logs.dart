import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart';
import '../../domain/entities/activity_event.dart';
import '../../../../core/design_system/app_theme.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/_components/audit_vault_components.dart';

class RecentActivityLogs extends StatefulWidget {
  final List<ActivityEvent> events;

  const RecentActivityLogs({
    super.key,
    required this.events,
  });

  @override
  State<RecentActivityLogs> createState() => _RecentActivityLogsState();
}

class _RecentActivityLogsState extends State<RecentActivityLogs> {
  Map<String, List<ActivityEvent>> _groupEvents(List<ActivityEvent> events) {
    final Map<String, List<ActivityEvent>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // 🛡️ PREVIEW LIMIT: Restrict to 10 logs for the dashboard stream
    final previewEvents = events.take(10).toList();

    for (var event in previewEvents) {
      final eventDate = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
      String key;
      if (eventDate == today) {
        key = 'TODAY';
      } else if (eventDate == yesterday) {
        key = 'YESTERDAY';
      } else {
        key = DateFormat('MMMM d, y').format(eventDate).toUpperCase();
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(event);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEvents = _groupEvents(widget.events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            // ── TACTICAL HEADER ACTION: See All ──
            if (widget.events.length > 10)
              TextButton(
                onPressed: () => context.go('/manager/activity'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'SEE ALL (${widget.events.length})',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF64748B)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const Gap(24),
        
        if (widget.events.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('No records found.')))
        else
          ...groupedEvents.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    entry.key,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neutralGray400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final sentinel = Theme.of(context).sentinel;
                      final events = entry.value;
                      return Column(
                        children: events.asMap().entries.map((eventEntry) {
                          final index = eventEntry.key;
                          final event = eventEntry.value;
                          final isLast = index == events.length - 1;

                          return Column(
                            children: [
                              AuditLedgerRow(
                                event: event,
                                sentinel: sentinel,
                              ),
                              if (!isLast)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  height: 1,
                                  color: const Color(0xFFF1F5F9),
                                ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
      ],
    );
  }
}
