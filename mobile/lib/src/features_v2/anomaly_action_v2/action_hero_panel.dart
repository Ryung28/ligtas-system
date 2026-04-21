import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/top_notice.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_forensic_detail_sheet.dart';
import 'package:mobile/src/features/analyst_dashboard/domain/entities/resource_anomaly.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/controllers/analyst_dashboard_controller.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_prefill_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'anomaly_action_mode.dart';
import 'anomaly_injection_confirm_dialog.dart';
import 'anomaly_strategic_overview.dart';
import 'anomaly_shared_widgets.dart';

class ActionHeroPanel extends ConsumerStatefulWidget {
  final ResourceAnomaly anomaly;
  const ActionHeroPanel({super.key, required this.anomaly});

  @override
  ConsumerState<ActionHeroPanel> createState() => _ActionHeroPanelState();
}

class _ActionHeroPanelState extends ConsumerState<ActionHeroPanel> {
  final _qtyController = TextEditingController();
  final _goodController = TextEditingController();
  final _damagedController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _lostController = TextEditingController();

  bool _isProcessing = false;
  late ActionMode _mode;
  int? _selectedWarehouseId;
  int? _hydratedLocationRegistryId;
  int? _hydratedItemId;

  ResourceAnomaly get _a => widget.anomaly;

  int? get _rowLocationRegistryId =>
      _a.locationRegistryId ?? _hydratedLocationRegistryId;

  int? get _snapshotItemId => _a.itemId ?? _hydratedItemId;

  String _hubLabel(List<StorageHub> hubs, int? id) {
    if (id == null) return 'Unknown location';
    for (final h in hubs) {
      if (h.id == id) return h.name;
    }
    return 'Location #$id';
  }

  bool get _hasHealthIssue =>
      _a.qtyDamaged > 0 || _a.qtyMaintenance > 0;

