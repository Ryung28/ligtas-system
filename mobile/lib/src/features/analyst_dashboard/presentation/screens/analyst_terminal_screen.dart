import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/features/auth/providers/auth_provider.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../inventory/providers/inventory_providers.dart';
import '../../../../features_v2/inventory/presentation/providers/inventory_provider.dart';
import '../../../../core/design_system/widgets/atmospheric_background.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/widgets/dashboard_header.dart';
import '../../../dashboard/widgets/dashboard_background.dart';
import '../controllers/analyst_dashboard_controller.dart';
import '../../domain/entities/analyst_metrics.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/resource_anomalies_section.dart';
import '../widgets/recent_activity_logs.dart';
import '../../domain/entities/resource_anomaly.dart';
import '../../../../features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import 'package:mobile/src/features_v2/anomaly_action_v2/anomaly_action_sheet_v2.dart';
import '../../../navigation/providers/navigation_provider.dart';

/// ⚙️ SENSITIVITY STATE: Local filter for anomaly alerts
final alertSensitivityProvider = StateProvider<int>((ref) => 10); // Default to 10 units

/// 📡 ANALYST TERMINAL: Professional navigational hub with personal anchoring.
class AnalystTerminalScreen extends ConsumerStatefulWidget {
  const AnalystTerminalScreen({super.key});

  @override
  ConsumerState<AnalystTerminalScreen> createState() => _AnalystTerminalScreenState();
}

class _AnalystTerminalScreenState extends ConsumerState<AnalystTerminalScreen> {
  static const _premiumCurve = Cubic(0.05, 0.7, 0.1, 1.0);

  @override
  void initState() {
    super.initState();
    // 🛡️ PERFORMANCE LOCK: Mark entry as complete after the first build cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(analystTerminalEntryProvider.notifier).state = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final user = ref.watch(currentUserProvider);
    final missingProfileFields = <String>[
      if ((user?.fullName.trim().isEmpty ?? true)) 'name',
      if ((user?.phoneNumber?.trim().isEmpty ?? true)) 'phone',
      if ((user?.organization?.trim().isEmpty ?? true)) 'office',
    ];
    final hasEntered = ref.watch(analystTerminalEntryProvider);
    final duration = hasEntered ? 0.ms : 600.ms;

    return Scaffold(
      backgroundColor: sentinel.containerLow,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 0. FROZEN BACKGROUND LAYER ──
          const RepaintBoundary(
            child: DashboardBackground(),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.read(analystDashboardControllerProvider.notifier).refresh(),
              color: AppTheme.primaryBlue,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                   // ── 1. ISOLATED HEADER (Static/Semi-Static) ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    sliver: SliverToBoxAdapter(
                      child: const _IsolatedHeader()
                          .animate()
                          .fadeIn(duration: duration, curve: _premiumCurve)
                          .slideY(begin: 0.2, end: 0, duration: duration, curve: _premiumCurve),
                    ),
                  ),

                  if (missingProfileFields.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      sliver: SliverToBoxAdapter(
                        child: _AnalystProfileIncompleteBanner(missingFields: missingProfileFields),
                      ),
                    ),

                  // ── 2. METRIC MONITORING (Independent Refresh) ──
                  const _MetricSliver(),

                  // ── 3. ANOMALY ALERTS (Independent Refresh) ──
                  const _AnomaliesSliver(),

                  // ── 4. ACTIVITY SUBSYSTEM (Independent Refresh) ──
                  const SliverGap(32),
                  const _ActivitySliver(),
                  
                  const SliverGap(100), // Bottom padding for navigation clearance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalystProfileIncompleteBanner extends StatelessWidget {
  final List<String> missingFields;
  const _AnalystProfileIncompleteBanner({required this.missingFields});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFB45309)),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile incomplete',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: sentinel.navy.withOpacity(0.85),
                  ),
                ),
                const Gap(2),
                Text(
                  'Missing: ${missingFields.join(', ')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: sentinel.navy.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/profile/personal-info'),
            child: Text(
              'Complete now',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 10, color: sentinel.navy),
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 OBSERVER: Only rebuilds when Metrics Stream emits
class _MetricSliver extends ConsumerWidget {
  const _MetricSliver();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(watchMetricsStreamProvider).valueOrNull ?? AnalystMetrics();
    final hasEntered = ref.watch(analystTerminalEntryProvider);
    final duration = hasEntered ? 0.ms : 600.ms;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: KpiGrid(metrics: metrics)
            .animate()
            .fadeIn(delay: hasEntered ? 0.ms : 100.ms, duration: duration)
            .slideY(begin: 0.1, end: 0, duration: duration),
      ),
    );
  }
}

/// 📡 OBSERVER: Only rebuilds when Anomaly Stream emits
class _AnomaliesSliver extends ConsumerWidget {
  const _AnomaliesSliver();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anomalies = ref.watch(watchResourceAnomaliesProvider).valueOrNull ?? [];
    return SliverToBoxAdapter(
      child: ResourceAnomaliesSection(
        anomalies: anomalies,
        onAnomalyTap: (anomaly) {
          _showTriageSheet(context, ref, anomaly);
        },
      ),
    );
  }
}

/// 📜 OBSERVER: Only rebuilds when Activity Stream emits
class _ActivitySliver extends ConsumerWidget {
  const _ActivitySliver();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(watchActivityStreamProvider).valueOrNull ?? [];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: RecentActivityLogs(events: activities),
      ),
    );
  }
}

class _IsolatedHeader extends ConsumerWidget {
  const _IsolatedHeader();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return DashboardHeader(userName: user?.fullName ?? 'Analyst');
  }
}

void _showTriageSheet(BuildContext context, WidgetRef ref, ResourceAnomaly anomaly) async {
  HapticFeedback.mediumImpact();
  await AnomalyActionSheetV2.show(context, ref, anomaly);
}

void _showRestockSheet(BuildContext context, WidgetRef ref, ResourceAnomaly anomaly) async {
  HapticFeedback.mediumImpact();
  await AnomalyActionSheetV2.show(context, ref, anomaly);
}

void _showAlertTuning(BuildContext context, WidgetRef ref) {
  HapticFeedback.mediumImpact();
  context.showTacticalSheet(
    ref: ref,
    child: const _AlertTuningSheet(),
  );
}

class _AlertTuningSheet extends ConsumerWidget {
  const _AlertTuningSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensitivity = ref.watch(alertSensitivityProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STOCK WARNING LEVEL', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.neutralGray400, letterSpacing: 2.0)),
          const Gap(8),
          Text('Alert Settings', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.neutralGray900)),
          const Gap(12),
          Text('Set when you want to be notified about low stock. Current level is set to $sensitivity units.', 
               style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.neutralGray600, height: 1.5)),
          const Gap(32),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryBlue,
              inactiveTrackColor: AppTheme.neutralGray100,
              thumbColor: AppTheme.primaryBlue,
              overlayColor: AppTheme.primaryBlue.withOpacity(0.1),
              valueIndicatorTextStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
            ),
            child: Slider(
              value: sensitivity.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: sensitivity.toString(),
              onChanged: (v) => ref.read(alertSensitivityProvider.notifier).state = v.toInt(),
            ),
          ),
          
          const Gap(32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neutralGray900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('SAVE SETTINGS', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
