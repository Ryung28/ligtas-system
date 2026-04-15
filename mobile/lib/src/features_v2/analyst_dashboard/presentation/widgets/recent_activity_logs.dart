import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

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
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Asset Movement', 'Approvals', 'System'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Layer 1: Title (Single Line "Gold Standard") ──
        Text(
          'Recent Activity Logs',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.neutralGray900,
            letterSpacing: -0.8,
          ),
        ),
        const Gap(12),
        
        // ── Header Layer 2: Action Gutter (Filters) ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none, // Allow chip shadows to breathe
          child: Row(
            children: _filters.map((filter) => _buildFilterChip(filter)).toList(),
          ),
        ),
        const Gap(20),

        // ── Logs List ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.events.length,
          separatorBuilder: (_, __) => const Gap(16),
          itemBuilder: (context, index) {
            return _ActivityLogCard(event: widget.events[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                shape: label == 'All' ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: label == 'All' ? null : BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.neutralGray900 : AppTheme.neutralGray500,
          ),
        ),
      ),
    );
  }
}

class _ActivityLogCard extends StatelessWidget {
  final ActivityEvent event;

  const _ActivityLogCard({required this.event});

  Color get _containerColor {
    switch (event.type) {
      case EventType.assetOut:
      case EventType.assetIn:
        return const Color(0xFFF1F3F6); // Soft gray/blue
      case EventType.requisitionApproved:
        return const Color(0xFFE8F5E9); // Soft green
      case EventType.systemSync:
        return const Color(0xFFF1F3F6);
      default:
        return const Color(0xFFF1F3F6);
    }
  }

  Color get _iconColor {
    switch (event.type) {
      case EventType.requisitionApproved:
        return AppTheme.successGreen;
      default:
        return AppTheme.neutralGray600;
    }
  }

  IconData get _icon {
    switch (event.type) {
      case EventType.assetOut:
        return Icons.outbox_rounded;
      case EventType.assetIn:
        return Icons.move_to_inbox_rounded;
      case EventType.requisitionApproved:
        return Icons.check_circle_rounded;
      case EventType.systemSync:
        return Icons.sync_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm').format(event.timestamp);
    final periodStr = DateFormat('a').format(event.timestamp);
    final isToday = DateFormat('yyyy-MM-dd').format(event.timestamp) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001A33).withOpacity(0.04),
            offset: const Offset(4, 4),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Leading Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _icon,
                color: _iconColor,
                size: 20,
              ),
            ),
          ),
          const Gap(16),
          
          // Middle Content (Expanded to prevent overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray900,
                  ),
                ),
                const Gap(2),
                Text(
                  event.subtitle ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.neutralGray500,
                  ),
                ),
              ],
            ),
          ),
          
          const Gap(12),
          
          // Trailing Metadata (Temporal Anchoring)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutralGray900,
                ),
              ),
              Text(
                periodStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutralGray900,
                ),
              ),
              Text(
                isToday ? 'TODAY' : DateFormat('MMM d').format(event.timestamp).toUpperCase(),
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.neutralGray400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
