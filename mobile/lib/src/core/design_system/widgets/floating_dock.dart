import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../app_theme.dart';

/// Reusable Floating Dock Navigation Component
/// Used across user dashboard and analyst terminal
class FloatingDock extends StatelessWidget {
  final List<DockItem> items;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onScannerTap;
  final bool showScanner;

  const FloatingDock({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onScannerTap,
    this.showScanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildDockChildren(context, sentinel),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDockChildren(BuildContext context, SentinelColors sentinel) {
    final children = <Widget>[];
    
    // Calculate middle index for scanner placement
    final middleIndex = items.length ~/ 2;
    
    for (int i = 0; i < items.length; i++) {
      children.add(_buildDockItem(context, items[i], sentinel));
      
      // Insert scanner in the middle if enabled
      if (showScanner && i == middleIndex - 1) {
        children.add(_buildScannerButton(context, sentinel));
      }
    }
    
    return children;
  }

  Widget _buildDockItem(BuildContext context, DockItem item, SentinelColors sentinel) {
    final isSelected = selectedIndex == item.index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(item.index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant,
                    size: 24,
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: -20,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerButton(BuildContext context, SentinelColors sentinel) {
    return GestureDetector(
      onTap: onScannerTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sentinel.navy.withOpacity(0.8), sentinel.navy],
          ),
          boxShadow: sentinel.tactile.raised,
        ),
        child: const Center(
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Data model for dock items
class DockItem {
  final int index;
  final IconData icon;
  final String label;

  const DockItem({
    required this.index,
    required this.icon,
    required this.label,
  });
}
