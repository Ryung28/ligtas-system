import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/extensions/supabase_client_extension.dart';
import 'package:mobile/src/features/notifications/data/repositories/notification_repository.dart';
import 'package:mobile/src/features/notifications/data/models/notification_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

part 'notification_provider.g.dart';

/// Provider for unread notification count (using RPC like web)
@riverpod
Stream<int> unreadNotificationCount(UnreadNotificationCountRef ref) async* {
  final repository = NotificationRepository();
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    yield 0;
    return;
  }

  int lastKnownCount = 0;

  Future<int> fetchUnreadCount() async {
    final result = await repository.getInbox(limit: 200);
    if (!result.success) {
      throw Exception(result.message);
    }
    return result.data.where((notification) => !notification.isRead).length;
  }

  try {
    await supabase.checkConnection();
    lastKnownCount = await fetchUnreadCount();
    yield lastKnownCount;
  } catch (e) {
    debugPrint('[Notification-Count] Initial fetch failed: $e');
    yield lastKnownCount;
  }

  await for (final _ in Stream.periodic(const Duration(seconds: 15))) {
    try {
      await supabase.checkConnection();
      lastKnownCount = await fetchUnreadCount();
      yield lastKnownCount;
    } catch (e) {
      debugPrint('[Notification-Count] Poll failed, keeping last value: $e');
      yield lastKnownCount;
    }
  }
}

/// Provider for fetching system notifications using repository pattern
@riverpod
Future<List<NotificationItem>> systemNotifications(
  SystemNotificationsRef ref,
) async {
  final repository = NotificationRepository();
  final result = await repository.getInbox(limit: 50);
  
  if (!result.success) {
    throw Exception(result.message);
  }
  
  return result.data;
}

/// Provider for notification repository
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository();
}

/// Provider for marking notification as read
@riverpod
Future<void> markNotificationAsRead(
  MarkNotificationAsReadRef ref,
  String notificationId,
) async {
  final repository = ref.read(notificationRepositoryProvider);
  final result = await repository.markAsRead(notificationId);
  
  if (!result.success) {
    throw Exception(result.message);
  }
}

/// Provider for marking all notifications as read
@riverpod
Future<void> markAllNotificationsAsRead(
  MarkAllNotificationsAsReadRef ref,
) async {
  final repository = ref.read(notificationRepositoryProvider);
  final result = await repository.markAllRead();
  
  if (!result.success) {
    throw Exception(result.message);
  }
}

/// Provider for deleting notification
@riverpod
Future<void> deleteNotification(
  DeleteNotificationRef ref,
  String notificationId,
) async {
  final repository = ref.read(notificationRepositoryProvider);
  final result = await repository.deleteNotification(notificationId);
  
  if (!result.success) {
    throw Exception(result.message);
  }
}

/// Provider for real-time notification sync
@riverpod
class NotificationRealtimeSync extends _$NotificationRealtimeSync {
  NotificationRepository? _repository;

  @override
  void build() {
    // Initialize repository
    _repository = ref.read(notificationRepositoryProvider);
    
    // Start real-time sync when provider is built
    ref.onDispose(() {
      _repository?.stopRealtimeSync();
    });
    
    return;
  }

  /// Starts real-time sync for notifications
  void startSync(void Function() onUpdate) {
    unawaited(_repository?.startRealtimeSync(onUpdate));
  }

  /// Stops real-time sync
  void stopSync() {
    _repository?.stopRealtimeSync();
  }
}