  @override
  void initState() {
    super.initState();

    _mode = _hasHealthIssue ? ActionMode.triage : ActionMode.restock;

    if (_a.category == AnomalyCategory.depletion) {
      final gap = (_a.maxStock ?? _a.thresholdStock) - _a.currentStock;
      if (gap > 0) _qtyController.text = gap.toString();
    }

    _goodController.text = '0';
    _damagedController.text = '0';
    _maintenanceController.text = '0';
    _lostController.text = '0';

    final user = ref.read(currentUserProvider);
    _selectedWarehouseId = widget.anomaly.locationRegistryId ??
        int.tryParse(user?.assignedWarehouse ?? '');

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _hydrateInjectionContext());
  }

  Future<void> _hydrateInjectionContext() async {
    final invId = widget.anomaly.inventoryId;
    if (invId == null) return;

    final needsHydration = widget.anomaly.locationRegistryId == null ||
        widget.anomaly.itemId == null;

    if (!needsHydration) {
      if (mounted &&
          _selectedWarehouseId == null &&
          _rowLocationRegistryId != null) {
        setState(() => _selectedWarehouseId = _rowLocationRegistryId);
      }
      return;
    }

    try {
      final row = await Supabase.instance.client
          .from('inventory')
          .select('id, location_registry_id, parent_id')
          .eq('id', invId)
          .maybeSingle();

      if (!mounted || row == null) return;

      final pid = (row['parent_id'] as num?)?.toInt();
      final rid = (row['id'] as num?)?.toInt();

      setState(() {
        _hydratedLocationRegistryId =
            (row['location_registry_id'] as num?)?.toInt();
        _hydratedItemId = pid ?? rid;
        _selectedWarehouseId = widget.anomaly.locationRegistryId ??
            _hydratedLocationRegistryId ??
            int.tryParse(
                ref.read(currentUserProvider)?.assignedWarehouse ?? '');
      });
    } catch (e) {
      debugPrint('[ActionHeroPanel] injection context hydration failed: $e');
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _goodController.dispose();
    _damagedController.dispose();
    _maintenanceController.dispose();
    _lostController.dispose();
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void _inc(TextEditingController c) => setState(() {
        c.text = (_int(c) + 1).toString();
      });

  void _dec(TextEditingController c) => setState(() {
        if (_int(c) > 0) c.text = (_int(c) - 1).toString();
      });

  Future<void> _handleRestock() async {
    final goodQty = _int(_goodController);
    final damagedQty = _int(_damagedController);
    final maintQty = _int(_maintenanceController);
    final lostQty = _int(_lostController);
    final total = goodQty + damagedQty + maintQty + lostQty;

    if (total <= 0 || _a.inventoryId == null) {
      TopNotice.show(
        context,
        message: 'Please enter stock amounts first.',
        type: TopNoticeType.warning,
      );
      return;
    }

    if (_selectedWarehouseId == null) {
      TopNotice.show(
        context,
        message: 'Select a location first.',
        type: TopNoticeType.warning,
      );
      return;
    }

    late final List<StorageHub> hubs;
    try {
      hubs = await ref.read(managerStorageHubsProvider.future);
    } catch (_) {
      if (mounted) {
        TopNotice.show(
          context,
          message: 'Could not load locations. Try again.',
          type: TopNoticeType.error,
        );
      }
      return;
    }

    if (!mounted) return;

    final rowLoc = _rowLocationRegistryId;
    final injectionHubId = rowLoc ?? _selectedWarehouseId!;
    final hubDisplayName = _hubLabel(hubs, injectionHubId);
    final previewHubName = _hubLabel(hubs, _selectedWarehouseId);

    final previewMismatch = rowLoc != null &&
        _selectedWarehouseId != null &&
        rowLoc != _selectedWarehouseId;

    final confirmed = await showInjectionConfirmDialog(
      context,
      itemName: _a.itemName,
      inventoryId: _a.inventoryId,
      hubDisplayName: hubDisplayName,
      previewHubName: previewHubName,
      previewMismatch: previewMismatch,
      goodQty: goodQty,
      damagedQty: damagedQty,
      maintQty: maintQty,
      lostQty: lostQty,
      total: total,
    );

    if (confirmed != true || !mounted) return;

    await _executeRestock(
      total: total,
      goodQty: goodQty,
      damagedQty: damagedQty,
      maintQty: maintQty,
      lostQty: lostQty,
    );
  }

  Future<void> _executeRestock({
    required int total,
    required int goodQty,
    required int damagedQty,
    required int maintQty,
    required int lostQty,
  }) async {
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
        TopNotice.show(
          context,
          message: 'Added $total units.',
          type: TopNoticeType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        TopNotice.show(
          context,
          message: 'Could not add stock: $e',
          type: TopNoticeType.error,
        );
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
        TopNotice.show(
          context,
          message: 'Health triage saved.',
          type: TopNoticeType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        TopNotice.show(
          context,
          message: 'Triage update failed.',
          type: TopNoticeType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Changing preview away from this alert's hub requires confirmation.
  Future<void> _handleWarehouseChanged(int? nextId) async {
    final rowLoc = _rowLocationRegistryId;
    final diverges =
        rowLoc != null && nextId != null && nextId != rowLoc;

    if (!diverges) {
      setState(() => _selectedWarehouseId = nextId);
      return;
    }

    late final List<StorageHub> hubs;
    try {
      hubs = await ref.read(managerStorageHubsProvider.future);
    } catch (_) {
      if (mounted) {
        TopNotice.show(
          context,
          message: 'Could not load location names.',
          type: TopNoticeType.error,
        );
      }
      return;
    }

    if (!mounted) return;

    final previewName = _hubLabel(hubs, nextId);
    final alertHubName = _hubLabel(hubs, rowLoc);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.34),
      builder: (ctx) {
        final onyx = const Color(0xFF001A33);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: onyx.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: onyx.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warehouse_rounded,
                            size: 18,
                            color: onyx,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'You switched location',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: onyx,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      'Quick check before you continue.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onyx.withOpacity(0.56),
                      ),
                    ),
                    const Gap(14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: onyx.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location you are viewing now',
                            style: GoogleFonts.lexend(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: onyx.withOpacity(0.45),
                              letterSpacing: 0.7,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            previewName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: onyx,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            'Location this alert belongs to',
                            style: GoogleFonts.lexend(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: onyx.withOpacity(0.45),
                              letterSpacing: 0.7,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            alertHubName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: onyx,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        'You are viewing "$previewName".\nStock will be added to "$alertHubName".',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onyx.withOpacity(0.84),
                          height: 1.35,
                        ),
                      ),
                    ),
                    const Gap(18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: onyx.withOpacity(0.14)),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w800,
                                color: onyx.withOpacity(0.62),
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(ctx, true),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text(
                              'Continue',
                              style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: onyx,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      setState(() => _selectedWarehouseId = nextId);
    } else {
      setState(() {});
      TopNotice.show(
        context,
        message: 'Preview unchanged. This alert stays at $alertHubName.',
        type: TopNoticeType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final showToggle = _a.category == AnomalyCategory.depletion && _hasHealthIssue;

    return TacticalForensicDetailSheet(
      id: _a.id,
      title: _a.itemName,
      statusLabel: _mode == ActionMode.restock ? 'LOW STOCK' : 'HEALTH TRIAGE',
      accentColor:
          _mode == ActionMode.restock ? Colors.orange : AppTheme.errorRed,
      statusIcon: _mode == ActionMode.restock
          ? Icons.inventory_2_rounded
          : Icons.medical_services_rounded,
      imagePath: _a.imageUrl,
      heroTagPrefix: 'anomaly',
      categoryLabel: _a.category.name.toUpperCase(),
      details: const [],
      analystNotes: null,
      actionHub: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showToggle) ...[
            AnomalySharedUI.buildModeToggle(
              sentinel: sentinel,
              currentMode: _mode,
              onRestock: () => setState(() => _mode = ActionMode.restock),
              onTriage: () => setState(() => _mode = ActionMode.triage),
            ),
            const Gap(16),
          ],
          HubDeploymentContext(
            selectedWarehouseId: _selectedWarehouseId,
            snapshotItemId: _snapshotItemId,
            onWarehouseChanged: (id) {
              _handleWarehouseChanged(id);
            },
          ),
          const Gap(16),
          if (_mode == ActionMode.restock)
            _buildRestockBody(sentinel)
          else
            _buildTriageBody(sentinel),
        ],
      ),
    );
  }

  Widget _buildRestockBody(LigtasColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnomalyStrategicOverview(anomaly: _a),
        const Gap(16),
        Text(
          'Add stock amounts',
          style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: sentinel.onSurfaceVariant.withOpacity(0.5),
              letterSpacing: 1.0),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
                child: TacticalStepper(
                    label: 'GOOD',
                    controller: _goodController,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.emeraldGreen,
                    onIncrement: () => _inc(_goodController),
                    onDecrement: () => _dec(_goodController))),
            const Gap(10),
            Expanded(
                child: TacticalStepper(
                    label: 'DAMAGED',
                    controller: _damagedController,
                    icon: Icons.favorite_border_rounded,
                    color: Colors.orangeAccent,
                    onIncrement: () => _inc(_damagedController),
                    onDecrement: () => _dec(_damagedController))),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
                child: TacticalStepper(
                    label: 'NEEDS REPAIR',
                    controller: _maintenanceController,
                    icon: Icons.build_outlined,
                    color: AppTheme.warningAmber,
                    onIncrement: () => _inc(_maintenanceController),
                    onDecrement: () => _dec(_maintenanceController))),
            const Gap(10),
            Expanded(
                child: TacticalStepper(
                    label: 'LOST / MISSING',
                    controller: _lostController,
                    icon: Icons.history_rounded,
                    color: AppTheme.errorRed,
                    onIncrement: () => _inc(_lostController),
                    onDecrement: () => _dec(_lostController))),
          ],
        ),
        const Gap(16),
        AnomalySharedUI.buildConfirmButton(
          sentinel: sentinel,
          label: 'Add stock',
          icon: Icons.send_rounded,
          isProcessing: _isProcessing,
          onPressed: _handleRestock,
        ),
      ],
    );
  }

  Widget _buildTriageBody(LigtasColors sentinel) {
    final total = _int(_goodController) +
        _int(_damagedController) +
        _int(_maintenanceController) +
        _int(_lostController);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRIAGE DISTRIBUTION',
          style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: sentinel.onSurfaceVariant.withOpacity(0.5),
              letterSpacing: 1.0),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
                child: TacticalStepper(
                    label: 'GOOD',
                    controller: _goodController,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.emeraldGreen,
                    onIncrement: () => _inc(_goodController),
                    onDecrement: () => _dec(_goodController))),
            const Gap(10),
            Expanded(
                child: TacticalStepper(
                    label: 'DAMAGED',
                    controller: _damagedController,
                    icon: Icons.favorite_border_rounded,
                    color: Colors.orangeAccent,
                    onIncrement: () => _inc(_damagedController),
                    onDecrement: () => _dec(_damagedController))),
          ],
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
                child: TacticalStepper(
                    label: 'MAINTENANCE',
                    controller: _maintenanceController,
                    icon: Icons.build_outlined,
                    color: AppTheme.warningAmber,
                    onIncrement: () => _inc(_maintenanceController),
                    onDecrement: () => _dec(_maintenanceController))),
            const Gap(10),
            Expanded(
                child: TacticalStepper(
                    label: 'LOST',
                    controller: _lostController,
                    icon: Icons.history_rounded,
                    color: AppTheme.errorRed,
                    onIncrement: () => _inc(_lostController),
                    onDecrement: () => _dec(_lostController))),
          ],
        ),
        const Gap(12),
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
              Text(
                'COMPUTED TOTAL',
                style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5),
              ),
              Text(
                '$total Units',
                style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF001A33)),
              ),
            ],
          ),
        ),
        const Gap(24),
        AnomalySharedUI.buildConfirmButton(
          sentinel: sentinel,
          label: 'SAVE HEALTH TRIAGE',
          icon: Icons.medical_services_rounded,
          isProcessing: _isProcessing,
          onPressed: _handleTriage,
        ),
      ],
    );
  }
}
