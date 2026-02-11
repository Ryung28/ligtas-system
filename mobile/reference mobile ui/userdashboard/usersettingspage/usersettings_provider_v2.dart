// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mobileapplication/config/theme_config.dart';
// import 'package:mobileapplication/services/textbee_sms_service.dart';
// import 'package:mobileapplication/userdashboard/config/language_provider.dart';

// /// Clean architecture provider for user settings
// /// Follows separation of concerns and single responsibility principle
// class SettingsProviderV2 extends ChangeNotifier {
//   // Dependencies
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextBeeSMSService _smsService = TextBeeSMSService();

//   // State
//   bool _isLoading = true;
//   String _username = '';
//   String _email = '';
//   String? _profilePictureUrl;

//   // Theme colors
//   Color _deepBlue = const Color(0xFF0D47A1);
//   Color _surfaceBlue = const Color(0xFF1565C0);
//   Color _lightBlue = const Color(0xFF1976D2);
//   Color _whiteWater = Colors.white;

//   // Settings
//   ThemeType _selectedTheme = ThemeType.ocean;
//   SupportedLanguage _selectedLanguage = SupportedLanguage.english;

//   // Two-Factor Authentication
//   bool _is2FAEnabled = false;
//   TwoFactorMethod _selected2FAMethod = TwoFactorMethod.none;
//   String? _phoneNumber;
//   bool _isEmailVerified = false;

//   // SMS 2FA specific
//   String? _pendingVerificationCode;
//   DateTime? _verificationCodeExpiry;
//   bool _isSMSVerificationPending = false;

//   // Notification Settings
//   bool _notificationsEnabled = true;
//   bool _banPeriodNotifications = true;
//   bool _marineConditionsNotifications = true;
//   bool _educationNotifications = true;
//   bool _complaintNotifications = true;
//   bool _pushNotificationsEnabled = true;

//   // Getters
//   bool get isLoading => _isLoading;
//   String get username => _username;
//   String get email => _email;
//   String? get profilePictureUrl => _profilePictureUrl;

//   Color get deepBlue => _deepBlue;
//   Color get surfaceBlue => _surfaceBlue;
//   Color get lightBlue => _lightBlue;
//   Color get whiteWater => _whiteWater;

//   ThemeType get selectedTheme => _selectedTheme;
//   SupportedLanguage get selectedLanguage => _selectedLanguage;

//   bool get is2FAEnabled => _is2FAEnabled;
//   TwoFactorMethod get selected2FAMethod => _selected2FAMethod;
//   String? get phoneNumber => _phoneNumber;
//   bool get isEmailVerified => _isEmailVerified;

//   String? get pendingVerificationCode => _pendingVerificationCode;
//   DateTime? get verificationCodeExpiry => _verificationCodeExpiry;
//   bool get isSMSVerificationPending => _isSMSVerificationPending;

//   // Notification getters
//   bool get notificationsEnabled => _notificationsEnabled;
//   bool get banPeriodNotifications => _banPeriodNotifications;
//   bool get marineConditionsNotifications => _marineConditionsNotifications;
//   bool get educationNotifications => _educationNotifications;
//   bool get complaintNotifications => _complaintNotifications;
//   bool get pushNotificationsEnabled => _pushNotificationsEnabled;

//   /// Initialize and load user data
//   Future<void> initialize() async {
//     await loadUserData();
//   }

//   /// Load user data from Firestore
//   Future<void> loadUserData() async {
//     try {
//       _setLoading(true);

//       final user = _auth.currentUser;
//       if (user == null) return;

//       final userDoc = await _getUserDocument(user);
//       if (userDoc == null) return;

//       final userData = userDoc.data() as Map<String, dynamic>;

//       // Basic user info
//       _username = userData['displayName']?.toString() ?? '';
//       _email = userData['email']?.toString() ?? '';
//       _profilePictureUrl = userData['photoURL']?.toString();

//       // Load settings
//       await _load2FASettings(userData);
//       await _loadLanguageSettings(userData);
//       await _loadNotificationSettings(userData);
//       await _loadThemeSettings(userData);
//     } catch (e) {
//       debugPrint('Error loading user data: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Load 2FA settings from user data
//   Future<void> _load2FASettings(Map<String, dynamic> userData) async {
//     _is2FAEnabled = userData['is2FAEnabled'] ?? false;

