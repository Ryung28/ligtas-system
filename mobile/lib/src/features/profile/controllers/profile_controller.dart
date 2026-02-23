import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_state.dart';
import '../data/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';


class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileController(this._repository, this._ref) : super(const ProfileState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Initial sync with auth provider
    final user = _ref.read(currentUserProvider);
    state = state.copyWith(user: user, isLoading: true);
    
    await _loadSettings();
    
    // Refresh user data from Supabase to ensure we have latest profile fields
    if (user != null) {
      try {
        final profile = await _repository.fetchProfile(user.id);
        state = state.copyWith(user: profile, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false);
        debugPrint('Profile fetch error: $e');
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadSettings() async {
    try {
      final data = await _repository.fetchSettings();
      state = state.copyWith(
        pushNotificationsEnabled: data['push_notifications'] as bool,
        biometricEnabled: data['biometric_enabled'] as bool,
        isDarkMode: data['dark_mode'] as bool,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? organization,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = state.user!;
      final updatedUser = currentUser.copyWith(
        displayName: displayName ?? currentUser.displayName,
        phoneNumber: phoneNumber ?? currentUser.phoneNumber,
        organization: organization ?? currentUser.organization,
      );

      await _repository.updateProfile(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
      
      // Sync back to global auth state
      await _ref.read(authProvider.notifier).refreshProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    state = state.copyWith(pushNotificationsEnabled: value);
    await _repository.updateSetting('push_notifications', value);
  }

  Future<void> toggleBiometric(bool value) async {
    state = state.copyWith(biometricEnabled: value);
    await _repository.updateSetting('biometric_enabled', value);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    await _repository.updateSetting('dark_mode', value);
  }

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to sign out of LIGTAS?',
          style: TextStyle(color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _ref.read(authProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void navigateTo(BuildContext context, String route) {
    if (route == 'personal-info') {
      context.push('/profile/personal-info');
    } else if (route == 'security') {
      context.push('/profile/security');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feature coming soon'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}


final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileController(repo, ref);
});
