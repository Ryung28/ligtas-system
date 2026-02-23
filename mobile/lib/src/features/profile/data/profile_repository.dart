import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/app_providers.dart';
import '../../auth/models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Map<String, dynamic>> fetchSettings() async {
    // In a real app, settings might be in a 'user_settings' table
    // For now, we'll keep the mock logic for settings or use metadata
    return {
      'push_notifications': true,
      'biometric_enabled': false,
      'dark_mode': false,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    // This could also update Supabase if needed
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _client
          .from('user_profiles')
          .update({
            'full_name': user.displayName,
            'phone_number': user.phoneNumber,
            'organization': user.organization,
          })
          .eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> fetchProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromSupabase(response);
    } catch (e) {
      rethrow;
    }
  }

}

final profileRepositoryProvider = Provider((ref) {
  final client = ref.watch(AppProviders.supabaseClientProvider);
  return ProfileRepository(client);
});

