import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_forensic_detail_sheet.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/controllers/analyst_dashboard_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_prefill_provider.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_admin_fields.dart';

enum _ActionMode { restock, triage }

class AnomalyActionHero extends ConsumerStatefulWidget {
  final ResourceAnomaly anomaly;
  const AnomalyActionHero({super.key, required this.anomaly});

  /// 🛡️ PROTECTED INVOCATION: Self-orchestrates dock focus and triage lifecycle.
  static Future<T?> show<T>(BuildContext context, WidgetRef ref, ResourceAnomaly anomaly) async {
    ref.read(isDockSuppressedProvider.notifier).state = true;
    
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnomalyActionHero(anomaly: anomaly),
    );

    ref.read(isDockSuppressedProvider.notifier).state = false;
    return result;
  }

  @override
  ConsumerState<AnomalyActionHero> createState() => _AnomalyActionHeroState();
}

class _AnomalyActionHeroState extends ConsumerState<AnomalyActionHero> {
  final _qtyController = TextEditingController();
  final _goodController = TextEditingController();
  final _damagedController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _lostController = TextEditingController();

  bool _isProcessing = false;
  late _ActionMode _mode;
  int? _selectedWarehouseId;

  ResourceAnomaly get _a => widget.anomaly;

  bool get _isOverdue =>
      _a.category == AnomalyCategory.overdue ||
      _a.reason.toLowerCase().contains('overdue');

  bool get _hasHealthIssue => _a.qtyDamaged > 0 || _a.qtyMaintenance > 0;

