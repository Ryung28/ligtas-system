import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_theme.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../_components/anomaly_action_hero.dart';
import '../providers/alert_queue_providers.dart';
import '../widgets/alert_queue_empty_state.dart';
import '../widgets/alert_tactile_card.dart';
import '../../../../features/dashboard/widgets/dashboard_background.dart';

/// 📡 LIGTAS ALERTS TERMINAL
class LogisticalQueueScreen extends ConsumerStatefulWidget {
  const LogisticalQueueScreen({super.key});

  @override
  ConsumerState<LogisticalQueueScreen> createState() => _LogisticalQueueScreenState();
}

class _LogisticalQueueScreenState extends ConsumerState<LogisticalQueueScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(alertQueueSearchProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(alertQueueEntryCompleteProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openActionSheet(BuildContext context, ResourceAnomaly anomaly) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnomalyActionHero(anomaly: anomaly),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final activeFilter = ref.watch(alertQueueFilterProvider);
    final sortedAlerts = ref.watch(alertQueueSortedProvider);
    final sortNewestFirst = ref.watch(alertQueueSortNewestFirstProvider);
    final counts = ref.watch(alertQueueFilterCountsProvider);
    final entryComplete = ref.watch(alertQueueEntryCompleteProvider);

    const filters = ['All', 'Critical', 'Inventory', 'Logistics', 'Overdue', 'Access'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const DashboardBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alerts',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            color: sentinel.navy,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: sentinel.containerLow,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: sentinel.tactile.recessed,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => ref.read(alertQueueSearchProvider.notifier).state = val,
                              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: sentinel.navy),
                              decoration: InputDecoration(
                                hintText: 'Search items or SKU...',
                                hintStyle: GoogleFonts.lexend(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13),
                                prefixIcon: Icon(Icons.search_rounded, color: sentinel.onSurfaceVariant.withOpacity(0.5), size: 20),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Tooltip(
                          message: sortNewestFirst
                              ? 'Sorted newest → oldest. Tap to sort oldest → newest.'
                              : 'Sorted oldest → newest. Tap to sort newest → oldest.',
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref.read(alertQueueSortNewestFirstProvider.notifier).state = !sortNewestFirst;
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: sentinel.containerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: sentinel.tactile.recessed,
                                  border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.08)),
                                ),
                                child: Icon(
                                  sortNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  size: 22,
                                  color: sentinel.navy.withOpacity(0.85),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: filters.map((filter) {
                        final isActive = activeFilter == filter;
                        final count = counts[filter] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(alertQueueFilterProvider.notifier).state = filter;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : sentinel.containerLow,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isActive ? sentinel.tactile.active : sentinel.tactile.recessed,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filter.toUpperCase(),
                                    style: GoogleFonts.lexend(
                                      fontSize: 10,
                                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                      color: isActive ? sentinel.navy : sentinel.navy.withOpacity(0.4),
                                    ),
                                  ),
                                  if (count > 0) ...[
                                    const Gap(6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive ? sentinel.navy.withOpacity(0.1) : sentinel.navy.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        count.toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: isActive ? sentinel.navy : sentinel.navy.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SliverGap(8),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: sortedAlerts.isEmpty
                      ? const SliverToBoxAdapter(child: AlertQueueEmptyState())
                      : SliverList.builder(
                          itemCount: sortedAlerts.length,
                          itemBuilder: (context, index) {
                            final anomaly = sortedAlerts[index];
                            return AlertTactileCard(
                              key: ValueKey(anomaly.id),
                              anomaly: anomaly,
                              index: index,
                              sentinel: sentinel,
                              entryComplete: entryComplete,
                              onTap: () => _openActionSheet(context, anomaly),
                            );
                          },
                        ),
                ),
                const SliverGap(88),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
