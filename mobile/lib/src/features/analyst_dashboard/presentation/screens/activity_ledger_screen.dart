import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../../core/design_system/widgets/atmospheric_background.dart';
import '../../../dashboard/widgets/dashboard_background.dart';
import '../../domain/entities/activity_event.dart';
import '../_components/audit_vault_components.dart';
import '../controllers/activity_ledger_controller.dart';
import '../widgets/activity_event_tile.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter/services.dart';

class ActivityLedgerScreen extends ConsumerStatefulWidget {
  const ActivityLedgerScreen({super.key});

  @override
  ConsumerState<ActivityLedgerScreen> createState() => _ActivityLedgerScreenState();
}

class _ActivityLedgerScreenState extends ConsumerState<ActivityLedgerScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityLedgerProvider.notifier).loadMore();
    }
  }

  bool _isNewDay(List<ActivityEvent> events, int index) {
    if (index == 0) return true;
    final current = events[index].timestamp;
    final previous = events[index - 1].timestamp;
    return current.year != previous.year || 
           current.month != previous.month || 
           current.day != previous.day;
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(activityLedgerProvider);
    final sentinel = Theme.of(context).sentinel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DashboardBackground(),
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // ── 1. FIXED FORENSIC HEADER ──
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leadingWidth: 70,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  title: Text(
                    'SYSTEM AUDIT LEDGER',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  centerTitle: true,
                ),

                // ── 2. SEARCH & FILTER SECTION (PERSISTENT SEARCH ANCHOR) ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                          const Gap(12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => ref.read(activityLedgerProvider.notifier).search(val),
                              decoration: InputDecoration(
                                hintText: 'Search audit trail...',
                                hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF1E293B)),
                              onPressed: () {
                                // TODO: Implementation of Tactical Filter Drawer
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Activity',
                            value: 'all',
                            currentValue: ref.watch(activityLedgerProvider.notifier).currentStatus,
                            onTap: (v) => ref.read(activityLedgerProvider.notifier).filterByStatus(v),
                            sentinel: sentinel,
                          ),
                          const Gap(8),
                          _FilterChip(
                            label: 'Pending Approvals',
                            value: 'pending',
                            currentValue: ref.watch(activityLedgerProvider.notifier).currentStatus,
                            onTap: (v) => ref.read(activityLedgerProvider.notifier).filterByStatus(v),
                            sentinel: sentinel,
                            color: Colors.orange,
                          ),
                          const Gap(8),
                          _FilterChip(
                            label: 'Currently Borrowed',
                            value: 'borrowed',
                            currentValue: ref.watch(activityLedgerProvider.notifier).currentStatus,
                            onTap: (v) => ref.read(activityLedgerProvider.notifier).filterByStatus(v),
                            sentinel: sentinel,
                            color: AppTheme.primaryBlue,
                          ),
                          const Gap(8),
                          _FilterChip(
                            label: 'Returned',
                            value: 'returned',
                            currentValue: ref.watch(activityLedgerProvider.notifier).currentStatus,
                            onTap: (v) => ref.read(activityLedgerProvider.notifier).filterByStatus(v),
                            sentinel: sentinel,
                            color: Colors.green,
                          ),
                          const Gap(8),
                          _FilterChip(
                            label: 'Security Anomalies',
                            value: 'overdue',
                            currentValue: ref.watch(activityLedgerProvider.notifier).currentStatus,
                            onTap: (v) => ref.read(activityLedgerProvider.notifier).filterByStatus(v),
                            sentinel: sentinel,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverGap(12),

                // ── 3. DATA VIRTUALIZATION ENGINE ──
                ledgerState.when(
                  data: (logs) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == logs.length) {
                             return const Padding(
                               padding: EdgeInsets.symmetric(vertical: 20),
                               child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                             );
                          }
                          final event = logs[index];
                          final showHeader = _isNewDay(logs, index);

                          return Stack(
                            children: [
                              // ── VERTICAL TIMELINE THREAD ──
                              Positioned(
                                left: 24,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showHeader)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 48),
                                      child: _DateSeparator(date: event.timestamp),
                                    ),
                                  
                                  Padding(
                                    key: ValueKey(event.id ?? index),
                                    padding: const EdgeInsets.only(left: 48, bottom: 12),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // ── NODE INDICATOR ──
                                        Positioned(
                                          left: -31,
                                          top: 24,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _getEventColor(event.type),
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getEventColor(event.type).withOpacity(0.2),
                                                  blurRadius: 6,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        AuditLedgerRow(
                                          event: event,
                                          sentinel: sentinel,
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(delay: (index % 10 * 50).ms).slideX(begin: 0.1, end: 0),
                                ],
                              ),
                            ],
                          );
                        },
                        childCount: logs.length + (ledgerState.isLoading ? 1 : 0),
                      ),
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(child: Text('Vault Access Denied: $err')),
                  ),
                ),

                const SliverGap(60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.securityTrigger:
        return AppTheme.errorRed;
      case EventType.assetOut:
      case EventType.assetIn:
        return AppTheme.primaryBlue;
      case EventType.requisitionApproved:
        return AppTheme.emeraldGreen;
      case EventType.requisitionRejected:
      case EventType.requisitionDenied:
        return AppTheme.warningOrange;
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM dd, yyyy').format(date).toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🛡️ SENTINEL COMPONENT: Tactile Forensic Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String currentValue;
  final Function(String) onTap;
  final SentinelColors sentinel;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
    required this.sentinel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;
    final themeColor = color ?? const Color(0xFF1E293B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: inset.BoxDecoration(
          color: isSelected ? sentinel.navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: (isSelected ? sentinel.tactile.recessed : sentinel.tactile.raised).map((s) {
            return inset.BoxShadow(
              color: s.color,
              offset: s.offset,
              blurRadius: s.blurRadius,
              spreadRadius: s.spreadRadius,
              blurStyle: s.blurStyle,
              inset: s is inset.BoxShadow && s.inset,
            );
          }).toList(),
          border: isSelected 
            ? null 
            : Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : sentinel.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
