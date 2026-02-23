import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/atmospheric_background.dart';
import '../models/loan_model.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_card_glass.dart';
import '../widgets/loan_details_sheet.dart';
import '../widgets/loan_empty_state.dart';
import '../models/loan_filter.dart';
import '../../../core/design_system/widgets/app_toast.dart';
import '../../../core/design_system/widgets/ligtas_error_state.dart';
import '../providers/loan_filter_provider.dart';
import '../widgets/loan_list_skeleton.dart';
import '../../navigation/providers/navigation_provider.dart';

class ActiveLoansScreen extends ConsumerStatefulWidget {
  const ActiveLoansScreen({super.key});

  @override
  ConsumerState<ActiveLoansScreen> createState() => _ActiveLoansScreenState();
}

class _ActiveLoansScreenState extends ConsumerState<ActiveLoansScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _selectedTabIndex = _tabController.index);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          RefreshIndicator(
            onRefresh: _handleRefresh,
            displacement: 100,
            color: AppTheme.primaryBlue,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 1. Header Title (Matching Inventory)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Items',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w900,
                            fontSize: 34,
                            color: AppTheme.neutralGray900.withValues(alpha: 0.9),
                            letterSpacing: -1.5,
                          ),
                        ),
                        _buildStatsBadge(),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                  ),
                ),

                // 2. Tab Section
                _buildTabSection(),

                // 3. Filter & Sort Section
                _buildFilterSection(),

                // 4. Section Info Header
                _buildSectionHeader(),

                // 5. Dynamic List Content
                _buildSliverLoanList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final filter = ref.watch(loanFilterProvider);
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    ref.read(loanFilterProvider.notifier).updateQuery(val);
                  },
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: const Color(0xFF64748B).withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500),
                    prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF64748B).withValues(alpha: 0.6), size: 18),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            ref.read(loanFilterProvider.notifier).updateQuery('');
                          },
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const Gap(10),
            _buildSortPill(filter.sortBy),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildSortPill(LoanSortOption currentSort) {
    String label = 'NEWEST';
    IconData icon = Icons.sort_rounded;
    if (currentSort == LoanSortOption.oldest) {
      label = 'OLDEST';
      icon = Icons.history_rounded;
    }
    if (currentSort == LoanSortOption.alphabetical) {
      label = 'A-Z';
      icon = Icons.sort_by_alpha_rounded;
    }

    return PopupMenuButton<LoanSortOption>(
      initialValue: currentSort,
      onSelected: (sort) {
        HapticFeedback.lightImpact();
        ref.read(loanFilterProvider.notifier).updateSort(sort);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: LoanSortOption.newest, child: Text('Newest First')),
        const PopupMenuItem(value: LoanSortOption.oldest, child: Text('Oldest First')),
        const PopupMenuItem(value: LoanSortOption.alphabetical, child: Text('Alphabetical')),
      ],
      offset: const Offset(0, 54),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryBlue),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }


  SliverToBoxAdapter _buildTabSection() {
    final pendingCount = ref.watch(myPendingItemsProvider).length;
    final activeCount = ref.watch(myActiveItemsProvider).length;
    final overdueCount = ref.watch(myOverdueItemsProvider).length;
    final historyCount = ref.watch(myReturnedItemsProvider).length;

    final Widget tabContent = Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        height: 54, 
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          tabs: [
            _buildTabWithBadge('Requests', pendingCount, 0, color: AppTheme.warningAmber),
            _buildTabWithBadge('Active', activeCount, 1, color: AppTheme.primaryBlue),
            _buildTabWithBadge('Overdue', overdueCount, 2, color: AppTheme.errorRed),
            _buildTabWithBadge('History', historyCount, 3, color: AppTheme.neutralGray600),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);

    return SliverToBoxAdapter(child: tabContent);
  }

  Widget _buildTabWithBadge(String label, int count, int index, {required Color color}) {
    final isSelected = _selectedTabIndex == index;
    
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const Gap(4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliverLoanList() {
    final type = ['pending', 'active', 'overdue', 'history'][_selectedTabIndex];
    final myBorrowedItemsAsync = ref.watch(myBorrowedItemsProvider);

    return myBorrowedItemsAsync.when(
      data: (_) {
        final List<LoanModel> items = _getFilteredItems(type);
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
                final isReturnable = type == 'active' || type == 'overdue';
                final isCancellable = type == 'pending';

                Widget card = LoanCardGlass(
                  loan: loan,
                  onTap: () => _showLoanDetails(context, loan),
                ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).scale(
                      begin: const Offset(0.95, 0.95),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    );

                Widget content = card;

                if (isReturnable || isCancellable) {
                  content = Dismissible(
                    key: Key('loan_${loan.id}'),
                    direction: DismissDirection.endToStart,
                    onUpdate: (details) {
                      if (details.reached && !details.previousReached) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                    confirmDismiss: (direction) async {
                      return await _confirmAction(
                          context, isReturnable ? 'Return' : 'Cancel');
                    },
                    onDismissed: (direction) {
                      if (isReturnable) {
                        _onReturnValidated(loan);
                      } else if (isCancellable) {
                        _onCancelValidated(loan);
                      }
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: isReturnable
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isReturnable
                                ? Icons.assignment_return_rounded
                                : Icons.cancel_rounded,
                            color: Colors.white,
                          ),
                          const Gap(4),
                          Text(
                            isReturnable ? 'Return' : 'Cancel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: card,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: content,
                );
              },
              childCount: items.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: LoanListSkeleton(),
      ),
      error: (err, stack) => SliverFillRemaining(
        child: LigtasErrorState(
          title: 'Transaction Sync Error',
          message: 'Failed to retrieve your current equipment assignments.',
          onRetry: () => ref.invalidate(myBorrowedItemsProvider),
        ),
      ),
    );
  }

  List<LoanModel> _getFilteredItems(String type) {
    switch (type) {
      case 'pending':
        return ref.watch(myPendingItemsProvider);
      case 'active':
        return ref.watch(myActiveItemsProvider);
      case 'overdue':
        return ref.watch(myOverdueItemsProvider);
      case 'history':
        return ref.watch(myReturnedItemsProvider);
      default:
        return [];
    }
  }

  void _showLoanDetails(BuildContext context, LoanModel loan) async {
    // Senior Dev: Suppress the floating dock to prevent UI overlap and focus the user on the details
    ref.read(isDockSuppressedProvider.notifier).state = true;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoanDetailsSheet(loan: loan),
    );
    
    // Restore dock behavior after the modal is dismissed
    ref.read(isDockSuppressedProvider.notifier).state = false;
  }

  Future<bool> _confirmAction(BuildContext context, String action) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Return' ? AppTheme.successGreen : AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(action),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _handleRefresh() async {
    try {
      HapticFeedback.mediumImpact();
      await ref.read(loanRepositoryProvider).syncMyBorrowedItems();
      if (mounted) {
        AppToast.showSuccess(context, 'Borrowed items successfully updated');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  Widget _buildSectionHeader() {
    final type = ['pending', 'active', 'overdue', 'history'][_selectedTabIndex];
    final items = _getFilteredItems(type);
    
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
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.neutralGray900.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length} ${items.length == 1 ? 'ITEM' : 'ITEMS'}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray900.withValues(alpha: 0.4),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildStatsBadge() {
    // Badge removed - returning empty SizedBox
    return const SizedBox.shrink();
  }

  void _onReturnValidated(LoanModel loan) async {
    try {
      await ref.read(loanRepositoryProvider).requestReturn(loan.id);
      if (mounted) {
        AppToast.showSuccess(context, 'Return request initiated for ${loan.itemName}');
        // Refresh local data
        ref.invalidate(myBorrowedItemsProvider);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to initiate return: $e');
        ref.invalidate(myBorrowedItemsProvider); // Restore item to list
      }
    }
  }

  void _onCancelValidated(LoanModel loan) async {
    try {
      await ref.read(loanRepositoryProvider).cancelLoanRequest(loan.id);
      if (mounted) {
        AppToast.showSuccess(context, 'Request cancelled for ${loan.itemName}');
        // Refresh local data
        ref.invalidate(myBorrowedItemsProvider);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to cancel request: $e');
        ref.invalidate(myBorrowedItemsProvider); // Restore item to list
      }
    }
  }
}
