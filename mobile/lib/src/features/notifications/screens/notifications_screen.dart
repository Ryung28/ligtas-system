import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_theme.dart';
import '../presentation/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(systemNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001A33)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF001A33),
          ),
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group notifications by category
          final urgent = notifications.where((n) => 
            n['type'] == 'item_overdue'
          ).toList();
          
          final requests = notifications.where((n) => 
            n['type'] == 'borrow_approved' || 
            n['type'] == 'borrow_rejected'
          ).toList();
          
          final account = notifications.where((n) => 
            n['type'] == 'user_approved' || 
            n['type'] == 'user_suspended' || 
            n['type'] == 'user_reactivated'
          ).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (urgent.isNotEmpty) ...[
                _buildSectionHeader('🚨 URGENT', urgent.length, Colors.red),
                const Gap(12),
                ...urgent.map((n) => _buildNotificationCard(context, n, ref)),
                const Gap(24),
              ],
              if (requests.isNotEmpty) ...[
                _buildSectionHeader('📬 MY REQUESTS', requests.length, Colors.blue),
                const Gap(12),
                ...requests.map((n) => _buildNotificationCard(context, n, ref)),
                const Gap(24),
              ],
              if (account.isNotEmpty) ...[
                _buildSectionHeader('ℹ️ ACCOUNT', account.length, Colors.grey),
                const Gap(12),
                ...account.map((n) => _buildNotificationCard(context, n, ref)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF43474D),
            letterSpacing: 1.5,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification, WidgetRef ref) {
    final type = notification['type'] as String;
    final title = notification['title'] as String;
    final message = notification['message'] as String;
    final createdAt = DateTime.parse(notification['created_at'] as String);
    final isRead = notification['notification_reads'] != null && 
                   (notification['notification_reads'] as List).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.transparent : const Color(0xFF3B82F6).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getNotificationIcon(type),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF001A33),
                  ),
                ),
                const Gap(4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF43474D),
                    height: 1.4,
                  ),
                ),
                const Gap(8),
                Text(
                  timeago.format(createdAt),
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFF9CA3AF),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'borrow_approved':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'borrow_rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'item_overdue':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'user_approved':
        icon = Icons.verified_user;
        color = Colors.blue;
        break;
      case 'user_suspended':
        icon = Icons.block;
        color = Colors.red;
        break;
      case 'user_reactivated':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const Gap(24),
          Text(
            'All caught up!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF001A33),
            ),
          ),
          const Gap(8),
          Text(
            'No new notifications',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            'Failed to load notifications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF001A33),
            ),
          ),
          const Gap(8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
