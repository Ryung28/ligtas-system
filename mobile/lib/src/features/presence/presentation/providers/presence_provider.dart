import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/presence/data/repositories/presence_repository.dart';

part 'presence_provider.g.dart';

@riverpod
IPresenceRepository presenceRepository(PresenceRepositoryRef ref) {
  return PresenceRepository(
    Supabase.instance.client,
    IsarService.instance,
  );
}

@Riverpod(keepAlive: true)
class PresenceController extends _$PresenceController {
  Timer? _heartbeatTimer;
  static const _heartbeatInterval = Duration(minutes: 2);

  @override
  bool build() {
    // ── Audit: Controller Initialized ──
    // This build method sets up the heartbeat when the provider is first watched
    ref.onDispose(() => _heartbeatTimer?.cancel());
    _startHeartbeat();
    return true;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => updateHeartbeat());
    
    // Initial Pulse
    updateHeartbeat();
  }

  Future<void> updateHeartbeat() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // ── The Heartbeat Handshake ──
    await ref.read(presenceRepositoryProvider).updatePresence(user.id);
  }

  // 📡 CHAT PULSE ELEVATION
  // Invoked by ChatScreen to register immediate presence on entry.
  // The PresenceController owns the periodic timer; the widget just knocks.
  Future<void> triggerChatPulse() async => updateHeartbeat();
}
