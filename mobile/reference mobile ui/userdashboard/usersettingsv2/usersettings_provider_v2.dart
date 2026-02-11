import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/services/textbee_sms_service.dart';
import 'package:mobileapplication/userdashboard/config/language_provider.dart';
import 'package:mobileapplication/authenticationpages/loginpage/services/credential_storage_service.dart';
import 'package:mobileapplication/authenticationpages/loginpage/services/auth_persistence_service.dart';

/// Clean architecture provider for user settings
/// Follows separation of concerns and single responsibility principle
class SettingsProviderV2 extends ChangeNotifier {
  // Dependencies
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State
  bool _isLoading = true;
  String _username = '';
  String _email = '';
  String? _profilePictureUrl;
  String _firstName = '';
  String _lastName = '';
  String? _phoneNumberFromProfile;

  // Theme colors
  Color _deepBlue = const Color(0xFF0D47A1);
  Color _surfaceBlue = const Color(0xFF1565C0);
  Color _lightBlue = const Color(0xFF1976D2);
  Color _whiteWater = Colors.white;

  // Settings
  ThemeType _selectedTheme = ThemeType.ocean;
  SupportedLanguage _selectedLanguage = SupportedLanguage.english;

  // Two-Factor Authentication
  bool _is2FAEnabled = false;
  TwoFactorMethod _selected2FAMethod = TwoFactorMethod.none;
  String? _phoneNumber;
  bool _isEmailVerified = false;

  // SMS 2FA specific
  String? _pendingVerificationCode;
  DateTime? _verificationCodeExpiry;
  bool _isSMSVerificationPending = false;

  // Notification Settings
  bool _notificationsEnabled = true;
  bool _banPeriodNotifications = true;
  bool _marineConditionsNotifications = true;
  bool _educationNotifications = true;
  bool _complaintNotifications = true;
  bool _pushNotificationsEnabled = true;

  // Getters
  bool get isLoading => _isLoading;
  String get username => _username;
  String get email => _email;
  String? get profilePictureUrl => _profilePictureUrl;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String? get phoneNumberFromProfile => _phoneNumberFromProfile;

  Color get deepBlue => _deepBlue;
  Color get surfaceBlue => _surfaceBlue;
  Color get lightBlue => _lightBlue;
  Color get whiteWater => _whiteWater;

  ThemeType get selectedTheme => _selectedTheme;
  SupportedLanguage get selectedLanguage => _selectedLanguage;

  bool get is2FAEnabled => _is2FAEnabled;
  TwoFactorMethod get selected2FAMethod => _selected2FAMethod;
  String? get phoneNumber => _phoneNumber;
  bool get isEmailVerified => _isEmailVerified;

  String? get pendingVerificationCode => _pendingVerificationCode;
  DateTime? get verificationCodeExpiry => _verificationCodeExpiry;
  bool get isSMSVerificationPending => _isSMSVerificationPending;

  // Notification getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get banPeriodNotifications => _banPeriodNotifications;
  bool get marineConditionsNotifications => _marineConditionsNotifications;
  bool get educationNotifications => _educationNotifications;
  bool get complaintNotifications => _complaintNotifications;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  /// Initialize and load user data
  Future<void> initialize() async {
    await loadUserData();
  }

  /// Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      _setLoading(true);

      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _getUserDocument(user);
      if (userDoc == null) return;

      final userData = userDoc.data() as Map<String, dynamic>;

      // Basic user info
      // FIXED: Check 'username' field first (what registration saves), then fallback to 'displayName'
      _username = userData['username']?.toString() ?? 
                  userData['displayName']?.toString() ?? '';
      _email = userData['email']?.toString() ?? '';
      _profilePictureUrl = userData['photoURL']?.toString();
      
      // 🔥 FIX: Load firstName and lastName separately from Firestore
      _firstName = userData['firstName']?.toString() ?? '';
      _lastName = userData['lastName']?.toString() ?? '';
      _phoneNumberFromProfile = userData['phoneNumber']?.toString();
      
      // If firstName/lastName are empty but displayName exists, try to parse it
      if (_firstName.isEmpty && _lastName.isEmpty && _username.isNotEmpty) {
        final nameParts = _username.split(' ');
        if (nameParts.length >= 2) {
          _firstName = nameParts[0];
          _lastName = nameParts.sublist(1).join(' ');
        } else if (nameParts.length == 1) {
          _firstName = nameParts[0];
        }
      }

      // Load settings
      await _load2FASettings(userData);
      await _loadLanguageSettings(userData);
      await _loadNotificationSettings(userData);
      await _loadThemeSettings(userData);
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load 2FA settings from user data
  Future<void> _load2FASettings(Map<String, dynamic> userData) async {
    _is2FAEnabled = userData['is2FAEnabled'] ?? false;

    final methodString = userData['selected2FAMethod']?.toString() ?? 'none';
    _selected2FAMethod = TwoFactorMethod.values.firstWhere(
      (method) => method.name == methodString,
      orElse: () => TwoFactorMethod.none,
    );

    _phoneNumber = userData['phoneNumber']?.toString();
    _isEmailVerified = userData['isEmailVerified'] ?? false;
  }

