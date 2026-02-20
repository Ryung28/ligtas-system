import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../models/qr_payload.dart';
import '../../transactions/services/quick_borrow_service.dart';
import '../../../core/networking/supabase_client.dart';
import '../../../core/design_system/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/providers/navigation_provider.dart';

class ScanResultSheet extends ConsumerStatefulWidget {
  final LigtasQrPayload payload;

  const ScanResultSheet({super.key, required this.payload});

  @override
  ConsumerState<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends ConsumerState<ScanResultSheet> {
  bool _isLoading = false;
  bool _isFetchingStock = true;
  int _availableStock = 0;
  int _requestedQuantity = 1;
  String? _fetchError;

  // Scan-to-Return State
  List<Map<String, dynamic>> _allActiveBorrows = [];
  Map<String, dynamic>? _selectedLog;
  bool get _isReturnMode => _allActiveBorrows.isNotEmpty;
  String _returnCondition = 'Good';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Senior Dev: Suppress dock while scanner results are shown
    Future.microtask(() {
      if (mounted) ref.read(isDockSuppressedProvider.notifier).state = true;
    });
    _fetchStatus();
  }

  @override
  void dispose() {
    // Restore dock visibility
    ref.read(isDockSuppressedProvider.notifier).state = false;
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final supabase = SupabaseService.client;
      final service = QuickBorrowService();

      // Parallel fetch for efficiency
      final results = await Future.wait<dynamic>([
        supabase.from('inventory').select('stock_available').eq('id', widget.payload.itemId).single(),
        service.getActiveBorrows(widget.payload.itemId),
      ]);
      
      final inventoryResponse = results[0] as Map<String, dynamic>;
      final borrows = results[1] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _availableStock = inventoryResponse['stock_available'] ?? 0;
          _allActiveBorrows = borrows;
          _isFetchingStock = false;
          
          if (_isReturnMode) {
            _selectedLog = borrows.first;
            _requestedQuantity = _selectedLog!['quantity'];
          } else if (_availableStock <= 0) {
            _requestedQuantity = 0;
            _fetchError = 'This item is currently out of stock.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingStock = false;
          _fetchError = 'Could not verify system records.';
        });
      }
    }
  }

  void _adjustQuantity(int delta) {
    setState(() {
      final maxQty = _isReturnMode ? (_selectedLog?['quantity'] ?? 0) : _availableStock;
      final newValue = _requestedQuantity + delta;
      if (newValue >= 1 && newValue <= maxQty) {
        _requestedQuantity = newValue;
        HapticFeedback.lightImpact();
      }
    });
  }

  Future<void> _onConfirm() async {
    if (_requestedQuantity <= 0) return;

    setState(() {
      _isLoading = true;
    });

    final service = QuickBorrowService();
    
    final Map<String, dynamic> result;
    if (_isReturnMode && _selectedLog != null) {
      result = await service.executeReturn(
        logId: _selectedLog!['id'],
        itemId: widget.payload.itemId,
        totalBorrowedQuantity: _selectedLog!['quantity'],
        returnQuantity: _requestedQuantity,
        status: _returnCondition,
        notes: _notesController.text,
      );
    } else {
      result = await service.executeQuickBorrow(
        itemId: widget.payload.itemId,
        itemName: widget.payload.itemName,
        quantity: _requestedQuantity,
      );
    }

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: _isReturnMode ? AppTheme.secondaryOrange : AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
        });
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_isReturnMode ? 'Return Failed' : 'Transaction Failed'),
            content: Text(result['error'] ?? 'Unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildConditionButton(String label, IconData icon, Color color) {
    bool isSelected = _returnCondition == label;
    return GestureDetector(
      onTap: () {
        setState(() => _returnCondition = label);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isSelected ? color : AppTheme.neutralGray600
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.neutralGray800,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Glassmorphic Sheet
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const Gap(28),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isReturnMode ? AppTheme.secondaryOrange.withOpacity(0.1) : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _isReturnMode ? Icons.assignment_return_rounded : Icons.inventory_2_rounded, 
                      color: _isReturnMode ? AppTheme.secondaryOrange : AppTheme.primaryBlue, 
                      size: 28
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isReturnMode ? 'Possession Detected' : 'Equipment Recognized',
                          style: TextStyle(fontSize: 13, color: AppTheme.neutralGray500, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        Text(
                          _isReturnMode ? 'Return Item' : 'Borrow Item',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.neutralGray900, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn().slideX(begin: 0.1, end: 0),
              
              const Gap(24),
              
              // Item Details Card (Glass)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ITEM NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.neutralGray500)),
                        Text(
                          widget.payload.itemName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.neutralGray900),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.neutralGray500)),
                        _isFetchingStock 
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _availableStock > 0 ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _availableStock > 0 ? '$_availableStock Available' : 'Out of Stock',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700, 
                                  fontSize: 12,
                                  color: _availableStock > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                ),
                              ),
                            ),
                      ],
                    ),
                    if (_isReturnMode) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BORROWED ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.neutralGray500)),
                          Text(
                            _selectedLog != null 
                                ? '#${_selectedLog!['id'].toString().length > 8 
                                    ? _selectedLog!['id'].toString().substring(0, 8) 
                                    : _selectedLog!['id'].toString()}' 
                                : '-',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.neutralGray700),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.98, 0.98)),
              
              const Gap(24),

              // Quantity Selector
              Column(
                children: [
                  Text(
                    _isReturnMode ? 'RETURN QUANTITY' : 'QUANTITY NEEDED',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.neutralGray500),
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.neutralGray100.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onPressed: (!_isLoading && _requestedQuantity > 1) ? () => _adjustQuantity(-1) : null,
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            '$_requestedQuantity',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.neutralGray900, height: 1),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onPressed: (!_isLoading && _requestedQuantity < (_isReturnMode ? (_selectedLog?['quantity'] ?? 0) : _availableStock)) ? () => _adjustQuantity(1) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const Gap(24),

              if (_isReturnMode) ...[
                // RETURN ASSESSMENT UI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ITEM CONDITION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.neutralGray500),
                    ),
                    const Gap(12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildConditionButton('Good', Icons.check_circle_rounded, AppTheme.successGreen),
                          _buildConditionButton('Maintenance', Icons.build_rounded, AppTheme.warningAmber),
                          _buildConditionButton('Damaged', Icons.error_rounded, AppTheme.errorRed),
                          _buildConditionButton('Lost', Icons.question_mark_rounded, AppTheme.neutralGray600),
                        ],
                      ),
                    ),
                    const Gap(16),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Add remarks (optional)...',
                        hintStyle: TextStyle(fontSize: 14, color: AppTheme.neutralGray500),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppTheme.neutralGray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ],

              if (_fetchError != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_rounded, color: AppTheme.errorRed, size: 20),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _fetchError!,
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(),
                
              const Gap(32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        foregroundColor: AppTheme.neutralGray600,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            _isReturnMode ? AppTheme.secondaryOrange : AppTheme.primaryBlue,
                            _isReturnMode ? AppTheme.secondaryOrangeLight : AppTheme.primaryBlueDark,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isReturnMode ? AppTheme.secondaryOrange : AppTheme.primaryBlue).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: (_isLoading || _availableStock <= 0 || _isFetchingStock) ? null : _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              _isReturnMode ? 'Confirm Return' : 'Swipe to Borrow', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)
                            ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn().moveY(begin: 20, end: 0),
              
              Gap(MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black12,
      child: IconButton(
        icon: Icon(icon, color: AppTheme.neutralGray900, size: 24),
        onPressed: onPressed,
        disabledColor: AppTheme.neutralGray300,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
        splashColor: AppTheme.primaryBlue.withOpacity(0.1),
        highlightColor: AppTheme.primaryBlue.withOpacity(0.05),
      ),
    );
  }
}
