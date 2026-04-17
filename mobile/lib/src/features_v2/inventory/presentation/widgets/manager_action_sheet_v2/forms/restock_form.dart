import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_prefill_provider.dart';
import '../shared/form_fields.dart';

/// Add-stock form.
///
/// On mount it triggers [ManagerActionController._loadEditFields] (via the
/// controller's setMode logic) so the bucket fields are seeded with real DB
/// values instead of entity approximations.  A read-only condition snapshot
/// and fleet map sit above the editable buckets so the manager sees current
/// state before changing anything.
class RestockForm extends ConsumerStatefulWidget {
  final InventoryItem item;

  const RestockForm({super.key, required this.item});

  @override
  ConsumerState<RestockForm> createState() => _RestockFormState();
}

class _RestockFormState extends ConsumerState<RestockForm> {
  late final TextEditingController _goodCtrl;
  late final TextEditingController _damagedCtrl;
  late final TextEditingController _maintenanceCtrl;
  late final TextEditingController _lostCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(managerActionControllerProvider(widget.item));
    _goodCtrl = TextEditingController(text: s.qtyGood.toString());
    _damagedCtrl = TextEditingController(text: s.qtyDamaged.toString());
    _maintenanceCtrl = TextEditingController(text: s.qtyMaintenance.toString());
    _lostCtrl = TextEditingController(text: s.qtyLost.toString());
  }

  @override
  void dispose() {
    _goodCtrl.dispose();
    _damagedCtrl.dispose();
    _maintenanceCtrl.dispose();
    _lostCtrl.dispose();
    super.dispose();
  }

  /// Called once admin fields finish loading — syncs local controllers to the
  /// freshly fetched DB values so the bucket editor starts with real numbers.
  void _syncBucketsFromState() {
    final s = ref.read(managerActionControllerProvider(widget.item));
    _goodCtrl.text = s.qtyGood.toString();
    _damagedCtrl.text = s.qtyDamaged.toString();
    _maintenanceCtrl.text = s.qtyMaintenance.toString();
    _lostCtrl.text = s.qtyLost.toString();
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final ctrl = ref.read(managerActionControllerProvider(widget.item).notifier);
    final s = ref.watch(managerActionControllerProvider(widget.item));

    // Sync bucket controllers when loading transitions from true → false.
    ref.listen(
      managerActionControllerProvider(widget.item).select((st) => st.isEditLoading),
      (prev, next) {
        if (prev == true && next == false) _syncBucketsFromState();
      },
    );

    if (s.isEditLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: sentinel.primary),
            ),
            const Gap(12),
            Text(
              'Loading current stock data...',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: sentinel.navy.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final total = s.qtyGood + s.qtyDamaged + s.qtyMaintenance + s.qtyLost;

    // Snapshot is only valid when the selected hub IS the item's home hub.
    // Primary: compare storage location strings — always populated even with stale Isar.
    //   fetchAdminFields sets s.storageLocation to the raw DB value ("Boom Truck", "lower_warehouse", etc.)
    //   widget.item.location comes from active_inventory `storage_location AS location` — same value.
    //   If the manager selects a different hub, setLocationRegistry writes the hub's display name
    //   which won't match the raw storage_location string → correctly shows empty state.
    // Secondary: registry ID match once both sides are non-null (works after cache refresh).
    final locationStringMatch = s.storageLocation.isNotEmpty &&
        widget.item.location.isNotEmpty &&
        s.storageLocation == widget.item.location;
    final registryMatch = s.locationRegistryId != null &&
        widget.item.locationRegistryId != null &&
        s.locationRegistryId == widget.item.locationRegistryId;
    final isHomeHub = locationStringMatch || registryMatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LocationDropdown(item: widget.item),
        const Gap(16),

        // ── Current Condition Snapshot (read-only reference) ────────────────
        _ConditionSnapshot(
          qtyGood: s.qtyGood,
          qtyDamaged: s.qtyDamaged,
          qtyMaintenance: s.qtyMaintenance,
          qtyLost: s.qtyLost,
          location: s.storageLocation,
          sentinel: sentinel,
          hasStockAtLocation: isHomeHub && total > 0,
        ),
        const Gap(12),

        // ── Multi-hub fleet map ─────────────────────────────────────────────
        if (widget.item.variants.isNotEmpty) ...[
          _FleetMap(item: widget.item, sentinel: sentinel),
          const Gap(12),
        ],

        // ── Editable bucket distribution ────────────────────────────────────
        Text(
          'UPDATE STOCK DISTRIBUTION',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.carbonGray,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: SheetNumberField(
                label: 'GOOD',
                hint: '0',
                controller: _goodCtrl,
                statusColor: AppTheme.successGreen,
                onChanged: (v) => ctrl.setQtyGood(int.tryParse(v) ?? 0),
              ),
            ),
            const Gap(10),
            Expanded(
              child: SheetNumberField(
                label: 'DAMAGED',
                hint: '0',
                controller: _damagedCtrl,
                statusColor: AppTheme.errorRed,
                onChanged: (v) => ctrl.setQtyDamaged(int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: SheetNumberField(
                label: 'MAINTENANCE',
                hint: '0',
                controller: _maintenanceCtrl,
                statusColor: AppTheme.warningAmber,
                onChanged: (v) => ctrl.setQtyMaintenance(int.tryParse(v) ?? 0),
              ),
            ),
            const Gap(10),
            Expanded(
              child: SheetNumberField(
                label: 'LOST',
                hint: '0',
                controller: _lostCtrl,
                statusColor: AppTheme.carbonGray,
                onChanged: (v) => ctrl.setQtyLost(int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ),
        const Gap(12),
        Text(
          'SITE TOTAL: $total',
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.carbonGray.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        const Gap(24),
      ],
    );
  }
}

// ── Read-only condition snapshot ─────────────────────────────────────────────

class _ConditionSnapshot extends StatelessWidget {
  final int qtyGood;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;
  final String location;
  final SentinelColors sentinel;
  /// False when a different hub is selected or total is 0 — forces empty state.
  final bool hasStockAtLocation;

  const _ConditionSnapshot({
    required this.qtyGood,
    required this.qtyDamaged,
    required this.qtyMaintenance,
    required this.qtyLost,
    required this.location,
    required this.sentinel,
    required this.hasStockAtLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.onyxBlack.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 12, color: sentinel.navy.withOpacity(0.5)),
              const Gap(6),
              Text(
                'CURRENT CONDITION',
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: sentinel.navy.withOpacity(0.5),
                  letterSpacing: 0.8,
                ),
              ),
              if (location.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sentinel.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, size: 9, color: sentinel.primary),
                      const Gap(3),
                      Text(
                        location.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: sentinel.navy,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Gap(12),
          if (!hasStockAtLocation) ...[
            // Empty state — different hub selected or location has no stock
            Row(
              children: [
                Icon(Icons.inbox_outlined, size: 14, color: AppTheme.carbonGray.withOpacity(0.4)),
                const Gap(8),
                Text(
                  'No stock recorded at this location',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.carbonGray.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ConditionPill('GOOD', qtyGood, AppTheme.successGreen),
                _ConditionPill('DAMAGED', qtyDamaged, AppTheme.errorRed),
                _ConditionPill('MAINT.', qtyMaintenance, AppTheme.warningAmber),
                _ConditionPill('LOST', qtyLost, AppTheme.carbonGray),
              ],
            ),
            const Gap(10),
            // Proportional condition bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 5,
                child: Row(
                  children: [
                    if (qtyGood > 0)
                      Expanded(flex: qtyGood, child: Container(color: AppTheme.successGreen)),
                    if (qtyDamaged > 0)
                      Expanded(flex: qtyDamaged, child: Container(color: AppTheme.errorRed)),
                    if (qtyMaintenance > 0)
                      Expanded(flex: qtyMaintenance, child: Container(color: AppTheme.warningAmber)),
                    if (qtyLost > 0)
                      Expanded(flex: qtyLost, child: Container(color: AppTheme.carbonGray.withOpacity(0.5))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConditionPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ConditionPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const Gap(4),
        Text(
          value.toString(),
          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900, color: color),
        ),
        const Gap(2),
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 7.5, fontWeight: FontWeight.w800, color: AppTheme.carbonGray),
        ),
      ],
    );
  }
}

// ── Multi-hub fleet map ───────────────────────────────────────────────────────

String _restockSiteHealthCaption(int damaged, int maintenance, int lost) {
  if (damaged == 0 && maintenance == 0 && lost == 0) return 'All units serviceable at this site';
  final parts = <String>[];
  if (damaged > 0) parts.add('$damaged damaged');
  if (maintenance > 0) parts.add('$maintenance maintenance');
  if (lost > 0) parts.add('$lost lost');
  return parts.join(' · ');
}

class _FleetMap extends StatelessWidget {
  final InventoryItem item;
  final SentinelColors sentinel;

  const _FleetMap({required this.item, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 11, color: sentinel.primary),
            const Gap(6),
            Text(
              'EQUIPMENT LOCATION',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: sentinel.navy.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: sentinel.containerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: item.variants.map((v) {
              final isLast = item.variants.last == v;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── COLUMN 1: SUBJECT & STATE ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.location.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onyxBlack,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Gap(4),
                          if (v.qtyDamaged > 0 || v.qtyMaintenance > 0 || v.qtyLost > 0)
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (v.qtyDamaged > 0)
                                  _HealthIndicator(
                                    label: 'DAMAGED',
                                    count: v.qtyDamaged,
                                    color: AppTheme.errorRed,
                                  ),
                                if (v.qtyMaintenance > 0)
                                  _HealthIndicator(
                                    label: 'MAINT.',
                                    count: v.qtyMaintenance,
                                    color: AppTheme.warningOrange,
                                  ),
                                if (v.qtyLost > 0)
                                  _HealthIndicator(
                                    label: 'LOST',
                                    count: v.qtyLost,
                                    color: AppTheme.neutralGray500,
                                  ),
                              ],
                            )
                          else
                            Text(
                              'ALL UNITS SERVICEABLE',
                              style: GoogleFonts.lexend(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.successGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Gap(12),

                    // ── COLUMN 2: CAPACITY readout ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: AppTheme.onyxBlack,
                            ),
                            children: [
                              TextSpan(
                                text: '${v.stockAvailable}',
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              TextSpan(
                                text: ' / ${v.stockTotal}',
                                style: TextStyle(
                                  color: AppTheme.carbonGray.withOpacity(0.5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'AVAIL / TOTAL',
                          style: GoogleFonts.lexend(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.carbonGray.withOpacity(0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _HealthIndicator({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const Gap(6),
        Text(
          '$count $label',
          style: GoogleFonts.lexend(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _LocationDropdown extends ConsumerWidget {
  final InventoryItem item;

  const _LocationDropdown({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final ctrl = ref.read(managerActionControllerProvider(item).notifier);
    final selectedId = ref.watch(
      managerActionControllerProvider(item).select((s) => s.locationRegistryId),
    );
    final hubsAsync = ref.watch(managerStorageHubsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STORAGE HUB',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.carbonGray.withOpacity(0.8),
          ),
        ),
        const Gap(8),
        hubsAsync.when(
          data: (hubs) {
            final safeValue = hubs.any((h) => h.id == selectedId) ? selectedId : null;
            return DropdownButtonFormField<int>(
              value: safeValue,
              icon: Icon(Icons.arrow_drop_down_rounded, color: sentinel.primary),
              decoration: InputDecoration(
                filled: true,
                fillColor: sentinel.containerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text(
                'Select Terminal... ▼',
                style: GoogleFonts.plusJakartaSans(
                  color: sentinel.onSurfaceVariant.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('NONE',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.carbonGray)),
                ),
                ...hubs.map((hub) => DropdownMenuItem<int>(
                      value: hub.id,
                      child: Text(hub.name.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onyxBlack)),
                    )),
              ],
              onChanged: (val) => ctrl.setLocationRegistry(
                  val, val != null ? hubs.firstWhere((h) => h.id == val).name : ''),
            );
          },
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )),
          error: (e, _) => Text('Error loading hubs: $e'),
        ),
      ],
    );
  }
}
