import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system/app_theme.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import '../controllers/profile_controller.dart';
import '../widgets/digital_id_card.dart';
import '../widgets/profile_menu_items.dart';
import '../widgets/logout_button.dart';
import '../../notifications/widgets/sync_error_banner.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      backgroundColor: sentinel.containerLowest,
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: false,
              pinned: true,
              backgroundColor: sentinel.containerLowest,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              title: Text(
                'SETTINGS',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: sentinel.navy,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SyncErrorBanner(),
                  const Gap(16),
                  
                  // ── Digital ID Card ──
                  DigitalIdCard(user: state.user ?? user),

                  const Gap(32),

                  // ── Account & Access ──
                  ProfileSection(
                    title: 'ACCOUNT & ACCESS',
                    children: [
                      ProfileActionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Details',
                        subtitle: 'Name, email, and profile page',
                        onTap: () => controller.navigateTo(context, 'personal-info'),
                        iconColor: sentinel.navy,
                      ),
                      ProfileActionTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Security',
                        subtitle: 'Password and authentication',
                        onTap: () => controller.navigateTo(context, 'security'),
                        iconColor: sentinel.navy,
                      ),
                      if (user?.role.toLowerCase() == 'editor' || user?.role.toLowerCase() == 'admin')
                        ProfileActionTile(
                          icon: Icons.warehouse_rounded,
                          title: 'Assigned Location',
                          subtitle: user?.assignedWarehouse?.toUpperCase() ?? 
                                   (user?.role.toLowerCase() == 'admin' ? 'GLOBAL ACCESS' : 'UNASSIGNED'),
                          onTap: () {},
                          iconColor: Colors.orange[800],
                        ),
                    ],
                  ),

                  const Gap(24),

                  // ── App Settings ──
                  ProfileSection(
                    title: 'SETTINGS',
                    children: [
                      ProfileSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        value: state.pushNotificationsEnabled,
                        onChanged: (val) => controller.togglePushNotifications(val),
                        iconColor: sentinel.navy,
                      ),
                      ProfileActionTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'English (Default)',
                        onTap: () => controller.navigateTo(context, 'language'),
                        iconColor: sentinel.navy,
                      ),
                    ],
                  ),

                  const Gap(24),

                  // ── Administration ──
                  if (user?.role.toLowerCase() == 'editor' || user?.role.toLowerCase() == 'admin')
                    ProfileSection(
                      title: 'ADMINISTRATION',
                      children: [
                        ProfileActionTile(
                          icon: Icons.terminal_rounded,
                          title: 'Manager Dashboard',
                          subtitle: 'Inventory audit and triage tools',
                          onTap: () => context.push('/manager'),
                          iconColor: AppTheme.primaryBlue,
                        ),
                      ],
                    ),

                  const Gap(24),

                  // ── Support ──
                  ProfileSection(
                    title: 'SUPPORT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: () => controller.navigateTo(context, 'help'),
                        iconColor: sentinel.navy,
                      ),
                      ProfileActionTile(
                        icon: Icons.policy_outlined,
                        title: 'Privacy Policy',
                        onTap: () => controller.navigateTo(context, 'privacy'),
                        iconColor: sentinel.navy,
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
                    child: Column(
                      children: [
                        Text(
                          'SYSTEM OS V1.0.0',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: sentinel.navy.withOpacity(0.3),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'CONNECTED & SECURE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: sentinel.navy.withOpacity(0.2),
                            letterSpacing: 0.5,
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
      ),
    );
  }
}


