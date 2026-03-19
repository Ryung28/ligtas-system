import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../loans/presentation/widgets/borrow_request_sheet.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import 'reserve_button.dart';

class InventoryCard extends ConsumerWidget {
  final InventoryItem item;

  const InventoryCard({super.key, required this.item});

  void _expandImage(BuildContext context, WidgetRef ref) async {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) return;

    ref.read(isDockSuppressedProvider.notifier).state = true;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Hero(
                    tag: 'inventory_image_v2_${item.id}',
                    child: InteractiveViewer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => _SmartIcon(category: item.category),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    ref.read(isDockSuppressedProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigation to details would go here
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _expandImage(context, ref),
                    child: Hero(
                      tag: 'inventory_image_v2_${item.id}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 112, 
                                  memCacheHeight: 112,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: const Color(0xFFF1F5F9),
                                    highlightColor: Colors.white,
                                    child: Container(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => _SmartIcon(category: item.category),
                                )
                              : _SmartIcon(category: item.category),
                        ),
                      ),
                    ),
                  ),
                  
                  const Gap(12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Gap(8),
                        _buildStockIndicator(item.availableStock),
                      ],
                    ),
                  ),
                  
                  ReserveButton(onTap: () {
                    BorrowRequestSheet.show(context, item: item);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(int available) {
    Color color = const Color(0xFF10B981); // Emerald 500
    String label = 'AVAILABLE: $available';
    IconData icon = Icons.check_circle_outline_rounded;

    if (available == 0) {
      color = const Color(0xFFEF4444); // Red 500
      label = 'OUT OF STOCK';
      icon = Icons.error_outline_rounded;
    } else if (available < 5) {
      color = const Color(0xFFF59E0B); // Amber 500
      label = 'LOW STOCK: $available';
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartIcon extends ConsumerWidget {
  final String category;
  const _SmartIcon({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = ref.watch(categoryIconProvider(category));
    return Center(
      child: Icon(icon, size: 30, color: const Color(0xFF64748B)),
    );
  }
}