//     final methodString = userData['selected2FAMethod']?.toString() ?? 'none';
//     _selected2FAMethod = TwoFactorMethod.values.firstWhere(
//       (method) => method.name == methodString,
//       orElse: () => TwoFactorMethod.none,
//     );

//     _phoneNumber = userData['phoneNumber']?.toString();
//     _isEmailVerified = userData['isEmailVerified'] ?? false;
//   }

//   /// Load language settings from user data
//   Future<void> _loadLanguageSettings(Map<String, dynamic> userData) async {
//     final languageString =
//         userData['selectedLanguage']?.toString() ?? 'english';
//     _selectedLanguage = SupportedLanguage.values.firstWhere(
//       (language) => language.name == languageString,
//       orElse: () => SupportedLanguage.english,
//     );
//   }

//   /// Load notification settings from user data
//   Future<void> _loadNotificationSettings(Map<String, dynamic> userData) async {
//     _notificationsEnabled = userData['notificationsEnabled'] ?? true;
//     _banPeriodNotifications = userData['banPeriodNotifications'] ?? true;
//     _marineConditionsNotifications =
//         userData['marineConditionsNotifications'] ?? true;
//     _educationNotifications = userData['educationNotifications'] ?? true;
//     _complaintNotifications = userData['complaintNotifications'] ?? true;
//     _pushNotificationsEnabled = userData['pushNotificationsEnabled'] ?? true;
//   }

//   /// Load theme settings from user data
//   Future<void> _loadThemeSettings(Map<String, dynamic> userData) async {
//     final themeString = userData['selectedTheme']?.toString() ?? 'ocean';
//     _selectedTheme = ThemeType.values.firstWhere(
//       (theme) => theme.name == themeString,
//       orElse: () => ThemeType.ocean,
//     );
//     _updateColorsFromTheme();
//   }

//   /// Get user document from Firestore
//   Future<DocumentSnapshot?> _getUserDocument(User user) async {
//     try {
//       // Try to find by Firebase UID first
//       var query = await _firestore
//           .collection('users')
//           .where('firebaseUID', isEqualTo: user.uid)
//           .get();

//       if (query.docs.isNotEmpty) {
//         return query.docs.first;
//       }

//       // Try to find by email
//       query = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: user.email)
//           .get();

//       return query.docs.isNotEmpty ? query.docs.first : null;
//     } catch (e) {
//       debugPrint('Error getting user document: $e');
//       return null;
//     }
//   }

//   /// Update user document in Firestore
//   Future<bool> _updateUserDocument(Map<String, dynamic> data) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return false;

//       final userDoc = await _getUserDocument(user);
//       if (userDoc == null) return false;

//       await userDoc.reference.update(data);
//       return true;
//     } catch (e) {
//       debugPrint('Error updating user document: $e');
//       return false;
//     }
//   }

//   /// Set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   /// Update colors based on current theme
//   void _updateColorsFromTheme() {
//     final colors = ThemeConfig.getThemeColors(_selectedTheme, false);
//     _deepBlue = colors['deepBlue']!;
//     _surfaceBlue = colors['surfaceBlue']!;
//     _lightBlue = colors['blueAccent']!;
//     _whiteWater = colors['card']!;
//   }

//   // Theme Management
//   Future<void> setTheme(ThemeType themeType) async {
//     _selectedTheme = themeType;
//     _updateColorsFromTheme();

//     final success = await _updateUserDocument({
//       'selectedTheme': themeType.name,
//     });

//     if (success) {
//       notifyListeners();
//     }
//   }

//   // Language Management
//   Future<void> setLanguage(SupportedLanguage language) async {
//     _selectedLanguage = language;

//     final success = await _updateUserDocument({
//       'selectedLanguage': language.name,
//     });

//     if (success) {
//       notifyListeners();
//     }
//   }

//   // Two-Factor Authentication
//   Future<Map<String, dynamic>> enable2FA(TwoFactorMethod method) async {
//     try {
//       if (method == TwoFactorMethod.sms) {
//         return await _enableSMS2FA();
//       }

//       // For other methods, just update the setting
//       _is2FAEnabled = true;
//       _selected2FAMethod = method;

