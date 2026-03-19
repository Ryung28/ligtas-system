import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/core/networking/supabase_client.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

/**
 * Presence Heartbeat class.
 * Tracks the user's presence by updating 'last_seen' in the database.
 */
class PresenceHeartbeat extends WidgetsBindingObserver {
  final Ref _ref;
  Timer? _heartbeatTimer;
  static const _heartbeatInterval = Duration(minutes: 2);

  PresenceHeartbeat(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _updatePresence());
    // Initial update
    _updatePresence();
  }

  Future<void> _updatePresence() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await SupabaseService.client
          .from('user_profiles')
          .update({'last_seen': DateTime.now().toUtc().toIso8601String()})
          .eq('id', user.id);
    } catch (e) {
      debugPrint('[Presence] Heartbeat failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _heartbeatTimer?.cancel();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
  }
}

/// Provider to initialize the heartbeat mechanism
final presenceHeartbeatProvider = Provider((ref) {
  final heartbeat = PresenceHeartbeat(ref);
  ref.onDispose(() => heartbeat.dispose());
  return heartbeat;
});
