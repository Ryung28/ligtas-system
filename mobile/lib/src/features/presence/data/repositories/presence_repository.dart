import 'dart:io';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/src/features/presence/data/models/presence_model.dart';
import 'package:mobile/src/features/presence/domain/entities/presence.dart';

abstract class IPresenceRepository {
  Future<void> updatePresence(String userId);
  Future<UserPresence?> getLocalPresence(String userId);
}

class PresenceRepository implements IPresenceRepository {
  final SupabaseClient _client;
  final Isar _isar;

  PresenceRepository(this._client, this._isar);

  @override
  Future<void> updatePresence(String userId) async {
    final now = DateTime.now().toUtc();

    // 1. 🌐 Remote Sync with Tactical Retry (The Vault)
    await _syncRemoteWithBackoff(userId, now);

    // 2. ⚡ Local Persistence (Isar - Offline-First Source of Truth)
    final entity = UserPresence(
      userId: userId,
      lastSeen: now,
      isOnline: true,
    );

    await _isar.writeTxn(() async {
      await _isar.presenceCollections.put(PresenceCollection.fromEntity(entity));
    });
  }

  /// 🔄 Exponential Backoff Retry for SocketException failures.
  /// Delays: 1s → 2s → 4s. If all fail, we remain offline silently.
  Future<void> _syncRemoteWithBackoff(String userId, DateTime now) async {
    const delays = [1, 2, 4]; // seconds
    for (int i = 0; i <= delays.length; i++) {
      try {
        await _client
            .from('user_profiles')
            .update({'last_seen': now.toIso8601String()})
            .eq('id', userId);
        debugPrint('[Tactical-Presence-Guard] ✅ Remote sync success.');
        return; // ✅ Success — exit immediately
      } on SocketException catch (e) {
        if (i < delays.length) {
          debugPrint('[Tactical-Presence-Guard] ⚠️ SocketException: $e. Retrying in ${delays[i]}s...');
          await Future.delayed(Duration(seconds: delays[i]));
        } else {
          debugPrint('[Tactical-Presence-Guard] 🔴 All retries exhausted. Staying offline: $e');
        }
      } catch (e) {
        // Non-socket errors (e.g. RLS, 500): log and bail immediately
        debugPrint('[Tactical-Presence-Guard] 🔴 Non-recoverable error: $e');
        return;
      }
    }
  }

  @override
  Future<UserPresence?> getLocalPresence(String userId) async {
    final record = await _isar.presenceCollections
        .filter()
        .userIdEqualTo(userId)
        .findFirst();

    return record?.toEntity();
  }
}
