import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/app_providers.dart';
import '../../auth/domain/models/user_model.dart';

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
      // Schema-tolerant write:
      // - phone field can be `phone_number` or `phone`
      // - office field can be `organization` or `department`
      final payloads = [
        {
          'full_name': user.displayName,
          'phone_number': user.phoneNumber,
          'organization': user.organization,
        },
        {
          'full_name': user.displayName,
          'phone': user.phoneNumber,
          'organization': user.organization,
        },
        {
          'full_name': user.displayName,
          'phone_number': user.phoneNumber,
          'department': user.organization,
        },
        {
          'full_name': user.displayName,
          'phone': user.phoneNumber,
          'department': user.organization,
        },
        // Fallbacks for environments that have no phone column in user_profiles.
        {
          'full_name': user.displayName,
          'organization': user.organization,
        },
        {
          'full_name': user.displayName,
          'department': user.organization,
        },
        {
          'full_name': user.displayName,
        },
      ];

      PostgrestException? lastSchemaErr;
      for (final payload in payloads) {
        try {
          await _client
              .from('user_profiles')
              .update(payload)
              .eq('id', user.id);
          return;
        } on PostgrestException catch (e) {
          final msg = e.message.toLowerCase();
          final isSchemaColumnError = msg.contains('could not find') ||
              msg.contains('schema cache') ||
              msg.contains('column');
          if (!isSchemaColumnError) rethrow;
          lastSchemaErr = e;
        }
      }

      if (lastSchemaErr != null) throw lastSchemaErr;
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

