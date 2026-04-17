import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  int retryCount = 0;
  const maxRetries = 3;

  while (retryCount < maxRetries) {
    try {
      // 🛡️ Health Check
      await supabase.checkConnection();

      // Count unread using the same role-aware inbox pipeline as web/mobile feed.
      Future<int> fetchUnreadCount() async {
        final result = await repository.getInbox(limit: 200);
        if (!result.success) {
          throw Exception(result.message);
        }
        return result.data.where((notification) => !notification.isRead).length;
      }

      yield await fetchUnreadCount();
      yield* Stream.periodic(const Duration(seconds: 15))
          .asyncMap((_) => fetchUnreadCount())
          .handleError((error) {
        debugPrint('[Notification-Count] Stream Error: $error');
        throw error;
      });
      
      break;
    } catch (e) {
      retryCount++;
      debugPrint('[Notification-Count] Reconnecting socket (Attempt $retryCount/$maxRetries)...');
      await Future.delayed(Duration(seconds: retryCount * 2));
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
