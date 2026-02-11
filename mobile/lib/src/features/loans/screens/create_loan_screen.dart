import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../scanner/widgets/scanner_view.dart';
import '../models/loan_model.dart';
import '../providers/loan_providers.dart';
import '../services/cdrrmo_items_service.dart';
import '../models/cdrrmo_item_model.dart';
import '../../auth/providers/auth_provider.dart';

/// Screen for submitting borrow requests with QR scanner integration
class CreateLoanScreen extends ConsumerStatefulWidget {
  final String? scannedItemId;

  const CreateLoanScreen({
    super.key,
    this.scannedItemId,
  });

  @override
  ConsumerState<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends ConsumerState<CreateLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _borrowerContactController = TextEditingController();
  final _borrowerEmailController = TextEditingController();
  final _borrowerOrganizationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  String? _selectedItemId;
  String? _selectedItemName;
  String? _selectedItemCode;
  String? _selectedItemCategory;
  String? _selectedItemDescription;
  DateTime _expectedReturnDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.scannedItemId != null) {
      _selectedItemId = widget.scannedItemId;
      _loadItemDetails();
    }
    
    // Pre-fill user information
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        setState(() {
          _borrowerNameController.text = user.displayName ?? '';
          _borrowerContactController.text = user.phoneNumber ?? '';
          _borrowerEmailController.text = user.email ?? '';
          _borrowerOrganizationController.text = user.organization ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _borrowerContactController.dispose();
    _borrowerEmailController.dispose();
    _borrowerOrganizationController.dispose();
    _purposeController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadItemDetails() async {
    if (_selectedItemId == null) return;
    
    // Find item in CDRRMO items service
    final item = CdrrmoItemsService.findItem(_selectedItemId!);
    
    setState(() {
      if (item != null) {
        _selectedItemName = item.name;
        _selectedItemCode = item.code;
        _selectedItemCategory = item.category;
        _selectedItemDescription = item.description;
      } else {
        _selectedItemName = 'Unknown Item';
        _selectedItemCode = _selectedItemId!;
        _selectedItemCategory = 'Unknown';
        _selectedItemDescription = 'Item not found in CDRRMO inventory';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralGray50,
      appBar: AppBar(
        title: const Text('Borrow Item Request'),
        actions: [
          if (_selectedItemId == null)
            IconButton(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: 'Scan QR Code',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Selection Section
              _buildItemSelectionSection(),
              const Gap(AppSpacing.lg),
              
              // Borrower Information Section
              _buildBorrowerSection(),
              const Gap(AppSpacing.lg),
              
              // Loan Details Section
              _buildLoanDetailsSection(),
              const Gap(AppSpacing.lg),
              
              // Notes Section
              _buildNotesSection(),
              const Gap(AppSpacing.xl),
              
              // Submit Button
              _buildSubmitButton(),
              const Gap(AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSelectionSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_rounded,
                color: AppTheme.primaryBlue,
                size: AppSizing.iconMd,
              ),
              const Gap(AppSpacing.sm),
              Text(
                'CDRRMO Item Selection',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          
          if (_selectedItemId != null) ...[
            // Selected item display
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedItemName ?? 'Loading...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              'Code: ${_selectedItemCode ?? 'Loading...'}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.neutralGray600,
                              ),
                            ),
                            if (_selectedItemCategory != null) ...[
                              const Gap(AppSpacing.xs),
                              Text(
                                'Category: $_selectedItemCategory',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.neutralGray500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedItemId = null;
                            _selectedItemName = null;
                            _selectedItemCode = null;
                            _selectedItemCategory = null;
                            _selectedItemDescription = null;
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.successGreen,
                        size: AppSizing.iconSm,
                      ),
                      const Gap(AppSpacing.sm),
                      Text(
                        'Available for borrowing',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Item selection options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan QR Code'),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showItemPicker,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Browse Items'),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: AppTheme.warningAmber.withOpacity(0.1),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppTheme.warningAmber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.warningAmber,
                    size: AppSizing.iconSm,
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Scan the QR code on CDRRMO equipment to request borrowing',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBorrowerSection() {
    final bool isProfileComplete = _borrowerNameController.text.isNotEmpty && 
                                  _borrowerContactController.text.isNotEmpty &&
                                  _borrowerOrganizationController.text.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: AppTheme.primaryBlue,
                size: AppSizing.iconMd,
              ),
              const Gap(AppSpacing.sm),
              Text(
                'Borrower Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isProfileComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.successGreen),
                      const Gap(4),
                      Text(
                        'Verified',
                        style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.md),
          
          if (!isProfileComplete)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Please complete your contact details below.',
                style: TextStyle(color: AppTheme.errorRed, fontSize: 12),
              ),
            ),

          TextFormField(
            controller: _borrowerNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Name required' : null,
          ),
          const Gap(AppSpacing.md),
          
          TextFormField(
            controller: _borrowerContactController,
            decoration: const InputDecoration(
              labelText: 'Contact Number *',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty ?? true ? 'Number required' : null,
          ),
          const Gap(AppSpacing.md),
          
          TextFormField(
            controller: _borrowerOrganizationController,
            decoration: const InputDecoration(
              labelText: 'Office / Organization *',
              hintText: 'e.g. CDRRMO, BFP, CSWD',
              prefixIcon: Icon(Icons.account_balance_rounded),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Office required' : null,
          ),
          const Gap(AppSpacing.md),
          
          TextFormField(
            controller: _borrowerEmailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_rounded,
                color: AppTheme.primaryBlue,
                size: AppSizing.iconMd,
              ),
              const Gap(AppSpacing.sm),
              Text(
                'Borrow Request Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    hintText: 'Enter quantity',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter quantity';
                    }
                    final quantity = int.tryParse(value!);
                    if (quantity == null || quantity <= 0) {
                      return 'Please enter valid quantity';
                    }
                    if (quantity > 5) { // Reasonable limit for borrowing
                      return 'Maximum 5 units per request';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _selectReturnDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expected Return Date *',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      '${_expectedReturnDate.day}/${_expectedReturnDate.month}/${_expectedReturnDate.year}',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          
          TextFormField(
            controller: _purposeController,
            decoration: const InputDecoration(
              labelText: 'Purpose of Borrowing *',
              hintText: 'Enter purpose of borrowing (e.g., Emergency drill, Training)',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            maxLines: 2,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter purpose';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                color: AppTheme.primaryBlue,
                size: AppSizing.iconMd,
              ),
              const Gap(AppSpacing.sm),
              Text(
                'Additional Notes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Enter any additional notes (optional)',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || _selectedItemId == null ? null : _submitBorrowRequest,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Submit Borrow Request'),
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScannerView(
          onQrCodeDetected: (qrCode) {
            Navigator.of(context).pop();
            setState(() {
              _selectedItemId = qrCode;
            });
            _loadItemDetails();
          },
          overlayText: 'Scan CDRRMO equipment QR code to borrow',
        ),
      ),
    );
  }

  void _showItemPicker() {
    final items = CdrrmoItemsService.getAllItems();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select CDRRMO Item'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code: ${item.code}'),
                    Text(
                      'Category: ${item.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralGray600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedItemId = item.id;
                  });
                  _loadItemDetails();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expectedReturnDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _expectedReturnDate = date;
      });
    }
  }

  Future<void> _submitBorrowRequest() async {
    if (!_formKey.currentState!.validate() || _selectedItemId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateLoanRequest(
        inventoryItemId: _selectedItemId!,
        borrowerName: _borrowerNameController.text.trim(),
        borrowerContact: _borrowerContactController.text.trim(),
        borrowerEmail: _borrowerEmailController.text.trim(),
        borrowerOrganization: _borrowerOrganizationController.text.trim(),
        purpose: _purposeController.text.trim(),
        quantityBorrowed: int.parse(_quantityController.text),
        expectedReturnDate: _expectedReturnDate,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      await ref.read(myBorrowedItemsProvider.notifier).submitBorrowRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Borrow request submitted successfully! Admin will review your request.'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 4),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit borrow request: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}