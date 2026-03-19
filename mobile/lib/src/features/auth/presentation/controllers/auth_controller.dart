import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/auth/domain/models/auth_state.dart';
import 'package:mobile/src/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/src/core/errors/app_exceptions.dart';
import 'package:mobile/src/features/auth/domain/models/user_model.dart';
import 'package:mobile/src/core/local_storage/isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  StreamSubscription<AuthState>? _sub;

  @override
  FutureOr<AuthState> build() async {
    // 🛡️ TACTICAL LISTEN: Bind Supabase Auth Events to Riverpod State
    _sub?.cancel();
    
    // Using a micro-task to avoid setting state during build if the stream emits immediately
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await refreshProfile();
      } else {
        if (state.value is! Initial) {
           state = AsyncValue.data(AuthState.initial());
        }
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    
    if (user != null) {
      return _mapUserToAuthState(user);
    }
    return const AuthState.initial();
  }

  /// 🛡️ SANITIZATION: Centralized Status Triage
  AuthState _mapUserToAuthState(UserModel user) {
    if (user.isActive) {
      return AuthState.authenticated(user);
    } else if (user.isPending) {
      return AuthState.pendingApproval(user);
    } else if (user.isSuspended) {
      return const AuthState.error("Account access restricted. Please contact Admin.");
    }
    return const AuthState.initial();
  }

  Future<void> refreshProfile() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(_mapUserToAuthState(user));
      } else {
        state = AsyncValue.data(AuthState.initial());
      }
    } catch (e) {
      debugPrint('[AuthController] Profile Refresh Failed: $e');
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
      await repo.signInWithGoogle(rememberMe: rememberMe);
      // Profile will be refreshed by onAuthStateChange listener
    } catch (e) {
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
