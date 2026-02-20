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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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
                
                // Allow some time for providers to reset and start loading
                await Future.delayed(const Duration(milliseconds: 800));
                
                if (mounted) {
                  _showTopNotification(context, 'Dashboard synced with server');
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

                  // 6. Recent Borrowed Feed (uses existing OperationFeedSection)
                  const SliverPadding(
                    padding: EdgeInsets.only(top: 24, bottom: 24),
                    sliver: SliverToBoxAdapter(
                      child: OperationFeedSection(),
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

  void _showTopNotification(BuildContext context, String message) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().slideY(begin: -1.5, end: 0, duration: 500.ms, curve: Curves.easeOutBack).fadeOut(delay: 2500.ms, duration: 400.ms),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
