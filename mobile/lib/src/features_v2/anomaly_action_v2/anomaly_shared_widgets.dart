import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_prefill_provider.dart';
import 'package:mobile/src/features/analyst_dashboard/presentation/controllers/analyst_dashboard_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';

import 'anomaly_action_mode.dart';

class AnomalySharedUI {
  static Widget buildConfirmButton({
    required LigtasColors sentinel,
    required String label,
    required IconData icon,
    required bool isProcessing,
    required VoidCallback onPressed,
  }) {
    const navy = Color(0xFF001A33);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isProcessing ? navy.withOpacity(0.7) : navy,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isProcessing ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: navy.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: isProcessing
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

  static Widget buildModeToggle({
    required LigtasColors sentinel,
    required ActionMode currentMode,
    required VoidCallback onRestock,
    required VoidCallback onTriage,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: sentinel.containerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: Row(
        children: [
          _toggleSegment('RESTOCK', currentMode == ActionMode.restock,
              sentinel.navy, onRestock),
          _toggleSegment('HEALTH TRIAGE', currentMode == ActionMode.triage,
              AppTheme.errorRed, onTriage),
        ],
      ),
    );
  }

  static Widget _toggleSegment(
      String label, bool isActive, Color color, VoidCallback onTap) {
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
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isActive ? color : Colors.black38,
                  letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  static BoxDecoration premiumShadow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4)),
      ],
    );
  }

  static String hubLabel(List<StorageHub> hubs, int? id) {
    if (id == null) return 'Unknown location';
    for (final h in hubs) {
      if (h.id == id) return h.name;
    }
    return 'Location #$id';
  }
}

class TacticalStepper extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const TacticalStepper({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.color,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    const onyx = Color(0xFF001A33);
    final val = int.tryParse(controller.text.trim()) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.lexend(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5)),
              Icon(icon, size: 12, color: color),
            ],
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepperBtn(Icons.remove_rounded, onDecrement, onyx, false),
              Text(val.toString().padLeft(2, '0'),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: onyx)),
              _stepperBtn(Icons.add_rounded, onIncrement, onyx, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn(
      IconData icon, VoidCallback onTap, Color onyx, bool isPrimary) {
    return Material(
      color: isPrimary ? onyx : onyx.withOpacity(0.05),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon,
              size: 14, color: isPrimary ? Colors.white : onyx),
        ),
      ),
    );
  }
}

/// Injection hub dropdown + optional ledger preview (parity with monolith hub section).
class HubDeploymentContext extends ConsumerWidget {
  final int? selectedWarehouseId;
  final int? rowLocationRegistryId;
  final ValueChanged<int?> onWarehouseChanged;
  final int? snapshotItemId;

  const HubDeploymentContext({
    super.key,
    required this.selectedWarehouseId,
    required this.rowLocationRegistryId,
    required this.onWarehouseChanged,
    required this.snapshotItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final onyx = const Color(0xFF001A33);
    final hubsAsync = ref.watch(managerStorageHubsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INJECTION HUB',
          style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: sentinel.onSurfaceVariant.withOpacity(0.5),
              letterSpacing: 1.0),
        ),
        const Gap(12),
        hubsAsync.when(
          data: (hubs) {
            final showCurrent =
                rowLocationRegistryId != null || selectedWarehouseId != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCurrent) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF0EA5E9).withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 20,
                            color: sentinel.navy.withOpacity(0.7)),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT LOCATION (THIS ALERT)',
                                  style: GoogleFonts.lexend(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: onyx.withOpacity(0.45),
                                    letterSpacing: 0.6,
                                  )),
                              const Gap(4),
                              Text(
                                AnomalySharedUI.hubLabel(
                                  hubs,
                                  rowLocationRegistryId ?? selectedWarehouseId,
                                ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: onyx,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                ],
                Container(
                  decoration: AnomalySharedUI.premiumShadow(),
                  child: DropdownButtonFormField<int>(
                    value: hubs.any((h) => h.id == selectedWarehouseId)
                        ? selectedWarehouseId
                        : null,
                    icon:
                        Icon(Icons.arrow_drop_down_rounded, color: sentinel.navy),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.warehouse_rounded,
                          size: 18, color: sentinel.navy.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                    items: hubs
                        .map((h) => DropdownMenuItem<int>(
                              value: h.id,
                              child: Text(h.name,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                    onChanged: onWarehouseChanged,
                    hint: Text(
                      'Preview another hub (optional)…',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: Colors.black26),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Failed to load hubs'),
        ),
        const Gap(12),
        _HubLedgerPreview(
          sentinel: sentinel,
          itemId: snapshotItemId,
          warehouseId: selectedWarehouseId,
        ),
      ],
    );
  }
}

class _HubLedgerPreview extends ConsumerWidget {
  final LigtasColors sentinel;
  final int? itemId;
  final int? warehouseId;

  const _HubLedgerPreview({
    required this.sentinel,
    required this.itemId,
    required this.warehouseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null || warehouseId == null) {
      return const SizedBox.shrink();
    }

    final snapshot = ref.watch(hubStockSnapshotProvider(
      itemId: itemId!,
      warehouseId: warehouseId!,
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
                Icon(Icons.info_outline_rounded,
                    size: 14, color: sentinel.navy.withOpacity(0.4)),
                const Gap(8),
                Text(
                  'No existing stock found at this hub.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sentinel.navy.withOpacity(0.4)),
                ),
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
              Text(
                'HUB LEDGER (CURRENT HOLDINGS)',
                style: GoogleFonts.lexend(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5),
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _snapshotItem(
                      'GOOD', data['good'] ?? 0, AppTheme.emeraldGreen),
                  _snapshotItem(
                      'DMG', data['damaged'] ?? 0, Colors.orangeAccent),
                  _snapshotItem(
                      'MNT', data['maintenance'] ?? 0, AppTheme.warningAmber),
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
    const onyx = Color(0xFF001A33);
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: statusColor),
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
}
