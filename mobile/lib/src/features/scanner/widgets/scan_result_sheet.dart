import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/qr_payload.dart';
import '../../transactions/services/quick_borrow_service.dart';
import '../../../core/networking/supabase_client.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/primary_button.dart';
import '../../../core/design_system/widgets/app_toast.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/utils/storage_utils.dart';
import '../../borrowing/providers/personnel_search_controller.dart';
import '../../fast_dispatch/model/dispatch_session.dart';

/// 🛡️ QUICK-BORROW BENTO CONSOLE (V17)
/// User-friendly manifest with simplified wording and large visual showcases.
class ScanResultSheet extends ConsumerStatefulWidget {
  final LigtasQrPayload payload;

  const ScanResultSheet({super.key, required this.payload});

  @override
  ConsumerState<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends ConsumerState<ScanResultSheet> {
  late DockSuppressionController _dockSuppressionController;
  bool _isLoading = false;
  bool _isFetchingStock = true;
  int _availableStock = 0;
  int _requestedQuantity = 1;
  String? _fetchError;
  String? _imageUrl;
  String? _category;

  // Hardened Design Tokens
  static const Color stitchNavy = Color(0xFF0F172A);
  static const Color stitchSurface = Color(0xFFF8FAFC);
  static const Color stitchBorder = Color(0xFFE2E8F0);

  // Scan-to-Return State
  List<Map<String, dynamic>> _allActiveBorrows = [];
  Map<String, dynamic>? _selectedLog;
  bool get _isReturnMode => _allActiveBorrows.isNotEmpty;
  String _returnCondition = 'Good';

  // Form State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _authorizedByController = TextEditingController();
  final TextEditingController _releasedByController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  
  int _durationDays = 7;
  bool _isCustomDuration = false;
  String _transactionPurpose = 'Field Deployment';
  final _formKey = GlobalKey<FormState>();

  int _currentPhase = 1; // 🛡️ 3-PHASE BORROW STATE

  @override
  void initState() {
    super.initState();
    _dockSuppressionController =
        ref.read(dockSuppressionControllerProvider.notifier);
    Future<void>(() {
      if (mounted) {
        _dockSuppressionController.suppress(DockSuppressionReason.detailSheet);
      }
    });
    
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.displayName ?? '';
    _contactController.text = user?.phoneNumber ?? '';
    _orgController.text = user?.organization ?? '';

    _qtyController.addListener(_onQtyTextChanged);
    _fetchStatus();
  }

  void _onQtyTextChanged() {
    final val = int.tryParse(_qtyController.text);
    if (val != null) {
      final maxQty = _isReturnMode ? (_selectedLog?['quantity'] ?? 0) : _availableStock;
      if (val >= 1 && val <= maxQty) {
        setState(() => _requestedQuantity = val);
      }
    }
  }

  @override
  void dispose() {
    Future<void>(() {
      _dockSuppressionController.release(DockSuppressionReason.detailSheet);
    });
    _nameController.dispose();
    _contactController.dispose();
    _orgController.dispose();
    _purposeController.dispose();
    _authorizedByController.dispose();
    _releasedByController.dispose();
    _notesController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  String? _itemName;

  int get _itemId => widget.payload.maybeMap(
        equipment: (e) => e.itemId,
        orElse: () => 0,
      );

  String get _initialItemName => widget.payload.maybeMap(
        equipment: (e) => e.itemName,
        orElse: () => 'Unknown',
      );

  Future<void> _fetchStatus() async {
    try {
      final supabase = SupabaseService.client;
      final service = QuickBorrowService();

      final results = await Future.wait<dynamic>([
        supabase.from('inventory').select('item_name, stock_available, image_url, category').eq('id', _itemId).single(),
        service.getActiveBorrows(_itemId),
      ]);
      
      final inventoryResponse = results[0] as Map<String, dynamic>;
      final borrows = results[1] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _itemName = inventoryResponse['item_name'];
          _availableStock = inventoryResponse['stock_available'] ?? 0;
          _imageUrl = StorageUtils.resolveAssetUrl(inventoryResponse['image_url']);
          _category = inventoryResponse['category'];
          _allActiveBorrows = borrows;
          _isFetchingStock = false;

          if (_isReturnMode) {
            _selectedLog = borrows.first;
            _requestedQuantity = _selectedLog!['quantity'];
            _qtyController.text = _requestedQuantity.toString();
          } else if (_availableStock <= 0) {
            _requestedQuantity = 0;
            _qtyController.text = '0';
            _fetchError = 'This item is currently out of stock.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingStock = false;
          _fetchError = 'Could not check records.';
        });
      }
    }
  }

