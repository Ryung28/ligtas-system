import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_admin_fields.dart';
import '../providers/inventory_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

enum ManagerMode { restock, dispatch, reserve, edit }

class ManagerActionSheet extends ConsumerStatefulWidget {
  final InventoryItem item;
  const ManagerActionSheet({super.key, required this.item});

  @override
  ConsumerState<ManagerActionSheet> createState() => _ManagerActionSheetState();
}

class _ManagerActionSheetState extends ConsumerState<ManagerActionSheet> {
  final _noteController = TextEditingController();
  final _recipientController = TextEditingController(); 
  final _officeController = TextEditingController(); 
  final _contactController = TextEditingController();
  final _approvedByController = TextEditingController();
  final _releasedByController = TextEditingController();
  final _goodQtyController = TextEditingController();
  final _damagedQtyController = TextEditingController();
  final _maintenanceQtyController = TextEditingController();
  final _lostQtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationRegistryIdController = TextEditingController();
  
  int _quantity = 1;
  ManagerMode _mode = ManagerMode.dispatch;
  DateTime? _expectedReturnDate;
  DateTime? _pickupScheduledAt;
  bool _isDateReturn = false;
  bool _isEditLoading = false;
  InventoryAdminFields? _editFields;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
    _recipientController.addListener(() => setState(() {}));
    _officeController.addListener(() => setState(() {}));
    _contactController.addListener(() => setState(() {}));
    _approvedByController.addListener(() => setState(() {}));
    _goodQtyController.addListener(() => setState(() {}));
    _damagedQtyController.addListener(() => setState(() {}));
    _maintenanceQtyController.addListener(() => setState(() {}));
    _lostQtyController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
    _locationRegistryIdController.addListener(() => setState(() {}));
    
