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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  Widget _buildRecentActivity() {
    final loansAsync = ref.watch(freshDashboardLoansProvider);
    
    return loansAsync.when(
      data: (loans) => RecentActivitySection(loans: loans),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => LigtasErrorState(
        title: 'Activity Error',
        message: 'Unable to stream recent activity logs.',
        onRetry: () => ref.invalidate(freshDashboardLoansProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(dashboardUserNameProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final controller = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Match My Borrowed Items background
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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. Header Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: DashboardHeader(userName: userName),
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
                          animationDelay: 100,
                        ),
                      ),
                    ),
                  ),

                  // 3. Overdue Banner
                  statsAsync.maybeWhen(
                    data: (stats) => stats.overdueLoans > 0 
                      ? SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          sliver: SliverToBoxAdapter(
                            child: OverdueAlertBanner(overdueCount: stats.overdueLoans),
                          ),
                        )
                      : const SliverToBoxAdapter(child: SizedBox.shrink()),
                    orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  // 4. Equipment Ribbon
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    sliver: SliverToBoxAdapter(
                      child: EquipmentRibbon(),
                    ),
                  ),

                  // 5. Telemetry Intelligence
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: SystemTelemetryGrid(),
                    ),
                  ),

                  // 6. Recent Borrowed Feed (replaced with RecentActivitySection for correct timestamps)
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildRecentActivity(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
