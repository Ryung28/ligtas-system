import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: sentinel.containerLow.withOpacity(0.9),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: sentinel.navy, size: 20),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CENTRAL INTELLIGENCE FEED',
                    style: GoogleFonts.lexend(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: sentinel.onSurfaceVariant.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'Active Alerts',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: sentinel.navy,
                    ),
                  ),
                ],
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

              final active = notifications.where((n) => !n.isRead).toList();
              final resolved = notifications.where((n) => n.isRead).toList();

              // Determine priority for active section
              final hasCritical = active.any((n) => ['stock_out', 'item_overdue', 'borrow_rejected', 'system_alert'].contains(n.type));

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SyncErrorBanner(),
                    
                    // ACTIVE ALERTS SECTION
                    if (active.isNotEmpty) ...[
                      _buildProtocolHeader(
                        context,
                        title: "Today's Protocol",
                        subtitle: DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                        icon: Icons.calendar_today_rounded,
                        isDark: true,
                        priority: hasCritical ? "High" : "Standard",
                      ),
                      ...active.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final n = entry.value;
                        return TacticalNotificationCard(
                          notification: n,
                          isFirst: idx == 0,
                          isLast: idx == active.length - 1 && resolved.isEmpty,
                        );
                      }),
                    ],

                    // RESOLVED EVENTS SECTION
                    if (resolved.isNotEmpty) ...[
                      const Gap(24),
                      _buildProtocolHeader(
                        context,
                        title: "Resolved Events",
                        subtitle: DateFormat('MMMM dd, yyyy').format(DateTime.now().subtract(const Duration(days: 1))),
                        icon: Icons.history_rounded,
                        isDark: false,
                        priority: "Archived",
                      ),
                      ...resolved.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final n = entry.value;
                        return TacticalNotificationCard(
                          notification: n,
                          isFirst: idx == 0,
                          isLast: idx == resolved.length - 1,
                        );
                      }),
                    ],
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

  Widget _buildProtocolHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required String priority,
  }) {
    final sentinel = Theme.of(context).sentinel;
    
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 16, top: 8),
      child: Row(
        children: [
          // Icon Node
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? sentinel.navy : sentinel.containerLow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : sentinel.onSurfaceVariant,
            ),
          ),
          const Gap(16),
          // Text Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: sentinel.navy,
                ),
              ),
              Text(
                '$subtitle • Priority Level: $priority',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: sentinel.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
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
            'INTEL FEED SILENT',
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.errorRed.withOpacity(0.3)),
            const Gap(16),
            Text(
              'SIGNAL INTERRUPTED',
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

