import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/mission_cart_provider.dart';
import 'manager_action_sheet.dart';
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
            builder: (context) => ManagerActionSheet(item: item),
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
              flex: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxHeight < 120; // 🛡️ ADAPTIVE PRUNING THRESHOLD
                  
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, // 🛡️ CONTENT-FIRST GROUPING
                      children: [
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
                            const Gap(2),
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                fontSize: 13,
                                color: sentinel.navy,
                              ),
                            ),
                            const Gap(4),
                              Text(
                                item.status.toLowerCase() == 'staged' || item.status.toLowerCase() == 'reserved'
                                    ? 'RESERVED'
                                    : (item.availableStock <= 0 
                                        ? 'OUT OF STOCK' 
                                        : (item.availableStock <= item.minStockLevel ? 'LOW STOCK: ${item.availableStock.toInt()} ${item.unit.toUpperCase()}' : 'STOCK: ${item.availableStock.toInt()} ${item.unit.toUpperCase()}')),
                                style: GoogleFonts.lexend(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: (item.status.toLowerCase() == 'staged' || item.status.toLowerCase() == 'reserved')
                                      ? AppTheme.primaryBlue
                                      : (item.availableStock <= 0 
                                          ? Colors.redAccent 
                                          : (item.availableStock <= item.minStockLevel ? Colors.orangeAccent : sentinel.onSurfaceVariant.withOpacity(0.6))),
                                ),
                              ),
                          ],
                        ),
                        
                        // 🛡️ ADAPTIVE PROXIMITY: Anchors the button to the bottom
                        const Gap(2), 
                        const Spacer(), 
                        const Gap(2), 
                        
                        // ── 🛡️ ACTION ROW (KINETIC HUB) ──
                        Consumer(
                          builder: (context, ref, child) {
                            final cart = ref.watch(missionCartNotifierProvider);
                            final isInCart = cart.containsKey(item.id.toString());
                            final currentQty = cart[item.id.toString()]?.quantity ?? 0;
                            final isReserved = item.status.toLowerCase() == 'staged' || item.status.toLowerCase() == 'reserved';
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isManager 
                                    ? sentinel.containerLow 
                                    : (isInCart ? sentinel.primary : (item.availableStock <= 0 || isReserved ? sentinel.containerLow : sentinel.navy)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isInCart 
                                    ? [BoxShadow(color: sentinel.primary.withOpacity(0.4), blurRadius: 8)] 
                                    : null,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                                },
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
                                          isManager ? Icons.settings_input_component_rounded : (isReserved ? Icons.bookmark_added_rounded : Icons.shopping_bag_outlined),
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
                                                        : 'BORROW ITEM')),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.visible, 
                                            style: GoogleFonts.lexend(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: isManager ? sentinel.navy : (item.availableStock <= 0 || isReserved ? sentinel.onSurfaceVariant.withOpacity(0.3) : Colors.white),
                                              letterSpacing: 1.0,
                                              height: 1.0,
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