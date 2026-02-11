import 'package:shared_preferences/shared_preferences.dart';

/// Manages intro cards display preference
class IntroCardManager {
  static const _keyPreference = 'intro_cards_preference';
  static const _valueAlways = 'always';
  static const _valueNever = 'never';

  /// Reset intro cards preference (show on next launch)
  static Future<void> resetIntroCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPreference);
    await prefs.setBool('show_intro_cards', true);
  }

  /// Whether to show intro cards on app launch
  static Future<bool> shouldShowIntroCards() async {
    final prefs = await SharedPreferences.getInstance();
    final preference = prefs.getString(_keyPreference);

    if (preference == _valueNever) return false;
    return true;
  }

  /// Save user preference for intro cards
  static Future<void> savePreference(bool alwaysShow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyPreference,
      alwaysShow ? _valueAlways : _valueNever,
    );
  }
}
