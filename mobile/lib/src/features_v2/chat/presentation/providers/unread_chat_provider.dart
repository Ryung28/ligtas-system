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

      // ── Realtime Unread Pulse ──
      yield* client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('receiver_id', user.id)
          .map((data) {
            final unreadMessages = data.where((m) => m['is_read'] == false).toList();
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
