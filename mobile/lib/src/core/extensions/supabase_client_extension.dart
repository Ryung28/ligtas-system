import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

extension SupabaseClientExtension on SupabaseClient {
  /// 🛡️ Health Check for Realtime Socket
  /// Ensures the driver-level connection is active before feature-level streams begin.
  Future<void> checkConnection() async {
    try {
      if (!realtime.isConnected) {
        debugPrint('[Supabase-Health] 💔 Socket Disconnected. Triggering reconnection...');

        // 🛠️ RELIABLE RECOVERY: Ensure we disconnect cleanly before attempting a fresh connect.
        // This clears any stale '1006' abnormal closure states in the driver.
        realtime.disconnect(); 
        await Future.delayed(const Duration(milliseconds: 500));
        realtime.connect();

        int poll = 0;
        while (!realtime.isConnected && poll < 5) {
          await Future.delayed(const Duration(seconds: 1));
          poll++;
          debugPrint('[Supabase-Health] ⏳ Polling socket status (Attempt $poll/5)...');
        }

        if (!realtime.isConnected) {
          throw TimeoutException('LIGTAS_SOCKET_OFFLINE: Coordination server unreachable.');
        }
      }
      debugPrint('[Supabase-Health] 💚 Socket Link: STABLE');
    } catch (e) {
      debugPrint('[Supabase-Health] ❌ Probe Failed: $e');
      rethrow;
    }
  }

}
