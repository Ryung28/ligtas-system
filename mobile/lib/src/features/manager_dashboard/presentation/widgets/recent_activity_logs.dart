import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/activity_event.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
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
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Movement', 'Approved', 'Pending'];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredEvents = widget.events.where((e) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Movement') return e.type == EventType.assetIn || e.type == EventType.assetOut;
      if (_selectedFilter == 'Approved') return e.status == EventStatus.verified;
      if (_selectedFilter == 'Pending') return e.status == EventStatus.pending;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'FIELD LOGISTICS FEED',
            style: GoogleFonts.lexend(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const Gap(12),
        
        // Tactical Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _filters.map((f) => _TacticalChip(
              label: f.toUpperCase(), 
              isSelected: _selectedFilter == f,
              onTap: () => setState(() => _selectedFilter = f),
            )).toList(),
          ),
        ),
        const Gap(16),

        // Mission Log List - 🛡️ UNIFIED COMPONENT
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredEvents.length,
          separatorBuilder: (_, __) => const Gap(4),
          itemBuilder: (context, index) {
            final sentinel = Theme.of(context).sentinel;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AuditLedgerRow(
                event: filteredEvents[index],
                sentinel: sentinel,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TacticalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TacticalChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            color: isSelected ? AppTheme.primaryBlue : Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// 🛡️ UNIFIED: _ActivityCard has been removed to favor AuditLedgerRow from audit_vault_components.dart

