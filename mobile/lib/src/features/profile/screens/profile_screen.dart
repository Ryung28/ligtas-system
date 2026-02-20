import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/widgets/dashboard_background.dart';
import '../controllers/profile_controller.dart';
import '../widgets/digital_id_card.dart';
import '../widgets/profile_menu_items.dart'; // Contains ProfileSection, ProfileActionTile, ProfileSwitchTile
import '../widgets/logout_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // ── Layer 1: Premium Ambient Background ──
          const DashboardBackground(),

          // ── Layer 2: Content ──
          SafeArea(
            top: true,
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Deep Glass App Bar ──
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0, // Disable the automatic surface tint
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: AppTheme.neutralGray900.withValues(alpha: 0.9),
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  // Balanced padding for premium spacing and dock clearance
                  padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Gap(10),
                      
                      // ── Digital ID Card ──
                      DigitalIdCard(user: user),

                      const Gap(32),

                      // ── Account Settings ──
                      ProfileSection(
                        title: 'Account',
                        children: [
                          ProfileActionTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Personal Information',
                            subtitle: 'Update your profile details',
                            onTap: () => controller.navigateTo(context, 'personal-info'),
                            iconColor: Theme.of(context).colorScheme.primary,
                          ),
                          ProfileActionTile(
                            icon: Icons.shield_outlined,
                            title: 'Security & Password',
                            onTap: () => controller.navigateTo(context, 'security'),
                            iconColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),

                      const Gap(24),

                      // ── Preferences ──
                      ProfileSection(
                        title: 'Preferences',
                        children: [
                          ProfileSwitchTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Push Notifications',
                            value: state.pushNotificationsEnabled,
                            onChanged: (val) => controller.togglePushNotifications(val),
                            iconColor: Theme.of(context).colorScheme.primary,
                          ),
                          ProfileActionTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: 'English (US)',
                            onTap: () => controller.navigateTo(context, 'language'),
                            iconColor: Colors.teal,
                          ),
                        ],
                      ),

                      const Gap(24),

                      // ── Support ──
                      ProfileSection(
                        title: 'Support',
                        children: [
                          ProfileActionTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help Center',
                            onTap: () => controller.navigateTo(context, 'help'),
                            iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          ProfileActionTile(
                            icon: Icons.policy_outlined,
                            title: 'Privacy Policy',
                            onTap: () => controller.navigateTo(context, 'privacy'),
                            iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),

                      const Gap(40),

                      // ── Logout ──
                      LogoutButton(
                        onPressed: () => controller.confirmLogout(context),
                      ),

                      const Gap(32),

                      // ── Version Info ──
                      Center(
                        child: Text(
                          'Version 1.0.0 (Build 100)',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),


          // Loading Overlay
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
        ],
      ),
    );
  }
}