  void _adjustQuantity(int delta) {
    final maxQty = _isReturnMode ? (_selectedLog?['quantity'] ?? 0) : _availableStock;
    final newValue = _requestedQuantity + delta;
    if (newValue >= 1 && newValue <= maxQty) {
      _qtyController.text = newValue.toString();
      HapticFeedback.lightImpact();
    }
  }

  void _nextPhase() {
    if (_currentPhase < 3) {
      setState(() => _currentPhase++);
      HapticFeedback.mediumImpact();
    }
  }

  void _prevPhase() {
    if (_currentPhase > 1) {
      setState(() => _currentPhase--);
      HapticFeedback.lightImpact();
    }
  }

  // 🛡️ TACTICAL CONFIRMATION: Finalizes either a Borrow or a Return transaction
  Future<void> _onConfirm() async {
    if (_requestedQuantity <= 0) return;
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final service = QuickBorrowService();
    
    try {
      final Map<String, dynamic> results;
      
      if (_isReturnMode && _selectedLog != null) {
        results = await service.executeReturn(
          logId: _selectedLog!['id'],
          itemId: _itemId,
          totalBorrowedQuantity: _selectedLog!['quantity'],
          returnQuantity: _requestedQuantity,
          status: _returnCondition,
          notes: _notesController.text,
        );
      } else {
        results = await service.executeQuickBorrow(
          itemId: _itemId,
          itemName: _itemName ?? _initialItemName,
          quantity: _requestedQuantity,
          borrowerName: _nameController.text,
          borrowerContact: _contactController.text,
          borrowerOrganization: _orgController.text,
          purpose: _transactionPurpose == 'Other' ? _purposeController.text : _transactionPurpose,
          durationDays: _durationDays,
          approvedByName: _authorizedByController.text,
          releasedByName: _releasedByController.text,
        );
      }

      if (mounted) {
        if (results['success'] == true) {
          if (_isReturnMode) {
            AppToast.show(
              context,
              results['message'] ?? 'Return Successful',
              color: AppTheme.secondaryOrange,
              icon: Icons.assignment_return_rounded,
            );
          } else {
            AppToast.showSuccess(
              context,
              results['message'] ?? 'Transaction Successful',
            );
          }
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isLoading = false);
          _showErrorDialog(results['error'] ?? 'Unknown Transaction Error');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String? error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: stitchSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Something went wrong', style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
        content: Text(error ?? 'Try again later', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: stitchNavy))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: stitchSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. ASSET HERO HEADER ──
            _buildHeroHeader(),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isReturnMode) ...[
                      _buildPhaseIndicator(),
                      const Gap(16),
                    ],
                    
                    AnimatedSwitcher(
                      duration: 400.ms,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _isReturnMode 
                        ? _buildReturnFlow()
                        : _buildBorrowPhaseContent(),
                    ),
                    
                    if (_fetchError != null)
                      _buildErrorBanner(_fetchError!),

                    const Gap(24),
                    _buildActionButtons(),
                    Gap(MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = _currentPhase >= step;
        final isCurrent = _currentPhase == step;
        
        return Expanded(
          child: Row(
            children: [
              AnimatedContainer(
                duration: 300.ms,
                width: isCurrent ? 24 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? stitchNavy : stitchBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: _currentPhase > step ? stitchNavy : stitchBorder,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBorrowPhaseContent() {
    return Column(
      key: ValueKey('phase_$_currentPhase'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currentPhase == 1) ...[
          _buildBentoSection(
            label: 'PHASE 1: IDENTIFY REQUESTER',
            icon: Icons.person_search_rounded,
            children: [
              _buildInfoRow('AVAILABILITY', _isFetchingStock ? 'Checking...' : '${_availableStock} Available', 
                color: _availableStock > 0 ? const Color(0xFF10B981) : Colors.redAccent),
              const Gap(12),
              Text('REQUESTER DETAILS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
              const Gap(8),
              _buildPersonnelSearchField(),
              const Gap(8),
              _buildTactileField(
                controller: _contactController, 
                hint: 'Phone (e.g. 09123456789)', 
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone required';
                  if (!v.startsWith('09')) return 'Must start with 09';
                  if (v.length != 11) return 'Must be 11 digits';
                  return null;
                }
              ),
              const Gap(8),
              _buildTactileField(
                controller: _orgController, 
                hint: 'Office / Department', 
                icon: Icons.business_rounded, 
                validator: (v) => v!.isEmpty ? 'Office required' : null
              ),
            ],
          ),
        ],

        if (_currentPhase == 2) ...[
          _buildBentoSection(
            label: 'PHASE 2: BORROW SPECIFICATIONS',
            icon: Icons.settings_input_component_rounded,
            children: [
              Text('QUANTITY', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              const Gap(12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityBtn(Icons.remove_rounded, (!_isLoading && _requestedQuantity > 1) ? () => _adjustQuantity(-1) : null),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w900, color: stitchNavy),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      _buildQuantityBtn(Icons.add_rounded, (!_isLoading && _requestedQuantity < _availableStock) ? () => _adjustQuantity(1) : null),
                    ],
                  ),
                ),
              ),
              const Gap(20),
              Text('PURPOSE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              const Gap(8),
              _buildTactileField(
                controller: _purposeController, 
                hint: 'Why are you borrowing this?', 
                icon: Icons.edit_note_rounded, 
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Purpose required' : null
              ),
              const Gap(16),
              Text('DURATION', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
              const Gap(8),
              _buildDurationSelector(),
            ],
          ),
        ],

        if (_currentPhase == 3) ...[
          _buildBentoSection(
            label: 'PHASE 3: AUDIT & AUTHORIZATION',
            icon: Icons.verified_user_rounded,
            children: [
              _buildTactileField(
                controller: _authorizedByController,
                hint: 'Authorized by (name)',
                icon: Icons.shield_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const Gap(8),
              _buildTactileField(
                controller: _releasedByController,
                hint: 'Released by (name)',
                icon: Icons.front_hand_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stitchBorder),
            ),
            child: Column(
              children: [
                _buildInfoRow('REQUESTER', _nameController.text),
                _buildInfoRow('ITEM', _itemName ?? _initialItemName),
                _buildInfoRow('QUANTITY', '$_requestedQuantity unit(s)'),
                _buildInfoRow('DURATION', '$_durationDays Days'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReturnFlow() {
    return Column(
      key: const ValueKey('return_flow'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBentoSection(
          label: 'RETURN DETAILS',
          icon: Icons.assignment_return_rounded,
          children: [
            _buildInfoRow('RECORD ID', '#${_selectedLog?['id'].toString().substring(0, 8).toUpperCase() ?? 'N/A'}', color: AppTheme.secondaryOrange),
            const Gap(12),
            Text('QUANTITY TO RETURN', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
            const Gap(8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityBtn(Icons.remove_rounded, (!_isLoading && _requestedQuantity > 1) ? () => _adjustQuantity(-1) : null),
                    SizedBox(
                      width: 70,
                      child: TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w900, color: stitchNavy),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    _buildQuantityBtn(Icons.add_rounded, (!_isLoading && _requestedQuantity < (_selectedLog?['quantity'] ?? 0)) ? () => _adjustQuantity(1) : null),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        _buildBentoSection(
          label: 'CONDITION & NOTES',
          icon: Icons.check_circle_outline_rounded,
          children: [
            _buildConditionSelector(),
            const Gap(12),
            _buildTactileField(controller: _notesController, hint: 'Return notes...', icon: Icons.edit_note_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Stack(
      children: [
        Hero(
          tag: 'inv_img_$_itemId',
          child: Container(
            height: 220, // 🛡️ BIGGER: Visual asset showcase
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
            child: _imageUrl != null && _imageUrl!.isNotEmpty
                ? CachedNetworkImage(imageUrl: _imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 64),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12, left: 0, right: 0,
          child: Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(2)))),
        ),
        Positioned(
          bottom: 16, left: 20, right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isReturnMode ? 'RETURNING ITEM' : 'ITEM FOUND', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 2.0)),
              const Gap(4),
              Text(_itemName ?? _initialItemName, style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoSection({required String label, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stitchBorder, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
              const Gap(8),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
            ],
          ),
          const Gap(10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
          Text(value, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, color: color ?? stitchNavy)),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: stitchNavy, size: 20),
      style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(8)),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [1, 3, 7, 14, 30];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...durations.map((d) {
            final isSelected = _durationDays == d && !_isCustomDuration;
            return GestureDetector(
              onTap: () => setState(() {
                _durationDays = d;
                _isCustomDuration = false;
              }),
              child: Container(
                width: 44, height: 36,
                margin: const EdgeInsets.only(right: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? stitchNavy : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? stitchNavy : stitchBorder),
                ),
                child: Text('${d}D', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : stitchNavy)),
              ),
            );
          }),
          GestureDetector(
            onTap: _pickCustomDuration,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isCustomDuration ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isCustomDuration ? AppTheme.primaryBlue : stitchBorder),
              ),
              child: Text(
                _isCustomDuration ? '${_durationDays}D Custom' : 'Custom',
                style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: _isCustomDuration ? Colors.white : AppTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomDuration() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final diff = date.difference(DateTime.now()).inDays + 1;
      setState(() {
        _durationDays = diff;
        _isCustomDuration = true;
      });
    }
  }

  Widget _buildConditionSelector() {
    final conditions = [
      {'l': 'Good', 'i': Icons.verified_rounded, 'c': AppTheme.emeraldGreen},
      {'l': 'Service', 'i': Icons.settings_suggest_rounded, 'c': AppTheme.warningAmber},
      {'l': 'Warning', 'i': Icons.report_problem_rounded, 'c': AppTheme.errorRed},
    ];
    return Row(
      children: conditions.map((c) {
        final isSelected = _returnCondition == c['l'];
        final color = c['c'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _returnCondition = c['l'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? color : stitchBorder),
              ),
              child: Column(
                children: [
                  Icon(c['i'] as IconData, size: 18, color: isSelected ? color : const Color(0xFF94A3B8)),
                  const Gap(4),
                  Text(c['l'] as String, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? color : const Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTactileField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? Function(String?)? validator
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0))
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: stitchNavy),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorStyle: GoogleFonts.lexend(fontSize: 10, color: Colors.redAccent, height: 0.8),
        ),
      ),
    );
  }

  Widget _buildPersonnelSearchField() {
    return SearchAnchor(
      builder: (context, controller) {
        return _buildTactileField(
          controller: _nameController,
          hint: 'Search or Type Name',
          icon: Icons.person_add_rounded,
          onChanged: (val) {
            controller.text = val;
            if (val.isNotEmpty && !controller.isOpen) controller.openView();
          },
          validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
        );
      },
      suggestionsBuilder: (context, controller) {
        final results = ref.watch(personnelSearchControllerProvider(controller.text));
        
        return results.map((p) => ListTile(
          leading: const Icon(Icons.person_outline_rounded, size: 20, color: stitchNavy),
          title: Text(p.name, style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 14, color: stitchNavy)),
          subtitle: Text('${p.office} • ${p.contact}', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
          onTap: () {
            setState(() {
              _nameController.text = p.name;
              _contactController.text = p.contact;
              _orgController.text = p.office ?? '';
            });
            controller.closeView(p.name);
            FocusScope.of(context).unfocus();
          },
        )).toList();
      },
    );
  }

  Widget _buildActionButtons() {
    final String actionLabel = _isReturnMode ? 'Return' : 'Borrow';
    
    return Row(
      children: [
        if (_currentPhase > 1 && !_isReturnMode) ...[
          IconButton(
            onPressed: _isLoading ? null : _prevPhase,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: stitchNavy,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Gap(12),
        ],
        
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading 
                ? null 
                : (_isReturnMode || _currentPhase == 3 ? _onConfirm : _nextPhase),
              style: ElevatedButton.styleFrom(
                backgroundColor: stitchNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    _isReturnMode || _currentPhase == 3 ? 'Confirm $actionLabel' : 'Next Step',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
      child: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
    ).animate().shake();
  }
}