    // Auto-fill released by with current user
    Future.microtask(() {
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      _releasedByController.text = user?.displayName ?? '';
      ref.read(isDockSuppressedProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _recipientController.dispose();
    _officeController.dispose();
    _contactController.dispose();
    _approvedByController.dispose();
    _releasedByController.dispose();
    _goodQtyController.dispose();
    _damagedQtyController.dispose();
    _maintenanceQtyController.dispose();
    _lostQtyController.dispose();
    _locationController.dispose();
    _locationRegistryIdController.dispose();
    Future.microtask(() {
      if (mounted) {
        ref.read(isDockSuppressedProvider.notifier).state = false;
      }
    });
    super.dispose();
  }

  int _parseIntOrZero(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  int? _parseNullableInt(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  bool get _canSubmit {
    if (_mode == ManagerMode.restock) return _noteController.text.trim().isNotEmpty;

    if (_mode == ManagerMode.edit) {
      if (_isEditLoading) return false;
      final reasonOk = _noteController.text.trim().isNotEmpty;
      final locationOk = _locationController.text.trim().isNotEmpty;
      if (!reasonOk || !locationOk) return false;

      final qtyGood = _parseIntOrZero(_goodQtyController);
      final qtyDamaged = _parseIntOrZero(_damagedQtyController);
      final qtyMaintenance = _parseIntOrZero(_maintenanceQtyController);
      final qtyLost = _parseIntOrZero(_lostQtyController);

      final sum = qtyGood + qtyDamaged + qtyMaintenance + qtyLost;
      return sum >= 1;
    }
    
    final basicFields = _noteController.text.trim().isNotEmpty && 
           _recipientController.text.trim().isNotEmpty &&
           _officeController.text.trim().isNotEmpty &&
           _approvedByController.text.trim().isNotEmpty &&
           _releasedByController.text.trim().isNotEmpty;

    if (_mode == ManagerMode.reserve) {
      return basicFields && _pickupScheduledAt != null;
    }
    
    return basicFields;
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(isDockSuppressedProvider.notifier).state = false;
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            top: 12, 
            bottom: bottomInset + 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4, 
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Gap(24),

                  Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: sentinel.navy.withOpacity(0.1), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.item.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: const Color(0xFFE2E8F0),
                                  highlightColor: Colors.white,
                                  child: Container(color: Colors.white),
                                ),
                              )
                            : Icon(Icons.inventory_2_outlined, color: sentinel.navy.withOpacity(0.2)),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getHeaderText(), 
                              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w900, color: sentinel.navy)),
                            Text(widget.item.name.toUpperCase(), 
                              style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: sentinel.onSurfaceVariant.withOpacity(0.5), letterSpacing: 1.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  _buildModeToggle(sentinel),
                  const Gap(24),

                  if (_mode == ManagerMode.edit) ...[
                    if (_isEditLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: sentinel.primary,
                              ),
                            ),
                            const Gap(12),
                            Text(
                              'Loading equipment details...',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: sentinel.navy.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _buildBucketEditor(sentinel),
                      const Gap(16),
                      _buildLocationEditor(sentinel),
                      const Gap(16),
                    ],
                  ] else ...[
                    Row(
                      children: [
                        Text(
                          'HOW MANY?',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: sentinel.navy,
                          ),
                        ),
                        const Spacer(),
                        _QuantitySelector(
                          quantity: _quantity,
                          onChanged: (val) => setState(() => _quantity = val),
                          max: _mode == ManagerMode.restock ? 999 : widget.item.availableStock,
                        ),
                      ],
                    ),
                    const Gap(24),

                    if (_mode != ManagerMode.restock) ...[
                      _buildSmallField('RECIPIENT / BORROWER', 'Full Name', _recipientController, sentinel),
                      const Gap(16),
                      Row(
                        children: [
                          Expanded(child: _buildSmallField('OFFICE/DEPT', 'Office #', _officeController, sentinel)),
                          const Gap(12),
                          Expanded(child: _buildSmallField('CONTACT NO.', '09XXXXXXXXX', _contactController, sentinel)),
                        ],
                      ),
                      const Gap(16),
                      if (_mode == ManagerMode.reserve) ...[
                        _buildSchedulePicker(
                          'TARGET PICKUP DATE',
                          _pickupScheduledAt,
                          (d) => setState(() => _pickupScheduledAt = d),
                          sentinel,
                        ),
                        const Gap(16),
                      ],
                      _buildReturnSchedule(sentinel),
                      const Gap(16),
                      _buildAuditSignOff(sentinel),
                      const Gap(16),
                    ],
                  ],

                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: _mode == ManagerMode.restock
                          ? 'Reason for restocking (required)'
                          : (_mode == ManagerMode.edit
                              ? 'Audit reason for equipment changes (required)'
                              : 'Additional audit notes (required)'),
                      hintStyle: GoogleFonts.plusJakartaSans(color: sentinel.onSurfaceVariant.withOpacity(0.4), fontSize: 13),
                      filled: true,
                      fillColor: sentinel.containerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  
                  const Gap(24),
                  
