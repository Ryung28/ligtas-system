import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_welcome_card.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_feature_cards.dart';
import '../../scanner/models/qr_payload.dart';
import '../../scanner/widgets/scan_result_sheet.dart';

/// Dashboard home screen (reference: UserDashboard)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScannerView(
          onQrCodeDetected: (qrCode) {
            // First validation: Is this a LIGTAS QR?
            final payload = LigtasQrPayload.tryParse(qrCode);
            
            if (payload == null) {
              // Not our QR code
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid QR Code. Please scan a LIGTAS equipment label.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Close the scanner camera
            Navigator.of(context).pop();

            // Show our premium confirmation sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ScanResultSheet(payload: payload),
            );
          },
          overlayText: 'Scan LIGTAS Equipment Label',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(dashboardUserNameProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            _DashboardBackground(),
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dashboardStatsProvider);
                },
                color: AppTheme.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardWelcomeCard(userName: userName),
                      const Gap(12),
                      DashboardQuickActions(
                        onOpenScanner: () => _openScanner(context),
                      ),
                      const Gap(12),
                      statsAsync.when(
                        data: (stats) => DashboardStatsCard(stats: stats),
                        loading: () => const _StatsCardSkeleton(),
                        error: (_, __) => const _StatsCardSkeleton(),
                      ),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.allLg,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neutralGray900.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DashboardFeatureCards(
                          onOpenScanner: () => _openScanner(context),
                        ),
                      ),
                      SizedBox(
                        height: 80 + MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            AppTheme.neutralGray50,
            const Color(0xFFE3F2FD),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -180,
            child: Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlueLight.withValues(alpha: 0.15),
                    AppTheme.primaryBlueLight.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: -150,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                    AppTheme.primaryBlue.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCardSkeleton extends StatelessWidget {
  const _StatsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.allLg,
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutralGray900.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
