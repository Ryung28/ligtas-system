import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:mobile/src/features/notifications/data/models/notification_model.dart';
import 'dart:async';

/// 🛰️ MOBILE NOTIFICATION REPOSITORY
/// Implements the same repository pattern as web dashboard
/// Uses Supabase RPC calls for consistent data access
class NotificationRepository {
  final SupabaseClient _supabase;
  StreamSubscription? _notificationStream;
  StreamSubscription? _readReceiptStream;
  Timer? _realtimeDebounce;
  static const Set<String> _mobileAnalystRoles = {
    'admin',
    'staff',
    'editor',
    'analyst',
    'responder',
  };
  static const Set<String> _mobileAnalystExcludedTypes = {
    'chat_message',
    'chat_message_ops',
    'chat_message_personal',
    'borrow_request',
    'borrow_request_new',
    'borrow_approved',
    'borrow_rejected',
    'request_approved',
    'request_rejected',
  };
  static const Set<String> _operationalAlertTypes = {
    'stock_low',
    'stock_out',
    'low_stock',
    'item_overdue',
  };
  static const Set<String> _operationalRoles = {
    'admin',
    'staff',
    'editor',
    'analyst',
    'responder',
  };

  NotificationRepository() : _supabase = Supabase.instance.client;

  /// Starts real-time subscription for notifications (like web dashboard)
  Future<void> startRealtimeSync(void Function() onUpdate) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Clean up existing subscriptions
    _notificationStream?.cancel();
    _readReceiptStream?.cancel();
    _realtimeDebounce?.cancel();

    void scheduleRefresh() {
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(const Duration(milliseconds: 350), onUpdate);
    }

