import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/userdashboard/config/language_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';
import 'package:mobileapplication/services/global_user_refresh_service.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/sms_verification_dialog.dart';
import 'package:mobileapplication/authenticationpages/loginpage/platform_login_page.dart';
import 'dart:io';

/// Dialog components for user settings
/// Follows clean architecture and separation of concerns
class SettingsDialogs {
  /// Show edit profile dialog
  static Future<void> showEditProfileDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show notification settings dialog
  static Future<void> showNotificationSettingsDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationSettingsDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show theme selection dialog
  static Future<void> showThemeSelectionDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeSelectionDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show language selection dialog
  static Future<void> showLanguageSelectionDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectionDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show 2FA settings dialog
  static Future<void> show2FASettingsDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TwoFactorAuthDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show change password dialog
  static Future<void> showChangePasswordDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        provider: provider,
        isDark: isDark,
      ),
    );
  }

  /// Show storage settings dialog
  static Future<void> showStorageSettingsDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
        title: Text(
          'Storage Settings',
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Storage management features coming soon!',
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDark ? ThemeConfig.darkBlueAccent : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show about app dialog
  static Future<void> showAboutAppDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    final themeColors = provider.getCurrentThemeColors(isDark);
    final primaryColor = themeColors['primary'] ?? (isDark ? ThemeConfig.darkBlueAccent : Colors.blue);
    
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Marine Guard',
                            style: UserDashboardFonts.bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: UserDashboardFonts.smallText.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: (isDark ? ThemeConfig.darkBlueAccent : primaryColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? ThemeConfig.darkBlueAccent : primaryColor).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: isDark ? ThemeConfig.darkBlueAccent : primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Marine Protection Platform',
                                    style: UserDashboardFonts.bodyText.copyWith(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Advanced monitoring and security',
                                    style: UserDashboardFonts.smallText.copyWith(
                                      color: isDark ? Colors.white70 : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'About Marine Guard',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Marine Guard is a comprehensive marine protection and monitoring application designed to safeguard marine environments and promote conservation efforts.',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it',
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: UserDashboardFonts.bodyText.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: UserDashboardFonts.smallText.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show terms and conditions dialog
  static Future<void> showTermsAndConditionsDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    final themeColors = provider.getCurrentThemeColors(isDark);
    final primaryColor = themeColors['primary'] ?? (isDark ? ThemeConfig.darkBlueAccent : Colors.blue);
    
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated: January 2024',
                        style: UserDashboardFonts.smallText.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('1. Acceptance of Terms', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'By accessing and using Marine Guard, you accept and agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use our services.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('2. Use License', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'Permission is granted to temporarily use Marine Guard for personal, non-commercial use only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Remove any copyright or proprietary notations',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('3. User Responsibilities', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'Users are responsible for maintaining the confidentiality of their account credentials and for all activities that occur under their account. You agree to notify us immediately of any unauthorized use of your account.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('4. Privacy', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'Your use of Marine Guard is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices regarding the collection and use of your information.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('5. Limitations', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'In no event shall Marine Guard or its suppliers be liable for any damages arising out of the use or inability to use the application, even if we have been notified of the possibility of such damage.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('6. Revisions', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'Marine Guard may revise these terms at any time without notice. By using this application, you are agreeing to be bound by the current version of these Terms and Conditions.',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'I Understand',
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: UserDashboardFonts.bodyText.copyWith(
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  static Widget _buildSectionContent(String content, bool isDark) {
    return Text(
      content,
      style: UserDashboardFonts.bodyText.copyWith(
        color: isDark ? Colors.white70 : Colors.grey[700],
        fontSize: 13,
        height: 1.6,
      ),
    );
  }

  /// Show privacy policy dialog
  static Future<void> showPrivacyPolicyDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    final themeColors = provider.getCurrentThemeColors(isDark);
    final primaryColor = themeColors['primary'] ?? (isDark ? ThemeConfig.darkBlueAccent : Colors.blue);
    
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.privacy_tip_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? ThemeConfig.darkBlueAccent : primaryColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isDark ? ThemeConfig.darkBlueAccent : primaryColor).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: isDark ? ThemeConfig.darkBlueAccent : primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Last Updated: January 2024',
                                style: UserDashboardFonts.smallText.copyWith(
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Information We Collect', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'We collect information that you provide directly to us, including:\n\n• Account information (name, email, phone)\n• Usage data and preferences\n• Device information and identifiers\n• Location data (when permitted)',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('How We Use Your Information', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'We use the information we collect to:\n\n• Provide and improve our services\n• Send you notifications and alerts\n• Ensure security and prevent fraud\n• Comply with legal obligations',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Data Security', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'We implement appropriate technical and organizational security measures to protect your personal information. This includes encryption, secure servers, and regular security audits.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Your Rights', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'You have the right to:\n\n• Access your personal data\n• Request correction of inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Data portability',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Cookies & Tracking', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'We use cookies and similar tracking technologies to enhance your experience. You can control cookie preferences through your device settings.',
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Contact Us', isDark),
                      const SizedBox(height: 8),
                      _buildSectionContent(
                        'If you have questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@marineguard.com\nSupport: support@marineguard.com',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'I Understand',
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show contact support dialog
  static Future<void> showContactSupportDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
        title: Text(
          'Contact Support',
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: support@marineguard.com',
              style: UserDashboardFonts.bodyText.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: +1 (555) 123-4567',
              style: UserDashboardFonts.bodyText.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDark ? ThemeConfig.darkBlueAccent : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  static Future<void> showLogoutConfirmationDialog({
    required BuildContext context,
    required SettingsProviderV2 provider,
    required bool isDark,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
        title: Text(
          'Sign Out',
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleSignOut(context, provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign Out',
              style: UserDashboardFonts.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle sign out process with proper navigation
  static Future<void> _handleSignOut(
    BuildContext context,
    SettingsProviderV2 provider,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out from provider
      await provider.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PlatformLoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

// Compact and Functional Edit Profile Dialog
class _EditProfileDialog extends StatefulWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _EditProfileDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _imageUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadUserData() {
    _usernameController.text = widget.provider.username;
    _emailController.text = widget.provider.email;
    _imageUrl = widget.provider.profilePictureUrl;

    // 🔥 FIX: Load firstName and lastName directly from provider (which loads from Firestore)
    _firstNameController.text = widget.provider.firstName;
    _lastNameController.text = widget.provider.lastName;
    
    // Also load phone number if available
    if (widget.provider.phoneNumberFromProfile != null) {
      _phoneController.text = widget.provider.phoneNumberFromProfile!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors for consistent styling
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color primaryColor = themeColors['primary']!;
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // More compact
      decoration: BoxDecoration(
        color: widget.isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Compact header
          _buildCompactHeader(primaryColor, textColor),

          // Form content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCompactForm(primaryColor, textColor, cardColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: UserDashboardFonts.titleText.copyWith(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Update your information',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactForm(
      Color primaryColor, Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Compact profile photo section
            _buildCompactProfilePhoto(primaryColor, cardColor),

            const SizedBox(height: 20),

            // Name fields in a row
            Row(
              children: [
                Expanded(
                  child: _buildCompactTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Username field
            _buildCompactTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
              primaryColor: primaryColor,
              textColor: textColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username required';
                }
                if (value.length < 3) {
                  return 'Min 3 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email field
            _buildCompactTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              primaryColor: primaryColor,
              textColor: textColor,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Invalid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone field
            _buildCompactTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              icon: Icons.phone_outlined,
              primaryColor: primaryColor,
              textColor: textColor,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Action buttons
            _buildCompactActionButtons(primaryColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactProfilePhoto(Color primaryColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Compact avatar
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: cardColor,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                          ? NetworkImage(_imageUrl!)
                          : null),
                  child: _selectedImage == null &&
                          (_imageUrl == null || _imageUrl!.isEmpty)
                      ? Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: primaryColor.withOpacity(0.6),
                        )
                      : null,
                ),
              ),
              if (_isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Photo change button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: widget.isDark ? Colors.white : Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploadingImage ? null : _pickImage,
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                        label: Text(
                          'Change Photo',
                          style: UserDashboardFonts.smallText.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side:
                              BorderSide(color: primaryColor.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    if (_selectedImage != null ||
                        (_imageUrl != null && _imageUrl!.isNotEmpty)) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isUploadingImage ? null : _removeImage,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    required Color textColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: UserDashboardFonts.bodyText.copyWith(
          color: textColor,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: UserDashboardFonts.smallText.copyWith(
            color: widget.isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.grey[600],
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryColor.withOpacity(0.7),
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCompactActionButtons(Color primaryColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Text(
              'Cancel',
              style: UserDashboardFonts.bodyText.copyWith(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Save Changes',
                        style: UserDashboardFonts.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _imageUrl;

    try {
      setState(() {
        _isUploadingImage = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Upload to Cloudinary using the existing service
      final downloadUrl = await CloudinaryService.uploadFile(
        _selectedImage!,
        'marine_guard/profile_pictures',
      );

      setState(() {
        _isUploadingImage = false;
        _imageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      _showErrorSnackBar('Failed to upload image: $e');
      return null;
    }
  }

  /// Get user document reference from Firestore
  /// This method handles the proper lookup of user documents
  Future<DocumentReference?> _getUserDocumentReference(User user) async {
    try {
      // First try to find user by Firebase UID
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.reference;
      }

      // If not found by UID, try to find by email
      if (user.email != null) {
        userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userQuery.docs.isNotEmpty) {
          return userQuery.docs.first.reference;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error finding user document reference: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Show premium confirmation dialog
    final shouldSave = await _showSaveConfirmationDialog();
    if (!shouldSave) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Prepare data for parallel operations
      final displayName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim();
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phoneNumber = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null;

      // Start parallel operations for better performance
      final futures = <Future>[];

      // Upload image if selected (this can run in parallel)
      Future<String?> imageUploadFuture;
      if (_selectedImage != null) {
        imageUploadFuture = _uploadImage();
        futures.add(imageUploadFuture);
      } else {
        imageUploadFuture = Future.value(_imageUrl);
      }

      // Get user document reference (this can run in parallel with image upload)
      final userDocRefFuture = _getUserDocumentReference(user);
      futures.add(userDocRefFuture);

      // Wait for parallel operations to complete
      await Future.wait(futures);

      final profileImageUrl = await imageUploadFuture;
      final userDocRef = await userDocRefFuture;

      if (userDocRef == null) {
        _showErrorSnackBar('User document not found. Please try again.');
        return;
      }

      // Prepare Firebase Auth updates
      final authUpdates = <Future>[];
      authUpdates.add(user.updateDisplayName(displayName));

      if (profileImageUrl != null) {
        authUpdates.add(user.updatePhotoURL(profileImageUrl));
      }

      // 🔥 FIX: Save firstName and lastName as separate fields in Firestore
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      
      // Prepare Firestore update data
      final firestoreData = {
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoURL': profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Execute Firebase Auth and Firestore updates in parallel
      await Future.wait([
        ...authUpdates,
        userDocRef.update(firestoreData),
      ]);

      // Update provider state immediately (no await needed)
      widget.provider.updateUserProfile(
        username: username,
        email: email,
        profilePictureUrl: profileImageUrl,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // Reload provider data to ensure everything is in sync
      widget.provider.loadUserData();

      // Refresh user data across the entire application (run in background)
      GlobalUserRefreshService().refreshAllUserData();

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
      _showSuccessFloatingDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to update profile: $e');
    }
  }

  Future<bool> _showSaveConfirmationDialog() async {
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color primaryColor = themeColors['primary']!;
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.save_rounded,
                              color: primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Save Changes?',
                            style: UserDashboardFonts.titleText.copyWith(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your profile information will be updated. This action cannot be undone.',
                            textAlign: TextAlign.center,
                            style: UserDashboardFonts.bodyText.copyWith(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: widget.isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: UserDashboardFonts.bodyText.copyWith(
                                  color: widget.isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Save',
                                    style: UserDashboardFonts.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: UserDashboardFonts.smallText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4ADE80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: UserDashboardFonts.smallText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessFloatingDialog() {
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4ADE80).withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF4ADE80),
                          size: 32,
                        ),
                      ),
                      // Animated checkmark
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4ADE80).withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Color(0xFF4ADE80),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Success message
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Text(
                        'Profile Updated!',
                        style: UserDashboardFonts.titleText.copyWith(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your profile has been successfully updated and will be reflected across the app.',
                        textAlign: TextAlign.center,
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADE80),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Got it!',
                        style: UserDashboardFonts.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
}

// Notification Settings Dialog - Modern Design with White Background
class _NotificationSettingsDialog extends StatefulWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _NotificationSettingsDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  State<_NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<_NotificationSettingsDialog> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProviderV2>(
      builder: (context, provider, child) {
        final themeColors = provider.getCurrentThemeColors(widget.isDark);
        final Color primaryColor = themeColors['primary']!;
        final Color textColor = themeColors['text']!;
        final Color cardColor = themeColors['card']!;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8, // More compact
          decoration: BoxDecoration(
            color: Colors.white, // White background as requested
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Compact handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Modern header
              _buildModernHeader(primaryColor, textColor),

              // Scrollable content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildScrollableContent(
                        provider, primaryColor, textColor, cardColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: UserDashboardFonts.titleText.copyWith(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Manage your notification preferences',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(SettingsProviderV2 provider,
      Color primaryColor, Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Enable Notifications Form with Gradient
          _buildGradientForm(
            title: 'Enable Notifications',
            subtitle: 'Receive notifications from Marine Guard',
            icon: Icons.notifications_active_rounded,
            value: provider.notificationsEnabled,
            onChanged: (value) {
              provider.updateNotificationSettings(
                notificationsEnabled: value,
              );
            },
            primaryColor: primaryColor,
            textColor: textColor,
          ),

          const SizedBox(height: 16),

          // Push Notifications Form with Gradient
          _buildGradientForm(
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            icon: Icons.push_pin_rounded,
            value: provider.pushNotificationsEnabled,
            onChanged: (value) {
              provider.updateNotificationSettings(
                pushNotificationsEnabled: value,
              );
            },
            primaryColor: primaryColor,
            textColor: textColor,
          ),

          const SizedBox(height: 20),

          // Notification Types Section
          _buildNotificationTypesSection(
              provider, primaryColor, textColor, cardColor),
        ],
      ),
    );
  }

  Widget _buildGradientForm({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primaryColor,
    required Color textColor,
  }) {
    // Get gradient colors matching the user dashboard welcome page - darker colors
    final Color gradientStart = widget.isDark
        ? const Color(0xFF0D47A1) // Darker blue for dark mode
        : const Color(0xFF1976D2); // Darker blue for light mode
    final Color gradientEnd = widget.isDark
        ? const Color(0xFF01579B) // Darker deep blue for dark mode
        : const Color(0xFF0D47A1); // Darker deep blue for light mode

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: gradientStart.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative background bubbles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: -15,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: -10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: -10,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // Main content
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: UserDashboardFonts.bodyTextMedium.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: UserDashboardFonts.smallText.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: value,
                    onChanged: onChanged,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.3),
                    inactiveThumbColor: Colors.white.withOpacity(0.6),
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypesSection(SettingsProviderV2 provider,
      Color primaryColor, Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: UserDashboardFonts.bodyTextMedium.copyWith(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Ban Period Alerts
        _buildNotificationTypeCard(
          title: 'Ban Period Alerts',
          subtitle: 'Get notified about fishing ban periods',
          icon: Icons.block_rounded,
          value: provider.banPeriodNotifications,
          onChanged: (value) {
            debugPrint(
                '🔄 Ban period toggle clicked: ${provider.banPeriodNotifications} -> $value');
            provider.updateNotificationSettings(
              banPeriodNotifications: value,
            );
          },
          primaryColor: primaryColor,
          textColor: textColor,
        ),

        const SizedBox(height: 12),

        // Marine Conditions
        _buildNotificationTypeCard(
          title: 'Marine Conditions',
          subtitle: 'Weather and sea condition updates',
          icon: Icons.waves_rounded,
          value: provider.marineConditionsNotifications,
          onChanged: (value) {
            debugPrint(
                '🔄 Marine conditions toggle clicked: ${provider.marineConditionsNotifications} -> $value');
            provider.updateNotificationSettings(
              marineConditionsNotifications: value,
            );
          },
          primaryColor: primaryColor,
          textColor: textColor,
        ),

        const SizedBox(height: 12),

        // Education Content
        _buildNotificationTypeCard(
          title: 'Education Content',
          subtitle: 'Marine education and awareness updates',
          icon: Icons.school_rounded,
          value: provider.educationNotifications,
          onChanged: (value) {
            debugPrint(
                '🔄 Education toggle clicked: ${provider.educationNotifications} -> $value');
            provider.updateNotificationSettings(
              educationNotifications: value,
            );
          },
          primaryColor: primaryColor,
          textColor: textColor,
        ),

        const SizedBox(height: 12),

        // Complaint Updates
        _buildNotificationTypeCard(
          title: 'Complaint Updates',
          subtitle: 'Updates on your submitted complaints',
          icon: Icons.report_rounded,
          value: provider.complaintNotifications,
          onChanged: (value) {
            debugPrint(
                '🔄 Complaint toggle clicked: ${provider.complaintNotifications} -> $value');
            provider.updateNotificationSettings(
              complaintNotifications: value,
            );
          },
          primaryColor: primaryColor,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildNotificationTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: UserDashboardFonts.smallText.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// Theme Selection Dialog
class _ThemeSelectionDialog extends StatelessWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _ThemeSelectionDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8FAFC),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.palette_rounded,
                  color: isDark ? Colors.white : Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Theme',
                  style: UserDashboardFonts.largeTextSemiBold.copyWith(
                    color: isDark ? Colors.white : Colors.grey[800],
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Theme options - EXACT COPY from old usersettings
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4, // Increased to make cards shorter
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: ThemeConfig.getAllThemes().length,
                itemBuilder: (context, index) {
                  final theme = ThemeConfig.getAllThemes()[index];
                  final isSelected = provider.selectedTheme == theme;
                  final colors = ThemeConfig.getThemeColors(theme, isDark);

                  return _buildThemeCard(
                    context: context,
                    theme: theme,
                    colors: colors,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      provider.setTheme(theme);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Theme card widget - EXACT COPY from old usersettings
  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeType theme,
    required Map<String, Color> colors,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme == ThemeType.ocean
                  ? [
                      const Color(0xFF1976D2),
                      const Color(0xFF0D47A1)
                    ] // Original darker blue gradient for ocean theme
                  : [
                      colors['gradientStart']!,
                      colors['gradientEnd']!,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? ThemeConfig.darkBlueAccent : colors['primary']!)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? colors['primary']! : Colors.black)
                    .withOpacity(isSelected ? 0.3 : 0.1),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Theme preview circles
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors['primary']!.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors['accent']!.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 12,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors['blueAccent']!.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      ThemeConfig.getThemeIcon(theme),
                      color: theme == ThemeType.ocean
                          ? Colors.white
                          : colors['text'],
                      size: 20, // Reduced icon size
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Text(
                      ThemeConfig.getThemeName(theme),
                      style: TextStyle(
                        color: theme == ThemeType.ocean
                            ? Colors.white
                            : colors['text'],
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      ThemeConfig.getThemeDescription(theme),
                      style: TextStyle(
                        color: theme == ThemeType.ocean
                            ? Colors.white.withOpacity(0.9)
                            : colors['text']!.withOpacity(0.7),
                        fontSize: 10, // Reduced font size
                      ),
                      maxLines: 1, // Reduced to 1 line
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4), // Reduced spacing
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colors['primary'],
                            size: 14, // Reduced icon size
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: TextStyle(
                              color: colors['primary'],
                              fontSize: 10, // Reduced font size
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Language Selection Dialog
class _LanguageSelectionDialog extends StatelessWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _LanguageSelectionDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8FAFC),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: isDark ? Colors.white : Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Language',
                  style: UserDashboardFonts.largeTextSemiBold.copyWith(
                    color: isDark ? Colors.white : Colors.grey[800],
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Language options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: SupportedLanguage.values.map((language) {
                final isSelected = provider.selectedLanguage == language;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1))
                        : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                              ? Colors.white.withOpacity(0.3)
                              : Colors.blue)
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[200]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.language_rounded,
                      color: isSelected
                          ? Colors.blue
                          : (isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600]),
                    ),
                    title: Text(
                      provider.getLanguageName(language),
                      style: UserDashboardFonts.bodyText.copyWith(
                        color: isSelected
                            ? Colors.blue
                            : (isDark ? Colors.white : Colors.grey[800]),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                          )
                        : null,
                    onTap: () {
                      provider.setLanguage(language);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Two-Factor Authentication Dialog - Modern Design
class _TwoFactorAuthDialog extends StatefulWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _TwoFactorAuthDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  State<_TwoFactorAuthDialog> createState() => _TwoFactorAuthDialogState();
}

class _TwoFactorAuthDialogState extends State<_TwoFactorAuthDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color primaryColor = themeColors['primary']!;
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // More compact
      decoration: BoxDecoration(
        color: widget.isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Modern header
          _buildModernHeader(primaryColor, textColor),

          // Scrollable content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child:
                    _buildScrollableContent(primaryColor, textColor, cardColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.security_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Two-Factor Authentication',
                  style: UserDashboardFonts.titleText.copyWith(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Secure your account',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey[600],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
      Color primaryColor, Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Current Status Card
          _buildStatusCard(primaryColor, textColor, cardColor),

          const SizedBox(height: 20),

          // Security Methods
          _buildSecurityMethods(primaryColor, textColor, cardColor),

          const SizedBox(height: 20),

          // Security Tips
          _buildSecurityTips(primaryColor, textColor, cardColor),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      Color primaryColor, Color textColor, Color cardColor) {
    final isEnabled = widget.provider.is2FAEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
            ),
            child: Icon(
              isEnabled ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: isEnabled ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnabled ? '2FA Enabled' : '2FA Disabled',
                  style: UserDashboardFonts.bodyTextMedium.copyWith(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled
                      ? 'Your account is protected with SMS authentication'
                      : 'Add an extra layer of security to your account',
                  style: UserDashboardFonts.smallText.copyWith(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityMethods(
      Color primaryColor, Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Methods',
          style: UserDashboardFonts.bodyTextMedium.copyWith(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // SMS Authentication
        _buildMethodCard(
          title: 'SMS Authentication',
          subtitle: 'Receive verification codes via text message',
          icon: Icons.sms_rounded,
          isEnabled: widget.provider.is2FAEnabled,
          onTap: _handleSMSToggle,
          primaryColor: primaryColor,
          textColor: textColor,
          cardColor: cardColor,
        ),

        const SizedBox(height: 12),

        // Email Authentication (Coming Soon)
        _buildMethodCard(
          title: 'Email Authentication',
          subtitle: 'Receive verification codes via email',
          icon: Icons.email_rounded,
          isEnabled: false,
          isComingSoon: true,
          onTap: () {},
          primaryColor: primaryColor,
          textColor: textColor,
          cardColor: cardColor,
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color textColor,
    required Color cardColor,
    bool isComingSoon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isComingSoon ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: UserDashboardFonts.bodyText.copyWith(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isComingSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Soon',
                                style: UserDashboardFonts.smallText.copyWith(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: UserDashboardFonts.smallText.copyWith(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isComingSoon) ...[
                  Switch(
                    value: isEnabled,
                    onChanged: (value) => onTap(),
                    activeColor: primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTips(
      Color primaryColor, Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Tips',
                style: UserDashboardFonts.bodyTextMedium.copyWith(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Keep your phone secure and accessible'),
          _buildTipItem('Use a strong, unique password'),
          _buildTipItem('Enable notifications for security alerts'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: UserDashboardFonts.smallText.copyWith(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSMSToggle() async {
    if (_isLoading) return;

    if (widget.provider.is2FAEnabled) {
      // Disable 2FA
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await widget.provider.disable2FA();

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          _showSuccessFloatingDialog(result['message']);
        } else {
          _showErrorSnackBar(result['message']);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('An error occurred: $e');
      }
    } else {
      // Enable SMS 2FA - Show phone number input dialog
      _showPhoneNumberDialog();
    }
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SMSPhoneNumberDialog(
        isDark: widget.isDark,
        provider: widget.provider,
      ),
    );
  }

  void _showSuccessFloatingDialog(String message) {
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4ADE80).withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF4ADE80),
                      size: 32,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Text(
                        'Success!',
                        style: UserDashboardFonts.titleText.copyWith(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADE80),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Got it!',
                        style: UserDashboardFonts.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: UserDashboardFonts.smallText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Change Password Dialog
class _ChangePasswordDialog extends StatefulWidget {
  final SettingsProviderV2 provider;
  final bool isDark;

  const _ChangePasswordDialog({
    required this.provider,
    required this.isDark,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 400,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Modern Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDark
                      ? [
                          ThemeConfig.darkBlueAccent.withOpacity(0.2),
                          ThemeConfig.darkBlueAccent.withOpacity(0.1),
                        ]
                      : [
                          widget.provider.deepBlue.withOpacity(0.1),
                          widget.provider.deepBlue.withOpacity(0.05),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isDark
                            ? [
                                ThemeConfig.darkBlueAccent,
                                ThemeConfig.darkBlueAccent.withOpacity(0.8),
                              ]
                            : [
                                widget.provider.deepBlue,
                                widget.provider.deepBlue.withOpacity(0.8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isDark
                                  ? ThemeConfig.darkBlueAccent
                                  : widget.provider.deepBlue)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: UserDashboardFonts.bodyText.copyWith(
                            color: widget.isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your account password',
                          style: UserDashboardFonts.smallText.copyWith(
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: widget.isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Form Content - Scrollable for mobile devices
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current Password
                      TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        hintText: 'Enter your current password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: widget.isDark
                              ? ThemeConfig.darkBlueAccent
                              : widget.provider.deepBlue,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: widget.isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? ThemeConfig.darkBlueAccent
                                : widget.provider.deepBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // New Password
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: widget.isDark
                              ? ThemeConfig.darkBlueAccent
                              : widget.provider.deepBlue,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: widget.isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? ThemeConfig.darkBlueAccent
                                : widget.provider.deepBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        hintText: 'Re-enter your new password',
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: widget.isDark
                              ? ThemeConfig.darkBlueAccent
                              : widget.provider.deepBlue,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: widget.isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: widget.isDark
                                ? ThemeConfig.darkBlueAccent
                                : widget.provider.deepBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    ],
                  ),
                ),
              ),
            ),
            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: widget.isDark
                              ? Colors.white70
                              : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isDark
                              ? [
                                  ThemeConfig.darkBlueAccent,
                                  ThemeConfig.darkBlueAccent.withOpacity(0.8),
                                ]
                              : [
                                  widget.provider.deepBlue,
                                  widget.provider.deepBlue.withOpacity(0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isDark
                                    ? ThemeConfig.darkBlueAccent
                                    : widget.provider.deepBlue)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Change Password',
                                    style: UserDashboardFonts.bodyText.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.email == null) {
        throw Exception('User email is not available');
      }

      // Check if user is using email/password authentication
      // Users signed in with Google/OAuth don't have passwords
      final providerData = user.providerData;
      final hasEmailPassword = providerData.any(
        (info) => info.providerId == 'password',
      );

      if (!hasEmailPassword) {
        throw Exception(
          'Password change is only available for email/password accounts. '
          'If you signed in with Google, please use your Google account settings to change your password.',
        );
      }

      // Validate current password is not empty
      final currentPassword = _currentPasswordController.text.trim();
      if (currentPassword.isEmpty) {
        throw Exception('Current password cannot be empty');
      }

      // Validate new password is not empty
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.isEmpty) {
        throw Exception('New password cannot be empty');
      }

      // Check if new password is different from current password
      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      // Reauthenticate user with current password
      debugPrint('🔐 Attempting password change for: ${user.email}');
      debugPrint('🔐 Provider data: ${user.providerData.map((p) => p.providerId).toList()}');
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        debugPrint('🔐 Reauthenticating user...');
        await user.reauthenticateWithCredential(credential);
        debugPrint('✅ Reauthentication successful');
      } on FirebaseAuthException catch (e) {
        // Provide more specific error messages for reauthentication
        if (e.code == 'wrong-password') {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Current password is incorrect. Please check and try again.',
          );
        } else if (e.code == 'invalid-credential') {
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'The current password you entered is incorrect.',
          );
        } else if (e.code == 'user-mismatch') {
          throw FirebaseAuthException(
            code: 'user-mismatch',
            message: 'User mismatch. Please log out and log back in.',
          );
        } else {
          rethrow;
        }
      }

      // Update password
      debugPrint('🔐 Updating password...');
      await user.updatePassword(newPassword);
      debugPrint('✅ Password updated successfully');

      // Reload user to ensure changes are reflected
      await user.reload();
      debugPrint('✅ User reloaded');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Password changed successfully!',
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Current password is incorrect. Please check and try again.';
            break;
          case 'invalid-credential':
            errorMessage = 'The current password you entered is incorrect.';
            break;
          case 'weak-password':
            errorMessage = 'New password is too weak. Please use a stronger password (at least 6 characters).';
            break;
          case 'requires-recent-login':
            errorMessage =
                'For security reasons, please log out and log back in before changing your password.';
            break;
          case 'user-mismatch':
            errorMessage = 'User mismatch. Please log out and log back in.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please wait a few minutes and try again.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection and try again.';
            break;
          default:
            errorMessage = e.message ?? 'Failed to change password. Please try again.';
            // Log the full error for debugging
            debugPrint('❌ Password change error: ${e.code} - ${e.message}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'An error occurred: ${e.toString()}',
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

/// Phone Number Input Dialog for SMS 2FA Setup
class SMSPhoneNumberDialog extends StatefulWidget {
  final bool isDark;
  final SettingsProviderV2 provider;

  const SMSPhoneNumberDialog({
    super.key,
    required this.isDark,
    required this.provider,
  });

  @override
  State<SMSPhoneNumberDialog> createState() => _SMSPhoneNumberDialogState();
}

class _SMSPhoneNumberDialogState extends State<SMSPhoneNumberDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the phone input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = widget.provider.getCurrentThemeColors(widget.isDark);
    final Color primaryColor = themeColors['primary']!;
    final Color textColor = themeColors['text']!;
    final Color cardColor = themeColors['card']!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sms_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SMS Two-Factor Authentication',
                      style: UserDashboardFonts.bodyTextMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: widget.isDark ? Colors.white70 : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200],
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Description Text
                  Text(
                    'Enter your phone number to receive verification codes',
                    textAlign: TextAlign.center,
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: widget.isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Input
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[50],
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      textAlign: TextAlign.center,
                      style: UserDashboardFonts.bodyText.copyWith(
                        fontSize: 16,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: '09xxxxxxxxx',
                        hintStyle: UserDashboardFonts.bodyText.copyWith(
                          fontSize: 16,
                          letterSpacing: 1.5,
                          color:
                              widget.isDark ? Colors.white30 : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Info Note
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Example: 09123456789',
                          style: UserDashboardFonts.smallText.copyWith(
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[100],
                            border: Border.all(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: UserDashboardFonts.bodyText.copyWith(
                                color: widget.isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleEnableSMS2FA,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Enable 2FA',
                                    style: UserDashboardFonts.bodyText.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEnableSMS2FA() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter a phone number');
      return;
    }

    if (_phoneController.text.length < 11) {
      _showErrorSnackBar('Please enter a valid 11-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Enable SMS 2FA with the provided phone number
      final result = await widget.provider
          .enable2FA(TwoFactorMethod.sms, _phoneController.text);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Close the phone number dialog
        Navigator.pop(context);

        // Show success message
        _showSuccessSnackBar(result['message']);

        // If verification is required, show the verification dialog
        if (result['requiresVerification'] == true) {
          _showSMSVerificationDialog();
        }
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  void _showSMSVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SMSVerificationDialog(
        phoneNumber: _phoneController.text,
        provider: widget.provider,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
