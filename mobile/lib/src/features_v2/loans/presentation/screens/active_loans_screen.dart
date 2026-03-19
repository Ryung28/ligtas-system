import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/atmospheric_background.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/core/design_system/widgets/ligtas_error_state.dart';
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
      if (!_tabController.indexIsChanging) {
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
    // Watch Enterprise Providers
    final filteredItems = ref.watch(filteredLoansProvider);
    final selectedTabIndex = ref.watch(loanSelectedTabIndexProvider);
    final sortBy = ref.watch(loanSortByProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          RefreshIndicator(
            onRefresh: () async => ref.read(myLoansNotifierProvider.notifier).refresh(),
            displacement: 100,
            color: AppTheme.primaryBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'My Items',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -1.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                  ),
                ),

                _buildTabSection(selectedTabIndex),

                _buildFilterSection(sortBy),

                _buildSectionHeader(filteredItems, selectedTabIndex),

                _buildSliverLoanList(filteredItems, selectedTabIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(int selectedTabIndex) {
    final pendingCount = ref.watch(myPendingItemsProvider).length;
    final activeCount = ref.watch(myActiveItemsProvider).length;
    final overdueCount = ref.watch(myOverdueItemsProvider).length;
    final historyCount = ref.watch(myReturnedHistoryProvider).length;

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 54,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9), // 🛡️ Premium Soft Background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4), // 🛡️ Tactical Soft Neumorphism
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false, // 🛡️ Step 1.3: Force Full Width Alignment
                tabAlignment: TabAlignment.fill,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: GoogleFonts.inter( // 🛡️ Rule #2: Tactical Typography
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: -0.2,
                ),
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  _buildTab('Requests', pendingCount, 0, AppTheme.warningAmber, selectedTabIndex, isCompact),
                  _buildTab('Active', activeCount, 1, AppTheme.primaryBlue, selectedTabIndex, isCompact),
                  _buildTab('Overdue', overdueCount, 2, AppTheme.errorRed, selectedTabIndex, isCompact),
                  _buildTab('History', historyCount, 3, AppTheme.neutralGray600, selectedTabIndex, isCompact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, int index, Color badgeColor, int selectedIndex, bool isCompact) {
    final isSelected = selectedIndex == index;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label),
            ),
          ),
          if (count > 0) ...[
            const Gap(4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(isSelected ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection(String sortBy) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref.read(loanSearchQueryProvider.notifier).update(val),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: const Color(0xFF64748B).withOpacity(0.6), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF64748B).withOpacity(0.6), size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Gap(10),
            _buildSortPill(sortBy),
          ],
        ),
      ),
    );
  }

  Widget _buildSortPill(String sortBy) {
    return PopupMenuButton<String>(
      onSelected: (val) => ref.read(loanSortByProvider.notifier).update(val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'newest', child: Text('Newest First')),
        const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
        const PopupMenuItem(value: 'alphabetical', child: Text('Alphabetical')),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded, size: 16, color: AppTheme.primaryBlue),
            const Gap(8),
            Text(
              sortBy.toUpperCase(),
              style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.w900),
            ),
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
      builder: (_) => LoanDetailsSheet(loan: loan),
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
    
    String label = 'CURRENT STATUS';
    if (type == 'pending') label = 'PENDING APPROVAL';
    if (type == 'active') label = 'ACTIVE DEPLOYMENTS';
    if (type == 'overdue') label = 'URGENT ATTENTION';
    if (type == 'history') label = 'TRANSACTION LOGS';

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralGray900.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(8),
            Text(
              '${items.length} ITEMS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray900.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
