import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui';

/**
 * 🛰️ ResQTrack NOTIFICATION ISOLATE
 * Strict quarantine for background execution. No UI, no Riverpod, no context.
 */
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 1. Initialize Firebase in background isolate
  await Firebase.initializeApp();

  final notification = message.notification;
  final data = message.data;

  // 2. Data-only payload extraction (Versioned Guard)
  final title = notification?.title ?? data['title'] ?? data['sender_name'] ?? 'ResQTrack Tactical Update';
  final body = notification?.body ?? data['body'] ?? data['message'] ?? 'New operation logged. Check dashboard.';

  final localNotifs = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  
  await localNotifs.initialize(
    settings: const InitializationSettings(android: androidInit),
  );

  await localNotifs.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'emergency_coordination_v7',
        'Emergency Coordination',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF3B82F6),
        sound: RawResourceAndroidNotificationSound('critical_alarm'),
        playSound: true,
      ),
    ),
  );
}
