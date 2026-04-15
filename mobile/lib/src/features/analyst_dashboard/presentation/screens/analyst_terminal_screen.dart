import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../inventory/providers/inventory_providers.dart';
import '../../../../features_v2/inventory/presentation/providers/inventory_provider.dart';
import '../../../../core/design_system/widgets/atmospheric_background.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/widgets/dashboard_header.dart';
import '../../../dashboard/widgets/dashboard_background.dart';
import '../controllers/analyst_dashboard_controller.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/resource_anomalies_section.dart';
import '../widgets/recent_activity_logs.dart';
import '../../domain/entities/resource_anomaly.dart';

/// ⚙️ SENSITIVITY STATE: Local filter for anomaly alerts
final alertSensitivityProvider = StateProvider<int>((ref) => 10); // Default to 10 units

/// 📡 ANALYST TERMINAL: Professional navigational hub with personal anchoring.
class AnalystTerminalScreen extends ConsumerWidget {
  const AnalystTerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DashboardBackground(),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.read(analystDashboardControllerProvider.notifier).refresh(),
              color: AppTheme.primaryBlue,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // ── 1. PERSONALIZED HEADER ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final userName = ref.watch(dashboardUserNameProvider);
                          return DashboardHeader(userName: userName);
                        },
                      ),
                    ),
                  ),

                  // ── 2. KPI GRID (High-Pulse Stream) ──
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final metricsAsync = ref.watch(watchMetricsStreamProvider);
                          return metricsAsync.when(
                            data: (metrics) => KpiGrid(metrics: metrics),
                            loading: () => const _KpiGridSkeleton(),
                            error: (e, __) => _buildErrorCard('Metric Stream Desync: $e'),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverGap(32),

                  // ── 3. EQUIPMENT ANOMALIES (Stable State) ──
                  SliverToBoxAdapter(
                    child: Consumer(
                      builder: (context, ref, _) {
                          final anomaliesAsync = ref.watch(watchResourceAnomaliesProvider);
                          final sensitivity = ref.watch(alertSensitivityProvider);
                          
                          return anomaliesAsync.when(
                            data: (anomalies) {
                              // 🛰️ STRATEGIC FILTER: Tune stock alerts, but keep Operational/Security visible
                              final filtered = anomalies.where((a) {
                                if (a.category != AnomalyCategory.depletion) return true;
                                return a.currentStock <= sensitivity;
                              }).toList();
                              
                              return ResourceAnomaliesSection(
                                key: const ValueKey('resource_anomalies_stable_list'),
                                anomalies: filtered,
                                onTuningTap: () => _showAlertTuning(context, ref),
                                onViewAll: () => context.go('/manager/queue'),
                                onAnomalyTap: (anomaly) => _showTriageSheet(context, ref, anomaly),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, __) => _buildErrorCard('Scanner Offline: $e'),
                          );
                        },
                    ),
                  ),

                  const SliverGap(32),

                  // ── 4. ACTIVITY SUBSYSTEM ──
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final activitiesAsync = ref.watch(watchActivityStreamProvider);
                          return activitiesAsync.when(
                            data: (activities) => RecentActivityLogs(events: activities),
                            loading: () => const _ActivitySkeleton(),
                            error: (e, __) => _buildErrorCard('Activity Feed Severed: $e'),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverGap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.1)),
      ),
      child: Text(
        message,
        style: GoogleFonts.roboto(color: AppTheme.errorRed, fontSize: 13),
      ),
    );
  }
}

class _KpiGridSkeleton extends StatelessWidget {
  const _KpiGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      )),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds);
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      )),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}

void _showTriageSheet(BuildContext context, WidgetRef ref, ResourceAnomaly anomaly) {
  HapticFeedback.mediumImpact();
  
  context.showTacticalSheet(
    ref: ref,
    child: _AnomalyTriageSheet(anomaly: anomaly),
  );
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALERT TUNING', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
            ],
          ),
          const Gap(24),
          
          Text('Global Sensitivity Threshold', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.neutralGray900)),
          const Gap(8),
          Text('Only items with stock levels below this value will trigger a Logistical Alert on the dashboard.', 
               style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.neutralGray500)),
          
          const Gap(32),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.neutralGray50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neutralGray100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TuningBtn(icon: Icons.remove, onTap: () {
                      if (sensitivity > 0) ref.read(alertSensitivityProvider.notifier).state--;
                    }),
                    Column(
                      children: [
                        Text('$sensitivity', style: GoogleFonts.lexend(fontSize: 42, fontWeight: FontWeight.w900, color: AppTheme.neutralGray900)),
                        Text('UNITS', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.neutralGray400, letterSpacing: 1.0)),
                      ],
                    ),
                    _TuningBtn(icon: Icons.add, onTap: () {
                      ref.read(alertSensitivityProvider.notifier).state++;
                    }),
                  ],
                ),
              ],
            ),
          ),
          
          const Gap(40),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('SAVE ENGINE CONFIGS', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

class _TuningBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TuningBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutralGray200),
        ),
        child: Icon(icon, color: AppTheme.neutralGray900),
      ),
    );
  }
}

