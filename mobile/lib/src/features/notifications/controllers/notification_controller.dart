import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../providers/notification_status_provider.dart';
import '../data/services/user_notification_service.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationController extends _$NotificationController {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _service = UserNotificationService();

  @override
  FutureOr<void> build() async {
    // Initial sync on startup
    await initialize();
  }

  Future<void> initialize() async {
    debugPrint('📡 FCM: Initializing Tactical Notification Status Sync...');

    // 1. Request Permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await refreshAndSaveToken();
    }

    // 2. Listen for token refresh
    _fcm.onTokenRefresh.listen((token) async {
       await _service.handleAuthStateChange(Supabase.instance.client.auth.currentUser?.id);
    });
  }

  Future<void> refreshAndSaveToken() async {
    ref.read(notificationStatusNotifierProvider.notifier).setRetrying();
    
    try {
      await _service.syncDeviceToken();
      ref.read(notificationStatusNotifierProvider.notifier).setSynced();
    } catch (e) {
      debugPrint('📡 FCM Error: $e');
      ref.read(notificationStatusNotifierProvider.notifier).setFailing(e.toString());
    }
  }
}
