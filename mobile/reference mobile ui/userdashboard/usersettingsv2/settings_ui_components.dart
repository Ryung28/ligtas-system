import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';

/// Reusable UI components for user settings
/// Follows clean architecture and separation of concerns
class SettingsUIComponents {
  /// Build a clean settings section header for gradient backgrounds
  static Widget buildGradientSectionHeader({
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
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
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: UserDashboardFonts.largeTextSemiBold.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clean switch tile for gradient backgrounds
  static Widget buildGradientSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: enabled ? accentColor : Colors.white.withOpacity(0.4),
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
                  style: UserDashboardFonts.bodyText.copyWith(
                    color:
                        enabled ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: UserDashboardFonts.smallText.copyWith(
                    color: enabled
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled ? value : false,
            onChanged: enabled ? onChanged : null,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white.withOpacity(0.3),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  /// Build a clean settings section header
  static Widget buildSectionHeader({
    required String title,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: UserDashboardFonts.largeTextSemiBold.copyWith(
                color: isDark ? Colors.white : Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clean settings tile
  static Widget buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: UserDashboardFonts.bodyText.copyWith(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: UserDashboardFonts.smallText.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: trailing ??
            (showArrow
                ? Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : Colors.grey[400],
                    size: 16,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  /// Build a clean switch tile
  static Widget buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: enabled
            ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white)
            : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled
                  ? accentColor.withOpacity(0.1)
                  : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? accentColor
                  : (isDark ? Colors.white.withOpacity(0.4) : Colors.grey[400]),
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
                  style: UserDashboardFonts.bodyText.copyWith(
                    color: enabled
                        ? (isDark ? Colors.white : Colors.grey[800])
                        : (isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.grey[500]),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: UserDashboardFonts.smallText.copyWith(
                    color: enabled
                        ? (isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600])
                        : (isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.grey[400]),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled ? value : false,
            onChanged: enabled ? onChanged : null,
            activeColor: accentColor,
            inactiveThumbColor:
                isDark ? Colors.white.withOpacity(0.3) : Colors.grey[300],
            inactiveTrackColor:
                isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  /// Build a clean divider
  static Widget buildDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
    );
  }

  /// Build a clean profile header
  static Widget buildProfileHeader({
    required String username,
    required String email,
    required String? profilePictureUrl,
    required VoidCallback onImageTap,
    required VoidCallback onCameraTap,
    required bool isDark,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Hero(
                  tag: 'profile-${profilePictureUrl ?? "default"}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      image: profilePictureUrl != null &&
                              profilePictureUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(profilePictureUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        profilePictureUrl == null || profilePictureUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.grey[600],
                              )
                            : null,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onCameraTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: UserDashboardFonts.largeTextSemiBold.copyWith(
              color: isDark ? Colors.white : Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: UserDashboardFonts.bodyText.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clean loading state
  static Widget buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: UserDashboardFonts.bodyText.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clean error state
  static Widget buildErrorState({
    required String message,
    required VoidCallback onRetry,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: UserDashboardFonts.largeTextSemiBold.copyWith(
              color: isDark ? Colors.white : Colors.grey[800],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: UserDashboardFonts.bodyText.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? Colors.white.withOpacity(0.1) : Colors.blue,
              foregroundColor: isDark ? Colors.white : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retry',
              style: UserDashboardFonts.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clean section divider
  static Widget buildSectionDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
    );
  }

  /// Build a clean empty state
  static Widget buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: UserDashboardFonts.largeTextSemiBold.copyWith(
              color: isDark ? Colors.white : Colors.grey[800],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: UserDashboardFonts.bodyText.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