class _AnomalyTriageSheet extends ConsumerStatefulWidget {
  final ResourceAnomaly anomaly;
  const _AnomalyTriageSheet({required this.anomaly});

  @override
  ConsumerState<_AnomalyTriageSheet> createState() => _AnomalyTriageSheetState();
}

class _AnomalyTriageSheetState extends ConsumerState<_AnomalyTriageSheet> {
  late int _g, _d, _m, _l;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _g = widget.anomaly.qtyGood;
    _d = widget.anomaly.qtyDamaged;
    _m = widget.anomaly.qtyMaintenance;
    _l = widget.anomaly.qtyLost;
  }

  int get _total => _g + _d + _m + _l;

  Future<void> _handleCommit() async {
    if (widget.anomaly.inventoryId == null) return;
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();
    
    try {
      final repo = ref.read(analystRepositoryProvider);
      
      await repo.updateAssetHealth(
        inventoryId: widget.anomaly.inventoryId!,
        qtyGood: _g,
        qtyDamaged: _d,
        qtyMaintenance: _m,
        qtyLost: _l,
        notes: 'Terminal Audit Sync - Total: $_total',
      );

      ref.invalidate(resourceAnomaliesProvider);
      ref.invalidate(watchMetricsStreamProvider);
      ref.invalidate(analystMetricsProvider);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('🚨 COMMAND-FAILURE: Operational sync failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. STEALTH HEADER ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.neutralGray900),
                      const Gap(8),
                      Text('BACK', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ],
                  ),
                ),
                Text('MANAGEMENT TERMINAL', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.neutralGray400, letterSpacing: 2.0)),
              ],
            ),
          ),
          const Divider(height: 1),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 2. IDENTITY BLOCK (Compact) ──
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: AppTheme.neutralGray50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.neutralGray100)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.anomaly.imageUrl != null 
                              ? Image.network(widget.anomaly.imageUrl!, fit: BoxFit.cover)
                              : const Icon(Icons.inventory_2_outlined, color: Colors.black12, size: 24),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.anomaly.itemName, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.neutralGray900, letterSpacing: -0.5)),
                            Text('SN: ${widget.anomaly.inventoryId ?? "---"} • ${widget.anomaly.category.name}', 
                                 style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.neutralGray400)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(20),

                  // ── 3. TOTAL ANCHOR BANNER ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Σ TOTAL ACCOUNTED', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, letterSpacing: 1.0)),
                        Text('$_total UNITS', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ),

                  const Gap(24),
                  Text('STATUS RECONCILIATION', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.neutralGray400, letterSpacing: 1.5)),
                  const Gap(12),

                  // ── 4. THE TRIAGE MATRIX (2x2) ──
                  Row(
                    children: [
                      Expanded(child: _StatusBucketCard(label: 'READY', value: _g, color: Colors.green, onAdd: () => setState(() => _g++), onSub: () { if (_g > 0) setState(() => _g--); })),
                      const Gap(12),
                      Expanded(child: _StatusBucketCard(label: 'MAINT.', value: _m, color: Colors.orange, onAdd: () => setState(() => _m++), onSub: () { if (_m > 0) setState(() => _m--); })),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(child: _StatusBucketCard(label: 'DAMAGED', value: _d, color: Colors.red, onAdd: () => setState(() => _d++), onSub: () { if (_d > 0) setState(() => _d--); })),
                      const Gap(12),
                      Expanded(child: _StatusBucketCard(label: 'LOST', value: _l, color: Colors.black, onAdd: () => setState(() => _l++), onSub: () { if (_l > 0) setState(() => _l--); })),
                    ],
                  ),

                  const Gap(32),

                  // ── 5. PRIMARY COMMAND ACTION ──
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleCommit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neutralGray900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isProcessing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('RECONCILE LOGISTICAL STATE', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white, letterSpacing: 1.5)),
                    ),
                  ),
                  const Gap(12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBucketCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final VoidCallback onAdd;
  final VoidCallback onSub;

  const _StatusBucketCard({
    required this.label,
    required this.value,
    required this.color,
    required this.onAdd,
    required this.onSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutralGray50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neutralGray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const Gap(8),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.neutralGray500, letterSpacing: 0.5)),
            ],
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniCommandBtn(icon: Icons.remove, onTap: onSub),
              Text('$value', style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.neutralGray900)),
              _MiniCommandBtn(icon: Icons.add, onTap: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCommandBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniCommandBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.neutralGray200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 16, color: AppTheme.neutralGray900),
      ),
    );
  }
}
