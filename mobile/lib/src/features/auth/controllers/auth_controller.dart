import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart'; // Ensure this model exists

class AuthController extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() async {
    // Check initial auth status on app start
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    
    if (user != null) {
      return AuthState.authenticated(user);
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
        state = AsyncValue.data(AuthState.authenticated(user));
      } else {
        state = const AsyncValue.data(AuthState.error("User not found after login"));
      }
    } catch (e, st) {
      // Set custom Error state explicitly
      state = AsyncValue.data(AuthState.error(e.toString()));
      // Also utilize Riverpod's error handling if needed, but we rely on our state class here
      // state = AsyncValue.error(e, st); 
    }
  }

  Future<void> signInWithGoogle(bool rememberMe) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle(rememberMe: rememberMe);
      
      final user = await repo.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(AuthState.authenticated(user));
      } else {
        state = const AsyncValue.data(AuthState.error("User profile not found"));
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(email: email, password: password, name: name);
      
      // After signup, user might need to verify email or is auto-logged in
      final user = await repo.getCurrentUser();
      
      if (user != null) {
        state = AsyncValue.data(AuthState.authenticated(user));
      } else {
        // Assume email verification needed
        state = const AsyncValue.data(AuthState.initial()); 
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(AuthState.loading());
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(AuthState.initial());
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
