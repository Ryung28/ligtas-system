import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/activity_event.dart';
import 'activity_event_tile.dart';
import '../../../../core/design_system/app_theme.dart';

enum ActivityFilter { all, assetInOut, securityTriggers }

class ActivityStreamList extends StatefulWidget {
  final List<ActivityEvent> events;
  final VoidCallback? onLoadMore;

  const ActivityStreamList({
    super.key,
    required this.events,
    this.onLoadMore,
  });

  @override
  State<ActivityStreamList> createState() => _ActivityStreamListState();
}

class _ActivityStreamListState extends State<ActivityStreamList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ActivityFilter _selectedFilter = ActivityFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ActivityEvent> get _filteredEvents {
    switch (_selectedFilter) {
      case ActivityFilter.all:
        return widget.events;
      case ActivityFilter.assetInOut:
        return widget.events.where((e) =>
            e.type == EventType.assetIn || e.type == EventType.assetOut).toList();
      case ActivityFilter.securityTriggers:
        return widget.events.where((e) =>
            e.type == EventType.securityTrigger).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Activity Stream',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutralGray900,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const Gap(12),
        
        // Tab Bar
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.neutralGray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.neutralGray900,
              borderRadius: BorderRadius.circular(6),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.neutralGray600,
            labelStyle: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'LIVE'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        const Gap(12),
        
        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All Events',
                isSelected: _selectedFilter == ActivityFilter.all,
                onTap: () => setState(() => _selectedFilter = ActivityFilter.all),
              ),
              const Gap(8),
              _FilterChip(
                label: 'Asset In/Out',
                isSelected: _selectedFilter == ActivityFilter.assetInOut,
                onTap: () => setState(() => _selectedFilter = ActivityFilter.assetInOut),
              ),
              const Gap(8),
              _FilterChip(
                label: 'Security Triggers',
                isSelected: _selectedFilter == ActivityFilter.securityTriggers,
                onTap: () => setState(() => _selectedFilter = ActivityFilter.securityTriggers),
              ),
            ],
          ),
        ),
        const Gap(16),
        
        // Event List
        if (_filteredEvents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No activity events',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.neutralGray500,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredEvents.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              return ActivityEventTile(event: _filteredEvents[index]);
            },
          ),
        
        // Load More Button
        if (widget.onLoadMore != null) ...[
          const Gap(16),
          Center(
            child: TextButton(
              onPressed: widget.onLoadMore,
              child: Text(
                'LOAD PREVIOUS ENTRIES',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neutralGray900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.neutralGray900 : AppTheme.neutralGray300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.neutralGray700,
          ),
        ),
      ),
    );
  }
}
