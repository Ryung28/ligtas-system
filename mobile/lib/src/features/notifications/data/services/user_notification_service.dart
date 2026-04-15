import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:mobile/src/features/notifications/data/models/notification_config_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/core/navigation/navigator_key.dart';
import 'package:audioplayers/audioplayers.dart';

enum SyncStatus { success, failing, retrying }

class NotificationSyncState {
  final bool isSynced;
  final String? errorMessage;
  final bool isRetrying;

  const NotificationSyncState({
    this.isSynced = true,
    this.errorMessage,
    this.isRetrying = false,
  });

  NotificationSyncState copyWith({
    bool? isSynced,
    String? errorMessage,
    bool? isRetrying,
  }) {
    return NotificationSyncState(
      isSynced: isSynced ?? this.isSynced,
      errorMessage: errorMessage ?? this.errorMessage,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }
}

/// 🚨 LIGTAS ENTERPRISE NOTIFICATION SYSTEM
/// Implementation of advanced messaging styles, quick actions, and high-priority coordination channels.
class UserNotificationService {
  static final UserNotificationService _instance = UserNotificationService._internal();
  factory UserNotificationService() => _instance;
  UserNotificationService._internal();


  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // 🛡️ TACTICAL GUARD: Reference to the active stream to prevent leaks
  StreamSubscription<RemoteMessage>? _messagingSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  DateTime _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  static final StreamController<String> _navStream = StreamController<String>.broadcast();
  static Stream<String> get navigationStream => _navStream.stream;

  // 🔄 Sync Status: UI listens to this for disaster recovery
  static final ValueNotifier<NotificationSyncState> syncStatus = ValueNotifier(const NotificationSyncState());

  // 🛡️ LIFECYCLE GUARD: Prevents the listener from being garbage collected
  AppLifecycleListener? _lifecycleListener;


  // ============================================================
  // 🏗️ SINGLE SOURCE OF TRUTH: Channel Constants
  // Update this ONE constant to rename the channel system-wide.
  // ============================================================
  static const String kEmergencyChannelId = 'emergency_coordination_v7';

  SupabaseClient get _supabase => Supabase.instance.client;

  // 📡 Emergency Coordination: v6 High-Importance Tactical Channel
  static const AndroidNotificationChannel _emergencyChannel = AndroidNotificationChannel(
    kEmergencyChannelId,
    'Emergency Coordination',
    description: 'High-priority channel for Heads-Up alerts and disaster coordination.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('critical_alarm'),
    enableVibration: true,
    showBadge: true,
  );

  Future<void> initialize() async {
    debugPrint('📡 [ENTERPRISE-DISPATCHER]: Booting Tactical Notification Pipeline...');

    // 🛡️ PERMISSION ESCALATION: Explicitly request for Android 13+
    NotificationSettings permSettings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (permSettings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('📡 [ENTERPRISE-DISPATCHER]: Tactical Auth Granted (Priority High)');
    } else {
      debugPrint('📡 [ENTERPRISE-DISPATCHER]: ⚠️ Auth Conflict: ${permSettings.authorizationStatus}');
    }

    // 1. Branding: Use dedicated monochrome silhouette icon for Android status bar compliance.
    // 🛡️ TACTICAL FIX: @drawable/ic_stat_cdrrmo_logo is the user-provided white-on-transparent PNG
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@drawable/ic_stat_cdrrmo_logo');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    
    try {
      // 🛡️ ACTUAL API FIX: v20.1.0 (Installed) REQUIRES named parameters
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          _handleNotificationAction(details);
        },
      );
      
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      // 🛡️ Step 3: Channel Lifecycle Audit
      // Android channels are immutable once created. We must delete/re-create to update the sound resource.
      debugPrint('📡 [ENTERPRISE-DISPATCHER]: Purging legacy Acoustic Channels...');
      await androidPlugin?.deleteNotificationChannel(channelId: 'emergency_coordination'); // Clean legacy v1
      await androidPlugin?.deleteNotificationChannel(channelId: 'emergency_coordination_v4'); // Clean v4
      await androidPlugin?.deleteNotificationChannel(channelId: 'emergency_coordination_v5'); // Clean v5
      await androidPlugin?.deleteNotificationChannel(channelId: 'emergency_coordination_v6'); // Clean v6
      await androidPlugin?.deleteNotificationChannel(channelId: 'emergency_coordination_v6_chat'); // Clean v6 chat
      await androidPlugin?.deleteNotificationChannel(channelId: 'LIGTAS_CRITICAL_V2'); // Clean v2
      await androidPlugin?.deleteNotificationChannel(channelId: _emergencyChannel.id); // v7 refresh
      
      if (Platform.isAndroid) {
        await androidPlugin?.createNotificationChannel(_emergencyChannel);
      }
      
