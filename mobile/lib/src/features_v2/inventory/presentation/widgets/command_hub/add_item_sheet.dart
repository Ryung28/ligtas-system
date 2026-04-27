import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/core/utils/storage_utils.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({super.key});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _SiteDistribution {
  final int locationId;
  final String locationName;
  final int qtyGood;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;

  const _SiteDistribution({
    required this.locationId,
    required this.locationName,
    required this.qtyGood,
    required this.qtyDamaged,
    required this.qtyMaintenance,
    required this.qtyLost,
  });

  int get total => qtyGood + qtyDamaged + qtyMaintenance + qtyLost;
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _qtyGoodCtrl = TextEditingController(text: '1');
  final _qtyDamagedCtrl = TextEditingController(text: '0');
  final _qtyMaintenanceCtrl = TextEditingController(text: '0');
  final _qtyLostCtrl = TextEditingController(text: '0');
  final _unitCtrl = TextEditingController(text: 'pcs');
  final _targetCtrl = TextEditingController();
  final _minCtrl = TextEditingController(text: '20');
  
  String _selectedCategory = 'Logistics';
  String _selectedItemType = 'equipment';
  int? _selectedLocationId;
  DateTime? _expiryDate;
  bool _restockAlertEnabled = true;
  Uint8List? _compressedBytes;
  bool _submitting = false;
  final List<_SiteDistribution> _extraDistributions = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _serialCtrl.dispose();
    _modelCtrl.dispose();
    _qtyGoodCtrl.dispose();
    _qtyDamagedCtrl.dispose();
    _qtyMaintenanceCtrl.dispose();
    _qtyLostCtrl.dispose();
    _unitCtrl.dispose();
    _targetCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  int _safeInt(TextEditingController controller, {int fallback = 0}) {
    return int.tryParse(controller.text.trim()) ?? fallback;
  }

  int get _totalStock =>
      _safeInt(_qtyGoodCtrl) +
      _safeInt(_qtyDamagedCtrl) +
      _safeInt(_qtyMaintenanceCtrl) +
      _safeInt(_qtyLostCtrl);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 80);
      if (image == null) return;

      // Atomic Compression Sequence
      final bytes = await image.readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1024,
        minWidth: 1024,
        quality: 70,
      );
      
      setState(() => _compressedBytes = compressed);
      debugPrint('🛡️ Compression: ${bytes.length} -> ${compressed.length} bytes');
    } catch (e) {
      if (mounted) AppToast.showError(context, 'IMAGE CAPTURE FAILED');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sentinel = Theme.of(context).sentinel;
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: sentinel.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sentinel.onSurfaceVariant.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Gap(14),
                Text(
                  'SELECT IMAGE SOURCE',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.45,
                    color: sentinel.navy,
                  ),
                ),
                const Gap(4),
                Text(
                  'Choose where to get your item photo.',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: sentinel.onSurfaceVariant.withOpacity(0.72),
                  ),
                ),
                const Gap(14),
                _buildImageSourceAction(
                  icon: Icons.camera_alt_rounded,
                  title: 'CAMERA',
                  subtitle: 'Capture a new photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Gap(10),
                _buildImageSourceAction(
                  icon: Icons.photo_library_rounded,
                  title: 'GALLERY',
                  subtitle: 'Use an existing photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final sentinel = Theme.of(context).sentinel;
    return Material(
      color: sentinel.containerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sentinel.navy.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: sentinel.navy),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: sentinel.navy,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: sentinel.onSurfaceVariant.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: sentinel.navy.withOpacity(0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDistributionEditor({
    required List<StorageHub> hubs,
    _SiteDistribution? existing,
    int? editIndex,
  }) async {
    int? selectedLocationId = existing?.locationId;
    final qtyGoodCtrl = TextEditingController(text: (existing?.qtyGood ?? 0).toString());
    final qtyDamagedCtrl = TextEditingController(text: (existing?.qtyDamaged ?? 0).toString());
    final qtyMaintenanceCtrl = TextEditingController(text: (existing?.qtyMaintenance ?? 0).toString());
    final qtyLostCtrl = TextEditingController(text: (existing?.qtyLost ?? 0).toString());

    final result = await showModalBottomSheet<_SiteDistribution>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sentinel = Theme.of(context).sentinel;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
            final keyboardOpen = keyboardInset > 0;
            return SafeArea(
              top: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  offset: keyboardOpen ? Offset.zero : const Offset(0, 0.015),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.82,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    decoration: BoxDecoration(
                      color: sentinel.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            existing == null ? 'ADD DISTRIBUTION SITE' : 'EDIT DISTRIBUTION SITE',
                            style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900, color: sentinel.navy),
                          ),
                          const Gap(12),
                          DropdownButtonFormField<int>(
                            value: selectedLocationId,
                            decoration: _inputDecoration(context, 'WAREHOUSE'),
                            items: hubs
                                .map((h) => DropdownMenuItem(
                                      value: h.id,
                                      child: Text(h.name, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                            onChanged: (value) => setSheetState(() => selectedLocationId = value),
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              Expanded(child: _field(qtyGoodCtrl, 'GOOD', keyboard: TextInputType.number, required: true, labelColor: const Color(0xFF16A34A))),
                              const Gap(8),
                              Expanded(child: _field(qtyDamagedCtrl, 'DAMAGED', keyboard: TextInputType.number, labelColor: const Color(0xFFDC2626))),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(child: _field(qtyMaintenanceCtrl, 'MAINTENANCE', keyboard: TextInputType.number, labelColor: const Color(0xFFEA580C))),
                              const Gap(8),
                              Expanded(child: _field(qtyLostCtrl, 'LOST', keyboard: TextInputType.number, labelColor: const Color(0xFF6B7280))),
                            ],
                          ),
                          const Gap(12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                StorageHub? selectedHub;
                                for (final hub in hubs) {
                                  if (hub.id == selectedLocationId) {
                                    selectedHub = hub;
                                    break;
                                  }
                                }
                                final good = int.tryParse(qtyGoodCtrl.text.trim()) ?? 0;
                                final damaged = int.tryParse(qtyDamagedCtrl.text.trim()) ?? 0;
                                final maintenance = int.tryParse(qtyMaintenanceCtrl.text.trim()) ?? 0;
                                final lost = int.tryParse(qtyLostCtrl.text.trim()) ?? 0;
                                final total = good + damaged + maintenance + lost;
                                if (selectedHub == null) {
                                  AppToast.showError(context, 'SELECT A WAREHOUSE');
                                  return;
                                }
                                if (total < 1) {
                                  AppToast.showError(context, 'SITE TOTAL MUST BE AT LEAST 1');
                                  return;
                                }
                                Navigator.pop(
                                  context,
                                  _SiteDistribution(
                                    locationId: selectedHub.id,
                                    locationName: selectedHub.name,
                                    qtyGood: good,
                                    qtyDamaged: damaged,
                                    qtyMaintenance: maintenance,
                                    qtyLost: lost,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sentinel.navy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                existing == null ? 'ADD SITE' : 'SAVE SITE',
                                style: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      if (editIndex != null) {
        _extraDistributions[editIndex] = result;
      } else {
        _extraDistributions.add(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final categories = ref.watch(inventoryCategoriesProvider).where((c) => c != 'All').toList();
    final storageHubs = ref.watch(storageHubsProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: sentinel.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: sentinel.onSurfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  const Icon(Icons.add_box_rounded, size: 24),
                  const Gap(12),
                  Text(
                    'ADD ITEM',
                    style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w900, color: sentinel.navy, letterSpacing: -0.5),
                  ),
                ],
              ),
              const Gap(24),

              // ── PROFESSIONAL IMAGE PICKER ──
              _sectionLabel('ASSET IMAGE'),
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: sentinel.containerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.1)),
                    image: _compressedBytes != null 
                        ? DecorationImage(image: MemoryImage(_compressedBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _compressedBytes == null ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: sentinel.navy.withOpacity(0.4), size: 32),
                      const Gap(8),
                      Text(
                        'UPLOAD IMAGE',
                        style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.4), letterSpacing: 0.8),
                      ),
                    ],
                  ) : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: sentinel.navy.withOpacity(0.8),
                        radius: 14,
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(24),

              // ── IDENTITY MODULE ──
              _sectionLabel('IDENTITY'),
              _field(_nameCtrl, 'ITEM NAME', required: true),
              const Gap(16),
              _sectionLabel('ITEM TYPE'),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('EQUIPMENT'),
                      selected: _selectedItemType == 'equipment',
                      onSelected: (_) => setState(() => _selectedItemType = 'equipment'),
                      checkmarkColor: Colors.white,
                      labelStyle: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _selectedItemType == 'equipment'
                            ? Colors.white
                            : sentinel.navy.withOpacity(0.65),
                      ),
                      selectedColor: sentinel.navy,
                      backgroundColor: sentinel.containerLow,
                      side: BorderSide.none,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('CONSUMABLE'),
                      selected: _selectedItemType == 'consumable',
                      onSelected: (_) => setState(() => _selectedItemType = 'consumable'),
                      checkmarkColor: Colors.white,
                      labelStyle: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _selectedItemType == 'consumable'
                            ? Colors.white
                            : sentinel.navy.withOpacity(0.65),
                      ),
                      selectedColor: sentinel.navy,
                      backgroundColor: sentinel.containerLow,
                      side: BorderSide.none,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(child: _field(_serialCtrl, 'SERIAL NO')),
                  const Gap(12),
                  Expanded(child: _field(_modelCtrl, 'MODEL NO')),
                ],
              ),
              const Gap(12),
              _field(_brandCtrl, 'BRAND'),
              const Gap(24),

              // ── CATEGORY MATRIX ──
              _sectionLabel('CATEGORY'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    checkmarkColor: Colors.white,
                    labelStyle: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : sentinel.navy.withOpacity(0.6),
                    ),
                    selectedColor: sentinel.navy,
                    backgroundColor: sentinel.containerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  );
                }).toList(),
              ),
              const Gap(24),

              // ── STOCK BREAKDOWN ──
              _sectionLabel('STOCK BREAKDOWN'),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _qtyGoodCtrl,
                      'AVAILABLE',
                      keyboard: TextInputType.number,
                      required: true,
                      labelColor: const Color(0xFF16A34A),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _field(
                      _qtyDamagedCtrl,
                      'DAMAGED',
                      keyboard: TextInputType.number,
                      labelColor: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _qtyMaintenanceCtrl,
                      'IN MAINTENANCE',
                      keyboard: TextInputType.number,
                      labelColor: const Color(0xFFEA580C),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _field(
                      _qtyLostCtrl,
                      'LOST / MISSING',
                      keyboard: TextInputType.number,
                      labelColor: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sentinel.containerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.12)),
                ),
                child: Text(
                  'TOTAL STOCK: $_totalStock',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    color: sentinel.navy.withOpacity(0.85),
                  ),
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(child: _field(_targetCtrl, 'MAX STOCK GOAL', keyboard: TextInputType.number)),
                  const Gap(12),
                  Expanded(child: _field(_minCtrl, 'WARN AT (%)', keyboard: TextInputType.number)),
                ],
              ),
              const Gap(12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _restockAlertEnabled,
                onChanged: (value) => setState(() => _restockAlertEnabled = value),
                title: Text(
                  'ENABLE RESTOCK ALERT',
                  style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: sentinel.navy),
                ),
                subtitle: Text(
                  'Uses target and warning percentage to trigger alerts.',
                  style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: sentinel.onSurfaceVariant.withOpacity(0.7)),
                ),
              ),
              if (_selectedItemType == 'consumable') ...[
                const Gap(12),
                _sectionLabel('EXPIRY TRACKING'),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: sentinel.onSurfaceVariant.withOpacity(0.10)),
                  ),
                  tileColor: sentinel.containerLow,
                  title: Text(
                    _expiryDate == null
                        ? 'SELECT EXPIRY DATE'
                        : '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}',
                    style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  trailing: Icon(Icons.calendar_month_rounded, color: sentinel.navy),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setState(() => _expiryDate = picked);
                  },
                ),
              ],
              const Gap(24),

              // ── STORAGE PLOT ──
              _sectionLabel('STORAGE PLOT'),
              storageHubs.when(
                data: (hubs) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedLocationId,
                      onChanged: (val) => setState(() => _selectedLocationId = val),
                      validator: (val) => val == null ? 'SELECT A WAREHOUSE' : null,
                      decoration: _inputDecoration(context, 'PRIMARY WAREHOUSE'),
                      items: hubs
                          .map((h) => DropdownMenuItem(
                                value: h.id,
                                child: Text(h.name, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Additional Sites (${_extraDistributions.length})',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: sentinel.onSurfaceVariant.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openDistributionEditor(hubs: hubs),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                          label: Text(
                            'ADD SITE',
                            style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    if (_extraDistributions.isNotEmpty)
                      ..._extraDistributions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final dist = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: sentinel.containerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sentinel.onSurfaceVariant.withOpacity(0.12)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dist.locationName,
                                        style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, color: sentinel.navy),
                                      ),
                                      const Gap(2),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            'GOOD ${dist.qtyGood}',
                                            style: GoogleFonts.lexend(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF16A34A),
                                            ),
                                          ),
                                          Text(
                                            'MAINT ${dist.qtyMaintenance}',
                                            style: GoogleFonts.lexend(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFEA580C),
                                            ),
                                          ),
                                          Text(
                                            'DAMAGE ${dist.qtyDamaged}',
                                            style: GoogleFonts.lexend(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFDC2626),
                                            ),
                                          ),
                                          Text(
                                            'LOST ${dist.qtyLost}',
                                            style: GoogleFonts.lexend(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                          Text(
                                            'TOTAL ${dist.total}',
                                            style: GoogleFonts.lexend(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: sentinel.navy,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _openDistributionEditor(
                                    hubs: hubs,
                                    existing: dist,
                                    editIndex: idx,
                                  ),
                                  icon: Icon(Icons.edit_outlined, size: 18, color: sentinel.navy),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _extraDistributions.removeAt(idx)),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => _field(TextEditingController(), 'ERROR LOADING HUBS'),
              ),
              const Gap(32),

              // ── INITIATE SEQUENCE ──
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sentinel.navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_submitting ? Icons.sync : Icons.send_rounded, color: Colors.white, size: 18),
                      const Gap(12),
                      Text(
                        _submitting ? 'INITIATING...' : 'CREATE ITEM',
                        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final sentinel = Theme.of(context).sentinel;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.onSurfaceVariant.withOpacity(0.5), letterSpacing: 1.2),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label, {
    Color? labelColor,
  }) {
    final sentinel = Theme.of(context).sentinel;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lexend(
        color: labelColor ?? sentinel.onSurfaceVariant.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: sentinel.containerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: sentinel.onSurfaceVariant.withOpacity(0.10), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: sentinel.onSurfaceVariant.withOpacity(0.10), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: sentinel.navy.withOpacity(0.45), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    Color? labelColor,
  }) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: sentinel.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'REQUIRED' : null : null,
        decoration: _inputDecoration(context, label, labelColor: labelColor),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final totalStock = _totalStock;
    final thresholdPercent = _safeInt(_minCtrl, fallback: 20);
    if (totalStock < 1) {
      AppToast.showError(context, 'TOTAL STOCK MUST BE AT LEAST 1');
      return;
    }
    if (thresholdPercent < 0 || thresholdPercent > 100) {
      AppToast.showError(context, 'WARN AT (%) MUST BE 0-100');
      return;
    }
    setState(() => _submitting = true);
    
    try {
      String? remoteImagePath;
      
      // 🛡️ ATOMIC UPLOAD: Handle image if picked
      if (_compressedBytes != null) {
        final client = Supabase.instance.client;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        remoteImagePath = await StorageUtils.uploadImage(client, fileName, _compressedBytes!);
      }

      final repo = ref.read(inventoryRepositoryProvider);
      final hubs = ref.read(storageHubsProvider).valueOrNull ?? const <StorageHub>[];
      final selectedLocationId = _selectedLocationId;
      if (selectedLocationId == null) {
        throw Exception('Please select a warehouse before creating the item.');
      }
      final selectedHubName = hubs
          .where((h) => h.id == selectedLocationId)
          .map((h) => h.name)
          .firstWhere((_) => true, orElse: () => 'location_$selectedLocationId');
      final primaryDistribution = {
        'locationId': selectedLocationId,
        'locationName': selectedHubName,
        'qtyGood': _safeInt(_qtyGoodCtrl),
        'qtyDamaged': _safeInt(_qtyDamagedCtrl),
        'qtyMaintenance': _safeInt(_qtyMaintenanceCtrl),
        'qtyLost': _safeInt(_qtyLostCtrl),
      };
      final allDistributions = <Map<String, dynamic>>[
        primaryDistribution,
        ..._extraDistributions.map((d) => {
              'locationId': d.locationId,
              'locationName': d.locationName,
              'qtyGood': d.qtyGood,
              'qtyDamaged': d.qtyDamaged,
              'qtyMaintenance': d.qtyMaintenance,
              'qtyLost': d.qtyLost,
            }),
      ];
      final uniqueLocationIds = allDistributions
          .map((d) => d['locationId'] as int)
          .toSet();
      if (uniqueLocationIds.length != allDistributions.length) {
        AppToast.showError(context, 'DUPLICATE DISTRIBUTION SITES ARE NOT ALLOWED');
        return;
      }
      await repo.createItem(
        name: _nameCtrl.text,
        category: _selectedCategory,
        itemType: _selectedItemType,
        qtyGood: _safeInt(_qtyGoodCtrl),
        qtyDamaged: _safeInt(_qtyDamagedCtrl),
        qtyMaintenance: _safeInt(_qtyMaintenanceCtrl),
        qtyLost: _safeInt(_qtyLostCtrl),
        locationRegistryId: selectedLocationId,
        storageLocation: selectedHubName,
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        unit: _unitCtrl.text,
        serialNumber: _serialCtrl.text,
        modelNumber: _modelCtrl.text,
        expiryDate: _expiryDate?.toIso8601String().split('T').first,
        expiryAlertDays: _selectedItemType == 'consumable' ? 15 : null,
        targetStock: int.tryParse(_targetCtrl.text),
        lowStockThreshold: thresholdPercent,
        restockAlertEnabled: _restockAlertEnabled,
        imageUrl: remoteImagePath,
        siteDistributions: allDistributions,
      );
      
      await ref.read(inventoryNotifierProvider.notifier).refresh();
      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(context, 'ASSET REGISTERED');
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'REGISTRATION FAILED');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}


