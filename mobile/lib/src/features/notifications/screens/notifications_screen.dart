import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_theme.dart';
import '../presentation/providers/notification_provider.dart';
import '../data/models/notification_model.dart';
import '../presentation/widgets/tactical_notification_card.dart';
import '../widgets/sync_error_banner.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationRealtimeSyncProvider.notifier).startSync(() {
        ref.invalidate(systemNotificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
      });
    });
  }

  @override
  void dispose() {
    ref.read(notificationRealtimeSyncProvider.notifier).stopSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(systemNotificationsProvider);
    final sentinel = Theme.of(context).sentinel;

    return Scaffold(
      backgroundColor: sentinel.containerLow,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── TACTILE HEADER ──
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: sentinel.containerLow.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: sentinel.navy, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                'Tactical Feed',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: sentinel.navy,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.done_all_rounded, color: sentinel.primary),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(markAllNotificationsAsReadProvider.future);
                  ref.invalidate(systemNotificationsProvider);
                },
              ),
              const Gap(8),
            ],
          ),

          // ── NOTIFICATION STREAM ──
          notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context));
              }

              // Split by Category (Mirroring Web UI behavior)
              final urgent = notifications.where((n) => 
                ['stock_out', 'item_overdue', 'borrow_rejected'].contains(n.type)
              ).toList();
              
              final rest = notifications.where((n) => 
                !urgent.contains(n)
              ).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SyncErrorBanner(),
                    
                    if (urgent.isNotEmpty) ...[
                      _buildSectionHeader('CRITICAL PULSE', urgent.length, AppTheme.errorRed),
                      const Gap(12),
                      ...urgent.map((n) => TacticalNotificationCard(notification: n)),
                      const Gap(24),
                    ],

                    if (rest.isNotEmpty) ...[
                      _buildSectionHeader('SYSTEM LOGS', rest.length, sentinel.primary),
                      const Gap(12),
                      ...rest.map((n) => TacticalNotificationCard(notification: n)),
                    ],
                    
                    const Gap(100), // Bottom clearance
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _buildErrorState(context, err.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const Gap(10),
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).sentinel.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        const Gap(10),
        Expanded(child: Divider(color: color.withOpacity(0.05))),
      ],
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sentinel.containerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: sentinel.onSurfaceVariant.withOpacity(0.2),
            ),
          ),
          const Gap(24),
          Text(
            'FEED SILENT',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: sentinel.navy,
              letterSpacing: 2.0,
            ),
          ),
          const Gap(8),
          Text(
            'All tactical updates acknowledged.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: sentinel.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.errorRed.withOpacity(0.3)),
            const Gap(16),
            Text(
              'SIGNAL LOST',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w900, color: AppTheme.errorRed, fontSize: 14, letterSpacing: 1.5),
            ),
            const Gap(8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
