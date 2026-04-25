import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/core/design_system/widgets/app_toast.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_batch/manager_batch_provider.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_batch/manager_batch_state.dart';
import 'package:mobile/src/features_v2/inventory/presentation/widgets/tactical_asset_image.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_image_viewer.dart';
import 'package:mobile/src/features/borrowing/providers/personnel_search_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerBatchReviewSheet extends ConsumerStatefulWidget {
  const ManagerBatchReviewSheet({super.key});

  @override
  ConsumerState<ManagerBatchReviewSheet> createState() => _ManagerBatchReviewSheetState();
}

class _ManagerBatchReviewSheetState extends ConsumerState<ManagerBatchReviewSheet> {
  final _nameCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _approvedCtrl = TextEditingController();
  final _releasedCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  DateTime? _returnDate;
  DateTime? _pickupDate;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _officeCtrl.text = user?.organization ?? '';
    _releasedCtrl.text = user?.displayName ?? '';
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _officeCtrl.dispose();
    _contactCtrl.dispose();
    _approvedCtrl.dispose();
    _releasedCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() => _searchQuery = _nameCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerBatchControllerProvider);
    final ctrl = ref.read(managerBatchControllerProvider.notifier);
    final isReserve = state.isReserveMode;
    const onyx = Color(0xFF001A33);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4F8), // 🛡️ REUSABLE HERO CANVAS
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              // HERO HEADER
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(color: onyx.withOpacity(0.1), borderRadius: BorderRadius.circular(99)),
              ),
              const Gap(20),
              Text(
                (isReserve ? 'RESERVE SUMMARY' : 'DISPATCH SUMMARY').toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: onyx,
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(24),
              
              Expanded(
                child: ListView(
                  children: [
                    _sectionHeader(
                      title: 'Personnel',
                      subtitle: 'Who receives this handoff',
                    ),
                    _voucherField(
                      label: 'Recipient Name', 
                      controller: _nameCtrl, 
                      placeholder: 'Search borrower...',
                      required: true,
                    ),
                    if (_searchQuery.length >= 1) ...[
                      _buildBorrowerSuggestions(),
                      const Gap(12),
                    ],
                    _voucherField(
                      label: 'Office / Unit', 
                      controller: _officeCtrl,
                      placeholder: 'e.g. Logistics Hub',
                    ),
                    _voucherField(
                      label: 'Contact Details', 
                      controller: _contactCtrl,
                      placeholder: 'Phone or Email',
                    ),
                    const Gap(8),

                    _sectionHeader(
                      title: 'Authorization',
                      subtitle: 'Who approved and released this summary',
                    ),
                    _voucherField(
                      label: 'Approved By', 
                      controller: _approvedCtrl, 
                      placeholder: 'Name of authorizing officer',
                      required: true,
                    ),
                    _voucherField(
                      label: 'Released By', 
                      controller: _releasedCtrl,
                      placeholder: 'Name of issuing staff',
                    ),
                    _voucherField(
                      label: 'Purpose / Notes', 
                      controller: _purposeCtrl,
                      placeholder: 'Brief reason for dispatch',
                    ),
                    const Gap(8),

                    _sectionHeader(
                      title: 'Schedule',
                      subtitle: 'Timing details for tracking',
                    ),
                    
                    if (isReserve) ...[
                      _tacticalDateButton(
                        label: 'Pickup schedule',
                        value: _pickupDate == null ? 'Select date' : _dateText(_pickupDate!),
                        onTap: () async {
                          final d = await _pickDate(context, _pickupDate);
                          if (d != null) setState(() => _pickupDate = d);
                        },
                      ),
                      const Gap(12),
                    ],
                    _tacticalDateButton(
                      label: 'Expected return',
                      value: _returnDate == null ? 'Not set' : _dateText(_returnDate!),
                      onTap: () async {
                        final d = await _pickDate(context, _returnDate);
                        if (d != null) setState(() => _returnDate = d);
                      },
                    ),
                    
                    const Gap(14),
                    _sectionHeader(
                      title: 'Items',
                      subtitle: 'What will be handed off',
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: onyx.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: state.lines.values.map((line) => _buildManifestItem(line)).toList(),
                      ),
                    ),
                    
                    if (state.lastFailures.isNotEmpty) ...[
                      const Gap(20),
                      Text('Failed items', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                      const Gap(8),
                      ...state.lastFailures.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${f.itemName}: ${f.error}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.redAccent)),
                        ),
                      ),
                    ],
                    const Gap(24),
                  ],
                ),
              ),
              
              if (state.submitError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(state.submitError!, style: GoogleFonts.lexend(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                ),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : () => _handleSubmit(ctrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onyx,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: onyx.withOpacity(0.3),
                  ),
                  child: Text(
                    state.isSubmitting ? 'PROCESSING...' : (isReserve ? 'CONFIRM RESERVE' : 'CONFIRM DISPATCH'),
                    style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(ManagerBatchController ctrl) async {
    final isReserveFlow = ref.read(managerBatchControllerProvider).isReserveMode;
    final ok = await ctrl.submit(
      recipientName: _nameCtrl.text,
      recipientOffice: _officeCtrl.text,
      recipientContact: _contactCtrl.text,
      approvedBy: _approvedCtrl.text,
      releasedBy: _releasedCtrl.text,
      purpose: _purposeCtrl.text,
      expectedReturnDate: _returnDate,
      pickupScheduledAt: _pickupDate,
    );
    if (!mounted) return;
    if (ok) {
      AppToast.showSuccess(
        context,
        isReserveFlow ? 'Reserve batch confirmed.' : 'Handoff dispatched successfully.',
      );
      Navigator.pop(context);
      return;
    }

    final latestState = ref.read(managerBatchControllerProvider);
    AppToast.showError(
      context,
      latestState.submitError ?? 'Unable to complete this action. Please review and retry.',
    );
  }

  Widget _buildBorrowerSuggestions() {
    final suggestions = ref.watch(personnelSearchControllerProvider(_searchQuery));
    const onyx = Color(0xFF001A33);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: onyx.withOpacity(0.08)),
          ),
          child: Column(
            children: suggestions.take(5).map((person) => ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: onyx.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, size: 16, color: onyx),
              ),
              title: Text(
                person.name,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: onyx,
                ),
              ),
              subtitle: Text(
                [
                  if ((person.office ?? '').isNotEmpty) person.office!,
                  if (person.contact.isNotEmpty) person.contact,
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              onTap: () {
                _nameCtrl.text = person.name;
                _officeCtrl.text = person.office ?? '';
                _contactCtrl.text = person.contact;
                setState(() => _searchQuery = '');
                FocusScope.of(context).unfocus();
              },
            )).toList(),
          ),
        );
  }

  Widget _voucherField({
    required String label, 
    required TextEditingController controller, 
    String? placeholder,
    bool required = false
  }) {
    const onyx = Color(0xFF0F172A);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: onyx.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            required ? '$label *' : label,
            style: GoogleFonts.lexend(
              fontSize: 10, 
              fontWeight: FontWeight.w700, 
              color: const Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(
              color: onyx, 
              fontSize: 15, 
              fontWeight: FontWeight.w700,
            ),
            cursorColor: onyx,
            decoration: InputDecoration(
              isDense: true,
              hintText: placeholder,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: onyx.withOpacity(0.3),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tacticalDateButton({required String label, required String value, required VoidCallback onTap}) {
    const onyx = Color(0xFF001A33);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: onyx.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF64748B), letterSpacing: 1.0)),
                const Gap(4),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: onyx)),
              ],
            ),
            const Spacer(),
            Icon(Icons.calendar_month_rounded, size: 20, color: onyx.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildManifestItem(ManagerBatchLine line) {
    const onyx = Color(0xFF0F172A);
    final heroTag = 'dispatch-review-item-${line.item.id}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final viewerUrl = _resolveViewerUrl(line);
              if (viewerUrl.isEmpty) return;
              TacticalImageViewer.show(
                context,
                url: viewerUrl,
                title: line.item.name,
                heroTag: heroTag,
              );
            },
            child: Hero(
              tag: heroTag,
              child: TacticalAssetImage(
                assetId: line.item.id,
                path: line.item.imageUrl,
                width: 40,
                height: 40,
                borderRadius: 10,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700, color: onyx)),
                Text('${line.item.availableStock} available', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: onyx.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
            child: Text(
              'qty ${line.quantity.toString().padLeft(2, '0')}',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w800,
                color: onyx,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveViewerUrl(ManagerBatchLine line) {
    final storage = Supabase.instance.client.storage;
    final path = line.item.imageUrl?.trim() ?? '';
    if (path.isNotEmpty) {
      if (path.startsWith('http')) return path;
      var clean = path;
      if (clean.startsWith('item-images/')) {
        clean = clean.replaceFirst('item-images/', '');
      }
      if (clean.startsWith('/')) {
        clean = clean.substring(1);
      }
      return storage.from('item-images').getPublicUrl(clean);
    }

    final imageMap = ref.read(inventoryImageMapProvider);
    final mappedPath = (imageMap[line.item.id] ?? '').trim();
    if (mappedPath.isEmpty) return '';
    if (mappedPath.startsWith('http')) return mappedPath;
    return storage.from('item-images').getPublicUrl(mappedPath);
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    const onyx = Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: onyx,
              letterSpacing: -0.2,
            ),
          ),
          const Gap(2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? seed) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: seed ?? now,
    );
  }

  String _dateText(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
