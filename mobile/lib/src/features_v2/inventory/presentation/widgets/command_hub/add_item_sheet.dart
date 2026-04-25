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

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _unitCtrl = TextEditingController(text: 'pcs');
  final _targetCtrl = TextEditingController();
  final _minCtrl = TextEditingController(text: '20');
  
  String _selectedCategory = 'Logistics';
  int? _selectedLocationId;
  Uint8List? _compressedBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serialCtrl.dispose();
    _modelCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    _targetCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

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
              Row(
                children: [
                  Expanded(child: _field(_serialCtrl, 'SERIAL NO')),
                  const Gap(12),
                  Expanded(child: _field(_modelCtrl, 'MODEL NO')),
                ],
              ),
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

              // ── RESOURCE MATRIX ──
              _sectionLabel('RESOURCE MATRIX'),
              Row(
                children: [
                  Expanded(child: _field(_stockCtrl, 'INITIAL STOCK', keyboard: TextInputType.number, required: true)),
                  const Gap(12),
                  Expanded(child: _field(_unitCtrl, 'UNIT (PCS/BOX)')),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(child: _field(_minCtrl, 'LOW THRESHOLD', keyboard: TextInputType.number)),
                  const Gap(12),
                  Expanded(child: _field(_targetCtrl, 'TARGET STOCK', keyboard: TextInputType.number)),
                ],
              ),
              const Gap(24),

              // ── STORAGE PLOT ──
              _sectionLabel('STORAGE PLOT'),
              storageHubs.when(
                data: (hubs) => DropdownButtonFormField<int>(
                  value: _selectedLocationId,
                  onChanged: (val) => setState(() => _selectedLocationId = val),
                  decoration: _inputDecoration(context, 'SELECT WAREHOUSE'),
                  items: hubs.map((h) => DropdownMenuItem(
                    value: h.id,
                    child: Text(h.name, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600)),
                  )).toList(),
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

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final sentinel = Theme.of(context).sentinel;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lexend(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      filled: true,
      fillColor: sentinel.containerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool required = false, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'REQUIRED' : null : null,
      decoration: _inputDecoration(context, label),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
      await repo.createItem(
        name: _nameCtrl.text,
        category: _selectedCategory,
        initialStock: int.parse(_stockCtrl.text),
        storageLocation: _selectedLocationId?.toString() ?? '',
        unit: _unitCtrl.text,
        serialNumber: _serialCtrl.text,
        modelNumber: _modelCtrl.text,
        targetStock: int.tryParse(_targetCtrl.text),
        lowStockThreshold: int.tryParse(_minCtrl.text),
        imageUrl: remoteImagePath,
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


