import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../models/qr_payload.dart';
import '../../transactions/services/quick_borrow_service.dart';
import '../../../core/networking/supabase_client.dart';

class ScanResultSheet extends StatefulWidget {
  final LigtasQrPayload payload;

  const ScanResultSheet({super.key, required this.payload});

  @override
  State<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<ScanResultSheet> {
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
    _fetchStatus();
  }

  @override
  void dispose() {
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
            backgroundColor: _isReturnMode ? Colors.orange[800] : Colors.green,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 18, 
              color: isSelected ? Colors.white : color
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isReturnMode ? Colors.orange[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isReturnMode ? Icons.assignment_return_outlined : Icons.inventory_2_outlined, 
                  color: _isReturnMode ? Colors.orange[700] : Colors.blue, 
                  size: 30
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isReturnMode ? 'Possession Detected' : 'Equipment Recognized',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _isReturnMode ? 'Process Return' : 'Borrowing Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: 0.1, end: 0),
          
          const Gap(24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isReturnMode ? Colors.orange[50]?.withOpacity(0.3) : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _isReturnMode ? Colors.orange[100]! : Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Item Name', style: TextStyle(color: Colors.grey)),
                    Text(
                      widget.payload.itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Stock', style: TextStyle(color: Colors.grey)),
                    _isFetchingStock 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          '$_availableStock units available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: _availableStock > 0 ? Colors.green[700] : Colors.red,
                          ),
                        ),
                  ],
                ),
                if (_isReturnMode) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Qty to Return', style: TextStyle(color: Colors.grey)),
                      Text(
                        '$_requestedQuantity',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          
          if (_isReturnMode && _allActiveBorrows.length > 1) ...[
            const Text(
              'SELECT BORROWING SESSION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
            ),
            const Gap(12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _allActiveBorrows.length,
                itemBuilder: (context, index) {
                  final log = _allActiveBorrows[index];
                  final isSelected = _selectedLog?['id'] == log['id'];
                  final date = DateTime.tryParse(log['borrow_date'] ?? '') ?? DateTime.now();
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLog = log;
                        _requestedQuantity = log['quantity'];
                      });
                      HapticFeedback.mediumImpact();
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? Colors.orange : Colors.grey[300]!),
                        boxShadow: isSelected ? [
                          BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ] : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${log['quantity']} Units',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${date.month}/${date.day}/${date.year}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(24),
          ],

          const Gap(24),

          // Quantity Selector (Borrow or Partial Return)
          Column(
            children: [
              Text(
                _isReturnMode ? 'RETURN QUANTITY' : 'BORROW QUANTITY',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: (!_isLoading && _requestedQuantity > 1) ? () => _adjustQuantity(-1) : null,
                  ),
                  const Gap(30),
                  Text(
                    '$_requestedQuantity',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const Gap(30),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: (!_isLoading && _requestedQuantity < (_isReturnMode ? (_selectedLog?['quantity'] ?? 0) : _availableStock)) ? () => _adjustQuantity(1) : null,
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),

          const Gap(24),

          if (_isReturnMode) ...[
            // RETURN ASSESSMENT UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONDITION UPON RETURN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ),
                const Gap(12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildConditionButton('Good', Icons.check_circle_outline, Colors.green),
                      const Gap(8),
                      _buildConditionButton('Maintenance', Icons.build_outlined, Colors.orange),
                      const Gap(8),
                      _buildConditionButton('Damaged', Icons.error_outline, Colors.red),
                      const Gap(8),
                      _buildConditionButton('Lost', Icons.help_outline, Colors.grey),
                    ],
                  ),
                ),
                const Gap(16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Add remarks (optional)',
                    hintStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ],

          if (_fetchError != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        _fetchError!,
                        style: TextStyle(color: Colors.red[700], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().shake(),
            
          const Gap(32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const Gap(16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (_isLoading || _availableStock <= 0 || _isFetchingStock) ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isReturnMode ? 'Confirm Return' : 'Confirm Borrow', 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                ),
              ),
            ],
          ).animate(delay: 600.ms).fadeIn().moveY(begin: 20, end: 0),
          
          Gap(MediaQuery.of(context).padding.bottom),
        ],
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
      color: Colors.blue[50],
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.blue[700]),
        onPressed: onPressed,
        disabledColor: Colors.grey[300],
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
