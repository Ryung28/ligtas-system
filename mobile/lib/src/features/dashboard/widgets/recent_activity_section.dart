import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:mobile/src/core/design_system/widgets/shimmer_skeleton.dart';
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart';
import 'package:mobile/src/features_v2/loans/presentation/widgets/loan_details_sheet.dart';

class RecentActivitySection extends ConsumerWidget {
  final List<LoanModel>? loans; 
  final bool isLoading;

  const RecentActivitySection({
    super.key, 
    this.loans,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) return const _LoadingActivityState();
    if (loans == null || loans!.isEmpty) return const _EmptyActivityState();

    final theme = Theme.of(context);
    final sentinel = theme.sentinel;
    final displayLoans = loans!.take(3).toList(); // Capped to 3 for Dashboard Density

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: sentinel.navy,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              // 🛡️ SEE ALL NAVIGATION (Tactical Link)
              GestureDetector(
                onTap: () => context.push('/history'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sentinel.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SEE ALL',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w900,
                      color: sentinel.navy,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
        const Gap(20),

        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayLoans.length,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: ActivityPixelCard(
                item: displayLoans[index],
                delay: 400 + (index * 50),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 🛡️ SLIVER VERSION: Full virtualization for 120Hz consistency.
class SliverRecentActivitySection extends ConsumerWidget {
  final List<LoanModel>? loans;
  final bool isLoading;
  final int? maxItems; // 🛡️ CONFIGURABLE DENSITY

  const SliverRecentActivitySection({
    super.key,
    this.loans,
    this.isLoading = false,
    this.maxItems = 3, // Default to 3 for Dashboard
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const SliverToBoxAdapter(child: _LoadingActivityState());
    }
    if (loans == null || loans!.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyActivityState());
    }

    final theme = Theme.of(context);
    final sentinel = theme.sentinel;
    final displayLoans = loans!.take(3).toList(); // Capped to 3 for Dashboard Density

    return SliverMainAxisGroup(
      slivers: [
        // Title Header with SEE ALL Link
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: sentinel.navy,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                // 🛡️ SEE ALL NAVIGATION (Tactical Link)
                GestureDetector(
                  onTap: () => context.push('/history'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sentinel.navy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SEE ALL',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w900,
                        color: sentinel.navy,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ),

        // Virtualized List Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.builder(
            itemCount: displayLoans.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: ActivityPixelCard(
                  item: displayLoans[index],
                  delay: 400, // Static delay for virtualization stability
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ActivityPixelCard extends ConsumerWidget {
  final LoanModel item;
  final int delay;

  const ActivityPixelCard({super.key, required this.item, required this.delay});

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

  // 🛡️ REFINED SIGNALING: Tactical Black for most, Red for Crisis
  Color _getStatusColor(LoanStatus status, int overdueDays, LigtasColors sentinel) {
    if (overdueDays > 0) return const Color(0xFFEF4444); // Red-500
    if (status == LoanStatus.returned) return const Color(0xFF10B981); // Emerald-500
    return sentinel.navy; // 🛡️ ASSET STANDARD: High-contrast Navy/Black
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
    
    // Formatting: "APR 08, 14:30"
    final String timeLabel = DateFormat('MMM dd, HH:mm').format(item.borrowDate).toUpperCase();

    // 🛡️ CONVERGENCE: Map LoanModel to V2 LoanItem for Detail Sheet Reuse
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        showModalBottomSheet(
          context: context,
          useRootNavigator: true, 
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => LoanDetailsSheet(loan: loanItem, readOnly: true),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: sentinel.tactile.card, // 🛡️ V2 DEPTH STANDARD
        ),
        child: Row(
          children: [
            // 🛡️ HERO ASSET THUMBNAIL (Cached Network Image with Hero)
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
                tag: 'activity_img_${item.id}',
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

            // 📝 CLEAN CONTENT BLOCK: Aligned with My Items typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: sentinel.navy,
                      fontSize: 13, // 🛡️ ASSET STANDARD: Aligned with InventoryCard
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            // 🕒 TEMPORAL ANCHOR & STATUS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
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
                const Gap(6),
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
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms).slideY(begin: 0.1, end: 0);
  }
}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 48, color: AppTheme.neutralGray200),
          const Gap(16),
          Text(
            'NO RECENT LOGS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.neutralGray400,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingActivityState extends StatelessWidget {
  const _LoadingActivityState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const ShimmerSkeleton(width: 160, height: 28),
        ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: List.generate(3, (index) => const ShimmerCard()),
          ),
        ),
      ],
    );
  }
}
