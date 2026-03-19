import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

mixin SupabasePresenceMixin {
  SupabaseClient get client;

  /// 📡 Watch online users in a specific room
  Stream<List<String>> watchOnlineUsers(String roomId) {
    final myId = client.auth.currentUser?.id;
    StreamController<List<String>>? controller;
    RealtimeChannel? channel;

    controller = StreamController<List<String>>(
      onListen: () {
        debugPrint('[Presence] 🔌 Connecting to presence channel: $roomId');
        channel = client.channel('presence:$roomId');
        
        channel!
            .onPresenceSync((payload) {
              if (controller != null && !controller.isClosed) {
                final state = channel!.presenceState();
                
                final List<String> userIds = (state as List<SinglePresenceState>).expand((SinglePresenceState sps) {
                  return sps.presences;
                }).map((Presence p) {
                  return p.payload['user_id'] as String?;
                }).whereType<String>().toSet().toList();
                
                debugPrint('[Presence] 👥 Online Users: $userIds');
                controller!.add(userIds);
              }
            })
            .subscribe((status, error) {
              if (status == RealtimeSubscribeStatus.subscribed && myId != null) {
                channel?.track({'user_id': myId, 'online_at': DateTime.now().toIso8601String()});
              }
            });
      },
      onCancel: () async {
        debugPrint('[Presence] 🔌 Disconnecting presence channel: $roomId');
        await channel?.unsubscribe();
      },
    );

    return controller.stream;
  }

  /// 🙋‍♂️ Broadcast manual heartbeat to profiles table
  Future<void> sendHeartbeat() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await client.from('user_profiles').update({
        'last_seen': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[Presence] Heartbeat failed: $e');
    }
  }
}