  /// Load language settings from user data
  Future<void> _loadLanguageSettings(Map<String, dynamic> userData) async {
    final languageString =
        userData['selectedLanguage']?.toString() ?? 'english';
    _selectedLanguage = SupportedLanguage.values.firstWhere(
      (language) => language.name == languageString,
      orElse: () => SupportedLanguage.english,
    );
  }

  /// Load notification settings from user data
  Future<void> _loadNotificationSettings(Map<String, dynamic> userData) async {
    _notificationsEnabled = userData['notificationsEnabled'] ?? true;
    _banPeriodNotifications = userData['banPeriodNotifications'] ?? true;
    _marineConditionsNotifications =
        userData['marineConditionsNotifications'] ?? true;
    _educationNotifications = userData['educationNotifications'] ?? true;
    _complaintNotifications = userData['complaintNotifications'] ?? true;
    _pushNotificationsEnabled = userData['pushNotificationsEnabled'] ?? true;
  }

  /// Load theme settings from user data
  Future<void> _loadThemeSettings(Map<String, dynamic> userData) async {
    final themeString = userData['selectedTheme']?.toString() ?? 'ocean';
    _selectedTheme = ThemeType.values.firstWhere(
      (theme) => theme.name == themeString,
      orElse: () => ThemeType.ocean,
    );
    _updateColorsFromTheme();
  }

