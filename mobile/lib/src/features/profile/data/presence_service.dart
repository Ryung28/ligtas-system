import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

/**
 * PresenceService (Heartbeat Logic)
 * 
 * 🛠️ Patterns Applied: Heartbeat Mechanism, Observer Pattern
 * 
 * This service updates the 'last_seen' column in the user_profiles table
 * every 2 minutes while the app is in the foreground.
 */
class PresenceService extends WidgetsBindingObserver {
  final Ref _ref;
  final SupabaseClient _client;
  Timer? _heartbeatTimer;
  static const _heartbeatInterval = Duration(minutes: 2);

  PresenceService(this._ref, this._client) {
    WidgetsBinding.instance.addObserver(this);
    // Initial start if already resumed
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _startHeartbeat();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _updatePresence());
    // Trigger immediately on start
    _updatePresence();
  }

  Future<void> _updatePresence() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // ── The Heartbeat Handshake ──
      // Updates the individual profile to signal 'Online' status to the web dashboard
      await _client
          .from('user_profiles')
          .update({'last_seen': DateTime.now().toUtc().toIso8601String()})
          .eq('id', userId);
      
      print('[Presence-Service] Heartbeat delivered at ${DateTime.now()}');
    } catch (e) {
      debugPrint('[Presence-Service] Sync Failure: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ── Foreground Detection ──
    // Only pulse the heartbeat when the operator is actively using the app
    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
    } else {
      _heartbeatTimer?.cancel();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
  }
}

/// Provider to initialize and maintain the presence heartbeat
final presenceServiceProvider = Provider<PresenceService>((ref) {
  final client = Supabase.instance.client;
  final service = PresenceService(ref, client);
  
  // Ensure cleanup when provider is destroyed
  ref.onDispose(() => service.dispose());
  
  return service;
});
