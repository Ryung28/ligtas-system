import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import '../shared/form_fields.dart';

/// Metadata + bucket edit form. Shows a loading spinner while admin fields are
/// being fetched; once ready, hydrates its local controllers via [ref.listen].
class EditForm extends ConsumerStatefulWidget {
  final InventoryItem item;

  const EditForm({super.key, required this.item});

  @override
  ConsumerState<EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<EditForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(managerActionControllerProvider(widget.item));
    _nameCtrl = TextEditingController(text: s.itemName);
    _categoryCtrl = TextEditingController(text: s.category);
    _modelCtrl = TextEditingController(text: s.model);
    _targetCtrl = TextEditingController(text: s.targetStock.toString());
    _minCtrl = TextEditingController(text: s.minStock.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _categoryCtrl.dispose();
    _modelCtrl.dispose(); _targetCtrl.dispose(); _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final ctrl = ref.read(managerActionControllerProvider(widget.item).notifier);
    final s = ref.watch(managerActionControllerProvider(widget.item));

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
              'Loading equipment details...',
              style: GoogleFonts.lexend(
                  fontSize: 12, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Equipment Identity ──────────────────────────────────────────────
        Text(
          'EQUIPMENT IDENTITY',
          style: GoogleFonts.lexend(
              fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.carbonGray),
        ),
        const Gap(12),
        SheetTextField(label: 'NAME', hint: 'e.g. Motorola XPR', controller: _nameCtrl, onChanged: ctrl.setItemName),
        const Gap(12),
        _CategoryDropdown(item: widget.item),
        const Gap(12),
        SheetTextField(label: 'MODEL', hint: 'e.g. X-Series', controller: _modelCtrl, onChanged: ctrl.setModel),
        const Gap(12),
        Row(
          children: [
            Expanded(child: SheetNumberField(label: 'TARGET', hint: '0', controller: _targetCtrl, onChanged: ctrl.setTargetStock)),
            const Gap(10),
            Expanded(child: SheetNumberField(label: 'THRESHOLD', hint: '0', controller: _minCtrl, onChanged: ctrl.setMinStock)),
          ],
        ),
        const Gap(24),

        // ── Fleet Map ───────────────────────────────────────────────────────
        if (widget.item.variants.isNotEmpty) ...[
          _FleetMap(item: widget.item, sentinel: sentinel),
          const Gap(16),
        ],
      ],
    );
  }
}

class _CategoryDropdown extends ConsumerWidget {
  final InventoryItem item;

  const _CategoryDropdown({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;
    final ctrl = ref.read(managerActionControllerProvider(item).notifier);
    final selectedCategory = ref.watch(
      managerActionControllerProvider(item).select((s) => s.category),
    );
    final categories = ref.watch(inventoryCategoriesProvider)
        .where((c) => c != 'All')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: GoogleFonts.lexend(
              fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.carbonGray.withOpacity(0.8)),
        ),
        const Gap(8),
        DropdownButtonFormField<String>(
          value: categories.contains(selectedCategory) ? selectedCategory : null,
          icon: Icon(Icons.arrow_drop_down_rounded, color: sentinel.primary),
          decoration: InputDecoration(
            filled: true,
            fillColor: sentinel.containerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          hint: Text(
            'Select Category...',
            style: GoogleFonts.plusJakartaSans(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          items: categories.map((cat) => DropdownMenuItem<String>(
            value: cat,
            child: Row(
              children: [
                Icon(ref.watch(categoryIconProvider(cat)), size: 16, color: AppTheme.onyxBlack.withOpacity(0.8)),
                const Gap(12),
                Text(cat.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.onyxBlack)),
              ],
            ),
          )).toList(),
          onChanged: (v) { if (v != null) ctrl.setCategory(v); },
        ),
      ],
    );
  }
}

String _siteHealthCaption(int damaged, int maintenance, int lost) {
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
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: sentinel.containerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── MAIN HUB SNAPSHOT ──
              _LocationRow(
                location: '${item.location} · MAIN',
                avail: item.availableStock,
                total: item.totalStock,
                qtyDamaged: item.qtyDamaged,
                qtyMaintenance: item.qtyMaintenance,
                qtyLost: item.qtyLost,
              ),
              const Gap(16),
              // ── OTHER VARIANTS ──
              ...item.variants.map((v) {
                final isLast = item.variants.last == v;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: _LocationRow(
                    location: v.location,
                    avail: v.stockAvailable,
                    total: v.stockTotal,
                    qtyDamaged: v.qtyDamaged,
                    qtyMaintenance: v.qtyMaintenance,
                    qtyLost: v.qtyLost,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String location;
  final int avail;
  final int total;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;

  const _LocationRow({
    required this.location,
    required this.avail,
    required this.total,
    required this.qtyDamaged,
    required this.qtyMaintenance,
    required this.qtyLost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onyxBlack,
                  letterSpacing: -0.3,
                ),
              ),
              const Gap(4),
              if (qtyDamaged > 0 || qtyMaintenance > 0 || qtyLost > 0)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (qtyDamaged > 0)
                      _HealthIndicator(
                        label: 'DAMAGED',
                        count: qtyDamaged,
                        color: AppTheme.errorRed,
                      ),
                    if (qtyMaintenance > 0)
                      _HealthIndicator(
                        label: 'MAINT.',
                        count: qtyMaintenance,
                        color: AppTheme.warningOrange,
                      ),
                    if (qtyLost > 0)
                      _HealthIndicator(
                        label: 'LOST',
                        count: qtyLost,
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
                    text: '$avail',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: ' / $total',
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