  /// Get user document from Firestore
  Future<DocumentSnapshot?> _getUserDocument(User user) async {
    try {
      // Try to find by Firebase UID first
      var query = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }

      // Try to find by email
      query = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      return query.docs.isNotEmpty ? query.docs.first : null;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  /// Update user document in Firestore
  Future<bool> _updateUserDocument(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _getUserDocument(user);
      if (userDoc == null) return false;

      await userDoc.reference.update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating user document: $e');
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update colors based on current theme
  void _updateColorsFromTheme() {
    final colors = ThemeConfig.getThemeColors(_selectedTheme, false);
    _deepBlue = colors['deepBlue']!;
    _surfaceBlue = colors['surfaceBlue']!;
    _lightBlue = colors['blueAccent']!;
    _whiteWater = colors['card']!;
  }

  // Theme Management
  Future<void> setTheme(ThemeType themeType) async {
    // Update theme immediately for instant UI response
    _selectedTheme = themeType;
    _updateColorsFromTheme();
    notifyListeners(); // Notify listeners immediately for instant UI update

    // Update Firestore in background (don't wait for completion)
    _updateUserDocument({
      'selectedTheme': themeType.name,
    }).catchError((error) {
      debugPrint('Error saving theme to Firestore: $error');
      // Optionally revert theme if save fails
      // For now, we'll keep the UI change even if save fails
      return false;
    });
  }

  // Language Management
  Future<void> setLanguage(SupportedLanguage language) async {
    // Update language immediately for instant UI response
    _selectedLanguage = language;
    notifyListeners(); // Notify listeners immediately for instant UI update

    // Update Firestore in background (don't wait for completion)
    _updateUserDocument({
      'selectedLanguage': language.name,
    }).catchError((error) {
      debugPrint('Error saving language to Firestore: $error');
      // Optionally revert language if save fails
      // For now, we'll keep the UI change even if save fails
      return false;
    });
  }

  // Two-Factor Authentication
  Future<Map<String, dynamic>> enable2FA(TwoFactorMethod method,
      [String? phoneNumber]) async {
    try {
      if (method == TwoFactorMethod.sms) {
        return await _enableSMS2FA(phoneNumber);
      }

      // For other methods, just update the setting
      _is2FAEnabled = true;
      _selected2FAMethod = method;

      final success = await _updateUserDocument({
        'is2FAEnabled': true,
        'selected2FAMethod': method.name,
      });

      if (success) {
        notifyListeners();
        return {'success': true, 'message': '2FA enabled successfully'};
      } else {
        return {'success': false, 'message': 'Failed to enable 2FA'};
      }
    } catch (e) {
      debugPrint('Error enabling 2FA: $e');
      return {'success': false, 'message': 'Error enabling 2FA: $e'};
    }
  }

  Future<Map<String, dynamic>> _enableSMS2FA([String? phoneNumber]) async {
    // Use provided phone number or existing one
    final phoneToUse = phoneNumber ?? _phoneNumber;

    if (phoneToUse == null || phoneToUse.isEmpty) {
      return {
        'success': false,
        'message': 'Phone number is required for SMS 2FA'
      };
    }

    try {
      // Generate verification code
      final verificationCode = TextBeeSMSService.generateVerificationCode();

      // Send SMS
      final result = await TextBeeSMSService.sendVerificationSMS(
        phoneNumber: phoneToUse,
        verificationCode: verificationCode,
      );

      if (result['success']) {
        _phoneNumber = phoneToUse; // Store the phone number
        _isSMSVerificationPending = true;
        _pendingVerificationCode = verificationCode;
        _verificationCodeExpiry =
            DateTime.now().add(const Duration(minutes: 5));
        notifyListeners();

        return {
          'success': true,
          'message': 'Verification code sent to your phone',
          'requiresVerification': true,
        };
      } else {
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      debugPrint('Error sending SMS verification: $e');
      return {
        'success': false,
        'message': 'Error sending verification code: $e'
      };
    }
  }

  Future<Map<String, dynamic>> verifySMSCode(String code) async {
    try {
      if (_pendingVerificationCode == null || _verificationCodeExpiry == null) {
        return {'success': false, 'message': 'No pending verification'};
      }

      if (DateTime.now().isAfter(_verificationCodeExpiry!)) {
        return {'success': false, 'message': 'Verification code expired'};
      }

      if (_pendingVerificationCode != code) {
        return {'success': false, 'message': 'Invalid verification code'};
      }

      // SMS verification successful
      _is2FAEnabled = true;
      _selected2FAMethod = TwoFactorMethod.sms;
      _isSMSVerificationPending = false;
      _pendingVerificationCode = null;
      _verificationCodeExpiry = null;

      final success = await _updateUserDocument({
        'is2FAEnabled': true,
        'selected2FAMethod': TwoFactorMethod.sms.name,
        'phoneNumber': _phoneNumber,
      });

      if (success) {
        notifyListeners();
        return {'success': true, 'message': 'SMS 2FA enabled successfully'};
      } else {
        return {'success': false, 'message': 'Failed to save 2FA settings'};
      }
    } catch (e) {
      debugPrint('Error verifying SMS code: $e');
      return {'success': false, 'message': 'Error verifying code: $e'};
    }
  }

  Future<Map<String, dynamic>> sendSMSVerificationCode(
      String phoneNumber) async {
    try {
      _phoneNumber = phoneNumber;

      // Generate verification code
      final verificationCode = TextBeeSMSService.generateVerificationCode();

      // Send SMS
      final result = await TextBeeSMSService.sendVerificationSMS(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );

      if (result['success']) {
        _isSMSVerificationPending = true;
        _pendingVerificationCode = verificationCode;
        _verificationCodeExpiry =
            DateTime.now().add(const Duration(minutes: 5));
        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint('Error sending SMS verification: $e');
      return {
        'success': false,
        'message': 'Error sending verification code: $e'
      };
    }
  }

  Future<Map<String, dynamic>> disable2FA() async {
    try {
      _is2FAEnabled = false;
      _selected2FAMethod = TwoFactorMethod.none;
      _isSMSVerificationPending = false;
      _pendingVerificationCode = null;
      _verificationCodeExpiry = null;

      final success = await _updateUserDocument({
        'is2FAEnabled': false,
        'selected2FAMethod': TwoFactorMethod.none.name,
      });

      if (success) {
        notifyListeners();
        return {'success': true, 'message': '2FA disabled successfully'};
      } else {
        return {'success': false, 'message': 'Failed to disable 2FA'};
      }
    } catch (e) {
      debugPrint('Error disabling 2FA: $e');
      return {'success': false, 'message': 'Error disabling 2FA: $e'};
    }
  }

  void clearSMSVerification() {
    _isSMSVerificationPending = false;
    _pendingVerificationCode = null;
    _verificationCodeExpiry = null;
    notifyListeners();
  }

  // Notification Settings
  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? banPeriodNotifications,
    bool? marineConditionsNotifications,
    bool? educationNotifications,
    bool? complaintNotifications,
    bool? pushNotificationsEnabled,
  }) async {
    try {
      debugPrint('🔄 Updating notification settings...');
      final updateData = <String, dynamic>{};

      if (notificationsEnabled != null) {
        debugPrint(
            '📱 Master notifications: ${_notificationsEnabled} -> $notificationsEnabled');
        _notificationsEnabled = notificationsEnabled;
        updateData['notificationsEnabled'] = notificationsEnabled;
      }
      if (banPeriodNotifications != null) {
        debugPrint(
            '🚫 Ban period notifications: ${_banPeriodNotifications} -> $banPeriodNotifications');
        _banPeriodNotifications = banPeriodNotifications;
        updateData['banPeriodNotifications'] = banPeriodNotifications;
      }
      if (marineConditionsNotifications != null) {
        debugPrint(
            '🌊 Marine conditions notifications: ${_marineConditionsNotifications} -> $marineConditionsNotifications');
        _marineConditionsNotifications = marineConditionsNotifications;
        updateData['marineConditionsNotifications'] =
            marineConditionsNotifications;
      }
      if (educationNotifications != null) {
        debugPrint(
            '📚 Education notifications: ${_educationNotifications} -> $educationNotifications');
        _educationNotifications = educationNotifications;
        updateData['educationNotifications'] = educationNotifications;
      }
      if (complaintNotifications != null) {
        debugPrint(
            '📋 Complaint notifications: ${_complaintNotifications} -> $complaintNotifications');
        _complaintNotifications = complaintNotifications;
        updateData['complaintNotifications'] = complaintNotifications;
      }
      if (pushNotificationsEnabled != null) {
        debugPrint(
            '🔔 Push notifications: ${_pushNotificationsEnabled} -> $pushNotificationsEnabled');
        _pushNotificationsEnabled = pushNotificationsEnabled;
        updateData['pushNotificationsEnabled'] = pushNotificationsEnabled;
      }

      // Update UI immediately for better user experience
      debugPrint('✅ Updating UI immediately...');
      notifyListeners();

      // Update Firestore in background
      if (updateData.isNotEmpty) {
        debugPrint('💾 Updating Firestore with data: $updateData');
        final success = await _updateUserDocument(updateData);
        if (!success) {
          debugPrint(
              '⚠️ Warning: Failed to update notification settings in Firestore');
          // Optionally revert the local state if Firestore update fails
          // For now, we'll keep the local state as is for better UX
        } else {
          debugPrint('✅ Successfully updated Firestore');
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating notification settings: $e');
    }
  }

  // Profile Management
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? profilePictureUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (username != null && username.isNotEmpty) {
        _username = username;
        updateData['displayName'] = username;
      }
      if (email != null && email.isNotEmpty) {
        _email = email;
        updateData['email'] = email;
      }
      if (profilePictureUrl != null) {
        _profilePictureUrl = profilePictureUrl;
        updateData['photoURL'] = profilePictureUrl;
      }

      if (updateData.isNotEmpty) {
        final success = await _updateUserDocument(updateData);
        if (success) {
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Update user profile (alias for updateProfile for compatibility)
  void updateUserProfile({
    required String username,
    required String email,
    String? profilePictureUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    _username = username;
    _email = email;
    if (profilePictureUrl != null) {
      _profilePictureUrl = profilePictureUrl;
    }
    if (firstName != null) _firstName = firstName;
    if (lastName != null) _lastName = lastName;
    if (phoneNumber != null) _phoneNumberFromProfile = phoneNumber;
    notifyListeners();
  }

  // Utility Methods
  String getFormattedPhoneNumber() {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) return '';
    return _phoneNumber!.replaceAll(RegExp(r'\D'), '');
  }

  String getLanguageName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.tagalog:
        return 'Tagalog';
      case SupportedLanguage.cebuano:
        return 'Cebuano';
    }
  }

  String getCurrentThemeName() {
    return ThemeConfig.getThemeName(_selectedTheme);
  }

  String getCurrentThemeDescription() {
    return ThemeConfig.getThemeDescription(_selectedTheme);
  }

  IconData getCurrentThemeIcon() {
    return ThemeConfig.getThemeIcon(_selectedTheme);
  }

  Map<String, Color> getCurrentThemeColors(bool isDark) {
    return ThemeConfig.getThemeColors(_selectedTheme, isDark);
  }

  Color getDeepBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.9)
        : _deepBlue;
  }

  Color getSurfaceBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.8)
        : _surfaceBlue;
  }

  Color getWhiteWater(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : _whiteWater;
  }

  /// Sign out user and clear all data
  Future<void> signOut() async {
    try {
      // Clear Remember Me and credentials on logout
      await CredentialStorageService.clearOnLogout();
      await AuthPersistenceService.clearAll();
      
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear all local state
      _isLoading = true;
      _username = '';
      _email = '';
      _profilePictureUrl = null;
      _selectedTheme = ThemeType.ocean;
      _selectedLanguage = SupportedLanguage.english;
      _is2FAEnabled = false;
      _selected2FAMethod = TwoFactorMethod.none;
      _phoneNumber = null;
      _isEmailVerified = false;
      _pendingVerificationCode = null;
      _verificationCodeExpiry = null;
      _isSMSVerificationPending = false;
      _notificationsEnabled = true;
      _banPeriodNotifications = true;
      _marineConditionsNotifications = true;
      _educationNotifications = true;
      _complaintNotifications = true;
      _pushNotificationsEnabled = true;

      // Reset theme colors to default
      _updateColorsFromTheme();

      // Notify listeners
      notifyListeners();

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}

/// Two-Factor Authentication methods enum
enum TwoFactorMethod {
  none,
  sms,
}
