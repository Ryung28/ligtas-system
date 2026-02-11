import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/services/textbee_sms_service.dart';
import 'package:mobileapplication/userdashboard/config/language_provider.dart';

enum TwoFactorMethod {
  none,
  googleAuthenticator,
  sms,
  email,
}

class SettingsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String username = '';
  String email = '';
  String? profilePictureUrl;
  Color deepBlue = const Color(0xFF0D47A1); // Consistent darker blue
  Color surfaceBlue = const Color(0xFF1565C0); // Consistent darker blue
  Color lightBlue = const Color(0xFF1976D2); // Consistent darker blue
  Color whiteWater = Colors.white;

  // Theme selection
  ThemeType selectedTheme = ThemeType.ocean;

  // Language selection
  SupportedLanguage selectedLanguage = SupportedLanguage.english;

  // Two-Factor Authentication
  bool is2FAEnabled = false;
  TwoFactorMethod selected2FAMethod = TwoFactorMethod.none;
  String? phoneNumber;
  bool isEmailVerified = false;

  // SMS 2FA specific
  String? pendingVerificationCode;
  DateTime? verificationCodeExpiry;
  bool isSMSVerificationPending = false;

  // Notification Settings
  bool notificationsEnabled = true;
  bool banPeriodNotifications = true;
  bool marineConditionsNotifications = true;
  bool educationNotifications = true;
  bool complaintNotifications = true;
  bool pushNotificationsEnabled = true;

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user != null) {
        // First try to find user by Firebase UID
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // Try to find by email
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          username = userData['displayName']?.toString() ?? '';
          email = userData['email']?.toString() ?? '';
          profilePictureUrl = userData['photoURL']?.toString();

          // Load 2FA settings
          is2FAEnabled = userData['is2FAEnabled'] ?? false;
          final methodString =
              userData['selected2FAMethod']?.toString() ?? 'none';
          selected2FAMethod = TwoFactorMethod.values.firstWhere(
            (method) => method.name == methodString,
            orElse: () => TwoFactorMethod.none,
          );
          phoneNumber = userData['phoneNumber']?.toString();
          isEmailVerified = userData['isEmailVerified'] ?? false;

          // Load language settings
          final languageString =
              userData['selectedLanguage']?.toString() ?? 'english';
          selectedLanguage = SupportedLanguage.values.firstWhere(
            (language) => language.name == languageString,
            orElse: () => SupportedLanguage.english,
          );

          // Load notification settings
          notificationsEnabled = userData['notificationsEnabled'] ?? true;
          banPeriodNotifications = userData['banPeriodNotifications'] ?? true;
          marineConditionsNotifications =
              userData['marineConditionsNotifications'] ?? true;
          educationNotifications = userData['educationNotifications'] ?? true;
          complaintNotifications = userData['complaintNotifications'] ?? true;
          pushNotificationsEnabled =
              userData['pushNotificationsEnabled'] ?? true;

          // If username is empty, try other fields
          if (username.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              username = '$firstName $lastName'.trim();
            } else {
              username = userData['username']?.toString() ?? 'User';
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // First try to find user by Firebase UID
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // Try to find by email
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final docRef = userQuery.docs.first.reference;
          await docRef.update({
            'photoURL': imageUrl,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          profilePictureUrl = imageUrl;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }

  Future<bool> updateUserProfile({
    required String displayName,
    required String email,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // First try to find user by Firebase UID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        // Try to find by email
        userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
      }

      if (userQuery.docs.isNotEmpty) {
        final docRef = userQuery.docs.first.reference;

        // Prepare update data
        Map<String, dynamic> updateData = {
          'displayName': displayName,
          'email': email,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          updateData['phoneNumber'] = phoneNumber;
        }

        if (photoURL != null && photoURL.isNotEmpty) {
          updateData['photoURL'] = photoURL;
        }

        // Update Firestore document
        await docRef.update(updateData);

        // Update local state
        this.username = displayName;
        this.email = email;
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          this.phoneNumber = phoneNumber;
        }
        if (photoURL != null && photoURL.isNotEmpty) {
          this.profilePictureUrl = photoURL;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Color getDeepBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : deepBlue;
  }

  Color getSurfaceBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.8)
        : surfaceBlue;
  }

  Color getWhiteWater(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : whiteWater;
  }

  // Theme management methods
  void setTheme(ThemeType themeType) {
    selectedTheme = themeType;
    _updateColorsFromTheme();
    notifyListeners();
  }

  // Language management methods
  void setLanguage(SupportedLanguage language) {
    selectedLanguage = language;
    notifyListeners();
    _saveLanguageSettings();
  }

  Future<void> _saveLanguageSettings() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final docId = await _getUserDocumentId(user);
        if (docId != null) {
          await _firestore.collection('users').doc(docId).update({
            'selectedLanguage': selectedLanguage.name,
          });
        }
      }
    } catch (e) {
      print('Error saving language settings: $e');
    }
  }

  void _updateColorsFromTheme() {
    final isDark = false; // We'll get this from context when needed
    final colors = ThemeConfig.getThemeColors(selectedTheme, isDark);

    deepBlue = colors['deepBlue']!;
    surfaceBlue = colors['surfaceBlue']!;
    lightBlue = colors['blueAccent']!;
    whiteWater = colors['card']!;
  }

  // Get current theme colors based on brightness
  Map<String, Color> getCurrentThemeColors(bool isDark) {
    return ThemeConfig.getThemeColors(selectedTheme, isDark);
  }

  // Get theme name
  String getCurrentThemeName() {
    return ThemeConfig.getThemeName(selectedTheme);
  }

  // Get theme description
  String getCurrentThemeDescription() {
    return ThemeConfig.getThemeDescription(selectedTheme);
  }

  // Get theme icon
  IconData getCurrentThemeIcon() {
    return ThemeConfig.getThemeIcon(selectedTheme);
  }

  // Two-Factor Authentication Methods
  Future<void> enable2FA(TwoFactorMethod method) async {
    try {
      is2FAEnabled = true;
      selected2FAMethod = method;
      notifyListeners();

      // Save to Firestore
      await _save2FASettings();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> disable2FA() async {
    try {
      is2FAEnabled = false;
      selected2FAMethod = TwoFactorMethod.none;
      notifyListeners();

      // Save to Firestore
      await _save2FASettings();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> updatePhoneNumber(String phone) async {
    try {
      phoneNumber = phone;
      notifyListeners();
      await _save2FASettings();
    } catch (e) {
      // Handle error silently
    }
  }

  // SMS 2FA Methods
  Future<Map<String, dynamic>> sendSMSVerificationCode(
      String phoneNumber) async {
    try {
      // Validate phone number
      if (!TextBeeSMSService.isValidPhoneNumber(phoneNumber)) {
        return {
          'success': false,
          'message': 'Invalid phone number format',
        };
      }

      // Format phone number
      final formattedPhone = TextBeeSMSService.formatPhoneNumber(phoneNumber);

      // Generate verification code
      final verificationCode = TextBeeSMSService.generateVerificationCode();

      // Send SMS
      final result = await TextBeeSMSService.sendVerificationSMS(
        phoneNumber: formattedPhone,
        verificationCode: verificationCode,
      );

      if (result['success']) {
        // Store verification code and expiry
        pendingVerificationCode = verificationCode;
        verificationCodeExpiry = DateTime.now().add(const Duration(minutes: 5));
        isSMSVerificationPending = true;
        notifyListeners();

        return {
          'success': true,
          'message': 'Verification code sent to $formattedPhone',
        };
      } else {
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending verification code: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifySMSCode(String inputCode) async {
    try {
      // Check if verification is pending
      if (!isSMSVerificationPending || pendingVerificationCode == null) {
        return {
          'success': false,
          'message': 'No verification code pending',
        };
      }

      // Check if code has expired
      if (verificationCodeExpiry == null ||
          DateTime.now().isAfter(verificationCodeExpiry!)) {
        // Clear expired code
        pendingVerificationCode = null;
        verificationCodeExpiry = null;
        isSMSVerificationPending = false;
        notifyListeners();

        return {
          'success': false,
          'message': 'Verification code has expired',
        };
      }

      // Verify code
      if (inputCode == pendingVerificationCode) {
        // Clear verification data
        pendingVerificationCode = null;
        verificationCodeExpiry = null;
        isSMSVerificationPending = false;

        // Enable 2FA with SMS
        await enable2FA(TwoFactorMethod.sms);

        return {
          'success': true,
          'message': 'SMS 2FA enabled successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid verification code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying code: $e',
      };
    }
  }

  void clearSMSVerification() {
    pendingVerificationCode = null;
    verificationCodeExpiry = null;
    isSMSVerificationPending = false;
    notifyListeners();
  }

  bool isVerificationCodeExpired() {
    if (verificationCodeExpiry == null) return true;
    return DateTime.now().isAfter(verificationCodeExpiry!);
  }

  String getFormattedPhoneNumber() {
    if (phoneNumber == null) return '';
    return TextBeeSMSService.formatPhoneNumber(phoneNumber!);
  }

  Future<void> verifyEmail() async {
    try {
      isEmailVerified = true;
      notifyListeners();
      await _save2FASettings();
    } catch (e) {
      print('Error verifying email: $e');
    }
  }

  Future<void> _save2FASettings() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Find the correct document ID for the user
        final docId = await _getUserDocumentId(user);
        if (docId != null) {
          await _firestore.collection('users').doc(docId).update({
            'is2FAEnabled': is2FAEnabled,
            'selected2FAMethod': selected2FAMethod.name,
            'phoneNumber': phoneNumber,
            'isEmailVerified': isEmailVerified,
          });
        }
      }
    } catch (e) {
      // Handle error silently
      print('Error saving 2FA settings: $e');
    }
  }

  // Helper method to get the correct document ID for the current user
  Future<String?> _getUserDocumentId(User user) async {
    try {
      // First try to find user by Firebase UID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id;
      }

      // Then try to find by email
      userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id;
      }

      return null;
    } catch (e) {
      print('Error finding user document ID: $e');
      return null;
    }
  }

  String get2FAMethodDisplayName() {
    switch (selected2FAMethod) {
      case TwoFactorMethod.googleAuthenticator:
        return 'Google Authenticator';
      case TwoFactorMethod.sms:
        return 'SMS';
      case TwoFactorMethod.email:
        return 'Email';
      case TwoFactorMethod.none:
        return 'None';
    }
  }

  IconData get2FAMethodIcon() {
    switch (selected2FAMethod) {
      case TwoFactorMethod.googleAuthenticator:
        return Icons.security;
      case TwoFactorMethod.sms:
        return Icons.sms;
      case TwoFactorMethod.email:
        return Icons.email;
      case TwoFactorMethod.none:
        return Icons.security_outlined;
    }
  }

  // Language helper methods
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

  String getLanguageNativeName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.tagalog:
        return 'Filipino';
      case SupportedLanguage.cebuano:
        return 'Bisaya';
    }
  }

  // Notification Settings Methods
  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? banPeriodNotifications,
    bool? marineConditionsNotifications,
    bool? educationNotifications,
    bool? complaintNotifications,
    bool? pushNotificationsEnabled,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // Find user document
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
      }

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        final updateData = <String, dynamic>{};

        if (notificationsEnabled != null) {
          this.notificationsEnabled = notificationsEnabled;
          updateData['notificationsEnabled'] = notificationsEnabled;
        }
        if (banPeriodNotifications != null) {
          this.banPeriodNotifications = banPeriodNotifications;
          updateData['banPeriodNotifications'] = banPeriodNotifications;
        }
        if (marineConditionsNotifications != null) {
          this.marineConditionsNotifications = marineConditionsNotifications;
          updateData['marineConditionsNotifications'] =
              marineConditionsNotifications;
        }
        if (educationNotifications != null) {
          this.educationNotifications = educationNotifications;
          updateData['educationNotifications'] = educationNotifications;
        }
        if (complaintNotifications != null) {
          this.complaintNotifications = complaintNotifications;
          updateData['complaintNotifications'] = complaintNotifications;
        }
        if (pushNotificationsEnabled != null) {
          this.pushNotificationsEnabled = pushNotificationsEnabled;
          updateData['pushNotificationsEnabled'] = pushNotificationsEnabled;
        }

        if (updateData.isNotEmpty) {
          await userDoc.reference.update(updateData);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }
}
