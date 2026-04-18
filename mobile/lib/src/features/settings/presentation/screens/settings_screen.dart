import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../../core/design_system/widgets/atmospheric_background.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/controllers/profile_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final settingsState = ref.watch(settingsControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 🛡️ PREMIUM TERMINAL HEADER ──
            SliverAppBar(
              expandedHeight: 240,
              collapsedHeight: 100,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.blurBackground,
                  StretchMode.zoomBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            sentinel.navy.withOpacity(0.08),
                            sentinel.navy.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Gap(40),
                          // 🎯 TACTICAL AVATAR
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: sentinel.tactile.card,
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: sentinel.navy.withOpacity(0.05),
                              child: Text(
                                settingsState.maybeWhen(
                                  data: (user) {
                                    final name = user?.fullName.trim() ?? '';
                                    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
                                  },
                                  orElse: () => 'U',
                                ),
                                style: GoogleFonts.lexend(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: sentinel.navy,
                                ),
                              ),
                            ),
                          ),
                          const Gap(16),
                          Text(
                            settingsState.maybeWhen(
                              data: (user) => user?.fullName.toUpperCase() ?? 'LIGTAS USER',
                              orElse: () => 'LIGTAS USER',
                            ),
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: sentinel.navy,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sentinel.navy.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              settingsState.maybeWhen(
                                data: (user) => (user?.role.toUpperCase() ?? 'USER'),
                                orElse: () => 'USER',
                              ),
                              style: GoogleFonts.lexend(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: sentinel.navy.withOpacity(0.6),
                                letterSpacing: 1.0,
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

            // ── APP CONTENT ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Section: Account
                  _buildSectionHeader(sentinel, 'ACCOUNT'),
                  SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile Details',
                    subtitle: 'Manage your name, email and role',
                    onTap: () => context.push('/profile/personal-info'),
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Security',
                    subtitle: 'Change password and account safety',
                    onTap: () => context.push('/profile/security'),
                  ),

                  const Gap(32),
                  // Section: System
                  _buildSectionHeader(sentinel, 'APP SETTINGS'),
                  SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Get alerts about items and updates',
                    trailing: Switch.adaptive(
                      value: profileState.pushNotificationsEnabled,
                      activeColor: sentinel.navy,
                      onChanged: (val) {
                        ref.read(profileControllerProvider.notifier).togglePushNotifications(val);
                      },
                    ),
                    onTap: () {
                      ref.read(profileControllerProvider.notifier).togglePushNotifications(!profileState.pushNotificationsEnabled);
                    },
                  ),
                  SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Read guide and get help',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User guide is coming soon.', 
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                          backgroundColor: sentinel.navy,
                        )
                      );
                    },
                  ),

                  const Gap(48),
                  // LOGOUT ZONE
                  _buildSectionHeader(sentinel, 'ACCOUNT ACTIONS'),
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    iconColor: sentinel.error,
                    textColor: sentinel.error,
                    onTap: () async {
                      // 🛡️ SMART LOGOUT: Only confirm if this is a "Remembered" session
                      final prefs = await SharedPreferences.getInstance();
                      final isRemembered = prefs.getBool('is_remembered') ?? false;

                      bool confirmed = true;
                      if (isRemembered && context.mounted) {
                        confirmed = await _showConfirmLogout(context, sentinel) ?? false;
                      }

                      if (confirmed && context.mounted) {
                        await ref.read(settingsControllerProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    trailing: const SizedBox.shrink(),
                  ),
                  
                  const Gap(48),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'VERSION 2.1.0',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: sentinel.navy.withOpacity(0.3),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'LIGTAS System',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: sentinel.navy.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSectionHeader(SentinelColors sentinel, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 16, 16),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: sentinel.navy.withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Future<bool?> _showConfirmLogout(BuildContext context, SentinelColors sentinel) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Log Out?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w900, color: sentinel.navy),
        ),
        content: Text(
          'Are you sure you want to log out? You will need to sign in again to use the app.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: sentinel.onSurfaceVariant, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w800,
                color: sentinel.onSurfaceVariant.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: sentinel.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'LOG OUT',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
