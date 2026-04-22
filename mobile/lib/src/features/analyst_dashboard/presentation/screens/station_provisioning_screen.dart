import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import '../controllers/analyst_dashboard_controller.dart';
import '../../domain/entities/station_manifest.dart';
import '../../../fast_dispatch/providers/dispatch_controller.dart';

class StationProvisioningScreen extends ConsumerStatefulWidget {
  final String stationId;
  final String stationName;

  const StationProvisioningScreen({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  ConsumerState<StationProvisioningScreen> createState() => _StationProvisioningScreenState();
}

class _StationProvisioningScreenState extends ConsumerState<StationProvisioningScreen> {
  static const Color stitchNavy = Color(0xFF0F172A);
  static const Color stitchSurface = Color(0xFFF8FAFC);
  static const Color stitchBorder = Color(0xFFE2E8F0);
  
  String _searchQuery = '';
  String _activeFilter = 'All';
  static const List<String> _knownCategories = ['Medical', 'Rescue', 'Tools'];

  @override
  void initState() {
    super.initState();
    // Reuse Hero V2 dock-suppression pattern while this screen is active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(isDockSuppressedProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    ref.read(isDockSuppressedProvider.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manifestAsync = ref.watch(stationManifestProvider(stationId: widget.stationId));

    return Scaffold(
      backgroundColor: stitchSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: stitchNavy, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('STATION EQUIPMENT', 
              style: GoogleFonts.lexend(color: const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const Gap(2),
            Text(widget.stationName.toUpperCase(), 
              style: GoogleFonts.lexend(color: stitchNavy, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchHeader(),
        ),
      ),
      body: manifestAsync.when(
        data: (items) {
          final availableFilters = _buildCategoryFilters(items);
          if (!availableFilters.contains(_activeFilter)) {
            _activeFilter = 'All';
          }
          final filteredItems = _applyFilters(items);
          final summary = items.fold<Map<String, int>>(
            {'current': 0, 'target': 0},
            (val, item) {
              // 🛡️ HONESTY: Only count up to what is required. Extras don't fill gaps of other items.
              final effectiveStock = item.currentStock.clamp(0, item.quantityRequired);
              return {
                'current': val['current']! + effectiveStock,
                'target': val['target']! + item.quantityRequired,
              };
            },
          );

          return Column(
            children: [
              _buildCompactStockOverview(summary),
              _buildFilterChips(availableFilters),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) => _buildItemCard(filteredItems[index]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: stitchNavy)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.plusJakartaSans(color: Colors.red))),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
            icon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStockOverview(Map<String, int> summary) {
    final current = summary['current']!;
    final target = summary['target']!;
    // 🛡️ TACTICAL CLAMP: Readiness cannot exceed 100% even if overstocked
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    // 🎨 REACTIVE COLORS: Intelligence for the manager
    final Color barColor = progress > 0.8 
        ? const Color(0xFF10B981) // Green
        : progress > 0.2 
            ? Colors.orangeAccent 
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stitchNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: stitchNavy.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('STATION READINESS', style: GoogleFonts.lexend(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                   const Gap(2),
                   Text('${(progress * 100).toInt()}% READY', style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('STOCK LEVEL', style: GoogleFonts.lexend(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const Gap(2),
                  Text('$current / $target', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100), // Rounded for modern feel
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10, // 📏 THICKER: Visual priority
              backgroundColor: Colors.white.withOpacity(0.1),
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<String> filters) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((f) {
            final isSelected = _activeFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? stitchNavy : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? stitchNavy : stitchBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForCategoryFilter(f),
                      size: 12,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const Gap(6),
                    Text(
                      f,
                      style: GoogleFonts.lexend(
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemCard(StationManifestItem item) {
    final healthRatio = item.quantityRequired > 0 ? (item.currentStock / item.quantityRequired) : 0.0;
    
    // 🎨 TACTICAL TRIAGE COLORS: 
    // Green > 80% (Safe)
    // Orange 20-80% (Moderate/Warning)
    // Red < 20% (Critical)
    final Color healthColor = healthRatio < 0.2 
        ? Colors.redAccent 
        : (healthRatio < 0.8 ? Colors.orangeAccent : const Color(0xFF10B981));
    
    return InkWell(
      onTap: () {
        // 🚀 ONE-TAP DISPATCH: Pre-load item into single-voucher and move to Dispatch Hub
        ref.read(fastDispatchControllerProvider.notifier).selectItem(
          item.inventoryId, 
          item.itemName,
          imageUrl: item.imageUrl,
        );
        context.push('/manager/dispatch');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stitchBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TacticalAssetImage(
                  path: item.imageUrl,
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName.toUpperCase(), 
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: stitchNavy),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Gap(2),
                  Row(
                    children: [
                      Icon(
                        _iconForCategory(item.itemCategory),
                        size: 12,
                        color: const Color(0xFF64748B),
                      ),
                      const Gap(4),
                      Text(
                        _normalizeCategory(item.itemCategory),
                        style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text('${item.currentStock} AVAILABLE / ${item.quantityRequired} TOTAL', 
                    style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w700, color: healthColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  List<StationManifestItem> _applyFilters(List<StationManifestItem> items) {
    var filtered = items.where((item) => item.itemName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (_activeFilter != 'All') {
      filtered = filtered
          .where((item) => _normalizeCategory(item.itemCategory) == _activeFilter)
          .toList();
    }
    return filtered;
  }

  List<String> _buildCategoryFilters(List<StationManifestItem> items) {
    final present = items
        .map((item) => _normalizeCategory(item.itemCategory))
        .where((category) => _knownCategories.contains(category))
        .toSet()
        .toList()
      ..sort((a, b) => _knownCategories.indexOf(a).compareTo(_knownCategories.indexOf(b)));
    return ['All', ...present];
  }

  String _normalizeCategory(String? rawCategory) {
    final c = (rawCategory ?? '').toLowerCase();
    if (c.contains('med')) return 'Medical';
    if (c.contains('rescue')) return 'Rescue';
    if (c.contains('tool') || c.contains('utility')) return 'Tools';
    return 'Tools';
  }

  IconData _iconForCategory(String? rawCategory) {
    switch (_normalizeCategory(rawCategory)) {
      case 'Medical':
        return Icons.medical_services_rounded;
      case 'Rescue':
        return Icons.shield_rounded;
      case 'Tools':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  IconData _iconForCategoryFilter(String filter) {
    switch (filter) {
      case 'All':
        return Icons.grid_view_rounded;
      case 'Medical':
        return Icons.medical_services_rounded;
      case 'Rescue':
        return Icons.shield_rounded;
      case 'Tools':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
