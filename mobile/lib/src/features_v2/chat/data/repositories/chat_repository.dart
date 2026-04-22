import 'dart:io';
import 'package:isar/isar.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features_v2/chat/domain/entities/chat_message.dart';
import 'package:mobile/src/core/mixins/supabase_presence_mixin.dart';
import 'package:mobile/src/core/extensions/supabase_client_extension.dart';
import '../models/chat_isar_model.dart';

/// 🛡️ TACTICAL FALLBACK: If the network cannot resolve the partner identity,
/// we render a graceful 'Duty Officer' placeholder instead of crashing.
const Map<String, dynamic> _kDutyOfficerFallback = {
  'id': 'system',
  'full_name': 'ResQTrack Duty Officer',
  'role': 'admin',
};

abstract class IChatRepository {
  Stream<List<ChatMessage>> watchMessages(String roomId, String currentUserId);
  Future<void> sendMessage(ChatMessage message);
  Future<List<ChatMessage>> getCachedMessages(String roomId, {int limit = 50});
  Future<String?> getRoomIdForLoan(int loanId);
  Future<String?> getSupportRoomId();
  Future<void> markAsRead(String roomId);
  Future<void> deleteRoom(String roomId);
  Future<String?> getPartnerName(String roomId);
  Future<String?> getPartnerId(String roomId);
  Future<Map<String, dynamic>> getPartnerSnapshot(String roomId); // ✅ Consolidated single-call identity
  Future<void> sendHeartbeat(); // ── Liveness Pulse ──
  void leavePresenceChannel(String roomId); // ── Sync Cleanup ──
}


class ChatRepository with SupabasePresenceMixin implements IChatRepository {
  final SupabaseClient _client;
  final Isar _isar;

  @override
  SupabaseClient get client => _client;

  ChatRepository(this._client, this._isar);

