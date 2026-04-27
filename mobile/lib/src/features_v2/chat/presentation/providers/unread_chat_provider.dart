import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/core/extensions/supabase_client_extension.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

part 'unread_chat_provider.g.dart';

/**
 * UnreadChatCount Provider
 * 
 * 🛠️ Patterns Applied: Realtime Stream Observation, Tactical Filtering, Socket Resilience
 */
@riverpod
Stream<int> unreadChatCount(UnreadChatCountRef ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield 0;
    return;
  }

  final client = Supabase.instance.client;
  int retryCount = 0;
  const maxRetries = 3;

  while (retryCount < maxRetries) {
    try {
      // 🛡️ Ensure the underlying socket is warm
      await client.checkConnection();

      final role = user.role.toLowerCase();
      final isViewer = role == 'viewer';

      // Determine which rooms this actor can read. This avoids relying on
      // receiver_id, which is nullable in support-thread writes.
      Set<String> accessibleRoomIds = <String>{};
      if (isViewer) {
        final rooms = await client
            .from('chat_rooms')
            .select('id')
            .eq('borrower_user_id', user.id);
        accessibleRoomIds = rooms
            .map((row) => row['id']?.toString())
            .whereType<String>()
            .toSet();
      } else {
        final viewerProfiles = await client
            .from('user_profiles')
            .select('id')
            .eq('role', 'viewer');
        final viewerIds = viewerProfiles
            .map((row) => row['id']?.toString())
            .whereType<String>()
            .toList();

        final orFilters = <String>['borrower_user_id.eq.${user.id}'];
        if (viewerIds.isNotEmpty) {
          orFilters.add('borrower_user_id.in.(${viewerIds.join(',')})');
        }

        final rooms = await client
            .from('chat_rooms')
            .select('id')
            .or(orFilters.join(','));
        accessibleRoomIds = rooms
            .map((row) => row['id']?.toString())
            .whereType<String>()
            .toSet();
      }

      if (accessibleRoomIds.isEmpty) {
        yield 0;
        return;
      }

      // ── Realtime Unread Pulse ──
      yield* client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .map((data) {
            final unreadMessages = data.where((m) {
              final isUnread = m['is_read'] == false;
              final isNotMine = m['sender_id']?.toString() != user.id;
              final roomId = m['room_id']?.toString();
              final canAccessRoom =
                  roomId != null && accessibleRoomIds.contains(roomId);
              return isUnread && isNotMine && canAccessRoom;
            }).toList();
            return unreadMessages.length;
          })
          .handleError((error) {
            debugPrint('[Unread-Chat] Stream Error: $error');
            throw error;
          });
      
      break; // Success
    } catch (e) {
      retryCount++;
      debugPrint('[Unread-Chat] Reconnecting socket (Attempt $retryCount/$maxRetries)...');
      await Future.delayed(Duration(seconds: retryCount * 2));
    }
  }
}
