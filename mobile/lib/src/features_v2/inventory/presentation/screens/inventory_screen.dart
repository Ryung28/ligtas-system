import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/app_spacing.dart';
import 'package:mobile/src/core/design_system/widgets/atmospheric_background.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/core/design_system/widgets/ligtas_error_state.dart';
import 'package:mobile/src/core/di/app_providers.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_card.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/glass_filter_chip.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemsAsync = ref.watch(inventoryNotifierProvider);
    final filteredItems = ref.watch(filteredInventoryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(inventorySearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          AtmosphericBackground(),
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(inventoryNotifierProvider.notifier).refresh();
              if (context.mounted) {
                AppToast.showSuccess(context, 'Inventory records up to date');
              }
            },
            displacement: 100,
            color: AppTheme.primaryBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              cacheExtent: 600,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      context.l10n.inventoryTitle,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1.2,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                  ),
                ),

                SliverAppBar(
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 0,
                  collapsedHeight: 104,
                  expandedHeight: 104,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GlassSearchBar(
                            controller: _searchController,
                            onChanged: (val) => ref.read(inventorySearchQueryProvider.notifier).update(val),
                          ),
                        ),
                        const Gap(14),
                        _buildFilterSection(),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCategory == 'All' 
                                  ? "Equipment Inventory" 
                                  : "$selectedCategory Resources",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Gap(2),
                              Text(
                              "FIELD RESPONDER ACCESS",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue.withOpacity(0.7),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            "${filteredItems.length} TOTAL",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  ),
                ),

                inventoryItemsAsync.when(
                  data: (items) {
                    if (filteredItems.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(searchQuery),
                      );
                    }
                    
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InventoryCard(
                                key: ValueKey('inv_card_v2_${item.id}'),
                                item: item,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: ((index % 6) * 40).ms)
                                  .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                            );
                          },
                          childCount: filteredItems.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: LigtasErrorState(
                      title: 'Sync Interrupted',
                      message: 'V2 Data link could not reach Supabase.',
                      onRetry: () => ref.read(inventoryNotifierProvider.notifier).refresh(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final categories = ref.watch(inventoryCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none, // 🛡️ Step 1.3: Shadow Preservation
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // 🛡️ Step 2: Edge-to-Edge Scroll
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GlassFilterChip(
                label: category,
                isSelected: isSelected,
                onTap: () => ref.read(selectedCategoryProvider.notifier).update(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.primaryBlue.withOpacity(0.2)),
          const Gap(20),
          Text(
            searchQuery.isNotEmpty 
                ? context.l10n.noInventoryFound 
                : context.l10n.noInventoryAvailable,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          const Text(
            'Try adjusting your search criteria.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
