import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';

class UserSettingsWidgets {
  static Widget buildProfileHeader({
    required String username,
    required String email,
    required String? profilePicture,
    required Function() onImageTap,
    required Function() onCameraTap,
    required Color deepBlue,
    required Color whiteWater,
    required Color lightBlue,
  }) {
    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              deepBlue,
              lightBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: onImageTap,
                    child: Hero(
                      tag: 'profile-${profilePicture ?? "default"}',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: whiteWater,
                          image: profilePicture != null && profilePicture.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(profilePicture),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profilePicture == null || profilePicture.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: deepBlue.withOpacity(0.5),
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
                          color: deepBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: whiteWater,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: whiteWater,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: TextStyle(
                  color: whiteWater,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: whiteWater.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildSettingsSection({
    required String title,
    required List<Widget> items,
    required Color deepBlue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              color: deepBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  static Widget buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    required Color deepBlue,
    required Color color,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : deepBlue,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: (isDark ? Colors.white : deepBlue).withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: (isDark ? Colors.white : deepBlue).withOpacity(0.3),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