//       final success = await _updateUserDocument({
//         'is2FAEnabled': true,
//         'selected2FAMethod': method.name,
//       });

//       if (success) {
//         notifyListeners();
//         return {'success': true, 'message': '2FA enabled successfully'};
//       } else {
//         return {'success': false, 'message': 'Failed to enable 2FA'};
//       }
//     } catch (e) {
//       debugPrint('Error enabling 2FA: $e');
//       return {'success': false, 'message': 'Error enabling 2FA: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> _enableSMS2FA() async {
//     if (_phoneNumber == null || _phoneNumber!.isEmpty) {
//       return {
//         'success': false,
//         'message': 'Phone number is required for SMS 2FA'
//       };
//     }

//     try {
//       final result = await _smsService.sendVerificationCode(_phoneNumber!);

//       if (result['success']) {
//         _isSMSVerificationPending = true;
//         _pendingVerificationCode = result['code'];
//         _verificationCodeExpiry =
//             DateTime.now().add(const Duration(minutes: 5));
//         notifyListeners();

//         return {
//           'success': true,
//           'message': 'Verification code sent to your phone',
//           'requiresVerification': true,
//         };
//       } else {
//         return {'success': false, 'message': result['message']};
//       }
//     } catch (e) {
//       debugPrint('Error sending SMS verification: $e');
//       return {
//         'success': false,
//         'message': 'Error sending verification code: $e'
//       };
//     }
//   }

//   Future<Map<String, dynamic>> verifySMSCode(String code) async {
//     try {
//       if (_pendingVerificationCode == null || _verificationCodeExpiry == null) {
//         return {'success': false, 'message': 'No pending verification'};
//       }

//       if (DateTime.now().isAfter(_verificationCodeExpiry!)) {
//         return {'success': false, 'message': 'Verification code expired'};
//       }

//       if (_pendingVerificationCode != code) {
//         return {'success': false, 'message': 'Invalid verification code'};
//       }

//       // SMS verification successful
//       _is2FAEnabled = true;
//       _selected2FAMethod = TwoFactorMethod.sms;
//       _isSMSVerificationPending = false;
//       _pendingVerificationCode = null;
//       _verificationCodeExpiry = null;

//       final success = await _updateUserDocument({
//         'is2FAEnabled': true,
//         'selected2FAMethod': TwoFactorMethod.sms.name,
//         'phoneNumber': _phoneNumber,
//       });

//       if (success) {
//         notifyListeners();
//         return {'success': true, 'message': 'SMS 2FA enabled successfully'};
//       } else {
//         return {'success': false, 'message': 'Failed to save 2FA settings'};
//       }
//     } catch (e) {
//       debugPrint('Error verifying SMS code: $e');
//       return {'success': false, 'message': 'Error verifying code: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> sendSMSVerificationCode(
//       String phoneNumber) async {
//     try {
//       _phoneNumber = phoneNumber;

//       final result = await _smsService.sendVerificationCode(phoneNumber);

//       if (result['success']) {
//         _isSMSVerificationPending = true;
//         _pendingVerificationCode = result['code'];
//         _verificationCodeExpiry =
//             DateTime.now().add(const Duration(minutes: 5));
//         notifyListeners();
//       }

//       return result;
//     } catch (e) {
//       debugPrint('Error sending SMS verification: $e');
//       return {
//         'success': false,
//         'message': 'Error sending verification code: $e'
//       };
//     }
//   }

//   Future<Map<String, dynamic>> disable2FA() async {
//     try {
//       _is2FAEnabled = false;
//       _selected2FAMethod = TwoFactorMethod.none;
//       _isSMSVerificationPending = false;
//       _pendingVerificationCode = null;
//       _verificationCodeExpiry = null;

//       final success = await _updateUserDocument({
//         'is2FAEnabled': false,
//         'selected2FAMethod': TwoFactorMethod.none.name,
//       });

//       if (success) {
//         notifyListeners();
//         return {'success': true, 'message': '2FA disabled successfully'};
//       } else {
//         return {'success': false, 'message': 'Failed to disable 2FA'};
//       }
//     } catch (e) {
//       debugPrint('Error disabling 2FA: $e');
//       return {'success': false, 'message': 'Error disabling 2FA: $e'};
//     }
//   }

