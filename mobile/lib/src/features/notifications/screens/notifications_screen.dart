import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/design_system/app_theme.dart';
import '../data/models/notification_model.dart';
import '../presentation/providers/notification_provider.dart';
import '../presentation/widgets/tactical_notification_card.dart';
import '../widgets/sync_error_banner.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final NotificationRealtimeSync _realtimeSync;
  String _selectedTypeFilter = 'all';
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _realtimeSync = ref.read(notificationRealtimeSyncProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _realtimeSync.startSync(() {
        ref.invalidate(systemNotificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
      });
    });
  }

  @override
  void dispose() {
    _realtimeSync.stopSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(systemNotificationsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.role.toLowerCase();
    final canViewOperationalFilters = const {
      'admin',
      'staff',
      'editor',
      'analyst',
      'responder',
    }.contains(role);
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
                    'NOTIFICATIONS',
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
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  HapticFeedback.mediumImpact();
                  try {
                    await ref.read(markAllNotificationsAsReadProvider.future);
                    ref.invalidate(systemNotificationsProvider);
                    ref.invalidate(unreadNotificationCountProvider);
                  } catch (error) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Failed to mark all as read: $error')),
                    );
                  }
                },
              ),
              const Gap(8),
            ],
          ),

          // ── NOTIFICATION STREAM ──
          notificationsAsync.when(
            data: (allNotifications) {
              final notifications = allNotifications
                  .where(_matchesFilter)
                  .toList()
                ..sort((a, b) {
                  final aTime = DateTime.tryParse(a.time);
                  final bTime = DateTime.tryParse(b.time);
                  if (aTime == null || bTime == null) return 0;
                  final compare = aTime.compareTo(bTime);
                  return _sortNewestFirst ? -compare : compare;
                });

              if (notifications.isEmpty) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    const SyncErrorBanner(),
                    const Gap(8),
                    _buildFilterToolbar(
                      context,
                      canViewOperationalFilters: canViewOperationalFilters,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: _buildEmptyState(context),
                    ),
                  ]),
                );
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
                    const Gap(8),
                    _buildFilterToolbar(
                      context,
                      canViewOperationalFilters: canViewOperationalFilters,
                    ),
                    
                    // ACTIVE ALERTS SECTION
                    if (active.isNotEmpty) ...[
                      _buildProtocolHeader(
                        context,
                        title: "Today's Alerts",
                        subtitle: DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                        icon: Icons.calendar_today_rounded,
                        isDark: true,
                        priority: hasCritical ? "High" : "Normal",
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
                        title: "Resolved Alerts",
                        subtitle: DateFormat('MMMM dd, yyyy').format(DateTime.now().subtract(const Duration(days: 1))),
                        icon: Icons.history_rounded,
                        isDark: false,
                        priority: "Resolved",
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
            'NO NEW ALERTS',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: sentinel.navy,
              letterSpacing: 2.0,
            ),
          ),
          const Gap(8),
          Text(
            'You are all caught up.',
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

  Widget _buildFilterToolbar(
    BuildContext context, {
    required bool canViewOperationalFilters,
  }) {
    final sentinel = Theme.of(context).sentinel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip(context, label: 'All', value: 'all'),
                const Gap(8),
                if (canViewOperationalFilters) ...[
                  _buildTypeChip(context, label: 'Low Stock', value: 'stock'),
                  const Gap(8),
                ],
                _buildTypeChip(context, label: 'Returned', value: 'returned'),
                const Gap(8),
                if (canViewOperationalFilters) ...[
                  _buildTypeChip(context, label: 'Overdue', value: 'overdue'),
                  const Gap(8),
                ],
                _buildTypeChip(context, label: 'Approvals', value: 'approval'),
                const Gap(8),
                _buildTypeChip(context, label: 'System', value: 'system'),
              ],
            ),
          ),
          const Gap(8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _sortNewestFirst = !_sortNewestFirst);
              },
              icon: Icon(
                _sortNewestFirst
                    ? Icons.south_rounded
                    : Icons.north_rounded,
                size: 16,
                color: sentinel.onSurfaceVariant.withOpacity(0.8),
              ),
              label: Text(
                _sortNewestFirst ? 'Newest first' : 'Oldest first',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: sentinel.onSurfaceVariant.withOpacity(0.85),
                  letterSpacing: 0.4,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: sentinel.onSurfaceVariant.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final sentinel = Theme.of(context).sentinel;
    final selected = _selectedTypeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedTypeFilter = value),
      labelStyle: GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: selected ? Colors.white : sentinel.onSurfaceVariant.withOpacity(0.85),
      ),
      selectedColor: sentinel.navy,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? sentinel.navy
            : sentinel.onSurfaceVariant.withOpacity(0.2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  bool _matchesFilter(NotificationItem n) {
    final type = n.type.toLowerCase();
    switch (_selectedTypeFilter) {
      case 'stock':
        return type == 'stock_low' || type == 'stock_out' || type == 'low_stock';
      case 'returned':
        return type == 'item_returned';
      case 'overdue':
        return type == 'item_overdue';
      case 'approval':
        return type == 'borrow_request' ||
            type == 'borrow_approved' ||
            type == 'borrow_rejected' ||
            type == 'request_approved' ||
            type == 'request_rejected';
      case 'system':
        return type == 'system_alert' || type.startsWith('user_');
      case 'all':
      default:
        return true;
    }
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
              'CONNECTION ISSUE',
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

