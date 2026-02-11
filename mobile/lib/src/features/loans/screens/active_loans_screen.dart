import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/app_card.dart';
import '../models/loan_model.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_card.dart';
import '../widgets/loan_statistics_card.dart';
import '../widgets/loan_search_bar.dart';

class ActiveLoansScreen extends ConsumerStatefulWidget {
  const ActiveLoansScreen({super.key});

  @override
  ConsumerState<ActiveLoansScreen> createState() => _ActiveLoansScreenState();
}

class _ActiveLoansScreenState extends ConsumerState<ActiveLoansScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: AppTheme.neutralGray50,
      appBar: AppBar(
        title: const Text('My Borrowed Items'),
        actions: [
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.schedule_rounded)),
            Tab(text: 'Overdue', icon: Icon(Icons.warning_rounded)),
            Tab(text: 'History', icon: Icon(Icons.history_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics and Search Section
          Container(
            color: Colors.white,
            padding: AppSpacing.screenPaddingAll,
            child: Column(
              children: [
                // Statistics Cards
                const LoanStatisticsCard(),
                const Gap(AppSpacing.md),
                
                // Search Bar
                LoanSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Loans List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveLoansTab(),
                _buildOverdueLoansTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLoansTab() {
    final activeItems = ref.watch(filteredMyActiveItemsProvider(_searchQuery));
    final myBorrowedItemsAsync = ref.watch(myBorrowedItemsProvider);

    return myBorrowedItemsAsync.when(
      data: (_) {
        if (activeItems.isEmpty) {
          return AppEmptyState(
            icon: _searchQuery.isEmpty 
                ? Icons.check_circle_outline_rounded 
                : Icons.search_off_rounded,
            title: _searchQuery.isEmpty ? 'No active borrowed items' : 'No items found',
            subtitle: _searchQuery.isEmpty
                ? 'You haven\'t borrowed any items yet'
                : 'Try a different search term',
            action: _searchQuery.isEmpty
                ? ElevatedButton.icon(
                    onPressed: () => context.push('/loans/create'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Borrow Item'),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          child: ListView.builder(
            padding: AppSpacing.screenPaddingAll,
            itemCount: activeItems.length,
            itemBuilder: (context, index) {
              return LoanCard(
                loan: activeItems[index],
                onTap: () => _showLoanDetails(activeItems[index]),
                animationDelay: Duration(milliseconds: index * 100),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error loading borrowed items',
        subtitle: error.toString(),
        action: ElevatedButton.icon(
          onPressed: () => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ),
    );
  }

  Widget _buildOverdueLoansTab() {
    final overdueItems = ref.watch(filteredMyOverdueItemsProvider(_searchQuery));
    final myBorrowedItemsAsync = ref.watch(myBorrowedItemsProvider);

    return myBorrowedItemsAsync.when(
      data: (_) {
        if (overdueItems.isEmpty) {
          return AppEmptyState(
            icon: _searchQuery.isEmpty 
                ? Icons.check_circle_outline_rounded 
                : Icons.search_off_rounded,
            title: _searchQuery.isEmpty ? 'No overdue items' : 'No overdue items found',
            subtitle: _searchQuery.isEmpty
                ? 'All your borrowed items are on time'
                : 'Try a different search term',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          child: ListView.builder(
            padding: AppSpacing.screenPaddingAll,
            itemCount: overdueItems.length,
            itemBuilder: (context, index) {
              return LoanCard(
                loan: overdueItems[index],
                onTap: () => _showLoanDetails(overdueItems[index]),
                animationDelay: Duration(milliseconds: index * 100),
                isOverdue: true,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error loading overdue items',
        subtitle: error.toString(),
        action: ElevatedButton.icon(
          onPressed: () => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final returnedItems = ref.watch(filteredMyReturnedItemsProvider(_searchQuery));
    final myBorrowedItemsAsync = ref.watch(myBorrowedItemsProvider);

    return myBorrowedItemsAsync.when(
      data: (_) {
        if (returnedItems.isEmpty) {
          return AppEmptyState(
            icon: _searchQuery.isEmpty 
                ? Icons.history_rounded 
                : Icons.search_off_rounded,
            title: _searchQuery.isEmpty ? 'No borrow history' : 'No history found',
            subtitle: _searchQuery.isEmpty
                ? 'Your borrow history will appear here'
                : 'Try a different search term',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          child: ListView.builder(
            padding: AppSpacing.screenPaddingAll,
            itemCount: returnedItems.length,
            itemBuilder: (context, index) {
              return LoanCard(
                loan: returnedItems[index],
                onTap: () => _showLoanDetails(returnedItems[index]),
                animationDelay: Duration(milliseconds: index * 100),
                showHistory: true,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error loading history',
        subtitle: error.toString(),
        action: ElevatedButton.icon(
          onPressed: () => ref.read(myBorrowedItemsProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.read(myBorrowedItemsProvider.notifier).refresh();
  }

  void _showLoanDetails(LoanModel loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoanDetailsBottomSheet(loan: loan),
    );
  }
}

/// Bottom sheet for loan details
class LoanDetailsBottomSheet extends ConsumerWidget {
  final LoanModel loan;

  const LoanDetailsBottomSheet({
    super.key,
    required this.loan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray300,
                    borderRadius: AppRadius.allSm,
                  ),
                ),
              ),
              
              const Gap(AppSpacing.lg),
              
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.itemName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          'Code: ${loan.itemCode}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(loan.status, loan.daysOverdue > 0),
                ],
              ),
              
              const Gap(AppSpacing.lg),
              
              // Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Borrower Information', [
                        _buildDetailRow(Icons.person_rounded, 'Name', loan.borrowerName),
                        _buildDetailRow(Icons.phone_rounded, 'Contact', loan.borrowerContact),
                        if (loan.borrowerEmail.isNotEmpty)
                          _buildDetailRow(Icons.email_rounded, 'Email', loan.borrowerEmail),
                      ]),
                      
                      const Gap(AppSpacing.lg),
                      
                      _buildDetailSection('Loan Information', [
                        _buildDetailRow(Icons.inventory_rounded, 'Quantity', '${loan.quantityBorrowed}'),
                        _buildDetailRow(Icons.description_rounded, 'Purpose', loan.purpose),
                        _buildDetailRow(Icons.calendar_today_rounded, 'Borrow Date', 
                          _formatDate(loan.borrowDate)),
                        _buildDetailRow(Icons.event_rounded, 'Expected Return', 
                          _formatDate(loan.expectedReturnDate)),
                        if (loan.actualReturnDate != null)
                          _buildDetailRow(Icons.check_circle_rounded, 'Actual Return', 
                            _formatDate(loan.actualReturnDate!)),
                      ]),
                      
                      if (loan.notes?.isNotEmpty == true) ...[
                        const Gap(AppSpacing.lg),
                        _buildDetailSection('Notes', [
                          Text(
                            loan.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ]),
                      ],
                      
                      if (loan.returnNotes?.isNotEmpty == true) ...[
                        const Gap(AppSpacing.lg),
                        _buildDetailSection('Return Notes', [
                          Text(
                            loan.returnNotes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Action buttons - Remove admin features for borrowers
              if (loan.status == LoanStatus.active) ...[
                const Gap(AppSpacing.lg),
                Container(
                  padding: AppSpacing.allMd,
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withOpacity(0.1),
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: AppTheme.warningAmber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.warningAmber,
                        size: AppSizing.iconSm,
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Please return this item to CDRRMO office by the expected return date.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut)
        .fadeIn(duration: const Duration(milliseconds: 200));
  }

  Widget _buildStatusChip(LoanStatus status, bool isOverdue) {
    if (isOverdue) {
      return AppStatusChip.error('OVERDUE', icon: Icons.warning_rounded);
    }
    
    switch (status) {
      case LoanStatus.active:
        return AppStatusChip.warning('ACTIVE', icon: Icons.schedule_rounded);
      case LoanStatus.returned:
        return AppStatusChip.success('RETURNED', icon: Icons.check_circle_rounded);
      case LoanStatus.overdue:
        return AppStatusChip.error('OVERDUE', icon: Icons.warning_rounded);
      case LoanStatus.cancelled:
        return AppStatusChip.info('CANCELLED', icon: Icons.cancel_rounded);
    }
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.neutralGray900,
          ),
        ),
        const Gap(AppSpacing.sm),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizing.iconSm,
            color: AppTheme.neutralGray600,
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.neutralGray700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.neutralGray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _callBorrower(String phoneNumber) {
    // TODO: Implement phone call functionality
    // This would typically use url_launcher to make a phone call
  }
}