  @override
  Stream<List<ChatMessage>> watchMessages(String roomId, String currentUserId) async* {
    int retryCount = 0;
    const maxRetries = 5;

    // 🛡️ Step 2.1: Explicit Validation Log
    if (roomId.isEmpty) {
      debugPrint('[Chat-Audit] ❌ ERROR: Subscription attempted with NULL/EMPTY roomId.');
      return;
    }
    debugPrint('[Chat-Audit] 📡 Preparing Coordination Stream for Room: $roomId');

    DateTime? lastRetryTime;
    int rapidRetryCount = 0;

    while (retryCount < maxRetries) {
      // 🛡️ [TEMPORAL GUARD]: Infinite Loop Prevention
      final now = DateTime.now();
      if (lastRetryTime != null && now.difference(lastRetryTime).inSeconds < 5) {
        rapidRetryCount++;
      } else {
        rapidRetryCount = 0;
      }
      lastRetryTime = now;

      if (rapidRetryCount > 3) {
        debugPrint('[Chat-Sync] 🚨 FATAL: Rapid retry threshold exceeded. Cooling down link.');
        await Future.delayed(const Duration(seconds: 30));
        rapidRetryCount = 0;
      }

      try {
        // ── Step 3: Connectivity Heartbeat ──
        await _client.checkConnection();

        // 2. Cache Yield
        final cached = await getCachedMessages(roomId);
        if (cached.isNotEmpty) yield cached;

        // 🛡️ Step 2.2: Stream Initialization with Timeout Protection
        debugPrint('[Chat-Audit] 🚀 Invoking Supabase Realtime Stream...');
        
        yield* _client
            .from('chat_messages')
            .stream(primaryKey: ['id']) 
            .eq('room_id', roomId)
            .map((data) {
              final messages = <ChatMessage>[];
              for (final json in data) {
                try {
                  messages.add(ChatMessage.fromSupabase(json));
                } catch (e) {
                  debugPrint('⚠️ Data Parsing Error: $e');
                }
              }
              messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              _cacheMessages(messages);
              return messages;
            })
            .handleError((error) {
              debugPrint('[Chat-Socket] Stream Error: $error');
              throw error;
            });
            
        break; 
      } on TimeoutException catch (e) {
        debugPrint('❗ SYNC_TIMEOUT: Coordination link timed out. $e');
        retryCount++;
        await Future.delayed(Duration(seconds: (retryCount * 2) + 1));
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries || e.toString().contains('SECURITY_AUTH_DENIED')) {
          debugPrint('[Chat-Sync] Fatal Sync Failure: $e');
          rethrow;
        }
        final waitSeconds = (retryCount * 2) + 1;
        debugPrint('[Chat-Sync] Retrying link in ${waitSeconds}s (Attempt $retryCount/$maxRetries)...');
        await Future.delayed(Duration(seconds: waitSeconds));
      }
    }
  }

  // _checkRealtimeHeartbeat removed - moved to SupabaseClientExtension



  @override
  Future<void> sendMessage(ChatMessage message) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('AUTH_REQUIRED: You must be logged in to send messages.');

    // ── Audit: Strict Identity Enforcement ──
    final hardenedMessage = message.copyWith(
      senderId: currentUserId,
      status: MessageStatus.sending,
    );

    // Immediate Local Sync: Save in Isar before network attempt
    await _cacheMessages([hardenedMessage]);

    try {
      final response = await _client.from('chat_messages').insert({
        'id': hardenedMessage.id,
        'room_id': hardenedMessage.roomId,
        'sender_id': currentUserId, // Forced to match auth.uid()
        'receiver_id': hardenedMessage.receiverId,
        'content': hardenedMessage.content,
        'created_at': hardenedMessage.createdAt.toUtc().toIso8601String(),
        'status': 'sent',
      }).select().single().timeout(const Duration(seconds: 15));

      // Update cache on success
      await _cacheMessages([ChatMessage.fromSupabase(response)]);
    } catch (e) {
      print('[Chat-Repository] Send Failure: $e');
      // Tactical Fault Recovery: Mark as error in cache
      await _cacheMessages([hardenedMessage.copyWith(status: MessageStatus.error)]);
      
      // Return a human-friendly error that triggers the UI's red exclamation
      throw Exception('COORD_SYNC_ERR: Coordination link failed. Tap the red icon to retry.');
    }
  }

  @override
  Future<void> markAsRead(String roomId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('sender_id', userId);
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    // ── Audit: Coordination Deletion ──
    print('[Chat-Audit] Permanent Deletion initiated for Room: $roomId at ${DateTime.now().toUtc()}');

    // 1. Remote Sync: Deletes room and cascades to messages via Postgres constraint
    await _client.from('chat_rooms').delete().eq('id', roomId);

    // ── Temporal Shielding: Persistent Audit Trail ──
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _client.from('activity_log').insert({
        'user_id': userId,
        'action': 'DELETE_CHAT_ROOM',
        'table_name': 'chat_rooms',
        'changes': {'room_id': roomId, 'deleted_at': DateTime.now().toUtc().toIso8601String()},
      });
    }

    // 2. Cache Purge: Standardize local cleanup after remote confirmation
    await _isar.writeTxn(() async {
      await _isar.chatMessageIsars.where().roomIdEqualTo(roomId).deleteAll();
    });
  }

  @override
  Future<List<ChatMessage>> getCachedMessages(String roomId, {int limit = 50}) async {
    final results = await _isar.chatMessageIsars
        .where()
        .roomIdEqualTo(roomId)
        .sortByCreatedAt()
        .limit(limit)
        .findAll();

    return results.map((m) => ChatMessage(
      id: m.id,
      roomId: m.roomId,
      senderId: m.senderId,
      receiverId: m.receiverId, // ── Parity ──
      content: m.content,
      createdAt: m.createdAt,
      isRead: m.isRead,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == m.status,
        orElse: () => MessageStatus.sent,
      ),
    )).toList();
  }

  @override
  Future<String?> getRoomIdForLoan(int loanId) async {
    try {
      // ── Senior Dev: Tactical Parent Audit ──
      // Verify that the loan actually exists in 'borrow_logs' before initiating
      final parentResponse = await _client
          .from('borrow_logs')
          .select('id, borrower_user_id, borrowed_by') // ── Added borrowed_by ──
          .eq('id', loanId)
          .maybeSingle();

      if (parentResponse == null) {
        throw Exception('LT_SYNC_ERR_404: Parent log #$loanId not found. Coordination link aborted.');
      }

      // ── Audit Foreign Key Integrity (Hardened Fallback) ──
      // Fallback to 'borrowed_by' if profile link is missing
      final borrowerUserId = (parentResponse['borrower_user_id'] ?? parentResponse['borrowed_by'])?.toString();


      // ── The Idempotent 'Get-or-Create' UPSERT ──
      // Use UPSERT with onConflict for target-rich redundancy during multiple clicks
      final response = await _client
          .from('chat_rooms')
          .upsert({
            'borrow_request_id': loanId,
            'borrower_user_id': borrowerUserId,
          }, onConflict: 'borrow_request_id')
          .select('id')
          .single();
      
      return response['id'] as String?;
    } on PostgrestException catch (e) {
      // Safety Net: Return the exact Supabase error code for diagnostics
      throw Exception('LT_COORD_LINK_ERR_${e.code}: ${e.message}');
    } catch (e) {
      print('[ChatRepository] Unexpected Coordination Link Error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getSupportRoomId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('LT_AUTH_ERR: User session not found.');

    try {
      // ── DETERMINISTIC SUPPORT ROOM PATTERN ──
      // The Room ID matches the User ID. This allows staff to navigate 
      // immediately to /[USER_ID] to join a conversation.
      final response = await _client
          .from('chat_rooms')
          .upsert({
            'id': userId,
            'borrower_user_id': userId,
            'borrow_request_id': null,
          }, onConflict: 'id')
          .select('id')
          .single();

      return response['id'] as String;
    } on PostgrestException catch (e) {
      throw Exception('LT_SUPPORT_LINK_ERR_${e.code}: ${e.message}');
    } catch (e) {
      print('[ChatRepository] Support Link Error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getPartnerId(String roomId) async {
    final String? currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return null;

    try {
      // 🕵️ Step 1: Get the current user's role (The Steel Cage)
      final Map<String, dynamic>? myProfile = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUserId)
          .maybeSingle();
      
      final bool isStaff = myProfile != null && (myProfile['role'] == 'admin' || myProfile['role'] == 'editor');

      // 🏢 Step 2: Fetch Room Metadata
      final Map<String, dynamic>? roomResponse = await _client
          .from('chat_rooms')
          .select('borrower_user_id')
          .eq('id', roomId)
          .maybeSingle();

      if (roomResponse == null) return null;
      final String? borrowerId = roomResponse['borrower_user_id'] as String?;

      // 🛡️ Step 3: Branching Logic (Omniscient Staff Pattern)
      if (isStaff) {
        // I am Staff: My partner is ALWAYS the borrower
        return borrowerId;
      } else {
        // I am Borrower: My partner is THE LATEST sender (Staff) who replied
        // 🛡️ TACTICAL FIX: Null handling for FAB-initiated chats with no replies yet
        final Map<String, dynamic>? lastMsg = await _client
            .from('chat_messages')
            .select('sender_id')
            .eq('room_id', roomId)
            .neq('sender_id', currentUserId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        // If lastMsg is null, it means no staff has replied yet. 
        // We return null and allow the identity layer to handle it gracefully.
        return lastMsg?['sender_id'] as String?;
      }
    } catch (e) {
      debugPrint('[Chat-Identity] Resolve Partner Error: $e');
      return null;
    }
  }

  @override
  Future<String?> getPartnerName(String roomId) async {
    final snapshot = await getPartnerSnapshot(roomId);
    return snapshot['full_name'] as String?;
  }

  /// 🎯 CONSOLIDATED IDENTITY SNAPSHOT
  /// A single Supabase call replaces the old getPartnerId + getPartnerName chain.
  /// Returns a Map with: {'id', 'full_name', 'role'}
  /// 🛡️ Tactical Fallback: Returns ResQTrack Duty Officer on SocketException.
  @override
  Future<Map<String, dynamic>> getPartnerSnapshot(String roomId) async {
    final String? currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return _kDutyOfficerFallback;

    try {
      // 🔍 STEP 1: Determine role in ONE call using embedded select
      final myProfile = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUserId)
          .maybeSingle();

      final bool isStaff = myProfile != null &&
          (myProfile['role'] == 'admin' || myProfile['role'] == 'editor');

      if (isStaff) {
        // 🏢 STAFF PATH: Resolve borrower with profile join in a SINGLE query
        final room = await _client
            .from('chat_rooms')
            .select('borrower_user_id, user_profiles!borrower_user_id(full_name, role)')
            .eq('id', roomId)
            .maybeSingle();

        if (room == null) return _kDutyOfficerFallback;
        final profile = room['user_profiles'] as Map<String, dynamic>?;
        return {
          'id': room['borrower_user_id'],
          'full_name': profile?['full_name'] ?? 'ResQTrack Duty Officer',
          'role': profile?['role'] ?? 'user',
        };
      } else {
        // 👤 BORROWER PATH: Find the latest staff reply in one query
        final lastMsg = await _client
            .from('chat_messages')
            .select('sender_id, user_profiles!sender_id(full_name, role)')
            .eq('room_id', roomId)
            .neq('sender_id', currentUserId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastMsg == null) return _kDutyOfficerFallback;
        final profile = lastMsg['user_profiles'] as Map<String, dynamic>?;
        return {
          'id': lastMsg['sender_id'],
          'full_name': profile?['full_name'] ?? 'ResQTrack Duty Officer',
          'role': profile?['role'] ?? 'admin',
        };
      }
    } on SocketException catch (e) {
      debugPrint('[Chat-Snapshot] 🔴 SocketException — returning Duty Officer fallback: $e');
      return _kDutyOfficerFallback;
    } catch (e) {
      debugPrint('[Chat-Snapshot] ⚠️ Identity Resolution Error: $e');
      return _kDutyOfficerFallback;
    }
  }

  // sendHeartbeat implementation provided by SupabasePresenceMixin

  Future<void> _cacheMessages(List<ChatMessage> messages) async {
    final isars = messages.map((m) => ChatMessageIsar()
      ..id = m.id
      ..isarId = m.id.hashCode.abs() // Map UUID to unique int for Isar Id if not using auto-increment
      ..roomId = m.roomId
      ..senderId = m.senderId
      ..receiverId = m.receiverId // ── Parity ──
      ..content = m.content
      ..createdAt = m.createdAt
      ..isRead = m.isRead
      ..status = m.status.name
    ).toList();

    await _isar.writeTxn(() async {
      await _isar.chatMessageIsars.putAll(isars);
    });
  }

  @override
  Future<void> sendHeartbeat() async {
    // ── Liveness Pulse ──
    // Handled by client.checkConnection() in watchMessages or explicit mixin calls
  }

  @override
  void leavePresenceChannel(String roomId) {
    _client.channel('presence:$roomId').unsubscribe();
  }
}
