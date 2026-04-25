import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/app_providers.dart';
import '../../auth/domain/models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;
  static const String _pushNotificationsKey = 'push_notifications_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _darkModeKey = 'dark_mode';

  ProfileRepository(this._client);

  Future<Map<String, dynamic>> fetchSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'push_notifications': prefs.getBool(_pushNotificationsKey) ?? true,
      'biometric_enabled': prefs.getBool(_biometricKey) ?? false,
      'dark_mode': prefs.getBool(_darkModeKey) ?? false,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'push_notifications':
        await prefs.setBool(_pushNotificationsKey, value);
        break;
      case 'biometric_enabled':
        await prefs.setBool(_biometricKey, value);
        break;
      case 'dark_mode':
        await prefs.setBool(_darkModeKey, value);
        break;
      default:
        break;
    }
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

