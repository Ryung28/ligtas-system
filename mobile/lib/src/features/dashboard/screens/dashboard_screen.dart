import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../../loans/providers/loan_providers.dart';

import '../widgets/dashboard_background.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/bento_tiles.dart';

import '../controllers/dashboard_controller.dart';

import '../widgets/mission_control_widgets.dart';
import '../widgets/recent_activity_section.dart';
import '../../loans/repositories/loan_repository.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/design_system/widgets/app_toast.dart';
import '../../../core/design_system/widgets/ligtas_error_state.dart';
import '../../notifications/widgets/sync_error_banner.dart';
import 'package:mobile/src/features/presence/presentation/providers/presence_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  // Premium Gold Standard Curve
  static const _premiumCurve = Cubic(0.05, 0.7, 0.1, 1.0);

  @override
  void initState() {
    super.initState();
    // 🛡️ GOLD STANDARD: Mark entry as complete after the first build cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dashboardEntryProvider.notifier).state = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(dashboardUserNameProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final controller = ref.watch(dashboardControllerProvider);
    final loansAsync = ref.watch(sortedDashboardActivityProvider);
    
    // 🛡️ GOLD STANDARD: Animation Gating
    final hasEntered = ref.watch(dashboardEntryProvider);
    final duration = hasEntered ? 0.ms : 600.ms;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Layer 1: Ambient Background ──
          const DashboardBackground(),

          // ── Layer 2: Main Content (Sliver Based) ──
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                ref.invalidate(dashboardStatsProvider);
                ref.invalidate(myBorrowedItemsProvider);
                
                if (mounted) {
                  AppToast.showSuccess(context, 'Dashboard synced with server');
                }
              },
              color: AppTheme.primaryBlue,
              child: Listener(
                onPointerDown: (_) {
                  // 🏁 KINETIC PRE-LOAD: Signal display governor on touch
                  HapticFeedback.selectionClick();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                  // 0. Notification Sync Status
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: const SyncErrorBanner()
                          .animate()
                          .fadeIn(duration: duration, curve: _premiumCurve)
                          .slideY(begin: 0.2, end: 0, duration: duration, curve: _premiumCurve),
                    ),
                  ),

                  // 1. Header Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: DashboardHeader(userName: userName)
                          .animate()
                          .fadeIn(duration: duration, curve: _premiumCurve)
                          .slideY(begin: 0.2, end: 0, duration: duration, curve: _premiumCurve),
                    ),
                  ),

                  // 2. Scan Hero
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: BentoScanTile(
                          onTap: () => controller.openScanner(context),
                          animationDelay: hasEntered ? 0 : 200, // Staggered load balance
                        ),
                      ),
                    ),
                  ),

                  // 3. Equipment Ribbon (Categories)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    sliver: SliverToBoxAdapter(
                      child: const EquipmentRibbon()
                          .animate(delay: hasEntered ? 0.ms : 100.ms)
                          .fadeIn(duration: duration, curve: _premiumCurve)
                          .slideX(begin: 0.1, end: 0, duration: duration, curve: _premiumCurve),
                    ),
                  ),

                  // 4. Mission Intelligence (Bento Stat Grid)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: const SystemTelemetryGrid()
                          .animate(delay: hasEntered ? 0.ms : 200.ms)
                          .fadeIn(duration: duration, curve: _premiumCurve)
                          .slideY(begin: 0.2, end: 0, duration: duration, curve: _premiumCurve),
                    ),
                  ),

                   // 6. Recent Activity (Virtualized Sliver)
                  ref.watch(freshDashboardLoansProvider).when(
                    data: (_) => SliverRecentActivitySection(loans: loansAsync), // Use the pre-sorted list
                    loading: () => const SliverRecentActivitySection(isLoading: true),
                    error: (_, __) => SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      sliver: SliverToBoxAdapter(
                        child: LigtasErrorState(
                          title: 'Activity Error',
                          message: 'Unable to stream recent activity logs.',
                          onRetry: () => ref.invalidate(sortedDashboardActivityProvider),
                        ),
                      ),
                    ),
                  ),

                  const SliverGap(40),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }

}
