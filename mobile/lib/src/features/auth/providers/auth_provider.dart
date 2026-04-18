import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/networking/supabase_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Auth state notifier for professional session management
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseClient _supabase;
  static const String _rememberMeKey = 'is_remembered';

  AuthNotifier(this._supabase) : super(const AsyncValue.data(null)) {
    // Check initial session
    _init();
  }

  void _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null && session.user != null) {
      // 🛡️ TACTICAL BOOT: Immediately verify profile status on launch
      await _loadUserProfile(session.user!.id);
    }

    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _loadUserProfile(user.id);
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  /// Load user profile from user_profiles table
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final List<String> providers = (authUser.appMetadata['providers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [];

      if (response != null) {
        final userModel = UserModel.fromSupabase(response, providers);
        state = AsyncValue.data(userModel);
      } else {
        // profile doesn't exist yet, return a pending model based on metadata
        state = AsyncValue.data(_mapSupabaseUser(authUser));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Check if the session was marked as "Remembered"
  Future<bool> isSessionRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Update the remember me preference
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  /// Fallback: Map Supabase auth user to UserModel
  UserModel _mapSupabaseUser(User user) {
    final List<String> providers = (user.appMetadata['providers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] ?? user.email?.split('@').first,
      phoneNumber: user.userMetadata?['phone_number'] as String?,
      organization: user.userMetadata?['organization'] as String?,
      role: 'viewer', // Default role
      status: 'pending', // Default status for new users
      providers: providers,
    );
  }

  /// Refresh user profile (useful after approval)
  Future<void> refreshProfile() async {
    final currentUser = state.value;
    if (currentUser != null) {
      await _loadUserProfile(currentUser.id);
    }
  }

  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    state = const AsyncValue.loading();
    try {
      await setRememberMe(rememberMe);
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // State is updated by the onAuthStateChange listener
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Professional Sign In with Google
  Future<void> signInWithGoogle(Future<GoogleSignInAccount?> Function({bool rememberMe}) call, {bool rememberMe = false}) async {
    state = const AsyncValue.loading();
    try {
      await setRememberMe(rememberMe);
      final result = await call(rememberMe: rememberMe);
      if (result == null) {
        state = const AsyncValue.data(null);
      }
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
      if (response.session == null) {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    // Clear persistence on logout
    await setRememberMe(false);
    await _supabase.auth.signOut();
    state = const AsyncValue.data(null);
  }

  void setMockAuth() {
    // Create a mock user for development
    final mockUser = UserModel(
      id: 'dev-user-id',
      email: 'dev@ligtas.local',
      displayName: 'Development User',
      phoneNumber: null,
      organization: null,
      role: 'admin',
      status: 'active',
      providers: [],
    );
    state = AsyncValue.data(mockUser);
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

/// Provider to check if user has active access
final hasActiveAccessProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isActive ?? false;
});

/// Provider to check user status
final userStatusProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.status ?? 'pending';
});
