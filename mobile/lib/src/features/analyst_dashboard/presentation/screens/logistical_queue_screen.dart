import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_theme.dart';
import '../../../../core/design_system/widgets/atmospheric_background.dart';
import '../../../dashboard/widgets/dashboard_background.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../domain/entities/logistics_action.dart';
import '../controllers/logistics_queue_controller.dart';
import '../../../../features_v2/loans/presentation/providers/loan_provider.dart';
import '../../../../features_v2/loans/domain/entities/loan_item.dart';
import '../_components/audit_vault_components.dart';
import '../../domain/entities/activity_event.dart';

/// 📡 LOGISTICS COMMAND CENTER (V4 - CONSISTENT WHITE)
/// High-density Triage Hub aligned with the Analyst Dashboard's Soft White theme.
class LogisticalQueueScreen extends ConsumerStatefulWidget {
  const LogisticalQueueScreen({super.key});

  @override
  ConsumerState<LogisticalQueueScreen> createState() => _LogisticalQueueScreenState();
}

class _LogisticalQueueScreenState extends ConsumerState<LogisticalQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(logisticsQueueControllerProvider);
    final pendingLoans = ref.watch(managerPendingQueueProvider);
    final stagedLoans = ref.watch(managerStagedQueueProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DashboardBackground(),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(context, ref),
              _buildTacticalTabBar(),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // ── TAB 1: AUTHORIZATION ──
                _WorkstationView(
                  items: pendingLoans,
                  emptyLabel: 'NO PENDING REQUESTS',
                  builder: (item) => _LoanQueueCard(
                    loan: item as LoanItem,
                    phase: _QueuePhase.authorization,
                    onTap: () => _showLoanDetailSheet(context, ref, item),
                  ),
                ),

                // ── TAB 2: DISPATCH ──
                _WorkstationView(
                  items: stagedLoans,
                  emptyLabel: 'DISPATCH QUEUE CLEAR',
                  builder: (item) => _LoanQueueCard(
                    loan: item as LoanItem,
                    phase: _QueuePhase.dispatch,
                    onTap: () => _showLoanDetailSheet(context, ref, item),
                  ),
                ),

                // ── TAB 3: AUDIT ──
                _WorkstationView(
                  items: queueAsync.value ?? [],
                  emptyLabel: 'SYSTEM HEALTH STABLE',
                  builder: (item) => _QueueActionCard(
                    action: item as LogisticsAction,
                    onResolve: () => _showResolutionSheet(context, ref, item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.neutralGray900),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LOGISTICS TERMINAL',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.neutralGray900,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            'REAL-TIME COMMAND QUEUE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        _SyncPulseButton(
          onRefresh: () {
            ref.read(logisticsQueueControllerProvider.notifier).refresh();
            ref.read(managerLoansNotifierProvider.notifier).refresh();
          },
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildTacticalTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: Column(
                children: [
                  const Gap(8),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: [
                      _TacticalTab(
                        label: 'AUTH',
                        index: 0,
                        isActive: _tabController.index == 0,
                        count: ref.watch(managerPendingQueueProvider).length,
                        activeColor: AppTheme.warningOrange,
                      ),
                      _TacticalTab(
                        label: 'DISPATCH',
                        index: 1,
                        isActive: _tabController.index == 1,
                        count: ref.watch(managerStagedQueueProvider).length,
                        activeColor: AppTheme.emeraldGreen,
                      ),
                      _TacticalTab(
                        label: 'AUDIT',
                        index: 2,
                        isActive: _tabController.index == 2,
                        count: (ref.watch(logisticsQueueControllerProvider).value ?? []).length,
                        activeColor: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoanDetailSheet(BuildContext context, WidgetRef ref, LoanItem loan) async {
    HapticFeedback.mediumImpact();
    final event = ActivityEvent(
      id: loan.id, 
      title: loan.itemName,
      type: loan.status == LoanStatus.pending ? EventType.assetOut : EventType.requisitionApproved,
      timestamp: loan.borrowDate,
      referenceId: loan.id,
      actorName: loan.borrowerName,
      locationTarget: loan.borrowerName,
      notes: loan.purpose,
    );

    context.showTacticalSheet(
      ref: ref,
      child: CommandDetailSheet(event: event),
    );
  }

  void _showResolutionSheet(BuildContext context, WidgetRef ref, LogisticsAction action) {
    HapticFeedback.mediumImpact();
    context.showTacticalSheet(
      ref: ref,
      child: _ResolutionSheet(action: action),
    );
  }
}

enum _QueuePhase { authorization, dispatch }

class _WorkstationView extends StatelessWidget {
  final List<dynamic> items;
  final String emptyLabel;
  final Widget Function(dynamic) builder;

  const _WorkstationView({
    required this.items,
    required this.emptyLabel,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded, size: 48, color: AppTheme.neutralGray200),
            const Gap(16),
            Text(
              emptyLabel,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray400,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) => builder(items[index])
          .animate(delay: (index * 50).ms)
          .fadeIn()
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
    );
  }
}

class _TacticalTab extends StatelessWidget {
  final String label;
  final int index;
  final bool isActive;
  final int count;
  final Color activeColor;

  const _TacticalTab({
    required this.label,
    required this.index,
    required this.isActive,
    required this.count,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
        ),
        boxShadow: isActive ? [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isActive ? activeColor : AppTheme.neutralGray400,
              letterSpacing: 1.0,
            ),
          ),
          if (count > 0) ...[
            const Gap(6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? activeColor : AppTheme.neutralGray200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.lexend(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SyncPulseButton extends StatefulWidget {
  final VoidCallback onRefresh;
  const _SyncPulseButton({required this.onRefresh});

  @override
  State<_SyncPulseButton> createState() => _SyncPulseButtonState();
}

class _SyncPulseButtonState extends State<_SyncPulseButton> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isSyncing) return;
        HapticFeedback.mediumImpact();
        setState(() => _isSyncing = true);
        widget.onRefresh();
        Future.delayed(1.seconds, () => setState(() => _isSyncing = false));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(
          Icons.refresh_rounded,
          size: 18,
          color: _isSyncing ? AppTheme.primaryBlue : AppTheme.neutralGray600,
        ).animate(target: _isSyncing ? 1 : 0).rotate(duration: 1.seconds, end: 1),
      ),
    );
  }
}

class _LoanQueueCard extends StatelessWidget {
  final LoanItem loan;
  final _QueuePhase phase;
  final VoidCallback onTap;

  const _LoanQueueCard({required this.loan, required this.phase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = phase == _QueuePhase.authorization ? AppTheme.warningOrange : AppTheme.emeraldGreen;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // 🛡️ FORENSIC SPEC: 14px radius
        border: Border.all(color: AppTheme.neutralGray900.withOpacity(0.06), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutralGray900.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12), // 🛡️ FORENSIC SPEC: 12px padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP: HEADER ROW ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40, // 🛡️ FORENSIC SPEC: 40x40 icon
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        phase == _QueuePhase.authorization ? Icons.fact_check_rounded : Icons.local_shipping_rounded,
                        size: 18, color: statusColor,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loan.itemName.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w700, 
                                    color: AppTheme.neutralGray900,
                                    height: 1.1,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                Text(
                                  'REQ ID: ${loan.id.length > 8 ? loan.id.substring(0, 8) : loan.id}', 
                                  style: GoogleFonts.lexend(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.w600, 
                                    color: AppTheme.neutralGray900.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(loan.borrowDate), // Assuming borrowDate is the request time
                                style: GoogleFonts.lexend(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w500, 
                                  color: AppTheme.neutralGray900.withOpacity(0.5),
                                ),
                              ),
                              const Gap(4),
                              _TacticalActionBadge(
                                label: phase == _QueuePhase.authorization ? 'DECISION' : 'HANDOFF', 
                                color: statusColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Gap(10),

                // ── BOTTOM: CONTEXT STRIP ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray900.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REQUESTER',
                              style: GoogleFonts.lexend(
                                fontSize: 8, 
                                fontWeight: FontWeight.w500, 
                                color: AppTheme.neutralGray900.withOpacity(0.35), 
                                letterSpacing: 0.8
                              ),
                            ),
                            const Gap(3), 
                            Row(
                              children: [
                                Container(width: 14, height: 14, decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.08), shape: BoxShape.circle)), 
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    loan.borrowerName, 
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lexend(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w600, 
                                      color: AppTheme.neutralGray900.withOpacity(0.7)
                                    ), 
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10), 
                        width: 1, 
                        height: 18, 
                        color: AppTheme.neutralGray900.withOpacity(0.04),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PURPOSE',
                              style: GoogleFonts.lexend(
                                fontSize: 8, 
                                fontWeight: FontWeight.w500, 
                                color: AppTheme.neutralGray900.withOpacity(0.35), 
                                letterSpacing: 0.8
                              ),
                            ),
                            const Gap(3), 
                            Text(
                              loan.purpose, 
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                fontSize: 10, 
                                fontWeight: FontWeight.w600, 
                                color: AppTheme.neutralGray900.withOpacity(0.7)
                              ), 
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueActionCard extends StatelessWidget {
  final LogisticsAction action;
  final VoidCallback onResolve;

  const _QueueActionCard({required this.action, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final statusColor = action.type == ActionType.dispose 
        ? AppTheme.errorRed 
        : action.type == ActionType.dispense ? AppTheme.warningOrange : AppTheme.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralGray900.withOpacity(0.06), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutralGray900.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onResolve,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP: HEADER ROW ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.type == ActionType.dispose ? Icons.delete_forever_rounded : Icons.outbox_rounded,
                        size: 18, color: statusColor,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action.itemName.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w700, 
                                    color: AppTheme.neutralGray900,
                                    height: 1.1,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                Text(
                                  'ACT ID: ${action.id.length > 8 ? action.id.substring(0, 8) : action.id}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.w600, 
                                    color: AppTheme.neutralGray900.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(action.createdAt ?? DateTime.now()),
                                style: GoogleFonts.lexend(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w500, 
                                  color: AppTheme.neutralGray900.withOpacity(0.5),
                                ),
                              ),
                              const Gap(4),
                              _TacticalActionBadge(
                                label: action.typeLabel.toUpperCase(), 
                                color: statusColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Gap(10),

                // ── BOTTOM: CONTEXT STRIP ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray900.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ISSUED BY',
                              style: GoogleFonts.lexend(
                                fontSize: 8, 
                                fontWeight: FontWeight.w500, 
                                color: AppTheme.neutralGray900.withOpacity(0.35), 
                                letterSpacing: 0.8
                              ),
                            ),
                            const Gap(3), 
                            Row(
                              children: [
                                Container(width: 14, height: 14, decoration: BoxDecoration(color: AppTheme.neutralGray900.withOpacity(0.08), shape: BoxShape.circle)), 
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    action.requesterName ?? 'SYSTEM', 
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lexend(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w600, 
                                      color: AppTheme.neutralGray900.withOpacity(0.7)
                                    ), 
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10), 
                        width: 1, 
                        height: 18, 
                        color: AppTheme.neutralGray900.withOpacity(0.04),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOLUME',
                              style: GoogleFonts.lexend(
                                fontSize: 8, 
                                fontWeight: FontWeight.w500, 
                                color: AppTheme.neutralGray900.withOpacity(0.35), 
                                letterSpacing: 0.8
                              ),
                            ),
                            const Gap(3), 
                            Text(
                              '${action.quantity} UNITS', 
                              style: GoogleFonts.lexend(
                                fontSize: 10, 
                                fontWeight: FontWeight.w600, 
                                color: AppTheme.neutralGray900.withOpacity(0.7)
                              ), 
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TacticalActionBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TacticalActionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }
}

class _ResolutionSheet extends ConsumerStatefulWidget {
  final LogisticsAction action;
  const _ResolutionSheet({required this.action});

  @override
  ConsumerState<_ResolutionSheet> createState() => _ResolutionSheetState();
}

class _ResolutionSheetState extends ConsumerState<_ResolutionSheet> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
          const Gap(32),
          Text(widget.action.actionVerb.toUpperCase(), style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.neutralGray900)),
          const Gap(8),
          Text('FORENSIC AUDIT RECORD', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.neutralGray400, letterSpacing: 2.0)),
          const Gap(32),
          
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add forensic notes for the ledger...',
              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.neutralGray400, fontSize: 14),
              filled: true,
              fillColor: AppTheme.neutralGray50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
          
          const Gap(32),
          
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  'FLAG ANOMALY',
                  Colors.white,
                  AppTheme.errorRed,
                  () => _resolve(ActionStatus.flagged),
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildActionBtn(
                  'COMPLETE',
                  AppTheme.primaryBlue,
                  Colors.white,
                  () => _resolve(ActionStatus.completed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color bg, Color text, VoidCallback onTap) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: bg == Colors.white ? Border.all(color: text.withOpacity(0.2)) : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: text, letterSpacing: 1.0),
          ),
        ),
      ),
    );
  }

  void _resolve(ActionStatus status) {
    HapticFeedback.heavyImpact();
    ref.read(logisticsQueueControllerProvider.notifier).resolveAction(
      actionId: widget.action.id,
      status: status,
      forensicNote: _noteController.text,
    );
    Navigator.pop(context);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 74;
  @override
  double get maxExtent => 74;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => true;
}
