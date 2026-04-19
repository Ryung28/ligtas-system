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

    // Expiry urgency for this item
    final bool expiryAlert = item.hasAlert && item.expiryDate != null;
    final int? daysLeft = item.expiryDate != null
        ? item.expiryDate!.difference(DateTime.now()).inDays
        : null;
    final bool isExpired = daysLeft != null && daysLeft < 0;
    final bool isCritical = daysLeft != null && daysLeft >= 0 && daysLeft <= 7;
    final Color expiryAccent = isExpired || isCritical
        ? const Color(0xFFDC2626)
        : const Color(0xFFF59E0B);

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
          border: expiryAlert
              ? Border.all(color: expiryAccent.withOpacity(0.5), width: 1.5)
              : null,
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
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
                    // Expiry alert badge overlay
                    if (expiryAlert)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: expiryAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded, color: Colors.white, size: 9),
                              const SizedBox(width: 3),
                              Text(
                                isExpired
                                    ? 'EXPIRED'
                                    : isCritical
                                        ? '${daysLeft}D'
                                        : item.alertLabel,
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isTight)
                              Container(
                                width: 2.5,
                                height: 44, // 🛡️ Frames Category (8) + Gap (2) + Name (34)
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: expiryAlert
                                      ? expiryAccent.withOpacity(0.7)
                                      : const Color(0xFF1E293B).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            if (!isTight) const Gap(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isTight) 
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.layers_rounded, 
                                            size: 9, 
                                            color: const Color(0xFF1E293B).withOpacity(0.7)
                                          ),
                                          const Gap(4),
                                          Text(
                                            item.category.toUpperCase(),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: const Color(0xFF1E293B),
                                              letterSpacing: 1.2,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                    height: isTight ? 16 : 34, // 🛡️ ATOMIC SAFE-ZONE: Fixed height prevents layout push
                                    child: Text(
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(), // Re-enabled Spacer with Safe-Zone headroom

                        // 2. LOGISTICS BLOCK (Stock & Location)
                        if (!isTight) ...[
                          Row(
                            children: [
                              if (isManager)
                                Expanded(
                                  child: item.hasMultipleLocations
                                      ? _LocationBadge(
                                          label: '${item.variants.length + 1} HUBS',
                                          isMultiple: true,
                                        )
                                      : (item.location.isNotEmpty
                                          ? _LocationBadge(label: item.location)
                                          : const SizedBox.shrink()),
                                ),
                              const Gap(8),
                              _StockRatioText(item: item),
                            ],
                          ),
                          const Gap(6),
                          _StockProgressBar(item: item),
                        ] else ...[
                          // Minimal view for tight constraints
                          _StockRatioText(item: item),
                          const Gap(4),
                          _StockProgressBar(item: item),
                        ],
                        const Gap(8), 

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
                                                        : 'BORROW')),
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

/// Helper for the Stock Ratio (e.g. 12 / 45)
class _StockRatioText extends StatelessWidget {
  final InventoryItem item;
  const _StockRatioText({required this.item});

  @override
  Widget build(BuildContext context) {
    final double pct = item.displayTotal > 0 ? item.displayStock / item.displayTotal : 0;
    
    // 🛡️ DYNAMIC LOGISTICS COLOR ENGINE
    final Color color = pct >= 0.70 
        ? const Color(0xFF10B981) // Healthy Green
        : (pct >= 0.25 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)); // Amber or Red

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${item.displayStock}',
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
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
    );
  }
}

/// Helper for the Visual Health Bar
class _StockProgressBar extends StatelessWidget {
  final InventoryItem item;
  const _StockProgressBar({required this.item});

  @override
  Widget build(BuildContext context) {
    final double percentage = item.displayTotal > 0 
        ? (item.displayStock / item.displayTotal).clamp(0.0, 1.0) 
        : 0.0;
    
    // 🛡️ SYNCED COLOR LOGIC
    final Color barColor = percentage >= 0.70 
        ? const Color(0xFF10B981) 
        : (percentage >= 0.25 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return Container(
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