import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/design_system/app_theme.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

/// 📡 TACTICAL NOTIFICATION CARD (V4 - CENTRAL INTELLIGENCE FEED)
/// Clean timeline-based design with priority pills and explicit actions.
class TacticalNotificationCard extends ConsumerWidget {
  final NotificationItem notification;
  final bool isLast;
  final bool isFirst;

  const TacticalNotificationCard({
    super.key,
    required this.notification,
    this.isLast = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final isRead = notification.isRead;
    final createdAt = DateTime.parse(notification.time);
    
    final isCritical = ['stock_out', 'item_overdue', 'borrow_rejected', 'system_alert'].contains(notification.type);
    final isWarning = ['stock_low', 'borrow_request', 'item_returned', 'user_pending'].contains(notification.type);

    // 🎨 MOCKUP-ACCURATE PALETTE (CENTRAL INTELLIGENCE)
    final Color pillBgColor = isCritical 
        ? const Color(0xFFFEE2E2) // Soft Red
        : (isWarning ? const Color(0xFFFFEDD5) : const Color(0xFFE0F2FE)); // Soft Orange / Soft Blue
    
    final Color pillTextColor = isCritical 
        ? const Color(0xFF991B1B) // Dark Red
        : (isWarning ? const Color(0xFF9A3412) : const Color(0xFF0369A1)); // Dark Brown / Dark Blue

    final Color dotColor = isCritical 
        ? const Color(0xFFB91C1C) // Autoritative Red
        : (isWarning ? const Color(0xFF9A3412) : const Color(0xFF0369A1)); // Brownish Orange / Blue

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TIMELINE COLUMN ──
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical Line
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      width: 1.5,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                  ),
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: 24,
                    child: Container(
                      width: 1.5,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                  ),
                
                // Timeline Dot
                Positioned(
                  top: 24,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isRead ? Colors.grey.withOpacity(0.3) : dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        if (!isRead)
                          BoxShadow(
                            color: dotColor.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CARD CONTENT ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isRead ? const Color(0xFFF9FAFB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isRead ? null : sentinel.tactile.card,
                  border: isRead 
                    ? Border.all(color: Colors.transparent)
                    : Border.all(
                        color: dotColor.withOpacity(0.05),
                        width: 1,
                      ),
                ),
                child: Opacity(
                  opacity: isRead ? 0.6 : 1.0,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: isRead ? null : () => _handleTriage(context, ref),
                      onLongPress: () => _showDeleteDialog(context, ref),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Metadata Row
                            Row(
                              children: [
                                _buildPriorityPill(
                                  isRead ? 'RESOLVED' : (isCritical ? 'CRITICAL' : (isWarning ? 'WARNING' : 'INFORMATION')),
                                  isRead ? Colors.grey.withOpacity(0.1) : pillBgColor,
                                  isRead ? Colors.grey : pillTextColor,
                                ),
                                const Spacer(),
                                Text(
                                  timeago.format(createdAt, locale: 'en_short').toUpperCase(),
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: sentinel.onSurfaceVariant.withOpacity(0.4),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),

                            // Title
                            Text(
                              notification.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: isRead ? Colors.grey : sentinel.navy,
                                height: 1.2,
                              ),
                            ),
                            const Gap(8),

                            // Resource/Metadata Subtitle
                            _buildMetadataRow(sentinel, isRead),
                            
                            // Message Body
                            const Gap(12),
                            Text(
                              notification.message,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: sentinel.onSurfaceVariant.withOpacity(0.7),
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Action Buttons
                            if (!isRead) ...[
                              const Gap(20),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () => _handleTriage(context, ref),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Text(
                                    'DISMISS ALERT',
                                    style: GoogleFonts.lexend(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
  }

  Widget _buildPriorityPill(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _buildMetadataRow(LigtasColors sentinel, bool isRead) {
    final meta = notification.metadata;
    final itemName = meta['item_name'] ?? meta['search_query'];
    if (itemName == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (notification.type.contains('stock'))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  color: isRead ? Colors.grey.withOpacity(0.05) : sentinel.containerLow,
                  child: Icon(Icons.inventory_2_outlined, size: 16, color: isRead ? Colors.grey.withOpacity(0.3) : sentinel.navy.withOpacity(0.5)),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resource: ${itemName.toString()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isRead ? Colors.grey.withOpacity(0.5) : sentinel.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color color,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      height: 44,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFE0F2FE) : Colors.transparent,
          foregroundColor: color,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isPrimary ? null : BorderSide(color: Colors.grey.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14),
              const Gap(6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _handleTriage(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    // 🛡️ TACTICAL ISOLATION: Remove navigation, only handle resolution
    if (!notification.isRead) {
      ref.read(markNotificationAsReadProvider(notification.id).future);
      ref.invalidate(systemNotificationsProvider);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('ERASE INTEL?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        content: Text('This permanentlty removes the alert from the intelligence feed.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(deleteNotificationProvider(notification.id).future);
              ref.invalidate(systemNotificationsProvider);
            },
            child: Text('DELETE', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

