import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/core/design_system/widgets/ligtas_error_state.dart';
import 'package:mobile/src/features/dashboard/widgets/dashboard_background.dart';
import '../../domain/entities/loan_item.dart';
import '../providers/loan_provider.dart';
import '../widgets/loan_card_glass.dart';
import '../widgets/loan_details_sheet.dart';
import '../widgets/loan_empty_state.dart';
import '../widgets/loan_list_skeleton.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/core/errors/app_exceptions.dart';

class ActiveLoansScreen extends ConsumerStatefulWidget {
  const ActiveLoansScreen({super.key});

  @override
  ConsumerState<ActiveLoansScreen> createState() => _ActiveLoansScreenState();
}

class _ActiveLoansScreenState extends ConsumerState<ActiveLoansScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: ref.read(loanSelectedTabIndexProvider));
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != ref.read(loanSelectedTabIndexProvider)) {
        ref.read(loanSelectedTabIndexProvider.notifier).update(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(loanSelectedTabIndexProvider);
    final sortBy = ref.watch(loanSortByProvider);
    final sentinel = Theme.of(context).sentinel;

    return Scaffold(
      backgroundColor: sentinel.surface,
      body: Stack(
        children: [
          const DashboardBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myPendingItemsProvider);
                ref.invalidate(myActiveItemsProvider);
                ref.invalidate(myOverdueItemsProvider);
                ref.invalidate(myReturnedHistoryProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'My Items',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          color: sentinel.navy,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                    ),
                  ),
                  _buildTabSection(selectedTabIndex),
                  _buildFilterSection(sortBy),
                  const SliverGap(16),
                  _buildSliverLoanList(ref.watch(filteredLoansProvider), selectedTabIndex),
                  const SliverGap(100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(int selectedTabIndex) {
    final sentinel = Theme.of(context).sentinel;
    final tabs = ['Requests', 'Active', 'Overdue', 'History'];
    final counts = [
      ref.watch(myPendingItemsProvider).length,
      ref.watch(myActiveItemsProvider).length,
      ref.watch(myOverdueItemsProvider).length,
      ref.watch(myReturnedHistoryProvider).length,
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          height: 58,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: sentinel.containerLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: sentinel.tactile.recessed,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = (constraints.maxWidth) / 4;
              return Stack(
                children: [
                  // ── Neuromorphic Floating Pill ──
                  AnimatedPositioned(
                    duration: 250.ms,
                    curve: Curves.easeOutCubic,
                    left: selectedTabIndex * tabWidth,
                    width: tabWidth,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                        color: sentinel.containerLowest,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: sentinel.tactile.raised,
                      ),
                    ),
                  ),
                  
                  // ── Tab Buttons ──
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final isSelected = selectedTabIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _tabController.index = index;
                            ref.read(loanSelectedTabIndexProvider.notifier).update(index);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tabs[index],
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                ),
                                if (counts[index] > 0)
                                  Text(
                                    '${counts[index]}',
                                    style: GoogleFonts.lexend(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? sentinel.navy.withOpacity(0.5) : sentinel.onSurfaceVariant.withOpacity(0.3),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, int index, int selectedIndex) {
    return Tab(
      child: Text(label),
    );
  }

  Widget _buildFilterSection(String sortBy) {
    final sentinel = Theme.of(context).sentinel;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            // ── Neuromorphic Search Input ──
            Expanded(
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: sentinel.containerLow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: sentinel.tactile.recessed,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref.read(loanSearchQueryProvider.notifier).update(val),
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: sentinel.navy),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: GoogleFonts.lexend(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13),
                    prefixIcon: Container(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(Icons.search_rounded, color: sentinel.onSurfaceVariant.withOpacity(0.5), size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),
            const Gap(12),
            // ── Raised Tactile Sort Pill ──
            _buildSortPill(sortBy),
          ],
        ),
      ),
    );
  }

  Widget _buildSortPill(String sortBy) {
    final sentinel = Theme.of(context).sentinel;
    return PopupMenuButton<String>(
      onSelected: (val) {
        HapticFeedback.lightImpact();
        ref.read(loanSortByProvider.notifier).update(val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'newest', child: Text('Newest First')),
        const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
        const PopupMenuItem(value: 'alphabetical', child: Text('Alphabetical')),
      ],
      offset: const Offset(0, 64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: sentinel.containerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: sentinel.tactile.raised,
        ),
        child: Row(
          children: [
            Text(
              sortBy == 'newest' ? 'Newest' : sortBy.toUpperCase(),
              style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: sentinel.navy),
            ),
            const Gap(6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: sentinel.navy),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverLoanList(List<LoanItem> items, int selectedTabIndex) {
    final type = ['pending', 'active', 'overdue', 'history'][selectedTabIndex];
    final myLoansAsync = ref.watch(myLoansNotifierProvider);

    return myLoansAsync.when(
      data: (_) {
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: LoanEmptyState(statusType: type),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final loan = items[index];
                final isReturnable = loan.status == LoanStatus.active || loan.status == LoanStatus.overdue;
                final isCancellable = loan.status == LoanStatus.pending;

                Widget card = LoanCardGlass(
                  loan: loan,
                  onTap: () => _showLoanDetails(context, loan),
                  onReturn: (isReturnable || isCancellable) 
                    ? () async {
                        final confirmed = await _confirmAction(
                          context, 
                          loan, 
                          isReturnable ? 'Return' : 'Cancel'
                        );
                        if (confirmed) {
                          isReturnable ? _handleReturn(loan) : _handleCancel(loan);
                        }
                      }
                    : null,
                );

                return Padding(padding: const EdgeInsets.only(bottom: 12), child: card);
              },
              childCount: items.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(child: LoanListSkeleton()),
      error: (err, stack) => SliverFillRemaining(
        child: LigtasErrorState(
          title: 'V2 Data Failure',
          message: 'Could not sync loan records locally.',
          onRetry: () => ref.read(myLoansNotifierProvider.notifier).refresh(),
        ),
      ),
    );
  }

  void _showLoanDetails(BuildContext context, LoanItem loan) async {
    ref.read(isDockSuppressedProvider.notifier).state = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoanDetailsSheet(loan: loan, readOnly: true),
    );
    ref.read(isDockSuppressedProvider.notifier).state = false;
  }

  Future<bool> _confirmAction(BuildContext context, LoanItem loan, String action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action ${loan.itemName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    ) ?? false;
  }

  void _handleReturn(LoanItem loan) async {
    try {
      await ref.read(loanRepositoryProvider).returnItem(loan.id);
      if (mounted) AppToast.showSuccess(context, 'Return request sent');
    } catch (e) {
      if (mounted) AppToast.showError(context, ExceptionHandler.getDisplayMessage(e as Exception));
    }
  }

  void _handleCancel(LoanItem loan) async {
     try {
      await ref.read(loanRepositoryProvider).cancelLoan(loan.id);
      if (mounted) AppToast.showSuccess(context, 'Request cancelled');
    } catch (e) {
      if (mounted) AppToast.showError(context, ExceptionHandler.getDisplayMessage(e as Exception));
    }
  }

  Widget _buildSectionHeader(List<LoanItem> items, int selectedTabIndex) {
    final type = ['pending', 'active', 'overdue', 'history'][selectedTabIndex];
    final sentinel = Theme.of(context).sentinel;
    
    String label = 'Current Status';
    if (type == 'pending') label = 'Pending Approval';
    if (type == 'active') label = 'Active Deployments';
    if (type == 'overdue') label = 'Urgent Attention';
    if (type == 'history') label = 'Transaction Logs';

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(12),
            Flexible(
              child: Text(
                '$label (${items.length} Items)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sentinel.onSurfaceVariant.withOpacity(0.5),
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