      debugPrint('📡 [ENTERPRISE-DISPATCHER]: Tactical Channels Locked (v7 Hub)');
      
      // 🛡️ Steel Cage Lifecycle Binding
      _lifecycleListener?.dispose();
      _lifecycleListener = AppLifecycleListener(
        onResume: () {
          debugPrint('📡 [ENTERPRISE-DISPATCHER]: ❤️ Heartbeat: App resumed. Syncing tokens...');
          _refreshAndSaveToken();
        },
        onDetach: () {
          debugPrint('📡 [ENTERPRISE-DISPATCHER]: 🛑 Signal Interrupted: Cleaning up streams.');
        },
      );


      // 🛡️ STREAM ORCHESTRATION: Bind FCM to Local Display logic
      // TACTICAL GUARD: Ensure only one listener represents the doorman.
      await _messagingSubscription?.cancel();
      _messagingSubscription = FirebaseMessaging.onMessage.listen((message) => _showRichNotification(message));
      
      // ── 🛰️ FOREGROUND REALTIME PULSE: The Unified Acoustic Dispatcher ──
      // Catch 'system_notifications' Sink and play audio instantly if the app is in the foreground.
      await _realtimeSubscription?.cancel();
      _realtimeSubscription = _supabase
          .from('system_notifications')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .listen((data) {
        if (data.isEmpty) return;
        final latest = data.first;
        final createdAt = DateTime.parse(latest['created_at']);
        
        // 🛡️ FRESHNESS GUARD: Only play for events that happened in the last 10 seconds
        if (DateTime.now().difference(createdAt).inSeconds > 10) return;

        // 🛡️ ACOUSTIC DEBOUNCE: Prevent "Machine Gun" audio during bulk sync
        if (DateTime.now().difference(_lastPlayTime).inSeconds < 3) return;
        _lastPlayTime = DateTime.now();

        final type = latest['type'] as String;
        final player = AudioPlayer();

        // 🏗️ TACTICAL ACOUSTIC MAPPING
        if (['borrow_request', 'security_trigger', 'stock_out'].contains(type)) {
          player.play(AssetSource('sounds/critical_alarm.mp3'));
        } else {
          player.play(AssetSource('sounds/notification.mp3'));
        }
      });
      
