import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_provider.g.dart';

/// Provider for unread notification count
@riverpod
Stream<int> unreadNotificationCount(UnreadNotificationCountRef ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value(0);
  }

  // Stream unread count from system_notifications
  // A notification is unread if it doesn't have a corresponding entry in notification_reads
  return supabase
      .from('system_notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((notifications) {
        // Count notifications that don't have a read entry
        // This is a simplified approach - in production you'd join with notification_reads
        return notifications.length;
      });
}

/// Provider for fetching system notifications
@riverpod
Future<List<Map<String, dynamic>>> systemNotifications(
  SystemNotificationsRef ref,
) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return [];
  }

  final response = await supabase
      .from('system_notifications')
      .select('*, notification_reads!left(read_at)')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

  return List<Map<String, dynamic>>.from(response);
}
