import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../dashboard/widgets/dashboard_background.dart';
import '../_components/session_card.dart';
import '../controllers/activity_ledger_controller.dart';
import '../widgets/models/activity_session.dart';
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
  String? _focusToken;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusToken ??= GoRouterState.of(context).uri.queryParameters['focus']?.trim();
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

  bool _sessionMatchesFocus(ActivitySession session, String focusToken) {
    final token = focusToken.toLowerCase();
    for (final event in session.events) {
      final eventId = event.id.toLowerCase();
      final refId = (event.referenceId ?? '').toLowerCase();
      final assetId = event.assetId?.toString().toLowerCase() ?? '';
      if (eventId == token || refId == token || assetId == token) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
                    'ACTIVITY HISTORY',
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
                                hintText: 'Search activity...',
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
                ref.watch(groupedActivityHistoryProvider).when(
                  data: (grouped) {
                    if (grouped.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No activity found',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.neutralGray400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    final entries = grouped.entries.toList();
                    final isLoading = ref.watch(activityLedgerProvider).isLoading;

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, dateIndex) {
                            if (dateIndex == entries.length) {
                               return isLoading 
                                 ? const Padding(
                                     padding: EdgeInsets.symmetric(vertical: 20),
                                     child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                   )
                                 : const SizedBox.shrink();
                            }

                            final entry = entries[dateIndex];
                            final dateLabel = entry.key;
                            final dateSessions = entry.value;

                            return RepaintBoundary(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 10, top: dateIndex == 0 ? 0 : 20),
                                    child: Text(
                                      dateLabel,
                                      style: GoogleFonts.lexend(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF475569),
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ),
                                  // Session Card Container
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
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
                                        children: dateSessions.asMap().entries.map((e) {
                                          final isLast = e.key == dateSessions.length - 1;
                                          final isFocused = _focusToken != null &&
                                              _focusToken!.isNotEmpty &&
                                              _sessionMatchesFocus(e.value, _focusToken!);
                                          return Column(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 220),
                                                curve: Curves.easeOutCubic,
                                                margin: isFocused
                                                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                                                    : EdgeInsets.zero,
                                                decoration: isFocused
                                                    ? BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(14),
                                                        border: Border.all(
                                                          color: const Color(0xFF93C5FD),
                                                          width: 1.2,
                                                        ),
                                                      )
                                                    : null,
                                                child: SessionCard(session: e.value),
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
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: (dateIndex * 50).ms).slideY(begin: 0.05, end: 0),
                                ],
                              ),
                            );
                          },
                          childCount: entries.length + 1, // +1 for the loading indicator
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                  ),
                  error: (err, _) => SliverFillRemaining(
                     child: Center(child: Text('Vault Access Denied: $err', style: const TextStyle(color: Colors.red))),
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
