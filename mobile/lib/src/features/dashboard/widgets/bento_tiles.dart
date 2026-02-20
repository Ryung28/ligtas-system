import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_theme.dart';

/// Overdue Alert Banner - Sticky at top when items are overdue
class OverdueAlertBanner extends StatelessWidget {
  final int overdueCount;

  const OverdueAlertBanner({super.key, required this.overdueCount});

  @override
  Widget build(BuildContext context) {
    if (overdueCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.go('/loans');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withValues(alpha: 0.12),
              const Color(0xFFFCA5A5).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$overdueCount item${overdueCount > 1 ? 's' : ''} overdue',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Tap to view and return',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFEF4444).withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack);
  }
}

/// Bento Stat Tile - Large format, tactile 
class BentoStatTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.35),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top: Icon + Badge (Responsive)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: color.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Gap(12),
                  
                  // Bottom: Label
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neutralGray600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 600.ms, delay: animationDelay.ms)
     .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}

/// Quick Scan Hero - Redesigned as Bento "action" tile  
class BentoScanTile extends StatelessWidget {
  final VoidCallback onTap;
  final int animationDelay;

  const BentoScanTile({super.key, required this.onTap, this.animationDelay = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryBlueDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Borrow New Item',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Tap to scan equipment',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 52,
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
     .fadeIn(duration: 600.ms, delay: animationDelay.ms)
     .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack);
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
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue 
            ? const Color(0xFFEF4444).withValues(alpha: 0.25) 
            : isPending
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverdue 
              ? const Color(0xFFEF4444).withValues(alpha: 0.06) 
              : isPending
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForItem(itemName),
              color: _getColorForItem(itemName),
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray900,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralGray400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: animationDelay.ms).slideX(begin: 0.05, end: 0);
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
