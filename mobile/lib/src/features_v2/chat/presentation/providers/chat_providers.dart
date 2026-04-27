import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/repositories/chat_repository.dart';
import 'package:mobile/src/core/local_storage/isar_service_provider.dart';
import 'package:mobile/src/features_v2/chat/presentation/providers/unread_chat_provider.dart';

part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final client = Supabase.instance.client;
  final isar = ref.watch(isarServiceProvider).isar;
  return ChatRepository(client, isar);
}

@Riverpod(keepAlive: true)
Stream<List<ChatMessage>> chatSyncStream(ChatSyncStreamRef ref, String roomId) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Unauthorized');
  
  ref.onDispose(() => print('[Chat-Sync] Offloading stream: $roomId'));
  return ref.watch(chatRepositoryProvider).watchMessages(roomId, user.id);
}

// 🚀 Final Cache-Break: Renaming once more to sanitize memory
final chatPartnerIdentityProvider = FutureProvider.family<String?, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).getPartnerName(roomId);
});

final chatPartnerIdProvider = FutureProvider.family<String?, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).getPartnerId(roomId);
});

/// ✅ CONSOLIDATED PROVIDER: Single-shot identity resolution.
/// Replaces the chatPartnerIdProvider + chatPartnerIdentityProvider fan-out.
/// Returns: {'id', 'full_name', 'role'}
final partnerMetadataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).getPartnerSnapshot(roomId);
});

final chatPartnerFirstNameProvider = FutureProvider.family<String, String>((ref, roomId) async {
  final name = await ref.watch(chatPartnerIdentityProvider(roomId).future);
  if (name == null || name.isEmpty) return 'Admin';
  return name.split(' ').first;
});

final chatPartnerNameForLoanProvider = FutureProvider.family<String, int>((ref, loanId) async {
  final roomId = await ref.read(chatRepositoryProvider).getRoomIdForLoan(loanId);
  if (roomId == null) return 'Coordinator';
  return ref.watch(chatPartnerFirstNameProvider(roomId).future);
});

final partnerPresenceProvider = StreamProvider.family<DateTime?, String>((ref, partnerId) {
  // ── Hybrid Presence Calculation ──
  // Use the LATEST of: The DB's last_seen_at OR the latest message timestamp
  return Stream.periodic(const Duration(seconds: 30)) // Poll for message inference
      .asyncMap((_) async {
        try {
          // 1. Get DB Pulse
          final profile = await Supabase.instance.client
              .from('user_profiles')
              .select('last_seen')
              .eq('id', partnerId)
              .maybeSingle();

          final dbSeen = profile?['last_seen'] != null 
              ? DateTime.parse(profile!['last_seen']) 
              : null;

          // 2. Inference: Check latest message sent by partner
          final lastMsg = await Supabase.instance.client
              .from('chat_messages')
              .select('created_at')
              .eq('sender_id', partnerId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          final msgSeen = lastMsg?['created_at'] != null 
              ? DateTime.parse(lastMsg!['created_at']) 
              : null;

          // Return the high-water mark of liveness
          if (dbSeen == null) return msgSeen;
          if (msgSeen == null) return dbSeen;
          return dbSeen.isAfter(msgSeen) ? dbSeen : msgSeen;
        } catch (e) {
          return null;
        }
      });
});

@riverpod
class ChatSession extends _$ChatSession {
  final Map<String, ChatMessage> _optimisticMessages = {};

  @override
  List<ChatMessage> build(String roomId) {
    // 1. Listen to Scoped Messages
    final streamData = ref.watch(chatSyncStreamProvider(roomId));
    
    return streamData.maybeWhen(
      data: (messages) {
        // 2. Clean up optimistic
        for (final m in messages) {
          _optimisticMessages.remove(m.id);
        }
        
        // 3. Newest First (Required for reverse: true lists to show newest at bottom)
        final combined = [...messages, ..._optimisticMessages.values];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return combined;
      },
      orElse: () => _optimisticMessages.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  /// 🛡️ Kinetic Warm-up: Pre-fetches messages by ensuring the provider is active.
  void warmUp() {
    // Simply calling this ensures the build() logic (and sync stream) starts.
  }




  Future<void> sendMessage(String content) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final message = ChatMessage(
      id: const Uuid().v4(),
      roomId: roomId,
      senderId: user.id,
      receiverId: null, // ── User-vs-Admin: Resolved by Backend ──
      content: content,
      createdAt: DateTime.now().toUtc(),
      status: MessageStatus.sending,
    );

    _optimisticMessages[message.id] = message;
    ref.invalidateSelf();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(message);
    } catch (e) {
      _optimisticMessages[message.id] = message.copyWith(status: MessageStatus.error);
      ref.invalidateSelf();
    }
  }


  Future<void> retryMessage(ChatMessage message) async {
    _optimisticMessages[message.id] = message.copyWith(status: MessageStatus.sending);
    ref.invalidateSelf();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(message);
    } catch (e) {
      _optimisticMessages[message.id] = message.copyWith(status: MessageStatus.error);
      ref.invalidateSelf();
    }
  }

  Future<void> markAsRead() async {
    await ref.read(chatRepositoryProvider).markAsRead(roomId);
    ref.invalidate(unreadChatCountProvider);
  }

  Future<void> deleteRoom() async {
    await ref.read(chatRepositoryProvider).deleteRoom(roomId);
    ref.invalidateSelf();
  }
}

// 🚀 Tactical Fallback: Using standard Provider to unblock compiler
// while the generator catches up with the new features_v2 paths.
// 🚀 Tactical Handshake: Dynamic Label for Global FAB
final FutureProvider<String> chatDynamicFabLabelProvider = FutureProvider<String>((ref) async {
  try {
    final repo = ref.watch(chatRepositoryProvider);
    final roomId = await repo.getSupportRoomId();
    if (roomId == null) return 'Admin';
    
    return ref.watch(chatPartnerFirstNameProvider(roomId).future);
  } catch (e) {
    return 'Admin';
  }
});

final chatRoomOnlineUsersProvider = StreamProvider.family<List<String>, String>((ref, roomId) {
  final repo = ref.watch(chatRepositoryProvider);
  
  // ── Cleanup Hack ──
  // Ensure we leave the channel when the user exits the screen
  ref.onDispose(() => repo.leavePresenceChannel(roomId));
  
  return repo.watchOnlineUsers(roomId);
});
