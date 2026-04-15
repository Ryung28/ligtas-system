import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/core/utils/performance_utils.dart';
import 'src/app.dart';
import 'src/core/local_storage/isar_service.dart';
import 'src/core/networking/supabase_client.dart';
import 'src/features/notifications/data/services/user_notification_service.dart';
import 'src/features/notifications/data/services/notification_isolate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'src/core/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛡️ STEP 1: DNS WARM-UP GUARD
  // On certain Android OEMs (e.g. Infinix/Tecno), the network stack is 
  // not ready immediately after boot. We probe DNS before using the socket.
  await _waitForNetwork();

  // 🔍 STEP 2: Confirm sanitized environment target at runtime
  debugPrint('[LIGTAS-Boot] 🌐 API Target: ${Environment.supabaseUrl}');

  // 🛡️ STEP 3: Initialize Supabase with a timeout safety net
  await SupabaseService.initialize();

  // 🛡️ STEP 4: Initialize Firebase
  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    debugPrint('[LIGTAS-Boot] ✅ Analytics Handshake Complete.');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // Async: non-blocking notification service setup
    UserNotificationService().initialize();
  } catch (e) {
    debugPrint("🔥 Firebase Initialization Error: $e");
  }

  // 🛡️ STEP 4: Set High Refresh Rate (deferred to avoid Gralloc mismatch)
  if (Platform.isAndroid) {
    Future.delayed(const Duration(milliseconds: 500), () => PerformanceUtils.enforceHighRefreshRate());
  }

  // 🛡️ STEP 5: Initialize Local Storage  
  await IsarService.init();

  runApp(
    const ProviderScope(
      child: LigtasApp(),
    ),
  );
}

/// 🌐 DNS WARM-UP: Blocks until network is reachable or times out gracefully.
/// This prevents 'Failed host lookup' SocketExceptions during Supabase init.
Future<void> _waitForNetwork({int maxRetries = 5}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      debugPrint('[Boot-Guard] 🌐 DNS probe attempt $attempt/$maxRetries...');
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        debugPrint('[Boot-Guard] ✅ DNS resolution confirmed. Network is ready.');
        return;
      }
    } on SocketException {
      debugPrint('[Boot-Guard] ⚠️ Network not ready. Attempt $attempt/$maxRetries.');
    } catch (e) {
      debugPrint('[Boot-Guard] ⚠️ Probe error: $e. Attempt $attempt/$maxRetries.');
    }
    // Exponential back-off: 500ms, 1000ms, 2000ms...
    await Future.delayed(Duration(milliseconds: 500 * attempt));
  }
  debugPrint('[Boot-Guard] 🔴 Network unreachable after $maxRetries attempts. Proceeding offline.');
}

