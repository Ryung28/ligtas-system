import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobile/src/features/dashboard/widgets/bento_tiles.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobile/src/features/loans/providers/loan_providers.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart' hide LoanStatus;
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart' show LoanStatus;
import 'package:mobile/src/core/design_system/widgets/shimmer_skeleton.dart';

/// Small horizontal ribbon for equipment categories - iOS Glass Style
class EquipmentRibbon extends ConsumerWidget {
  const EquipmentRibbon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryStatsProvider);
    final hasEntered = ref.watch(dashboardEntryProvider);

    if (categoriesAsync.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary( // 🛡️ RASTER CACHE: Isolate category scrolling
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: categoriesAsync.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final cat = categoriesAsync[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100), // Pill shape
                border: Border.all(
                  color: const Color(0xFF001A33).withOpacity(0.12), // Tactical stroke
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat['icon'] as IconData, size: 14, color: const Color(0xFF43474D)),
                  const Gap(8),
                  Text(
                    (cat['name'] as String).toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1F),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001A33).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cat['count'].toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF001A33),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: hasEntered ? 0.ms : 400.ms, delay: hasEntered ? 0.ms : (index * 50).ms).slideX(begin: 0.1, end: 0);
          },
        ),
      ),
    );
  }
}

/// Compact grid for system health and telemetry - iOS Glass Style
class SystemTelemetryGrid extends ConsumerWidget {
  const SystemTelemetryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(inventorySummaryProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final hasEntered = ref.watch(dashboardEntryProvider);
    final stats = statsAsync.valueOrNull;
    final isLoading = statsAsync.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'MISSION INTELLIGENCE',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF43474D), // onSurfaceVariant
              letterSpacing: 1.5,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5, // Refactored for better vertical density
          children: isLoading 
            ? List.generate(4, (index) => const ShimmerTile())
            : [
                BentoStatTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'TOTAL',
                  value: '${summary['total_assets'] ?? 0}',
                  color: const Color(0xFF001A33), // stitchNavy
                  animationDelay: hasEntered ? 0 : 300,
                ),
                BentoStatTile(
                  icon: Icons.history_rounded,
                  label: 'OVERDUE',
                  value: '${stats?.overdueLoans ?? 0}',
                  color: const Color(0xFFBA1A1A), // stitchError
                  animationDelay: hasEntered ? 0 : 400,
                ),
                BentoStatTile(
                  icon: Icons.sync_alt_rounded,
                  label: 'BORROWED',
                  value: '${stats?.activeLoans ?? 0}',
                  color: const Color(0xFF43474D), // stitchOnSurfaceVariant
                  animationDelay: hasEntered ? 0 : 500,
                ),
                BentoStatTile(
                  icon: Icons.check_circle_rounded,
                  label: 'RETURNED',
                  value: '${stats?.totalReturnedItems ?? 0}',
                  color: const Color(0xFF575F6B), // secondary
                  animationDelay: hasEntered ? 0 : 600,
                ),
              ],
        ),
      ],
    );
  }
}

class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12), // 🛡️ ADAPTIVE PADDING: Prevent grid-clamping overflows
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // 🛡️ CENTER-ALIGNED: More resilient
          children: [
            ShimmerSkeleton(width: 24, height: 24, borderRadius: 8),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerSkeleton(width: 50, height: 10),
                SizedBox(height: 4),
                ShimmerSkeleton(width: 32, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Live Operation Feed for Team Activity
/// 🛡️ Virtualized for 120Hz performance on dashboard return.
class SliverOperationFeedSection extends ConsumerWidget {
  const SliverOperationFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segments = ref.watch(operationLogSegmentsProvider);
    final pendingLoans = segments['pending'] as List<LoanModel>;
    final activeLoans = segments['active'] as List<LoanModel>;
    final pendingCount = segments['all_pending_count'] as int;
    final activeCount = segments['all_active_count'] as int;

    if (pendingLoans.isEmpty && activeLoans.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        // Title Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OPERATION LOGS',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF43474D), // onSurfaceVariant
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('EXPLORE', 
                    style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF324863))),
                ),
              ],
            ),
          ),
        ),

        // 🛡️ PENDING SECTION (Virtualized)
        if (pendingLoans.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSectionHeader('PENDING', const Color(0xFF8B5CF6), Icons.hourglass_empty_rounded, pendingCount),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.builder(
              itemCount: pendingLoans.length,
              itemBuilder: (context, index) => RepaintBoundary(
                child: _OperationLogCard(loan: pendingLoans[index], statusColor: const Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SliverGap(16),
        ],

        // 🛡️ ACTIVE SECTION (Virtualized)
        if (activeLoans.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSectionHeader('ACTIVE', const Color(0xFF10B981), Icons.outbound_rounded, activeCount),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.builder(
              itemCount: activeLoans.length,
              itemBuilder: (context, index) {
                final loan = activeLoans[index];
                final isOverdue = loan.daysOverdue > 0;
                return RepaintBoundary(
                  child: _OperationLogCard(
                    loan: loan, 
                    statusColor: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const Gap(8),
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationLogCard extends ConsumerStatefulWidget {
  final LoanModel loan;
  final Color statusColor;

  const _OperationLogCard({required this.loan, required this.statusColor});

  @override
  ConsumerState<_OperationLogCard> createState() => _OperationLogCardState();
}

class _OperationLogCardState extends ConsumerState<_OperationLogCard> {
  bool _isAnimating = true;

  @override
  Widget build(BuildContext context) {
    final hasEntered = ref.watch(dashboardEntryProvider);
    final isPending = widget.loan.status == LoanStatus.pending;
    final isOverdue = widget.loan.daysOverdue > 0;
    
    // 🛡️ GOLD STANDARD: Prune Neumorphic depth during motion
    final depth = (hasEntered || !_isAnimating) ? 4.0 : 0.0;

    String actionText;
    if (isPending) {
      actionText = 'pending approval';
    } else if (isOverdue) {
      actionText = 'overdue';
    } else {
      actionText = 'borrowed';
    }

    return Neumorphic(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(24)),
        depth: depth,
        intensity: 0.8,
        color: Theme.of(context).sentinel.surface,
        lightSource: LightSource.topLeft,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending ? Icons.hourglass_empty_rounded : 
              isOverdue ? Icons.warning_rounded : Icons.check_circle_rounded,
              size: 18, 
              color: widget.statusColor,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.loan.itemName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, 
                    fontWeight: FontWeight.w800, 
                    color: const Color(0xFF191C1F), // onSurface
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  actionText.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 9, 
                    fontWeight: FontWeight.w700, 
                    color: widget.statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeago.format(widget.loan.borrowDate),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF43474D), // onSurfaceVariant
            ),
          ),
        ],
      ),
    ).animate(
      onComplete: (_) {
        if (mounted && !hasEntered) {
          setState(() => _isAnimating = false);
        }
      },
    ).fadeIn(duration: hasEntered ? 0.ms : 400.ms);
  }
}
