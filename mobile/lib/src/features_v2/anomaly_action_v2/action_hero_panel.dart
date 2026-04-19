import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
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
          .select('location_registry_id, item_id')
          .eq('id', invId)
          .maybeSingle();

      if (!mounted || row == null) return;

      setState(() {
        _hydratedLocationRegistryId =
            (row['location_registry_id'] as num?)?.toInt();
        _hydratedItemId = (row['item_id'] as num?)?.toInt();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter injection quantities.')));
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Injection hub could not be resolved.')));
      return;
    }

    late final List<StorageHub> hubs;
    try {
      hubs = await ref.read(managerStorageHubsProvider.future);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not load hubs for confirmation. Try again.')));
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
            rowLocationRegistryId: _rowLocationRegistryId,
            snapshotItemId: _snapshotItemId,
            onWarehouseChanged: (id) =>
                setState(() => _selectedWarehouseId = id),
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
          'INJECTION QUANTITIES',
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
                    label: 'GOOD STOCK',
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
                    label: 'LOST/SHRINK',
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
          label: 'CONFIRM INJECTION',
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
