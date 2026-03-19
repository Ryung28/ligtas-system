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
        realtime.connect();
        
        int poll = 0;
        while (!realtime.isConnected && poll < 5) {
          await Future.delayed(const Duration(seconds: 1));
          poll++;
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
