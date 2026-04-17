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

/// 📡 TACTICAL NOTIFICATION CARD (V3 - MIRROR PARITY)
/// Enterprise "Pure Signal" design using Tactile Glassmorphism.
class TacticalNotificationCard extends ConsumerWidget {
  final NotificationItem notification;

  const TacticalNotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final isRead = notification.isRead;
    final createdAt = DateTime.parse(notification.time);
    
    // 🎨 Priority Selection (Mirroring Web accents)
    final Color accentColor = Color(int.parse(notification.color.replaceFirst('#', '0xFF')));
    final isCritical = ['stock_out', 'item_overdue', 'borrow_rejected'].contains(notification.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: isRead ? Colors.white.withOpacity(0.7) : Colors.white,
            child: InkWell(
              onTap: () => _handleTriage(context, ref),
              onLongPress: () => _showDeleteDialog(context, ref),
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isRead ? sentinel.onSurfaceVariant.withOpacity(0.1) : accentColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🛡️ INTENT STRIPE (The Admin Edge)
                    Container(
                      width: 5,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                        boxShadow: [
                          if (!isRead)
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    
                    // ── CONTENT ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Metadata Header
                          Row(
                            children: [
                              Text(
                                notification.type.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor.withOpacity(0.8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (isCritical) ...[
                                const Gap(6),
                                _buildBadge('CRITICAL', AppTheme.errorRed),
                              ],
                              const Spacer(),
                              Text(
                                timeago.format(createdAt, locale: 'en_short'),
                                style: GoogleFonts.lexend(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: sentinel.onSurfaceVariant.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),

                          // Main Signal
                          Text(
                            notification.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: sentinel.navy,
                              height: 1.1,
                            ),
                          ),
                          const Gap(8),

                          // Item Chip (If metadata exists)
                          _buildItemChip(sentinel),
                          
                          // Footer Metadata
                          const Gap(10),
                          Row(
                            children: [
                              if (notification.referenceId != null)
                                Text(
                                  'REF: #${notification.referenceId!.split('-').last.toUpperCase()}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: sentinel.onSurfaceVariant.withOpacity(0.3),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                isRead ? '✓ ACKNOWLEDGED' : '[ TAP TO TRIAGE ]',
                                style: GoogleFonts.lexend(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: isRead 
                                    ? sentinel.onSurfaceVariant.withOpacity(0.2)
                                    : accentColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemChip(LigtasColors sentinel) {
    final meta = notification.metadata;
    final itemName = meta['item_name'] ?? meta['search_query'];
    if (itemName == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ITEM: ',
            style: GoogleFonts.lexend(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: sentinel.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
          Text(
            itemName.toString().toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: sentinel.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  void _handleTriage(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    if (!notification.isRead) {
      ref.read(markNotificationAsReadProvider(notification.id).future);
      ref.invalidate(systemNotificationsProvider);
    }

    if (notification.actionTarget != null) {
      context.push(notification.actionTarget!);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Pulse?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text('This removes the notification from your tactical feed.', style: GoogleFonts.inter()),
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
