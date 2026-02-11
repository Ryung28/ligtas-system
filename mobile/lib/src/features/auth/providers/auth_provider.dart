import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/networking/supabase_client.dart';
import 'package:mobile/src/features/auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state notifier for professional session management
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AsyncValue.data(null)) {
    // Check initial session
    _init();
  }

  void _init() {
    final session = _supabase.auth.currentSession;
    if (session != null && session.user != null) {
      state = AsyncValue.data(_mapSupabaseUser(session.user!));
    }

    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        state = AsyncValue.data(_mapSupabaseUser(user));
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  UserModel _mapSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] ?? user.email?.split('@').first,
      phoneNumber: user.userMetadata?['phone_number'] as String?,
      organization: user.userMetadata?['organization'] as String?,
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // State is updated by the onAuthStateChange listener
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password, String name, {String? phoneNumber, String? organization}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': name,
          'phone_number': phoneNumber,
          'organization': organization,
        },
      );
      
      // If session is null, it means email confirmation is likely enabled.
      // We reset state to data(null) so the UI stops loading.
      if (response.session == null) {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AsyncValue.data(null);
  }
}

/// Global provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(SupabaseService.client);
});

/// Accessibility provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).value;
});

/// Accessibility provider for loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
