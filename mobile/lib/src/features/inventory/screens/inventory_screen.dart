import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/atmospheric_background.dart';
import '../models/inventory_model.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_card.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/glass_filter_chip.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemsAsync = ref.watch(inventoryItemsProvider);
    
    final filteredItems = inventoryItemsAsync.when(
      data: (items) => _filterItems(items),
      loading: () => <InventoryModel>[],
      error: (_, __) => <InventoryModel>[],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Stack(
        children: [
          const AtmosphericBackground(),
          RefreshIndicator(
            onRefresh: () async {
              // Force a manual refresh of the repository
              await ref.read(inventoryRepositoryProvider).getAllItems();
              // Invalidate the provider to trigger a fresh watch
              ref.invalidate(inventoryItemsProvider);
              if (context.mounted) {
                _showTopNotification(context, 'Inventory records up to date');
              }
            },
            displacement: 100, // Move down so it doesn't overlap header
            color: AppTheme.primaryBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              cacheExtent: 600, // Pre-renders content off-screen for instant scrolling visibility
              slivers: [
              // ── Professional Header ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.l10n.inventoryTitle,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: Color(0xFF0F172A), // Slate 900
                      letterSpacing: -1.2,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                ),
              ),

              // ── Search & Filter Section (Sticky) ──
              SliverAppBar(
                pinned: false,
                floating: false,
                snap: false,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 0, // Senior Dev: Suppress default toolbar space to kill the gap
                collapsedHeight: 104,
                expandedHeight: 104,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassSearchBar(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        ),
                      ),
                      const Gap(14), // Added premium breathing room
                      _buildFilterSection(),
                    ],
                  ),
                ),
              ),

              // ── Sectional Header ──
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
                            _selectedCategory == context.l10n.categoryAll 
                                ? "Equipment Inventory" 
                                : "${_selectedCategory} Resources",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A), // Slate 900
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
                          color: const Color(0xFFF1F5F9), // Slate 100
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
                        ),
                        child: Text(
                          "${filteredItems.length} TOTAL",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF475569), // Slate 600
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                ),
              ),

              // ── Grid / List Content ──
              inventoryItemsAsync.when(
                data: (items) {
                  // Senior Dev Tech: Sanitize data to prevent Duplicate Key/Hero crashes
                  final uniqueItems = <String, InventoryModel>{};
                  for (var item in filteredItems) {
                    uniqueItems[item.id.toString()] = item;
                  }
                  final itemsList = uniqueItems.values.toList();

                  if (itemsList.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = itemsList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InventoryCard(
                              key: ValueKey('inv_card_${item.id}_$index'),
                              item: item,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: ((index % 6) * 40).ms)
                                .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                          );
                        },
                        childCount: itemsList.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
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
    final categories = [
      context.l10n.categoryAll,
      context.l10n.categoryRescue,
      context.l10n.categoryMedical,
      context.l10n.categoryComms,
      context.l10n.categoryVehicles,
      context.l10n.categoryTools,
      context.l10n.categoryPPE,
      context.l10n.categoryLogistics,
      context.l10n.categoryOffice,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none, // Senior dev tip: Prevents shadows from being cut off
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory.toLowerCase() == category.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassFilterChip(
              label: category,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedCategory = category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.primaryBlue.withOpacity(0.2)),
          const Gap(20),
          Text(
            _searchQuery.isNotEmpty 
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

  List<InventoryModel> _filterItems(List<InventoryModel> items) {
    return items.where((item) {
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == context.l10n.categoryAll ||
          item.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase();
          
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showTopNotification(BuildContext context, String message) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60, // Positioned below status bar area
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Emerald 500
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().slideY(begin: -1.5, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeOut(delay: 2500.ms, duration: 400.ms),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
