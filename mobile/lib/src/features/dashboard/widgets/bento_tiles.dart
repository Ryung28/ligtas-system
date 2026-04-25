import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_theme.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../providers/dashboard_provider.dart';

/// Overdue Alert Banner - Sticky at top when items are overdue
class OverdueAlertBanner extends ConsumerWidget {
  final int overdueCount;

  const OverdueAlertBanner({super.key, required this.overdueCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (overdueCount == 0) return const SizedBox.shrink();

    final hasEntered = ref.watch(dashboardEntryProvider);
    final duration = hasEntered ? 0.ms : 500.ms;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.go('/loans');
      },
      child: RepaintBoundary( // 🛡️ RASTER CACHE: Isolate static banner
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAD6).withOpacity(0.95), // Solid-ish error_container
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF93000A).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFBA1A1A), // error
                  size: 20,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$overdueCount ITEM${overdueCount > 1 ? 'S' : ''} OVERDUE',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFBA1A1A), // error
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Tap to view and return',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBA1A1A).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFBA1A1A).withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: duration).slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack);
  }
}

/// Bento Stat Tile - Large format, tactile 
class BentoStatTile extends ConsumerStatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int animationDelay;

  const BentoStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  ConsumerState<BentoStatTile> createState() => _BentoStatTileState();
}

class _BentoStatTileState extends ConsumerState<BentoStatTile> {
  bool _isAnimating = true;

  @override
  Widget build(BuildContext context) {
    final hasEntered = ref.watch(dashboardEntryProvider);
    final tacticalRadius = const BorderRadius.only(
      topLeft: Radius.circular(32),
      bottomRight: Radius.circular(32),
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );

    // 🛡️ GOLD STANDARD: Prune shadows during animation
    final showShadows = hasEntered || !_isAnimating;

    return RepaintBoundary( // 🛡️ RASTER CACHE: Isolate Neumorphic shadow rendering
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFB), // Premium Sub-Surface Shift
                borderRadius: tacticalRadius,
                border: Border.all(
                  color: AppTheme.neutralGray900.withOpacity(0.08),
                  width: 1.5,
                ),
                boxShadow: showShadows ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: ClipRRect(
                borderRadius: tacticalRadius,
                child: Stack(
                  children: [
                    // ── TACTICAL ACCENT BAR (Chromic Recognition) ──
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        color: widget.color,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Top: Icon + Badge (Responsive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(widget.icon, color: widget.color, size: 18),
                                ),
                              ),
                              const Gap(4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: showShadows ? [
                                    BoxShadow(
                                      color: widget.color.withOpacity(0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: Text(
                                  widget.value,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const Gap(6),
                          
                          // Bottom: Label
                          Text(
                            widget.label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF43474D), // stitchOnSurfaceVariant
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 🛡️ Decorative Tactical Aura (Premium Crisp Disc)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: tacticalRadius,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // 💎 DYNAMIC FILL: Matches the tile status (Available, Overdue, etc.)
                            color: widget.color.withOpacity(0.12),
                            // 💎 SHARP BORDER: Catches the light in the corner
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🛡️ Sentinel Inner Shine Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: tacticalRadius,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.5),
                      left: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate(
        onComplete: (_) {
          if (mounted && !hasEntered) {
            setState(() => _isAnimating = false);
          }
        },
      )
       .fadeIn(duration: hasEntered ? 0.ms : 600.ms, delay: widget.animationDelay.ms)
       .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart),
    );
  }
}

/// Quick Scan Hero - Redesigned as Bento "action" tile  
class BentoScanTile extends ConsumerWidget {
  final VoidCallback onTap;
  final int animationDelay;

  const BentoScanTile({super.key, required this.onTap, this.animationDelay = 0});

  // Stitch Design Tokens
  static const Color stitchNavy = Color(0xFF001A33);
  static const Color stitchNavyLight = Color(0xFF324863);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasEntered = ref.watch(dashboardEntryProvider);
    final duration = hasEntered ? 0.ms : 600.ms;

    return RepaintBoundary( // 🛡️ RASTER CACHE: Isolate Scanner Glow/Animation
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [stitchNavyLight, stitchNavy],
              stops: [0.0, 1.0],
            ),
            boxShadow: hasEntered ? [
              BoxShadow(
                color: stitchNavy.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ] : null, // Prune shadows during first entry motion
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // 1px Inner Shine Border (Sentinel signature)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                        left: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                      ),
                    ),
                  ),
                ),
                
                // Texture Overlay
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 180,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
    
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'QUICK SCAN',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.5),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Borrow Item',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.0,
                                height: 1.1,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Tap to scan and borrow\nnew equipment.',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // High-Precision Icon Container
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15), // Increased opacity to compensate for blur removal
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: hasEntered ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ] : null,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate()
       .fadeIn(duration: duration, delay: animationDelay.ms)
       .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuart),
    );
  }
}

/// Recent Activity Tile (Compact for Bento)
class BentoActivityTile extends StatelessWidget {
  final String itemName;
  final String timeAgo;
  final String status;
  final int animationDelay;

  const BentoActivityTile({
    super.key,
    required this.itemName,
    required this.timeAgo,
    required this.status,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = status == 'overdue';
    final isPending = status == 'pending';
    
    // Color for the status badge
    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = const Color(0xFF8B5CF6); // Purple for pending
      statusText = 'PENDING';
    } else if (isOverdue) {
      statusColor = const Color(0xFFEF4444); // Red for overdue
      statusText = 'OVERDUE';
    } else {
      statusColor = const Color(0xFFF59E0B); // Amber for active
      statusText = 'ACTIVE';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).sentinel.surface, // Neumorphic background match
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).sentinel.tactile.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).sentinel.containerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForItem(itemName),
              color: _getColorForItem(itemName),
              size: 22,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1F), // stitchOnSurface
                    letterSpacing: -0.2,
                  ),
                ),
                const Gap(2),
                Text(
                  timeAgo,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF43474D), // stitchOnSurfaceVariant
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: animationDelay.ms).slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  IconData _getIconForItem(String name) {
    final n = name.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) return Icons.settings_input_antenna_rounded;
    if (n.contains('drone')) return Icons.flight_takeoff_rounded;
    if (n.contains('generator') || n.contains('power')) return Icons.bolt_rounded;
    if (n.contains('boat') || n.contains('raft')) return Icons.directions_boat_rounded;
    if (n.contains('med') || n.contains('aid')) return Icons.medical_services_rounded;
    return Icons.inventory_2_outlined;
  }

  Color _getColorForItem(String name) {
    final n = name.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) return Colors.blueGrey[700]!;
    if (n.contains('drone')) return Colors.indigo[400]!;
    if (n.contains('generator') || n.contains('power')) return Colors.amber[600]!;
    if (n.contains('boat') || n.contains('raft')) return Colors.blue[400]!;
    if (n.contains('med') || n.contains('aid')) return Colors.red[400]!;
    return Colors.grey[600]!;
  }
}