//   void clearSMSVerification() {
//     _isSMSVerificationPending = false;
//     _pendingVerificationCode = null;
//     _verificationCodeExpiry = null;
//     notifyListeners();
//   }

//   // Notification Settings
//   Future<void> updateNotificationSettings({
//     bool? notificationsEnabled,
//     bool? banPeriodNotifications,
//     bool? marineConditionsNotifications,
//     bool? educationNotifications,
//     bool? complaintNotifications,
//     bool? pushNotificationsEnabled,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{};

//       if (notificationsEnabled != null) {
//         _notificationsEnabled = notificationsEnabled;
//         updateData['notificationsEnabled'] = notificationsEnabled;
//       }
//       if (banPeriodNotifications != null) {
//         _banPeriodNotifications = banPeriodNotifications;
//         updateData['banPeriodNotifications'] = banPeriodNotifications;
//       }
//       if (marineConditionsNotifications != null) {
//         _marineConditionsNotifications = marineConditionsNotifications;
//         updateData['marineConditionsNotifications'] =
//             marineConditionsNotifications;
//       }
//       if (educationNotifications != null) {
//         _educationNotifications = educationNotifications;
//         updateData['educationNotifications'] = educationNotifications;
//       }
//       if (complaintNotifications != null) {
//         _complaintNotifications = complaintNotifications;
//         updateData['complaintNotifications'] = complaintNotifications;
//       }
//       if (pushNotificationsEnabled != null) {
//         _pushNotificationsEnabled = pushNotificationsEnabled;
//         updateData['pushNotificationsEnabled'] = pushNotificationsEnabled;
//       }

//       if (updateData.isNotEmpty) {
//         final success = await _updateUserDocument(updateData);
//         if (success) {
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error updating notification settings: $e');
//     }
//   }

//   // Profile Management
//   Future<bool> updateProfile({
//     String? username,
//     String? email,
//     String? profilePictureUrl,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{};

//       if (username != null && username.isNotEmpty) {
//         _username = username;
//         updateData['displayName'] = username;
//       }
//       if (email != null && email.isNotEmpty) {
//         _email = email;
//         updateData['email'] = email;
//       }
//       if (profilePictureUrl != null) {
//         _profilePictureUrl = profilePictureUrl;
//         updateData['photoURL'] = profilePictureUrl;
//       }

//       if (updateData.isNotEmpty) {
//         final success = await _updateUserDocument(updateData);
//         if (success) {
//           notifyListeners();
//           return true;
//         }
//       }
//       return false;
//     } catch (e) {
//       debugPrint('Error updating profile: $e');
//       return false;
//     }
//   }

//   // Utility Methods
//   String getFormattedPhoneNumber() {
//     if (_phoneNumber == null || _phoneNumber!.isEmpty) return '';
//     return _phoneNumber!.replaceAll(RegExp(r'\D'), '');
//   }

//   String getLanguageName(SupportedLanguage language) {
//     switch (language) {
//       case SupportedLanguage.english:
//         return 'English';
//       case SupportedLanguage.tagalog:
//         return 'Tagalog';
//       case SupportedLanguage.cebuano:
//         return 'Cebuano';
//       case SupportedLanguage.hiligaynon:
//         return 'Hiligaynon';
//     }
//   }

//   String getCurrentThemeName() {
//     return ThemeConfig.getThemeName(_selectedTheme);
//   }

//   String getCurrentThemeDescription() {
//     return ThemeConfig.getThemeDescription(_selectedTheme);
//   }

//   IconData getCurrentThemeIcon() {
//     return ThemeConfig.getThemeIcon(_selectedTheme);
//   }

//   Map<String, Color> getCurrentThemeColors(bool isDark) {
//     return ThemeConfig.getThemeColors(_selectedTheme, isDark);
//   }

//   Color getDeepBlue(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.white.withOpacity(0.9)
//         : _deepBlue;
//   }

//   Color getSurfaceBlue(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.white.withOpacity(0.8)
//         : _surfaceBlue;
//   }

//   Color getWhiteWater(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.grey[900]!
//         : _whiteWater;
//   }
// }

// /// Two-Factor Authentication methods enum
// enum TwoFactorMethod {
//   none,
//   sms,
// }
