import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart' show LoanItem, LoanStatus;
import 'package:mobile/src/features_v2/loans/presentation/widgets/loan_details_sheet.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LoanHistoryScreen extends ConsumerStatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  ConsumerState<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends ConsumerState<LoanHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentinel = theme.sentinel;
    final groupedLoans = ref.watch(groupedLoanHistoryProvider);
    final loansAsync = ref.watch(freshDashboardLoansProvider);
    final sortBy = ref.watch(loanHistorySortProvider);
    final currentFilter = ref.watch(loanHistoryFilterProvider);

    return Scaffold(
      backgroundColor: sentinel.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🛡️ TACTICAL HEADER
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: sentinel.surface.withOpacity(0.9),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: sentinel.navy, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'TRANSACTION HISTORY',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w900,
                  color: sentinel.navy,
                  letterSpacing: 2.0,
                  fontSize: 14,
                ),
              ),
              centerTitle: true,
            ),

            // 🔍 SKEUOMORPHIC SEARCH & FILTER SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // 🛡️ MAX DENSITY MARGINS
                child: Column(
                  children: [
                    Row(
                      children: [
                        // ── Recessed Search Input ──
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: sentinel.containerLow,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: sentinel.tactile.recessed,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => ref.read(loanHistorySearchProvider.notifier).state = val,
                              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy),
                              decoration: InputDecoration(
                                hintText: 'Search logs...',
                                hintStyle: GoogleFonts.lexend(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13),
                                prefixIcon: Icon(Icons.search_rounded, color: sentinel.onSurfaceVariant.withOpacity(0.5), size: 22),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        // ── Raised Sort Pill ──
                        _buildSortPill(sortBy, sentinel),
                      ],
                    ),
                    const Gap(16),
                    // ── TACTICAL FILTER BAR ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', currentFilter, sentinel),
                          const Gap(8),
                          _buildFilterChip('ACTIVE', currentFilter, sentinel),
                          const Gap(8),
                          _buildFilterChip('RETURNED', currentFilter, sentinel),
                          const Gap(8),
                          _buildFilterChip('OVERDUE', currentFilter, sentinel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverGap(16),

            // 🧾 UNIFIED LEDGER SHEET (THE SLAB)
            ...loansAsync.when(
              data: (loans) {
                if (groupedLoans.isEmpty) {
                  return [
                    const SliverFillRemaining(
                      child: Center(child: Text('NO HISTORY FOUND')),
                    )
                  ];
                }

                final List<Widget> slivers = [];

                for (var entry in groupedLoans.entries) {
                  // RENDER DATE HEADER
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          entry.key,
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: sentinel.navy.withOpacity(0.4),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );

                  // RENDER LEDGER SLAB
                  slivers.add(
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: sentinel.tactile.card,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: List.generate(entry.value.length, (index) {
                              final item = entry.value[index];
                              final bool isLast = index == entry.value.length - 1;

                              return Column(
                                children: [
                                  _LedgerRow(item: item),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      indent: 16,
                                      endIndent: 16,
                                      color: sentinel.navy.withOpacity(0.05),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return slivers;
              },
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
              error: (err, _) => [
                SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ],
            ),

            const SliverGap(120),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String current, SentinelColors sentinel) {
    final bool isSelected = label == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(loanHistoryFilterProvider.notifier).state = label;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? sentinel.containerLow : sentinel.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? sentinel.tactile.recessed : null,
          border: isSelected ? null : Border.all(color: sentinel.navy.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? sentinel.navy : sentinel.navy.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSortPill(String sortBy, SentinelColors sentinel) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        HapticFeedback.lightImpact();
        ref.read(loanHistorySortProvider.notifier).state = val;
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'newest', child: Text('Newest First')),
        const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
        const PopupMenuItem(value: 'alphabetical', child: Text('Alphabetical')),
      ],
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: sentinel.containerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: sentinel.tactile.raised,
        ),
        child: Row(
          children: [
            Text(
              sortBy == 'newest' ? 'NEW' : sortBy.toUpperCase().substring(0, 3),
              style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: sentinel.navy),
            ),
            const Gap(4),
            Icon(Icons.unfold_more_rounded, size: 18, color: sentinel.navy),
          ],
        ),
      ),
    );
  }
}

/// 🛡️ HYBRID LEDGER ROW: Unified list structure with exact Dashboard card interior.
class _LedgerRow extends ConsumerWidget {
  final LoanModel item;

  const _LedgerRow({required this.item});

  String _getStatusText(LoanStatus status, int overdueDays) {
    if (overdueDays > 0) return 'OVERDUE';
    switch (status) {
      case LoanStatus.active: return 'ACTIVE';
      case LoanStatus.returned: return 'COMPLETED';
      case LoanStatus.pending: return 'PENDING';
      case LoanStatus.overdue: return 'OVERDUE';
      case LoanStatus.staged: return 'STAGED';
      default: return 'ACTIVE';
    }
  }

  Color _getStatusColor(LoanStatus status, int overdueDays, LigtasColors sentinel) {
    if (overdueDays > 0) return const Color(0xFFEF4444); // Red-500
    if (status == LoanStatus.returned) return const Color(0xFF10B981); // Emerald-500
    return sentinel.navy;
  }

  IconData _getIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('kit') || n.contains('medical')) return Icons.medical_services_rounded;
    if (n.contains('flashlight') || n.contains('light')) return Icons.flashlight_on_rounded;
    if (n.contains('radio')) return Icons.sensors_rounded;
    return Icons.inventory_2_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sentinel = theme.sentinel;
    final statusColor = _getStatusColor(item.status, item.daysOverdue, sentinel);
    final statusText = _getStatusText(item.status, item.daysOverdue);
    final bool isCrisis = item.daysOverdue > 0 || item.status == LoanStatus.returned;
    
    // Formatting matching dashboard: "MMM dd, HH:mm"
    final String timeLabel = DateFormat('MMM dd, HH:mm').format(item.borrowDate).toUpperCase();

    // Mapping for details sheet
    final loanItem = LoanItem(
      id: item.id,
      inventoryItemId: item.inventoryItemId,
      itemName: item.itemName,
      itemCode: item.itemCode,
      borrowerName: item.borrowerName,
      borrowerContact: item.borrowerContact,
      purpose: item.purpose,
      quantityBorrowed: item.quantityBorrowed,
      borrowDate: item.borrowDate,
      expectedReturnDate: item.expectedReturnDate,
      actualReturnDate: item.actualReturnDate,
      status: item.status,
      borrowedBy: item.borrowedBy,
      imageUrl: item.imageUrl,
      handedBy: item.handedBy,
      handedAt: item.handedAt,
      approvedBy: item.approvedBy,
      approvedAt: item.approvedAt,
    );

    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => LoanDetailsSheet(loan: loanItem, readOnly: true),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            // 🛡️ LOGO (Identical to Dashboard ActivityPixelCard)
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: sentinel.containerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.05)),
              ),
              child: Hero(
                tag: 'ledger_img_${item.id}',
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: sentinel.containerLow),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(_getIcon(item.itemName), color: sentinel.onSurfaceVariant.withOpacity(0.3), size: 24),
                      ),
                    )
                  : Center(
                      child: Icon(_getIcon(item.itemName), color: sentinel.onSurfaceVariant.withOpacity(0.3), size: 24),
                    ),
              ),
            ),
            const Gap(16),

            // 📝 CONTENT BLOCK (Typography Hierarchy)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: sentinel.navy,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'QUANTITY: ${item.quantityBorrowed}',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: sentinel.navy.withOpacity(0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // 🕒 TEMPORAL & STATUS (Identical to Dashboard ActivityPixelCard)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: GoogleFonts.lexend(
                    color: sentinel.navy.withOpacity(0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCrisis ? statusColor.withOpacity(0.1) : sentinel.containerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.lexend(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
