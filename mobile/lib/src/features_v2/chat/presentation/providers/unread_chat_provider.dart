import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';

part 'unread_chat_provider.g.dart';

/**
 * UnreadChatCount Provider
 * 
 * 🛠️ Patterns Applied: Realtime Stream Observation, Tactical Filtering
 * 
 * This provider listens to the 'chat_messages' table in realtime.
 * It counts all messages where:
 * 1. is_read = false
 * 2. receiver_id = current user's ID
 */
@riverpod
Stream<int> unreadChatCount(UnreadChatCountRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);

  final client = Supabase.instance.client;

  // ── Realtime Unread Pulse ──
  // Listens specifically for unread messages targeting the current user
  return client
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('receiver_id', user.id)
      .map((data) {
        // Local Filter: supabase streams only support a single equality filter.
        // We filter for is_read=false in Dart to comply with current SDK constraints.
        final unreadMessages = data.where((m) => m['is_read'] == false).toList();
        
        if (unreadMessages.isNotEmpty) {
          print('[Unread-Chat] Found ${unreadMessages.length} unread targeting ${user.id}');
        }
        return unreadMessages.length;
      });
}
