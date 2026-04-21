import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/auth/domain/models/auth_state.dart';
import 'package:mobile/src/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/src/core/errors/app_exceptions.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:shared_preferences/shared_preferences.dart';

part 'auth_controller.g.dart';

/// Shown after sign-in when `user_profiles.status` is not yet `active` (admin approval required).
const String _kPendingApprovalMessage =
    'Your account is pending administrator approval. You can sign in after an admin approves your access.';

const String _kSuspendedMessage =
    'Your account has been suspended. Contact an administrator if you need help.';

@riverpod
class AuthController extends _$AuthController {
  StreamSubscription? _sub;
  static const String _rememberMeKey = 'is_remembered';

  @override
  FutureOr<AuthState> build() async {
    // 🛡️ TACTICAL LISTEN: Bind Supabase Auth Events to Riverpod State
    _sub?.cancel();

    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      debugPrint('📡 Auth Lifecycle: [${event.name}] Session is ${session != null ? "ACTIVE" : "NONE"}');

      if (session != null) {
        await refreshProfile();
      } else {
        if (state.isLoading) return;
        final keepError =
            state.valueOrNull?.maybeMap(error: (_) => true, orElse: () => false) ?? false;
        if (keepError) return;
        if (state.hasValue && state.value is! Initial) {
          state = AsyncValue.data(AuthState.initial());
        }
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();

    if (user != null && !user.isActive) {
      final msg = user.isSuspended ? _kSuspendedMessage : _kPendingApprovalMessage;
      await repo.signOut();
      return AuthState.error(msg);
    }
    if (user != null && user.isActive) {
      return AuthState.authenticated(user);
    }
    return const AuthState.initial();
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();

      if (user == null) {
        state = AsyncValue.data(const AuthState.initial());
        return;
      }

      if (!user.isActive) {
        final msg = user.isSuspended ? _kSuspendedMessage : _kPendingApprovalMessage;
        state = AsyncValue.data(AuthState.error(msg));
        await repo.signOut();
        return;
      }

      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (e) {
      debugPrint('[AuthController] Profile Triage Failure: $e');
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    state = AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email: email, password: password);
      // Profile will be refreshed by onAuthStateChange listener
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> signInWithGoogle(bool rememberMe) async {
    state = AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      
      // 🛡️ PERSISTENCE: Save session type
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      
      final googleUser = await repo.signInWithGoogle(rememberMe: rememberMe);
      
      // 🛡️ RECOVERY: If user closed the picker, reset UI to initial clickable state
      if (googleUser == null) {
        debugPrint('📡 [Auth-Guard] Picker closed. Resetting UI...');
        state = AsyncValue.data(AuthState.initial());
        return;
      }

      // 🛡️ RECOVERY CHECK: If we return from the picker but no session exists, reset UI
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('📡 [Auth-Guard] No session found after picker. Resetting UI...');
        state = AsyncValue.data(AuthState.initial());
        return;
      }

      // 🚀 THE DOUBLE-DIVE: Force immediate profile triage
      await refreshProfile();
    } catch (e) {
      debugPrint('⛔ Google Auth Aborted: $e');
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      final isAutoLogin = await repo.signUp(email: email, password: password, name: name);
      
      if (!isAutoLogin) {
        state = AsyncValue.data(AuthState.initial());
      }
      // If isAutoLogin, onAuthStateChange will trigger refreshProfile
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> logout() async {
    state = AsyncValue.data(AuthState.loading());
    try {
      // 🛡️ PERSISTENCE: Wipe session preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, false);

      await ref.read(authRepositoryProvider).signOut();
      
      // 🚀 State Cleansing
      ref.invalidate(authRepositoryProvider);
      await IsarService.clearAll();
      
      state = AsyncValue.data(AuthState.initial());
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }
}