      // Handle taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final roomId = message.data['roomId'] ?? message.data['room_id'];
        final path = message.data['path'] ?? (roomId != null ? '/chat/$roomId' : '/dashboard');
        final context = rootNavigatorKey.currentState?.context;
        if (context != null) GoRouter.of(context).push(path);
      });

      // Handle cold start from notification
      _fcm.getInitialMessage().then((message) {
        if (message != null) {
          final roomId = message.data['roomId'] ?? message.data['room_id'];
          final path = message.data['path'] ?? (roomId != null ? '/chat/$roomId' : '/dashboard');
          final context = rootNavigatorKey.currentState?.context;
          if (context != null) GoRouter.of(context).push(path);
        }
      });
    } catch (e) {
      debugPrint('📡 FCM: ⚠️ Initialization Failed: $e');
    }
  }

  /// ❤️ Lifecycle Orchestration: Direct sync trigger for auth listeners
  Future<void> syncDeviceToken() async {
    await _refreshAndSaveToken();
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  // 🛡️ TACTICAL SYNC: Called by global auth listener
  Future<void> handleAuthStateChange(String? userId) async {
    if (userId != null) {
      debugPrint('[Notification-Facade] Auth change detected for $userId. Initiating sync...');
      await _refreshAndSaveToken();
    } else {
      debugPrint('[Notification-Facade] User logged out. Clearing sync status.');
      syncStatus.value = const NotificationSyncState(isSynced: true);
    }
  }

  Future<void> _refreshAndSaveToken() async {
    syncStatus.value = syncStatus.value.copyWith(isRetrying: true);
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      syncStatus.value = syncStatus.value.copyWith(isSynced: false, isRetrying: false);
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('[Chat-Push] 🛡️ ABORTed: No valid session for registration.');
      syncStatus.value = syncStatus.value.copyWith(isRetrying: false);
      return;
    }

    try {
      // 🛡️ TACTICAL GUARD: Idempotent Sync (Isar-First)
      // Only sync if the token OR the user has changed since last local registry.
      final isar = IsarService.instance;
      final config = await isar.notificationConfigs.get(0);
      
      if (config != null && config.lastFCMToken == token && config.lastRegisteredUserId == user.id) {
        debugPrint('[Chat-Push] 🛡️ SKIPped: Token already registry-synced for this user.');
        syncStatus.value = const NotificationSyncState(isSynced: true, isRetrying: false);
        return;
      }

      final platform = kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
      
      debugPrint('[Chat-Push] 🛰️ Initiating Upsert for user ${user.id} ($platform)...');
      
      // 🛡️ Use the Idempotent RPC to handle conflicts server-side
      await _supabase.rpc('handle_device_token', params: {
        'p_user_id': user.id,
        'p_token': token,
        'p_platform': platform,
      }).timeout(const Duration(seconds: 15));
      
      // 🏗️ Commit to local Vault (Isar)
      await isar.writeTxn(() async {
        await isar.notificationConfigs.put(NotificationConfig()
          ..lastFCMToken = token
          ..lastRegisteredUserId = user.id
          ..lastSyncedAt = DateTime.now());
      });

      syncStatus.value = const NotificationSyncState(isSynced: true, isRetrying: false);
      debugPrint('📡 FCM: Enterprise Token Registered IDEMPOTENTLY ($platform)');
    } catch (e) {
      debugPrint('[Chat-Push] ⚠️ Registry Failure: $e');
      syncStatus.value = NotificationSyncState(isSynced: false, isRetrying: false);
    }
  }

  void _handleNotificationAction(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null) {
      debugPrint('🧭 Notification Action: Navigating to $payload');
      final context = rootNavigatorKey.currentState?.context;
      if (context != null) {
        // Ensure path starts with /
        final path = payload.startsWith('/') ? payload : '/chat/$payload';
        GoRouter.of(context).push(path);
      }
    }
  }

  void _showRichNotification(RemoteMessage message, {bool isForeground = true}) {
    debugPrint('[FCM-Pulse] 📦 UI Banner Dispatch | Channel: $kEmergencyChannelId | Payload: ${message.data}');
    debugPrint('📡 FCM: Processing message payload (Foreground: $isForeground)...');
    
    final notification = message.notification;
    final data = message.data;

    // 1. Extract Identifiers
    final roomId = data['roomId'] ?? data['room_id'];
    final path = data['path'] ?? (roomId != null ? '/chat/$roomId' : '/dashboard');

    // 🛡️ THE STEEL CAGE: Context-Aware Suppression
    if (isForeground && roomId != null) {
      final context = rootNavigatorKey.currentState?.context;
      if (context != null) {
        final router = GoRouter.of(context);
        final currentPath = router.routeInformationProvider.value.uri.path;
        
        // If user is already in this specific chat room, ABORT local notification
        if (currentPath.contains('/chat/$roomId')) {
          debugPrint('🛡️ Guard: User already in chat $roomId. Silencing duplicate alert.');
          return;
        }
      }
    }

    // 2. Extract Content
    final title = notification?.title ?? data['title'] ?? data['sender_name'] ?? 'LIGTAS Alert';
    final body = notification?.body ?? data['body'] ?? data['message'] ?? 'Check your dashboard for updates.';
    
    final senderName = data['sender_name'] ?? 'LIGTAS Operator';
    
    // 3. Determine Messaging Style
    final isChat = data['type'] == 'CHAT' || roomId != null;

    // 🛡️ DETERMINISTIC ID: Calculate a stable ID based on RoomID
    // This forces Android to overwrite old notifications for the same room.
    final int notificationId = roomId?.hashCode ?? message.hashCode;

    final style = BigTextStyleInformation(
      body,
      contentTitle: title,
      // Removed "Coordination Message" summary to reduce visual noise
      summaryText: null, 
    );

    _display(notificationId, title, body, style, path);
  }

  void _display(int id, String title, String? body, StyleInformation style, String payload) {
    _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          kEmergencyChannelId,
          _emergencyChannel.name,
          channelDescription: _emergencyChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: style,
          color: const Color(0xFF3B82F6),
          // 🛡️ MONOCHROME MANDATE: Using the user-uploaded white-on-transparent icon
          icon: '@drawable/ic_stat_cdrrmo_logo',
          sound: const RawResourceAndroidNotificationSound('critical_alarm'),
          playSound: true,
          category: AndroidNotificationCategory.alarm,
          // 🛡️ TIME STANDARDS: Show when the message was received (Messenger Style)
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
          actions: [
            AndroidNotificationAction(
              'reply_action',
              'Reply',
              // 🛡️ TACTICAL FIX: Removed icon to prevent native crash
              inputs: [
                const AndroidNotificationActionInput(label: 'Type message...'),
              ],
            ),
            const AndroidNotificationAction(
              'read_action',
              'Mark as Read',
              showsUserInterface: false,
            ),
          ],
        ),
      ),
      payload: payload,
    );
  }
  /// 🛡️ STEEL CAGE DISPOSAL
  /// Prevents memory leaks and dangling subscriptions
  void dispose() {
    _messagingSubscription?.cancel();
    _lifecycleListener?.dispose();
    debugPrint('📡 [ENTERPRISE-DISPATCHER]: 💀 System Offline: Pipeline disassembled.');
  }
}
