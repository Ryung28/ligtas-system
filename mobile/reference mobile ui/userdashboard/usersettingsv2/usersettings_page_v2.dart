import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/settings_dialogs.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'dart:math' as math;

/// Clean, refactored user settings page following clean architecture principles
/// Maintains EXACT functionality and design from old usersettings
class UserSettingsPageV2 extends StatefulWidget {
  const UserSettingsPageV2({super.key});

  @override
  State<UserSettingsPageV2> createState() => _UserSettingsPageV2State();
}

class _UserSettingsPageV2State extends State<UserSettingsPageV2> {
  @override
  void initState() {
    super.initState();
    // Initialize the global provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<SettingsProviderV2>(context, listen: false);
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simple and reliable: No back button handling here - MainAppShell handles it
    // This prevents conflicts and black screen issues
    return Consumer<SettingsProviderV2>(
        builder: (context, provider, child) {
          final themeColors = provider.getCurrentThemeColors(isDark);
          
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark, // Dark (black) icons
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              body: Column(
                children: [
                  Expanded(
                  child: provider.isLoading
                      ? _buildLoadingState(isDark, provider)
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            _buildModernAppBar(
                                context, provider, isDark, themeColors),
                            SliverToBoxAdapter(
                              child: _buildSettingsContent(
                                  context, provider, isDark, themeColors),
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }

  Widget _buildLoadingState(bool isDark, SettingsProviderV2 provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, SettingsProviderV2 provider,
      bool isDark, Map<String, Color> themeColors) {
    // Deep blue gradient colors
    final deepBlueStart = isDark 
        ? const Color(0xFF0D47A1) 
        : const Color(0xFF1565C0);
    final deepBlueEnd = isDark 
        ? const Color(0xFF1976D2) 
        : const Color(0xFF0D47A1);
    final deepBlueMiddle = isDark 
        ? const Color(0xFF1565C0) 
        : const Color(0xFF1976D2);

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: deepBlueStart,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                deepBlueStart,
                deepBlueMiddle,
                deepBlueEnd,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Static decorative bubbles
              _buildStaticBubbles(isDark),
              
              // Static wave at the bottom (left to right)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _StaticWavePainter(isDark: isDark),
                ),
              ),
              
              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Settings',
                        style: UserDashboardFonts.largeHeadingText.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your account and preferences',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(context, provider, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static bubbles for decorative effect
  Widget _buildStaticBubbles(bool isDark) {
    return Stack(
      children: [
        // Large bubble top right
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                ],
              ),
            ),
          ),
        ),
        // Medium bubble bottom left
        Positioned(
          bottom: 20,
          left: -20,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
        // Small bubbles scattered
        Positioned(
          top: 20,
          left: -15,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 30,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        // Extra small bubbles
        Positioned(
          top: 100,
          right: 100,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 100,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
      BuildContext context, SettingsProviderV2 provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showFullScreenProfile(provider.profilePictureUrl),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? ThemeConfig.darkBlueAccent.withOpacity(0.3)
                      : provider.deepBlue.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: provider.profilePictureUrl != null &&
                        provider.profilePictureUrl!.isNotEmpty
                    ? Image.network(
                        provider.profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(isDark),
                      )
                    : _buildDefaultAvatar(isDark),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.username,
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  provider.email,
                  style: UserDashboardFonts.smallText.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showImageSourceSelection,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? ThemeConfig.darkBlueAccent.withOpacity(0.1)
                    : provider.deepBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? ThemeConfig.darkBlueAccent.withOpacity(0.3)
                      : provider.deepBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkBlueAccent : Colors.blue[400],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 35,
      ),
    );
  }

  Widget _buildSettingsContent(
      BuildContext context,
      SettingsProviderV2 provider,
      bool isDark,
      Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
      child: Column(
        children: [
          // Account Information Section - Display firstName, lastName, etc.
          _buildAccountInformationSection(context, provider, isDark, themeColors),
          const SizedBox(height: 16),
          
          // Account & Security Section
          _buildEnhancedSettingsSection(
            context: context,
            title: 'Account & Security',
            icon: Icons.security_rounded,
            color: Colors.blue,
            items: [
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => SettingsDialogs.showEditProfileDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
              _buildDivider(isDark),
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => SettingsDialogs.showChangePasswordDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
              _buildDivider(isDark),
              _buildTwoFactorAuthTile(context, isDark, provider),
              _buildDivider(isDark),
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () => SettingsDialogs.showNotificationSettingsDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
            ],
            isDark: isDark,
            provider: provider,
          ),
          const SizedBox(height: 16),

          // App Preferences Section
          _buildEnhancedSettingsSection(
            context: context,
            title: 'App Preferences',
            icon: Icons.tune_rounded,
            color: Colors.purple,
            items: [
              _buildThemeSelectionTile(context, isDark, provider),
            ],
            isDark: isDark,
            provider: provider,
          ),
          const SizedBox(height: 16),

          // Support & Info Section
          _buildEnhancedSettingsSection(
            context: context,
            title: 'Support & Information',
            icon: Icons.help_outline_rounded,
            color: Colors.green,
            items: [
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'About Marine Guard',
                subtitle: 'Version 1.0.0 • Learn more',
                onTap: () => SettingsDialogs.showAboutAppDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
              _buildDivider(isDark),
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                onTap: () => SettingsDialogs.showTermsAndConditionsDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
              _buildDivider(isDark),
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we protect your data',
                onTap: () => SettingsDialogs.showPrivacyPolicyDialog(
                  context: context,
                  provider: provider,
                  isDark: isDark,
                ),
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
              _buildDivider(isDark),
              _buildEnhancedSettingsTile(
                context: context,
                icon: Icons.contact_support_rounded,
                title: 'Contact Support',
                subtitle: 'Get help and support',
                // onTap: () => SettingsDialogs.showContactSupportDialog(
                //   context: context,
                //   provider: provider,
                //   isDark: isDark,
                // ),
                onTap: () {
                  // Temporary placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Contact Support: support@marineguard.com')),
                  );
                },
                isDark: isDark,
                provider: provider,
                showArrow: true,
              ),
            ],
            isDark: isDark,
            provider: provider,
          ),
          const SizedBox(height: 24),

          // Logout Button
          _buildEnhancedLogoutButton(context, isDark, provider),
        ],
      ),
    );
  }

  // Account Information Section - Display firstName, lastName, email, phone
  Widget _buildAccountInformationSection(
    BuildContext context,
    SettingsProviderV2 provider,
    bool isDark,
    Map<String, Color> themeColors,
  ) {
    final primaryColor = themeColors['primary'] ?? (isDark ? ThemeConfig.darkBlueAccent : Colors.blue);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Icons.person_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Information',
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // First Name
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'First Name',
            value: provider.firstName.isNotEmpty ? provider.firstName : 'Not set',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          _buildDivider(isDark),
          // Last Name
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Last Name',
            value: provider.lastName.isNotEmpty ? provider.lastName : 'Not set',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          _buildDivider(isDark),
          // Email
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: provider.email.isNotEmpty ? provider.email : 'Not set',
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          if (provider.phoneNumberFromProfile != null && provider.phoneNumberFromProfile!.isNotEmpty) ...[
            _buildDivider(isDark),
            // Phone Number
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: provider.phoneNumberFromProfile!,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: UserDashboardFonts.smallText.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Settings Section - EXACT COPY from old usersettings
  Widget _buildEnhancedSettingsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
    required bool isDark,
    required SettingsProviderV2 provider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  // Enhanced Settings Tile - EXACT COPY from old usersettings
  Widget _buildEnhancedSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required SettingsProviderV2 provider,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue,
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
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: UserDashboardFonts.smallText.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Colors.white54 : const Color(0xFF757575),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Divider - EXACT COPY from old usersettings
  Widget _buildDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
    );
  }

  // Enhanced Logout Button - EXACT COPY from old usersettings
  Widget _buildEnhancedLogoutButton(
      BuildContext context, bool isDark, SettingsProviderV2 provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _signOut,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Sign Out',
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Two-Factor Authentication Tile - EXACT COPY from old usersettings
  Widget _buildTwoFactorAuthTile(
      BuildContext context, bool isDark, SettingsProviderV2 provider) {
    return _buildEnhancedSettingsTile(
      context: context,
      icon: Icons.security_rounded,
      title: 'Two-Factor Authentication',
      subtitle: provider.is2FAEnabled
          ? 'SMS authentication enabled'
          : 'Secure your account with 2FA',
      onTap: () => SettingsDialogs.show2FASettingsDialog(
        context: context,
        provider: provider,
        isDark: isDark,
      ),
      isDark: isDark,
      provider: provider,
      showArrow: true,
    );
  }

  // Theme Selection Tile - EXACT COPY from old usersettings
  Widget _buildThemeSelectionTile(
      BuildContext context, bool isDark, SettingsProviderV2 provider) {
    return Consumer<SettingsProviderV2>(
      builder: (context, settingsProvider, child) {
        return _buildEnhancedSettingsTile(
          context: context,
          icon: Icons.palette_rounded,
          title: 'Theme',
          subtitle: settingsProvider.getCurrentThemeName(),
          onTap: () => SettingsDialogs.showThemeSelectionDialog(
            context: context,
            provider: provider,
            isDark: isDark,
          ),
          isDark: isDark,
          provider: provider,
          showArrow: true,
        );
      },
    );
  }

  // Helper methods for image handling
  void _showImageSourceSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ThemeConfig.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Image Source',
                    style: UserDashboardFonts.bodyText.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.camera_alt_rounded,
                          title: 'Camera',
                          subtitle: 'Take a photo',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImageFromCamera(
                                context,
                                Provider.of<SettingsProviderV2>(context,
                                    listen: false),
                                isDark);
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_library_rounded,
                          title: 'Gallery',
                          subtitle: 'Choose from gallery',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImageFromGallery(
                                context,
                                Provider.of<SettingsProviderV2>(context,
                                    listen: false),
                                isDark);
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: UserDashboardFonts.bodyText.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: UserDashboardFonts.smallText.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImageFromCamera(
      BuildContext context, SettingsProviderV2 provider, bool isDark) {
    // Implementation for camera image picker
    // This would use ImagePicker to take a photo
  }

  void _pickImageFromGallery(
      BuildContext context, SettingsProviderV2 provider, bool isDark) {
    // Implementation for gallery image picker
    // This would use ImagePicker to select from gallery
  }

  void _showFullScreenProfile(String? profilePictureUrl) {
    // Implementation for full screen profile view
  }

  void _signOut() {
    // Use the proper sign out implementation from SettingsDialogs
    final provider = Provider.of<SettingsProviderV2>(context, listen: false);
    SettingsDialogs.showLogoutConfirmationDialog(
      context: context,
      provider: provider,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }
}

/// Static wave painter - draws a wave from left to right
/// Optimized and efficient, no animations
class _StaticWavePainter extends CustomPainter {
  final bool isDark;

  _StaticWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.white.withOpacity(0.2);

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.15);

    // Main wave layer - flows left to right
    final path1 = Path();
    final waveHeight1 = 12.0;
    final waveLength1 = size.width / 1.8;
    final startY1 = size.height - 15;

    path1.moveTo(0, startY1);

    // Draw wave from left to right
    for (double x = 0; x <= size.width; x += 2) {
      final y = startY1 + waveHeight1 * math.sin((x / waveLength1) * 2 * math.pi);
      path1.lineTo(x, y);
    }

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, paint);

    // Secondary wave layer for depth - slightly offset
    final path2 = Path();
    final waveHeight2 = 8.0;
    final waveLength2 = size.width / 2.2;
    final startY2 = size.height - 10;

    path2.moveTo(0, startY2);

    for (double x = 0; x <= size.width; x += 2) {
      final y = startY2 + waveHeight2 * math.sin((x / waveLength2 + 0.5) * 2 * math.pi);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);

    // Subtle third layer for texture
    final path3 = Path();
    final waveHeight3 = 5.0;
    final waveLength3 = size.width / 3;
    final startY3 = size.height - 5;

    path3.moveTo(0, startY3);

    for (double x = 0; x <= size.width; x += 2) {
      final y = startY3 + waveHeight3 * math.sin((x / waveLength3 + 1.0) * 2 * math.pi);
      path3.lineTo(x, y);
    }

    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    canvas.drawPath(path3, paint2);
  }

  @override
  bool shouldRepaint(_StaticWavePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
