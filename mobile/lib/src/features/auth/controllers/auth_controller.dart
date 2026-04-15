import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../data/auth_repository.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/user_model.dart'; // Ensure this model exists
import '../../../core/local_storage/isar_service.dart';

class AuthController extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() async {
    // Check initial auth status on app start
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    
    if (user != null) {
      if (user.status == 'active') {
        return AuthState.authenticated(user);
      } else if (user.status == 'pending') {
        return AuthState.pendingApproval(user);
      }
    }
    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    // Set custom Loading state explicitly as requested
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email: email, password: password);
      
      // Fetch user after successful login
      final user = await repo.getCurrentUser();
      if (user != null) {
        if (user.status == 'active') {
          state = AsyncValue.data(AuthState.authenticated(user));
        } else if (user.status == 'pending') {
          state = AsyncValue.data(AuthState.pendingApproval(user));
        } else {
          state = const AsyncValue.data(AuthState.error("Account access restricted. Please contact Admin."));
        }
      } else {
        state = const AsyncValue.data(AuthState.error("User profile not found after login"));
      }
    } catch (e) {
      // Set custom Error state explicitly
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> signInWithGoogle(bool rememberMe) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      final googleUser = await repo.signInWithGoogle(rememberMe: rememberMe);
      
      // 🛡️ RECOVERY: If user closed the picker, reset UI to initial clickable state
      if (googleUser == null) {
        state = const AsyncValue.data(AuthState.initial());
        return;
      }

      final user = await repo.getCurrentUser();
      if (user != null) {
        if (user.status == 'active') {
          state = AsyncValue.data(AuthState.authenticated(user));
        } else if (user.status == 'pending') {
          state = AsyncValue.data(AuthState.pendingApproval(user));
        } else {
          state = const AsyncValue.data(AuthState.error("Account Access Denied. Contact HQ."));
        }
      } else {
        state = const AsyncValue.data(AuthState.error("User profile not found"));
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      final isAutoLogin = await repo.signUp(email: email, password: password, name: name);
      
      if (isAutoLogin) {
        final user = await repo.getCurrentUser();
        if (user != null) {
           // 🛡️ TACTICAL SHIFT: Newly registered users land in Pending Approval
           if (user.status == 'pending') {
             state = AsyncValue.data(AuthState.pendingApproval(user));
           } else if (user.status == 'active') {
             state = AsyncValue.data(AuthState.authenticated(user));
           } else {
             state = const AsyncValue.data(AuthState.initial());
           }
        } else {
           state = const AsyncValue.data(AuthState.initial());
        }
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(AuthState.loading());
    try {
      await ref.read(authRepositoryProvider).signOut();
      
      // 🚀 State Cleansing: Invalidate all data-sensitive providers to prevent ghost data
      ref.invalidate(authRepositoryProvider);
      
      // Wipe the local encrypted cache
      await IsarService.clearAll();
      
      state = const AsyncValue.data(AuthState.initial());
    } catch (e) {
      state = AsyncValue.data(AuthState.error(ExceptionHandler.getDisplayMessage(e)));
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