  @override
  void initState() {
    super.initState();

    _mode = _hasHealthIssue ? _ActionMode.triage : _ActionMode.restock;

    if (_a.category == AnomalyCategory.depletion) {
      final gap =
          (_a.maxStock ?? _a.thresholdStock) - _a.currentStock;
      if (gap > 0) _qtyController.text = gap.toString();
    }

    _goodController.text = '0'; // Default to 0 for restock additions
    _damagedController.text = '0';
    _maintenanceController.text = '0';
    _lostController.text = '0';

    // 🛡️ DEFAULT CONTEXT: Try to find a warehouse from the user profile
    final user = ref.read(currentUserProvider);
    if (user?.assignedWarehouse != null) {
      _selectedWarehouseId = int.tryParse(user!.assignedWarehouse!);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _goodController.dispose();
    _damagedController.dispose();
    _maintenanceController.dispose();
    _lostController.dispose();
    _returnNotesController.dispose();
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final analystName = user?.fullName ?? 'Analyst';

    if (_isOverdue) return _buildOverdueHero(context, analystName);
    return _buildActionHero(context, analystName);
  }

  // ---------------------------------------------------------------------------
  // OVERDUE FLOW
  // ---------------------------------------------------------------------------
  String? _returnCondition = 'good';
  final _returnNotesController = TextEditingController();

  Widget _buildOverdueHero(BuildContext context, String analystName) {
    final sentinel = Theme.of(context).sentinel;
    
    // ── Human-Readable Personnel Mapping ──
    final person = _a.borrowerName ?? 'Unknown Person';
    final org = _a.borrowerOrg ?? 'No Org';
    final approvedBy = _a.approvedByName ?? 'System';
    final releasedBy = _a.releasedByName ?? 'Pending';
    
    // ── Human-Readable Timestamps (2 Lines for Density) ──
    final sentOutDate = _a.borrowedAt != null
        ? DateFormat('dd, MMM yyyy\nh:mm a').format(_a.borrowedAt!.toLocal())
        : 'N/A';
    final deadlineDate = _a.dueDate != null
        ? DateFormat('dd, MMM yyyy\nh:mm a').format(_a.dueDate!.toLocal())
        : 'N/A';
        
    final isMobile = _a.platformOrigin == 'Mobile';
    final hasReturn = _a.borrowId != null && _a.inventoryId != null;

    return TacticalForensicDetailSheet(
      id: _a.id,
      title: _a.itemName,
      statusLabel: 'OVERDUE',
      accentColor: AppTheme.errorRed,
      statusIcon: Icons.timer_off_rounded,
      imagePath: _a.imageUrl,
      heroTagPrefix: 'anomaly',
      categoryLabel: 'OVERDUE',
      details: [
        DetailRowData(
          icon: Icons.person_outline_rounded,
          label: 'REQUESTER',
          value: person,
          zone: 'Personnel',
          isHalfWidth: false,
          trailing: Icon(
            isMobile ? Icons.smartphone_rounded : Icons.monitor_rounded,
            size: 11,
            color: isMobile ? Colors.orange : AppTheme.primaryBlue.withOpacity(0.6),
          ),
        ),
        DetailRowData(
          icon: Icons.business_rounded,
          label: 'ORGANIZATION',
          value: org,
          zone: 'Personnel',
          isHalfWidth: false,
        ),
        DetailRowData(
          icon: Icons.shield_outlined,
          label: 'APPROVED BY',
          value: approvedBy,
          zone: 'Transaction',
          isHalfWidth: true,
        ),
        DetailRowData(
          icon: Icons.check_circle_outline_rounded,
          label: 'HANDED BY',
          value: releasedBy,
          zone: 'Transaction',
          isHalfWidth: true,
        ),
        DetailRowData(
          icon: Icons.calendar_month_rounded,
          label: 'TIMESTAMP',
          value: sentOutDate.replaceAll('\n', ' '),
          zone: 'Transaction',
          isHalfWidth: false,
        ),
      ],
      analystNotes: null,
      actionHub: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReturn)
            _buildConfirmButton(
              sentinel: sentinel,
              label: 'PROCESS RETURN',
              icon: Icons.assignment_return_rounded,
              color: AppTheme.errorRed,
              onPressed: () => _showForceReturnDialog(context, analystName),
            ),
        ],
      ),
    );
  }

  void _showForceReturnDialog(BuildContext context, String analystName) {
    const charcoal = Color(0xFF0A0E14); 
    final receivingOfficerController = TextEditingController(text: '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Handle ──
              const Gap(12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(2)))),
              const Gap(20),

              Flexible(
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            children: [
                              const Icon(Icons.assignment_return_rounded, color: charcoal, size: 22),
                              const Gap(12),
                              Text(
                                'Process Return',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: charcoal,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          Text(
                            _a.category.name.toUpperCase(), 
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const Gap(20),
                          
                          // ── Receiving Officer ──
                          _buildPremiumLabel('Receiving Officer *'),
                          const Gap(10),
                          _buildPremiumTextField(
                            controller: receivingOfficerController,
                            hint: 'Enter name...',
                            suffix: TextButton(
                              onPressed: () => setModalState(() => receivingOfficerController.text = analystName),
                              child: Text('Use my name', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: charcoal)),
                            ),
                          ),
                          const Gap(28),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPremiumLabel('Condition State *'),
                                    const Gap(10),
                                    Container(
                                      decoration: _premiumShadow(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _returnCondition,
                                            isExpanded: true,
                                            icon: const Icon(Icons.expand_more_rounded, size: 18, color: charcoal),
                                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: charcoal),
                                            borderRadius: BorderRadius.circular(16),
                                            items: [
                                              _buildConditionItem('good', 'Good Condition', AppTheme.emeraldGreen),
                                              _buildConditionItem('maintenance', 'Needs Maintenance', AppTheme.warningOrange),
                                              _buildConditionItem('damaged', 'Damaged', AppTheme.errorRed),
                                              _buildConditionItem('lost', 'Lost Asset', Colors.grey),
                                            ],
                                            onChanged: (v) => setModalState(() => _returnCondition = v!),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPremiumLabel('Audit Notes'),
                                    const Gap(10),
                                    _buildPremiumTextField(
                                      controller: _returnNotesController,
                                      hint: 'Optional notes...',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const Gap(32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: charcoal.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: charcoal.withOpacity(0.05)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user_rounded, size: 18, color: charcoal.withOpacity(0.4)),
                                const Gap(14),
                                Expanded(
                                  child: Text(
                                    'LIGTAS-Audit: Timestamps and personnel ID will be recorded upon recovery.',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: charcoal.withOpacity(0.5), height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(32),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                                  child: Text('Cancel', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: charcoal.withOpacity(0.3))),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: charcoal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (receivingOfficerController.text.isEmpty) {
                                        HapticFeedback.heavyImpact();
                                        return;
                                      }
                                      Navigator.pop(context);
                                      _handleForceReturn(context, analystName, overrideReceivedBy: receivingOfficerController.text);
                                    },
                                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                                    label: Text('Confirm Recovery', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: charcoal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.lexend(
        fontSize: 10, 
        fontWeight: FontWeight.w800, 
        color: const Color(0xFF64748B),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildPremiumTextField({required TextEditingController controller, required String hint, Widget? suffix, bool isNumeric = false}) {
    return Container(
      decoration: _premiumShadow(),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : null,
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF001A33)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B).withOpacity(0.4)),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF001A33), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  BoxDecoration _premiumShadow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildConditionItem(String value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
          ),
          const Gap(10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionTileInDialog(String value, String label, IconData icon, Color color, LigtasColors sentinel, StateSetter setModalState) {
    final isSelected = _returnCondition == value;
    return InkWell(
      onTap: () {
        setModalState(() => _returnCondition = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: value != 'lost' ? Border(bottom: BorderSide(color: sentinel.navy.withOpacity(0.04))) : null,
          color: isSelected ? color.withOpacity(0.08) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? color : sentinel.onSurfaceVariant.withOpacity(0.4)),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const Gap(8),
              Text(
                label,
                style: GoogleFonts.lexend(
                    fontSize: 11, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conditionTile(String value, String label, IconData icon, Color color,
      LigtasColors sentinel) {
    final isSelected = _returnCondition == value;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _returnCondition = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : sentinel.onSurfaceVariant.withOpacity(0.4)),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? color : sentinel.navy.withOpacity(0.65),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.radio_button_checked_rounded, size: 16, color: color)
            else
              Icon(Icons.radio_button_off_rounded, size: 16,
                  color: sentinel.onSurfaceVariant.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESTOCK + TRIAGE (switchable via toggle)
  // ---------------------------------------------------------------------------
  Widget _buildActionHero(BuildContext context, String analystName) {
    final sentinel = Theme.of(context).sentinel;
    final showToggle = _a.category == AnomalyCategory.depletion && _hasHealthIssue;

    return TacticalForensicDetailSheet(
      id: _a.id,
      title: _a.itemName,
      statusLabel: _mode == _ActionMode.restock ? 'LOW STOCK' : 'HEALTH TRIAGE',
      accentColor: _mode == _ActionMode.restock ? Colors.orange : AppTheme.errorRed,
      statusIcon: _mode == _ActionMode.restock
          ? Icons.inventory_2_rounded
          : Icons.medical_services_rounded,
      imagePath: _a.imageUrl,
      heroTagPrefix: 'anomaly',
      categoryLabel: _a.category.name.toUpperCase(),
      details: [
        DetailRowData(
          icon: Icons.inventory_rounded,
          label: 'CURRENT STOCK',
          value: '${_a.currentStock} Units',
          zone: 'Stock Ledger',
          isHalfWidth: true,
        ),
        DetailRowData(
          icon: Icons.flag_rounded,
          label: 'TARGET STOCK',
          value: '${_a.maxStock ?? _a.thresholdStock} Units',
          zone: 'Stock Ledger',
          isHalfWidth: true,
        ),
      ],
      analystNotes: _a.reason,
      actionHub: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showToggle) ...[
            _buildModeToggle(sentinel),
            const Gap(20),
          ],
          if (_mode == _ActionMode.restock)
            _buildRestockPanel(sentinel, analystName)
          else
            _buildTriagePanel(sentinel),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODE TOGGLE
  // ---------------------------------------------------------------------------
  Widget _buildModeToggle(LigtasColors sentinel) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: Row(
        children: [
          _toggleSegment(
            label: 'RESTOCK',
            isActive: _mode == _ActionMode.restock,
            color: sentinel.navy,
            onTap: () => setState(() => _mode = _ActionMode.restock),
          ),
          _toggleSegment(
            label: 'HEALTH TRIAGE',
            isActive: _mode == _ActionMode.triage,
            color: AppTheme.errorRed,
            onTap: () => setState(() => _mode = _ActionMode.triage),
          ),
        ],
      ),
    );
  }

  Widget _toggleSegment({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isActive ? color : Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESTOCK TERMINAL (Strategic Injection)
  // ---------------------------------------------------------------------------
  Widget _buildRestockPanel(LigtasColors sentinel, String analystName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. STRATEGIC OVERVIEW (The "Why") ──
        _buildStrategicOverview(sentinel),
        const Gap(20),

        // ── 2. DEPLOYMENT TARGET (The "Where") ──
        _buildLocationSelector(sentinel),
        const Gap(12),
        _buildHubSnapshot(sentinel),
        const Gap(20),

        // ── 3. CONDITION INJECTION (The "What") ──
        Text('INJECTION QUANTITIES',
            style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: sentinel.onSurfaceVariant.withOpacity(0.5),
                letterSpacing: 1.0)),
        const Gap(12),
        Row(children: [
          Expanded(child: _bucketField('GOOD STOCK', _goodController, sentinel, accentColor: AppTheme.emeraldGreen)),
          const Gap(10),
          Expanded(child: _bucketField('DAMAGED', _damagedController, sentinel, accentColor: Colors.orangeAccent)),
        ]),
        const Gap(10),
        Row(children: [
          Expanded(child: _bucketField('MAINTENANCE', _maintenanceController, sentinel, accentColor: AppTheme.warningAmber)),
          const Gap(10),
          Expanded(child: _bucketField('LOST / SHRINK', _lostController, sentinel, accentColor: AppTheme.errorRed)),
        ]),
        
        const Gap(16),
        _buildAuditRow(sentinel, analystName),
        const Gap(24),
        _buildConfirmButton(
          sentinel: sentinel,
          label: 'CONFIRM INJECTION',
          icon: Icons.add_business_rounded,
          color: sentinel.navy,
          onPressed: _handleRestock,
        ),
      ],
    );
  }

  Widget _buildStrategicOverview(LigtasColors sentinel) {
    final target = _a.maxStock ?? _a.thresholdStock;
    final current = _a.currentStock;
    final gap = target - current;
    final progress = (current / (target > 0 ? target : 1)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001A33).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DEPLOYMENT GAP',
                  style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5)),
              if (gap > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('- $gap UNITS',
                      style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange)),
                ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress < 0.5 ? AppTheme.errorRed : AppTheme.primaryBlue),
            ),
          ),
          const Gap(12),
          Row(
            children: [
              Text('$current',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF001A33))),
              Text(' / $target UNITS',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(LigtasColors sentinel) {
    final hubsAsync = ref.watch(managerStorageHubsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INJECTION HUB',
            style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: sentinel.onSurfaceVariant.withOpacity(0.5),
                letterSpacing: 1.0)),
        const Gap(12),
        Container(
          decoration: _premiumShadow(),
          child: hubsAsync.when(
            data: (hubs) => DropdownButtonFormField<int>(
              value: hubs.any((h) => h.id == _selectedWarehouseId) ? _selectedWarehouseId : null,
              icon: Icon(Icons.arrow_drop_down_rounded, color: sentinel.navy),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.warehouse_rounded, size: 18, color: sentinel.navy.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: hubs.map((h) => DropdownMenuItem<int>(
                value: h.id,
                child: Text(h.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedWarehouseId = val),
              hint: Text('Select target location...', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black26)),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Failed to load hubs'),
          ),
        ),
      ],
    );
  }

  Widget _buildHubSnapshot(LigtasColors sentinel) {
    if (_a.itemId == null || _selectedWarehouseId == null) return const SizedBox.shrink();

    final snapshot = ref.watch(hubStockSnapshotProvider(
      itemId: _a.itemId!,
      warehouseId: _selectedWarehouseId!,
    ));

    return snapshot.when(
      data: (data) {
        if (data.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sentinel.navy.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: sentinel.navy.withOpacity(0.4)),
                const Gap(8),
                Text('No existing stock found at this hub.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sentinel.navy.withOpacity(0.4))),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001A33).withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HUB LEDGER (CURRENT HOLDINGS)',
                  style: GoogleFonts.lexend(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5)),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _snapshotItem('GOOD', data['good'] ?? 0, AppTheme.emeraldGreen),
                  _snapshotItem('DMG', data['damaged'] ?? 0, Colors.orangeAccent),
                  _snapshotItem('MNT', data['maintenance'] ?? 0, AppTheme.warningAmber),
                  _snapshotItem('LST', data['lost'] ?? 0, AppTheme.errorRed),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _snapshotItem(String label, int value, Color statusColor) {
    final onyx = const Color(0xFF001A33);
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
        ),
        const Gap(6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w900, color: onyx)),
            Text(label,
                style: GoogleFonts.lexend(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: onyx.withOpacity(0.4),
                    letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HEALTH TRIAGE PANEL
  // ---------------------------------------------------------------------------
  Widget _buildTriagePanel(LigtasColors sentinel) {
    final good = _int(_goodController);
    final damaged = _int(_damagedController);
    final maint = _int(_maintenanceController);
    final lost = _int(_lostController);
    final total = good + damaged + maint + lost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STOCK DISTRIBUTION',
            style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: sentinel.onSurfaceVariant.withOpacity(0.5),
                letterSpacing: 1.0)),
        const Gap(12),
        Row(children: [
          Expanded(
              child: _bucketField('GOOD', _goodController, sentinel,
                  accentColor: AppTheme.emeraldGreen)),
          const Gap(10),
          Expanded(
              child: _bucketField('DAMAGED', _damagedController, sentinel,
                  accentColor: Colors.orangeAccent)),
        ]),
        const Gap(10),
        Row(children: [
          Expanded(
              child: _bucketField('MAINTENANCE', _maintenanceController, sentinel,
                  accentColor: AppTheme.warningAmber)),
          const Gap(10),
          Expanded(
              child: _bucketField('LOST', _lostController, sentinel,
                  accentColor: AppTheme.errorRed)),
        ]),
        const Gap(14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('COMPUTED TOTAL',
                  style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5)),
              Text('$total Units',
                  style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF001A33))),
            ],
          ),
        ),
        const Gap(24),
        _buildConfirmButton(
          sentinel: sentinel,
          label: 'SAVE HEALTH TRIAGE',
          icon: Icons.medical_services_rounded,
          color: sentinel.navy,
          onPressed: _handleTriage,
        ),
      ],
    );
  }

  Widget _bucketField(
    String label,
    TextEditingController controller,
    LigtasColors sentinel, {
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            ),
            const Gap(6),
            Text(label,
                style: GoogleFonts.lexend(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: sentinel.navy.withOpacity(0.6),
                    letterSpacing: 0.5)),
          ],
        ),
        const Gap(6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF001A33)),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              hintText: '0',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B).withOpacity(0.4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED UI
  // ---------------------------------------------------------------------------
  Widget _buildAuditRow(LigtasColors sentinel, String analystName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded,
              size: 14, color: Color(0xFF64748B)),
          const Gap(10),
          Text('User:',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B))),
          const Gap(6),
          Text(analystName,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF001A33))),
        ],
      ),
    );
  }

  Widget _buildConfirmButton({
    required LigtasColors sentinel,
    required String label,
    required IconData icon,
    required Color color, // Ignoring color for design system override
    required VoidCallback onPressed,
  }) {
    final navy = const Color(0xFF001A33);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _isProcessing ? navy.withOpacity(0.7) : navy,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isProcessing ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: navy.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isProcessing
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const Gap(12),
                      Text(label,
                          style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  Future<void> _handleRestock() async {
    final goodQty = _int(_goodController);
    final damagedQty = _int(_damagedController);
    final maintQty = _int(_maintenanceController);
    final lostQty = _int(_lostController);
    final total = goodQty + damagedQty + maintQty + lostQty;

    if (total <= 0 || _a.inventoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter injection quantities.')));
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an injection hub.')));
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(analystDashboardControllerProvider.notifier).restockAsset(
            inventoryId: _a.inventoryId!,
            qtyGood: goodQty,
            qtyDamaged: damagedQty,
            qtyMaint: maintQty,
            qtyLost: lostQty,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Success: $total units injected.',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Injection protocol failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleTriage() async {
    if (_a.inventoryId == null) return;

    final good = _int(_goodController);
    final damaged = _int(_damagedController);
    final maint = _int(_maintenanceController);
    final lost = _int(_lostController);
    final total = good + damaged + maint + lost;

    if (total < 1) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(analystDashboardControllerProvider.notifier)
          .updateAssetHealth(
            _a.inventoryId!,
            qtyGood: good,
            qtyDamaged: damaged,
            qtyMaintenance: maint,
            qtyLost: lost,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Health triage saved',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Triage update failed.')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _dialPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email,
        queryParameters: {'subject': 'Overdue Item: ${_a.itemName}'});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handleForceReturn(BuildContext context, String analystName, {String? overrideReceivedBy}) async {
    final borrowId = _a.borrowId;
    final inventoryId = _a.inventoryId;
    if (borrowId == null || inventoryId == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final user = ref.read(currentUserProvider);
    final receivedByName = (overrideReceivedBy != null && overrideReceivedBy.isNotEmpty) 
        ? overrideReceivedBy 
        : analystName;

    final result = await ref
        .read(analystDashboardControllerProvider.notifier)
        .forceReturn(
          borrowId: borrowId,
          inventoryId: inventoryId,
          quantity: _a.borrowedQty > 0 ? _a.borrowedQty : 1,
          receivedByName: receivedByName,
          receivedByUserId: user?.id ?? '',
          returnCondition: _returnCondition ?? 'good',
          returnNotes: _returnNotesController.text.trim().isEmpty
              ? null
              : _returnNotesController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Return processed successfully',
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Force return failed.',
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