                  _buildSubmitButton(sentinel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getHeaderText() {
    switch (_mode) {
      case ManagerMode.restock: return 'RESTOCK INVENTORY';
      case ManagerMode.dispatch: return 'DISPATCH ITEM';
      case ManagerMode.reserve: return 'RESERVE EQUIPMENT';
      case ManagerMode.edit: return 'EDIT EQUIPMENT';
    }
  }

  Future<void> _loadEditFieldsIfNeeded() async {
    if (_isEditLoading) return;
    if (_editFields != null) return;

    setState(() => _isEditLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final fields = await repo.fetchAdminFields(widget.item.id);

      if (!mounted) return;

      setState(() {
        _editFields = fields;
        _goodQtyController.text = fields.qtyGood.toString();
        _damagedQtyController.text = fields.qtyDamaged.toString();
        _maintenanceQtyController.text = fields.qtyMaintenance.toString();
        _lostQtyController.text = fields.qtyLost.toString();
        _locationController.text = fields.storageLocation;
        _locationRegistryIdController.text = fields.locationRegistryId?.toString() ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load equipment details: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEditLoading = false);
    }
  }

  Widget _buildSchedulePicker(String label, DateTime? value, ValueChanged<DateTime> onSelected, SentinelColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.6))),
        const Gap(8),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) onSelected(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: sentinel.containerLow, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 16, color: sentinel.primary),
                const Gap(12),
                Text(
                  value == null ? 'Select Pickup Date' : '${value.day}/${value.month}/${value.year}',
                  style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: sentinel.navy),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.black26),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReturnSchedule(SentinelColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RETURN SCHEDULE', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.6))),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: sentinel.containerLow, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Text('Anytime', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
              Switch.adaptive(
                value: _isDateReturn,
                onChanged: (v) => setState(() => _isDateReturn = v),
                activeColor: sentinel.primary,
              ),
              Text('Specific Date', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700)),
              if (_isDateReturn) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _expectedReturnDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      _expectedReturnDate == null ? 'Select Date' : '${_expectedReturnDate!.day}/${_expectedReturnDate!.month}',
                      style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: sentinel.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditSignOff(SentinelColors sentinel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sentinel.containerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sentinel.navy.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: sentinel.primary),
              const Gap(8),
              Text('DISPATCH SIGN-OFF', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: sentinel.navy, letterSpacing: 1.0)),
            ],
          ),
          const Gap(16),
          _buildSmallField('APPROVED BY', 'Name of Approver', _approvedByController, sentinel),
          const Gap(12),
          _buildSmallField('RELEASED BY (SESSION)', 'Your Name', _releasedByController, sentinel),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(SentinelColors sentinel) {
    String label = 'CONFIRM ACTION';
    IconData icon = Icons.check_circle_rounded;
    Color color = sentinel.primary;

    if (_mode == ManagerMode.restock) {
      label = 'SAVE NEW STOCK';
      icon = Icons.add_business_rounded;
      color = AppTheme.emeraldGreen;
    } else if (_mode == ManagerMode.edit) {
      label = 'SAVE EQUIPMENT CHANGES';
      icon = Icons.save_alt_rounded;
      color = sentinel.navy;
    } else if (_mode == ManagerMode.reserve) {
      label = 'CONFIRM RESERVATION';
      icon = Icons.calendar_month_rounded;
      color = AppTheme.warningAmber;
    } else {
      label = 'CONFIRM DISPATCH';
      icon = Icons.outbox_rounded;
    }

    return _buildActionButton(label, icon, color, _canSubmit ? () => _triggerAction() : null);
  }

  Widget _buildModeToggle(SentinelColors sentinel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: sentinel.containerLow, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(child: _ToggleButton(label: 'RESTOCK', isActive: _mode == ManagerMode.restock, onTap: () => setState(() => _mode = ManagerMode.restock), activeColor: AppTheme.emeraldGreen)),
          Expanded(child: _ToggleButton(label: 'DISPATCH', isActive: _mode == ManagerMode.dispatch, onTap: () => setState(() => _mode = ManagerMode.dispatch), activeColor: sentinel.navy)),
          Expanded(child: _ToggleButton(label: 'RESERVE', isActive: _mode == ManagerMode.reserve, onTap: () => setState(() => _mode = ManagerMode.reserve), activeColor: AppTheme.warningAmber)),
          Expanded(
            child: _ToggleButton(
              label: 'EDIT',
              isActive: _mode == ManagerMode.edit,
              onTap: () {
                setState(() => _mode = ManagerMode.edit);
                _loadEditFieldsIfNeeded();
              },
              activeColor: sentinel.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerAction() async {
    HapticFeedback.heavyImpact();
    final repo = ref.read(inventoryRepositoryProvider);
    final user = ref.read(currentUserProvider);

    try {
      if (_mode == ManagerMode.restock) {
        await repo.adjustStock(
          itemId: widget.item.id,
          oldQuantity: widget.item.totalStock.toDouble(),
          newQuantity: (widget.item.totalStock + _quantity).toDouble(),
          actionType: 'adjustment',
          reason: _noteController.text.trim(),
          warehouseId: user?.assignedWarehouse,
        );
      } else if (_mode == ManagerMode.edit) {
        final qtyGood = _parseIntOrZero(_goodQtyController);
        final qtyDamaged = _parseIntOrZero(_damagedQtyController);
        final qtyMaintenance = _parseIntOrZero(_maintenanceQtyController);
        final qtyLost = _parseIntOrZero(_lostQtyController);

        await repo.updateAdminFields(
          itemId: widget.item.id,
          qtyGood: qtyGood,
          qtyDamaged: qtyDamaged,
          qtyMaintenance: qtyMaintenance,
          qtyLost: qtyLost,
          storageLocation: _locationController.text.trim(),
          locationRegistryId: _parseNullableInt(_locationRegistryIdController),
          forensicNote: _noteController.text.trim(),
        );
      } else {
        await repo.borrowItem(
          itemId: widget.item.id,
          quantity: _quantity,
          borrowerName: _recipientController.text.trim(),
          borrowerContact: _contactController.text.trim(),
          borrowerOrganization: _officeController.text.trim(),
          approvedBy: _approvedByController.text.trim(),
          releasedBy: _releasedByController.text.trim(),
          expectedReturnDate: _isDateReturn ? _expectedReturnDate : null,
          pickupScheduledAt: _mode == ManagerMode.reserve ? _pickupScheduledAt : null, // 🛡️ PASS PICKUP DATE
          purpose: _noteController.text.trim(),
          warehouseId: user?.assignedWarehouse,
        );
      }

      if (mounted) Navigator.pop(context);
      _showSuccessFeedback();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🛑 Action Failed: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), const Gap(12), Text('Inventory Registry Updated Successfully')]),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSmallField(String label, String hint, TextEditingController controller, SentinelColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.6))),
        const Gap(6),
        TextField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: sentinel.onSurfaceVariant.withOpacity(0.3), fontSize: 12),
            filled: true,
            fillColor: sentinel.containerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSmallField(
    String label,
    String hint,
    TextEditingController controller,
    SentinelColors sentinel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: sentinel.navy.withOpacity(0.6),
          ),
        ),
        const Gap(6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: sentinel.onSurfaceVariant.withOpacity(0.3), fontSize: 12),
            filled: true,
            fillColor: sentinel.containerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildBucketEditor(SentinelColors sentinel) {
    final qtyGood = _parseIntOrZero(_goodQtyController);
    final qtyDamaged = _parseIntOrZero(_damagedQtyController);
    final qtyMaintenance = _parseIntOrZero(_maintenanceQtyController);
    final qtyLost = _parseIntOrZero(_lostQtyController);
    final total = qtyGood + qtyDamaged + qtyMaintenance + qtyLost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STOCK DISTRIBUTION',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: sentinel.navy.withOpacity(0.6),
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(child: _buildNumberSmallField('GOOD', '0', _goodQtyController, sentinel)),
            const Gap(10),
            Expanded(child: _buildNumberSmallField('DAMAGED', '0', _damagedQtyController, sentinel)),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(child: _buildNumberSmallField('MAINTENANCE', '0', _maintenanceQtyController, sentinel)),
            const Gap(10),
            Expanded(child: _buildNumberSmallField('LOST', '0', _lostQtyController, sentinel)),
          ],
        ),
        const Gap(12),
        Text(
          'TOTAL STOCK: $total',
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: sentinel.navy.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationEditor(SentinelColors sentinel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: sentinel.navy.withOpacity(0.6),
          ),
        ),
        const Gap(12),
        _buildSmallField('STORAGE LOCATION', 'e.g. Warehouse A / Bay 3', _locationController, sentinel),
        const Gap(12),
        _buildNumberSmallField(
          'LOCATION REGISTRY ID (optional)',
          'e.g. 12',
          _locationRegistryIdController,
          sentinel,
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    final bool isEnabled = onTap != null;
    return Material(
      color: isEnabled ? color.withOpacity(0.08) : Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isEnabled ? color.withOpacity(0.2) : Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isEnabled ? color : Colors.black26, size: 20),
              const Gap(16),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12, 
                  fontWeight: FontWeight.w800, 
                  color: isEnabled ? color : Colors.black26, 
                  letterSpacing: 0.5
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isEnabled ? color.withOpacity(0.5) : Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const _ToggleButton({required this.label, required this.isActive, required this.onTap, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10, 
              fontWeight: FontWeight.w900, 
              color: isActive ? Colors.white : Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int max;

  const _QuantitySelector({required this.quantity, required this.onChanged, required this.max});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    return Container(
      decoration: BoxDecoration(color: sentinel.containerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Text(
            quantity.toString().padLeft(2, '0'),
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w900, color: sentinel.navy),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}
