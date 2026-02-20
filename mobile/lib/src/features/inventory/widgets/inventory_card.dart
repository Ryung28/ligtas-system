import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/design_system/app_theme.dart';
import '../models/inventory_model.dart';
import '../../loans/widgets/borrow_request_sheet.dart';
import 'reserve_button.dart';

import '../../navigation/providers/navigation_provider.dart';

class InventoryCard extends ConsumerWidget {
  final InventoryModel item;

  const InventoryCard({super.key, required this.item});

  void _expandImage(BuildContext context, WidgetRef ref) async {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) return;

    // Senior Dev: Suppress the dock for a clean photo viewing experience
    ref.read(isDockSuppressedProvider.notifier).state = true;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.8), // Senior Dev: Darker overlay for focus
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Premium Blur Effect ──
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              
              // ── Interactive View (Pinch to Zoom) ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Hero(
                    tag: 'inventory_image_${item.id}',
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          ),
                          errorWidget: (context, url, error) => _getSmartIcon(item.name),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Professional Close Button ──
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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

    // Restore the dock
    ref.read(isDockSuppressedProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Glassmorphic Card Container
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Glass opacity
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
              // Navigation to details or expand
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // ── Image / Icon Box ──
                  GestureDetector(
                    onTap: () => _expandImage(context, ref),
                    child: Hero(
                      tag: 'inventory_image_${item.id}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Slate 100
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  fit: BoxFit.cover,
                                  // Senior Dev Optimization: Decode at exactly twice the display size for retina sharpness
                                  // but significantly less memory than raw image resolution.
                                  memCacheWidth: 112, 
                                  memCacheHeight: 112,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: const Color(0xFFF1F5F9),
                                    highlightColor: Colors.white,
                                    child: Container(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: _getSmartIcon(item.name),
                                  ),
                                )
                              : Center(
                                  child: _getSmartIcon(item.name),
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  const Gap(12),
                  
                  // ── Title & Stock Info ──
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
                            color: Color(0xFF0F172A), // Slate 900
                            letterSpacing: -0.4,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Gap(8),
                        _buildStockIndicator(item.available),
                      ],
                    ),
                  ),
                  
                  // ── Reserve Button — opens premium bottom sheet ──
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
    Color color;
    String label;
    IconData icon;

    if (available == 0) {
      color = const Color(0xFFEF4444); // Red 500
      label = 'OUT OF STOCK';
      icon = Icons.error_outline_rounded;
    } else if (available < 5) {
      color = const Color(0xFFF59E0B); // Amber 500
      label = 'LOW STOCK: $available';
      icon = Icons.warning_amber_rounded;
    } else {
      color = const Color(0xFF10B981); // Emerald 500
      label = 'AVAILABLE: $available';
      icon = Icons.check_circle_outline_rounded;
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSmartIcon(String name) {
    IconData icon = Icons.inventory_2_outlined; // Default box
    Color color = Colors.grey[600]!;
    double size = 32;

    final n = name.toLowerCase();
    
    // Logic matching the new design's examples
    if (n.contains('generator') || n.contains('power')) {
      icon = Icons.bolt_rounded; 
      color = Colors.amber[700]!;
    } else if (n.contains('drone') || n.contains('fly')) {
      icon = Icons.flight_takeoff_rounded;
      color = Colors.blue[600]!;
    } else if (n.contains('radio') || n.contains('comms')) {
      icon = Icons.settings_input_antenna_rounded;
      color = Colors.orange[800]!;
    } else if (n.contains('tools') || n.contains('drill') || n.contains('saw')) {
      icon = Icons.construction_rounded;
      color = Colors.grey[700]!;
    } else if (n.contains('medical') || n.contains('kit')) {
      icon = Icons.medical_services_rounded;
      color = Colors.red[500]!;
    }

    return Icon(icon, size: size, color: color);
  }
}
