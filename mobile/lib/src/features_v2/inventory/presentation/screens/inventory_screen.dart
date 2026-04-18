import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/app_spacing.dart';
import 'package:mobile/src/features/dashboard/widgets/dashboard_background.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/core/design_system/widgets/ligtas_error_state.dart';
import 'package:mobile/src/core/design_system/widgets/shimmer_skeleton.dart';
import 'package:mobile/src/core/di/app_providers.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import '../providers/inventory_provider.dart';
import '../providers/mission_cart_provider.dart';
import '../widgets/inventory_card.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/glass_filter_chip.dart';
import '../widgets/manager_action_sheet_v2/manager_action_sheet_v2.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_image_viewer.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final String? initialItemId;
  final String? triageItemId;
  const InventoryScreen({super.key, this.initialItemId, this.triageItemId});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _triageExecuted = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    // 🛡️ SENIOR AUTO-FOCUS: If an ID was passed via search query param, update search state
    if (widget.initialItemId != null) {
      _searchController.text = widget.initialItemId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCategoryProvider.notifier).update('All');
        ref.read(inventorySearchQueryProvider.notifier).update(widget.initialItemId!);
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final currentOffset = _scrollController.position.pixels;
    final extent = _scrollController.position.maxScrollExtent;
    if (currentOffset >= extent * 0.8) {
      ref.read(inventoryNotifierProvider.notifier).loadMore();
    }
  }

  void _triggerAtomicTriage(List<InventoryItem> items) {
    if (_triageExecuted || widget.triageItemId == null) return;

    final targetId = int.tryParse(widget.triageItemId!);
    final match = items.where((item) => item.id == targetId).firstOrNull;
    
    if (match != null) {
      _triageExecuted = true;
      Future.microtask(() {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          useRootNavigator: true, 
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ManagerActionSheetV2(item: match),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemsAsync = ref.watch(inventoryNotifierProvider);
    final filteredItems = ref.watch(filteredInventoryProvider);
    
    // 🛡️ SENIOR TRIAGE OBSERVER: Wait for real data to arrive and auto-open triage sheet
    ref.listen(inventoryNotifierProvider, (previous, next) {
      next.whenData((items) => _triggerAtomicTriage(items));
    });
    
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(inventorySearchQueryProvider);
    final user = ref.watch(currentUserProvider);
    final isManager = user?.canEdit ?? false;
    final sentinel = Theme.of(context).sentinel;

    return Scaffold(
      backgroundColor: sentinel.surface,
      body: Stack(
        children: [
          const DashboardBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(inventoryNotifierProvider.notifier).refresh();
                if (context.mounted) {
                  AppToast.showSuccess(context, 'Inventory records up to date');
                }
              },
              displacement: 100,
              color: AppTheme.primaryBlue,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                cacheExtent: 1000, 
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        isManager ? 'Shelves' : 'Inventory',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          color: sentinel.navy,
                          letterSpacing: -0.8,
                        ),
                      ).animate()
                       .fadeIn(duration: 450.ms)
                       .slideX(begin: -0.15, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                    ),
                  ),

                  // ── TACTILE HEADER ──
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 2), 
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: sentinel.containerLow,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: sentinel.tactile.recessed,
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) => ref.read(inventorySearchQueryProvider.notifier).update(val),
                                    style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: sentinel.navy),
                                    decoration: InputDecoration(
                                      hintText: 'Search SKU, Area...',
                                      hintStyle: GoogleFonts.lexend(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13),
                                      prefixIcon: Icon(Icons.search_rounded, color: sentinel.onSurfaceVariant.withOpacity(0.5), size: 20),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(12),
                              _buildSortPill(),
                            ],
                          ),
                          const Gap(4),
                          _buildTabSection(selectedCategory),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final totalAsync = ref.watch(totalInventoryCountProvider);
                            final count = totalAsync.maybeWhen(data: (c) => c.toString(), orElse: () => '...');
                            return Text(
                              '$count ITEMS IN LOGISTICS VIEW',
                              style: GoogleFonts.lexend(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: sentinel.onSurfaceVariant.withOpacity(0.4),
                                letterSpacing: 1.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 🛡️ REPLICA RESOLVER: Reactive Equipment Hub
                  filteredItems.when(
                    data: (items) {
                      if (items.isNotEmpty) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.58,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = items[index];
                                return RepaintBoundary(
                                  child: InventoryCard(
                                    key: ValueKey('inv_card_${item.id}'),
                                    item: item,
                                    index: index,
                                    isManager: isManager,
                                    onBorrow: () {
                                      if (item.availableStock > 0) {
                                        HapticFeedback.mediumImpact();
                                        ref.read(missionCartNotifierProvider.notifier).addItem(item);
                                      } else {
                                        HapticFeedback.vibrate();
                                        // 🛡️ SILENT LOCKOUT: Vibration is enough to signify reserved/out-of-stock
                                      }
                                    },
                                    onImageTap: () {
                                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
                                        TacticalImageViewer.show(
                                          context,
                                          url: item.imageUrl!,
                                          title: item.name,
                                          heroTag: 'inv_img_${item.id}',
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              childCount: items.length,
                            ),
                          ),
                        );
                      } else {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context, searchQuery),
                        );
                      }
                    },
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.58, // 🛡️ Headroom for Safe-Zone
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ShimmerSkeleton(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 16,
                          ),
                          childCount: 6,
                        ),
                      ),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: _buildWarehouseErrorState(context, err),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isManager) _buildFloatingMissionDock(context, ref, sentinel),
        ],
      ),
    );
  }

  Widget _buildFloatingMissionDock(BuildContext context, WidgetRef ref, SentinelColors sentinel) {
    final cart = ref.watch(missionCartNotifierProvider);
    final cartNotifier = ref.read(missionCartNotifierProvider.notifier);
    final totalItems = cartNotifier.totalItems;

    return AnimatedPositioned(
      duration: 350.ms,
      curve: Curves.easeOutCubic,
      bottom: cart.isNotEmpty ? 110 : -130, // 🛡️ COMPONENT STACKING: Floats above 64px Nav Dock
      right: 20,
      left: 20, // 🛡️ FULL WIDTH PILL FOR BETTER REACH
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          _showCartBottomSheet(context, ref, sentinel);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: sentinel.navy.withOpacity(0.95), // 🛡️ OBSIDIAN BASE
            borderRadius: BorderRadius.circular(50), // 🛡️ PILL SHAPE
            boxShadow: [
              sentinel.tactile.raised[0],
              BoxShadow(
                color: sentinel.primary.withOpacity(0.3), // 🛡️ MISSION GLOW
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: sentinel.primary.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔋 STATUS SIGNAL
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: sentinel.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: sentinel.primary, blurRadius: 4),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(color: sentinel.primary.withOpacity(0.4), duration: 2.seconds),
              
              const Gap(12),
              
              Flexible( // 🛡️ FLEXIBLE CONTAINER: Prevents horizontal overflow on narrow devices
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totalItems.toString().padLeft(2, '0')} ITEMS READY', 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'REVIEW & CHECKOUT ➡️', 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Gap(12),   
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
    );
  }

  void _showCartBottomSheet(BuildContext context, WidgetRef ref, SentinelColors sentinel) {
    final cart = ref.read(missionCartNotifierProvider);
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // 🛡️ STEEL CAGE: Forces overlay on top of Shell (Bottom Nav)
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: sentinel.surface.withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
        ),
        child: Column(
          children: [
            // 🪙 GRAB HANDLE
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: sentinel.navy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(32),

            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BORROW REQUEST', 
                      style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w900, color: sentinel.navy, letterSpacing: -0.5),
                    ),
                    Text(
                      'VERIFY ITEMS BEFORE PROCEEDING', 
                      style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: sentinel.onSurfaceVariant.withOpacity(0.5), letterSpacing: 1.0),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () {
                    ref.read(missionCartNotifierProvider.notifier).clearCart();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            
            const Gap(24),
            
            Expanded(
              child: ListView.separated(
                itemCount: cart.length,
                separatorBuilder: (context, index) => Divider(color: sentinel.navy.withOpacity(0.05)),
                itemBuilder: (context, index) {
                  final item = cart.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: sentinel.containerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (item.item.imageUrl ?? '').isNotEmpty 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(item.item.imageUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.inventory_2_outlined),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.item.name.toUpperCase(), style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w800, color: sentinel.navy)),
                              Text(item.item.category.toUpperCase(), style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w700, color: sentinel.onSurfaceVariant.withOpacity(0.4))),
                            ],
                          ),
                        ),
                        Text('x${item.quantity}', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: sentinel.navy)),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Gap(24),

            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate();
                Navigator.pop(context);
                context.push('/inventory/request', extra: cart.values.toList());
              },
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: sentinel.navy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: sentinel.navy.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      const Gap(12),
                      Flexible(
                        child: Text(
                          'SUBMIT BORROW REQUEST', 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(String selectedCategory) {
    final sentinel = Theme.of(context).sentinel;
    final tabs = ref.watch(inventoryCategoriesProvider);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none, // 🛡️ SHADOW BREATHING: Prevents clipping lines
        padding: const EdgeInsets.symmetric(vertical: 12), // 🛡️ HEADROOM: Space for shadows
        child: RepaintBoundary(
          child: Row(
            children: tabs.map((tab) {
              final isSelected = selectedCategory == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(selectedCategoryProvider.notifier).update(tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : sentinel.containerLow, // 🛡️ CONSISTENCY: Matches Search Bar
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? sentinel.tactile.active : sentinel.tactile.recessed, // 🛡️ TACTILE: Restored Neumorphism
                    ),
                    child: Text(
                      tab.toUpperCase(), 
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? sentinel.navy : sentinel.navy.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSortPill() {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      height: 52, width: 52,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: sentinel.tactile.raised),
      child: const Icon(Icons.tune_rounded, size: 20),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    final sentinel = Theme.of(context).sentinel;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 64,
            color: sentinel.navy.withOpacity(0.1),
          ),
          const Gap(16),
          Text(
            isSearching 
                ? 'NO MATCHES FOUND' 
                : 'NO ${selectedCategory.toUpperCase()} EQUIPMENT',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: sentinel.navy.withOpacity(0.5),
            ),
          ),
          const Gap(8),
          Text(
            isSearching 
                ? 'Try a different keyword for "$searchQuery"'
                : 'Items in this category will appear here after sync.',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: sentinel.onSurfaceVariant.withOpacity(0.4),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildWarehouseErrorState(BuildContext context, Object? error) {
    final sentinel = Theme.of(context).sentinel;
    final errorMsg = error.toString();
    
    // Parse specific error types
    String title = 'Sync Error';
    String message = 'Unable to load inventory data.';
    IconData icon = Icons.cloud_off_rounded;
    
    if (errorMsg.contains('Authentication expired') || errorMsg.contains('JWT')) {
      title = 'SESSION EXPIRED';
      message = 'Your session has expired. Please log in again.';
      icon = Icons.lock_clock_rounded;
    } else if (errorMsg.contains('Access denied') || errorMsg.contains('policy')) {
      title = 'ACCESS DENIED';
      message = 'Your account is pending approval. Contact your administrator.';
      icon = Icons.shield_outlined;
    } else if (errorMsg.contains('Network error') || errorMsg.contains('connection')) {
      title = 'NETWORK ERROR';
      message = 'Check your internet connection and try again.';
      icon = Icons.wifi_off_rounded;
    } else if (errorMsg.contains('No warehouse assigned')) {
      title = 'NO WAREHOUSE ASSIGNED';
      message = 'Contact your administrator to assign you to a warehouse location.';
      icon = Icons.warehouse_outlined;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: sentinel.containerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: sentinel.onSurfaceVariant),
            ),
            const Gap(24),
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: sentinel.navy,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              message,
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: sentinel.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            GestureDetector(
              onTap: () => ref.read(inventoryNotifierProvider.notifier).refresh(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: sentinel.navy,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: sentinel.tactile.raised,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    const Gap(8),
                    Text(
                      'RETRY',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
