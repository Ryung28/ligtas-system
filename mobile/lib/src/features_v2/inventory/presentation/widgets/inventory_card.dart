import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/mission_cart_provider.dart';
import 'manager_action_sheet_v2/manager_action_sheet_v2.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'tactical_asset_image.dart';

class InventoryCard extends ConsumerWidget {
  final InventoryItem item;
  final int index; 
  final VoidCallback? onBorrow;
  final VoidCallback? onImageTap;
  final bool isManager;

  const InventoryCard({
    super.key,
    required this.item,
    required this.index,
    this.onBorrow,
    this.onImageTap,
    this.isManager = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (isManager) {
          HapticFeedback.heavyImpact();
          showModalBottomSheet(
            context: context,
            useRootNavigator: true, 
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ManagerActionSheetV2(item: item),
          );
        } else {
          onBorrow?.call();
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias, // 🛡️ ASSET SEAL: Prevent border bleeding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: sentinel.tactile.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 🛡️ ASSET HEADER (Image Area) ──
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onImageTap?.call();
                },
                child: Hero(
                  tag: 'inv_img_${item.id}',
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(color: sentinel.containerLow),
                          errorWidget: (context, url, error) => _buildIconPlaceholder(sentinel),
                        )
                      : _buildIconPlaceholder(sentinel),
                ),
              ),
            ),

            // ── 🛡️ INFO BLOCK (Content Area) ──
            Expanded(
              flex: 1, // 🛡️ Reverted to maintain image header size
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxHeight < 100; 
                  
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 8), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. IDENTITY BLOCK
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isTight) 
                              Text(
                                item.category.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: sentinel.primary.withOpacity(0.7),
                                  letterSpacing: 1.2,
                                  fontSize: 8,
                                ),
                              ),
                            Text(
                              item.name,
                              maxLines: isTight ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                fontSize: isTight ? 12 : 13,
                                color: sentinel.navy,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // 2. LOGISTICS BLOCK (Stock)
                        if (item.hasMultipleLocations && !isTight) ...[
                          _LocationBadge(
                            label: '${item.variants.length + 1} HUBS',
                            isMultiple: true,
                          ),
                          const Gap(4),
                        ] else if (item.location.isNotEmpty && !isTight) ...[
                          _LocationBadge(label: item.location),
                          const Gap(4),
                        ],
                        
                        _StockLabel(item: item, sentinel: sentinel),
                        const Gap(6), 
                        
                        // 3. ACTION ROW (KINETIC HUB)
                        Consumer(
                          builder: (context, ref, child) {
                            final cart = ref.watch(missionCartNotifierProvider);
                            final isInCart = cart.containsKey(item.id.toString());
                            final currentQty = cart[item.id.toString()]?.quantity ?? 0;
                            final isReserved = item.status.toLowerCase() == 'reserved' || item.status.toLowerCase() == 'staged';
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 32, // Tightened to save 2px
                              decoration: BoxDecoration(
                                color: isManager 
                                    ? sentinel.containerLow 
                                    : (isInCart ? sentinel.primary : (item.availableStock <= 0 || isReserved ? sentinel.containerLow : sentinel.navy)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isInCart && !isManager 
                                  ? Row(
                                      key: const ValueKey('counter_state'),
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _TacticalIconButton(
                                          icon: Icons.remove_circle_outline_rounded,
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            ref.read(missionCartNotifierProvider.notifier).decrementItem(item);
                                          },
                                        ),
                                        Text(
                                          '$currentQty',
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        _TacticalIconButton(
                                          icon: Icons.add_circle_rounded,
                                          onPressed: () {
                                            if (currentQty < item.availableStock) {
                                              HapticFeedback.mediumImpact();
                                              ref.read(missionCartNotifierProvider.notifier).addItem(item);
                                            } else {
                                              HapticFeedback.vibrate();
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : Row(
                                      key: const ValueKey('initial_state'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isManager ? Icons.tune_rounded : (isReserved ? Icons.event_available_rounded : Icons.send_rounded),
                                          color: isManager ? sentinel.navy : (item.availableStock <= 0 || isReserved ? sentinel.onSurfaceVariant.withOpacity(0.3) : Colors.white),
                                          size: 14,
                                        ),
                                        const Gap(6),
                                        Flexible(
                                          child: Text(
                                            isManager 
                                                ? 'MANAGE' 
                                                : (isReserved 
                                                    ? 'RESERVED' 
                                                    : (item.availableStock <= 0 
                                                        ? 'OUT OF STOCK' 
                                                        : 'DISPATCH')),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis, 
                                            style: GoogleFonts.lexend(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: isManager ? sentinel.navy : (item.availableStock <= 0 || isReserved ? sentinel.onSurfaceVariant.withOpacity(0.3) : Colors.white),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder(LigtasColors sentinel) {
    return Container(
      color: sentinel.containerLow,
      child: Center(
        child: Icon(
          _getCategoryIcon(item.category),
          color: sentinel.navy.withOpacity(0.15),
          size: 40,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final key = category.toLowerCase();
    if (key.contains('med')) return Icons.local_hospital_rounded;
    if (key.contains('rescue')) return Icons.construction_rounded;
    if (key.contains('food')) return Icons.inventory_2_rounded;
    if (key.contains('shelter')) return Icons.home_rounded;
    if (key.contains('water')) return Icons.water_drop_rounded;
    return Icons.inventory_rounded;
  }
}

/// Stock label row — High-speed "Logistics Progress Bar" layout.
/// Allows managers to scan stock levels visually (health bar) instead of reading.
class _StockLabel extends StatelessWidget {
  final InventoryItem item;
  final dynamic sentinel;

  const _StockLabel({required this.item, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    final double percentage = item.displayTotal > 0 
        ? (item.displayStock / item.displayTotal).clamp(0.0, 1.0) 
        : 0.0;
    
    final Color barColor = item.isOutOffStock 
        ? Colors.redAccent 
        : (item.isLowStock ? Colors.orangeAccent : const Color(0xFF1E293B));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '${item.displayStock}',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: barColor,
              ),
            ),
            Text(
              ' / ${item.displayTotal}',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B).withOpacity(0.5),
              ),
            ),
          ],
        ),
        const Gap(6),
        // 🛡️ LOGISTICS PROGRESS BAR: Visual health indicator
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.05),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Location badge shown on items so managers can see at a glance
/// where stock is situated — mirrors the web's location indicator.
class _LocationBadge extends StatelessWidget {
  final String label;
  final bool isMultiple;

  const _LocationBadge({required this.label, this.isMultiple = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isMultiple 
            ? const Color(0xFF6366F1).withOpacity(0.1) 
            : const Color(0xFF1E293B).withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: isMultiple 
            ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.2), width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_rounded, 
            size: 8, 
            color: isMultiple ? const Color(0xFF6366F1) : const Color(0xFF1E293B)
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label.replaceAll('_', ' ').toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: isMultiple ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🛡️ TACTICAL TOUCH TARGET: Expanded hit-testing for emergency precision
class _TacticalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _TacticalIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}