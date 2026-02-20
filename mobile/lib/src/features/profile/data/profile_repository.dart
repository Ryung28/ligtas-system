import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stub repository for feature-first architecture.
// In a real app, this would talk to Supabase/API or SharedPreferences.
class ProfileRepository {
  Future<Map<String, dynamic>> fetchSettings() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'push_notifications': true,
      'biometric_enabled': false,
      'dark_mode': false,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate successful update
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());