    // 📡 STREAM A: System notifications (like web)
    // Listen to all visible notifications for the session user.
    // This captures both targeted rows and role-based broadcasts.
    _notificationStream = _supabase
        .from('system_notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .listen((_) {
          scheduleRefresh();
        });

    // 📡 STREAM B: Read receipts (like web)
    _readReceiptStream = _supabase
        .from('notification_reads')
        .stream(primaryKey: ['notification_id', 'user_id'])
        .eq('user_id', userId)
        .listen((_) {
          scheduleRefresh();
        });
  }

  /// Stops real-time subscriptions
  void stopRealtimeSync() {
    _notificationStream?.cancel();
    _readReceiptStream?.cancel();
    _realtimeDebounce?.cancel();
    _notificationStream = null;
    _readReceiptStream = null;
    _realtimeDebounce = null;
  }

  /// Fetches the user's notification inbox using the same RPC as web
  Future<NotificationResult> getInbox({int limit = 20}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return NotificationResult(
          success: false,
          data: [],
          message: 'User not authenticated',
        );
      }

      // 🛡️ Use the same RPC function as web dashboard
      final response = await _supabase
          .rpc('get_user_inbox', params: {'p_limit': limit})
          .timeout(const Duration(seconds: 10));

      final List<dynamic> data = response as List<dynamic>;
      final role = await _getCurrentUserRole();

      // Map to domain models
      final notifications =
          data
              .map((item) {
                return NotificationItem(
                  id: item['id']?.toString() ?? '',
                  userId: item['user_id']?.toString(),
                  referenceId: item['reference_id']?.toString(),
                  title: item['title']?.toString() ?? 'System Alert',
                  message:
                      item['message']?.toString() ??
                      'Mission status information update.',
                  time:
                      item['created_at']?.toString() ??
                      DateTime.now().toIso8601String(),
                  type: item['type']?.toString() ?? 'system_alert',
                  isRead: item['is_read'] == true,
                  metadata:
                      item['metadata'] is Map<String, dynamic>
                          ? Map<String, dynamic>.from(item['metadata'] as Map)
                          : {},
                );
              })
              .where((notification) {
                return _isVisibleOnMobileForRole(notification.type, role);
              })
              .toList();

      // Cache in local storage for offline access
      await _cacheNotifications(notifications);

      return NotificationResult(
        success: true,
        data: notifications,
        message: 'Intel synchronized',
      );
    } catch (error) {
      debugPrint('[NotificationRepository] Error fetching inbox: $error');

      // Fallback to cached data
      final cached = await _getCachedNotifications();
      if (cached.isNotEmpty) {
        return NotificationResult(
          success: true,
          data: cached,
          message: 'Using cached data (offline mode)',
        );
      }

      return NotificationResult(
        success: false,
        data: [],
        message: error.toString(),
      );
    }
  }

  /// Marks a notification as read
  Future<NotificationResult> markAsRead(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return NotificationResult(
          success: false,
          data: [],
          message: 'User not authenticated',
        );
      }

      // 🛡️ Insert into notification_reads junction table (same as web)
      await _supabase
          .from('notification_reads')
          .upsert({'notification_id': notificationId, 'user_id': userId})
          .timeout(const Duration(seconds: 5));

      // Update local cache
      await _updateLocalReadStatus(notificationId, true);

      return NotificationResult(
        success: true,
        data: [],
        message: 'Intel marked as read',
      );
    } catch (error) {
      debugPrint('[NotificationRepository] Error marking as read: $error');
      return NotificationResult(
        success: false,
        data: [],
        message: error.toString(),
      );
    }
  }

  /// Marks all notifications as read
  Future<NotificationResult> markAllRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return NotificationResult(
          success: false,
          data: [],
          message: 'User not authenticated',
        );
      }

      // 1. Fetch unread notifications
      final inboxResult = await getInbox(limit: 1000);
      if (!inboxResult.success) {
        return inboxResult;
      }

      final unreadNotifications =
          inboxResult.data.where((n) => !n.isRead).toList();
      if (unreadNotifications.isEmpty) {
        return NotificationResult(
          success: true,
          data: [],
          message: 'Inbox is already operational',
        );
      }

      // 2. Bulk insert into notification_reads
      final unreadIds =
          unreadNotifications
              .map((n) => ({'notification_id': n.id, 'user_id': userId}))
              .toList();

      await _supabase
          .from('notification_reads')
          .upsert(unreadIds)
          .timeout(const Duration(seconds: 10));

      // Update all local notifications as read
      await _markAllLocalAsRead();

      return NotificationResult(
        success: true,
        data: [],
        message: 'Full inbox sync complete',
      );
    } catch (error) {
      debugPrint('[NotificationRepository] Error marking all as read: $error');
      return NotificationResult(
        success: false,
        data: [],
        message: error.toString(),
      );
    }
  }

  /// Deletes a notification
  Future<NotificationResult> deleteNotification(String notificationId) async {
    try {
      // 🛡️ Hard delete from system_notifications (same as web)
      await _supabase
          .from('system_notifications')
          .delete()
          .eq('id', notificationId)
          .timeout(const Duration(seconds: 5));

      // Remove from local cache
      await _removeFromLocalCache(notificationId);

      return NotificationResult(
        success: true,
        data: [],
        message: 'Intel erased',
      );
    } catch (error) {
      debugPrint(
        '[NotificationRepository] Error deleting notification: $error',
      );
      return NotificationResult(
        success: false,
        data: [],
        message: error.toString(),
      );
    }
  }

  // ============================================================
  // LOCAL CACHE MANAGEMENT
  // ============================================================

  Future<void> _cacheNotifications(List<NotificationItem> notifications) async {
    final col = IsarService.notificationItems;
    await IsarService.instance.writeTxn(() async {
      await col.clear();
      for (final notification in notifications) {
        await col.put(NotificationCollection.fromModel(notification));
      }
    });
  }

  Future<List<NotificationItem>> _getCachedNotifications() async {
    final entities = await IsarService.notificationItems.where().findAll();
    return entities.map((e) => e.toModel()).toList();
  }

  Future<void> _updateLocalReadStatus(
    String notificationId,
    bool isRead,
  ) async {
    final col = IsarService.notificationItems;
    final entity = await col.getByRemoteId(notificationId);
    if (entity != null) {
      entity.isRead = isRead;
      await IsarService.instance.writeTxn(() async {
        await col.put(entity);
      });
    }
  }

  Future<void> _markAllLocalAsRead() async {
    final col = IsarService.notificationItems;
    final entities = await col.where().findAll();
    await IsarService.instance.writeTxn(() async {
      for (final entity in entities) {
        entity.isRead = true;
        await col.put(entity);
      }
    });
  }

  Future<void> _removeFromLocalCache(String notificationId) async {
    final col = IsarService.notificationItems;
    await IsarService.instance.writeTxn(() async {
      await col.deleteByRemoteId(notificationId);
    });
  }

  Future<String?> _getCurrentUserRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final profile = await _supabase
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      return profile?['role']?.toString().toLowerCase();
    } catch (_) {
      return null;
    }
  }

  bool _isVisibleOnMobileForRole(String notificationType, String? role) {
    final normalizedType = notificationType.toLowerCase();
    final normalizedRole = role?.toLowerCase();

    // Default-safe for unknown role: hide operational-only alerts.
    if (normalizedRole == null) {
      return !_operationalAlertTypes.contains(normalizedType);
    }

    // Production rule: low-stock and overdue operational alerts are analyst-side only.
    if (_operationalAlertTypes.contains(normalizedType) &&
        !_operationalRoles.contains(normalizedRole)) {
      return false;
    }

    // Existing analyst feed policy: hide chat + approval traffic on analyst stream.
    if (_mobileAnalystRoles.contains(normalizedRole)) {
      return !_mobileAnalystExcludedTypes.contains(normalizedType);
    }

    return true;
  }
}

class NotificationResult {
  final bool success;
  final List<NotificationItem> data;
  final String message;

  NotificationResult({
    required this.success,
    required this.data,
    required this.message,
  });
}
