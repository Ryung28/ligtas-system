import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/widgets/premium_field.dart';
import '../../../core/design_system/widgets/quantity_stepper.dart';
import '../../../core/design_system/widgets/step_pill.dart';
import '../../../core/design_system/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inventory/models/inventory_model.dart';
import '../models/borrow_request_state.dart';
import '../providers/borrow_request_provider.dart';
import '../../navigation/providers/navigation_provider.dart';

/// Borrow Request Sheet - Multi-step form for equipment borrowing
/// Uses reusable widgets from core/design_system
class BorrowRequestSheet extends ConsumerStatefulWidget {
  final InventoryModel item;

  const BorrowRequestSheet({super.key, required this.item});

  /// Show the borrow request sheet
  static Future<bool> show(BuildContext context, {required InventoryModel item}) async {
    final container = ProviderScope.containerOf(context);
    container.read(borrowRequestProvider.notifier).reset();
    
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => BorrowRequestSheet(item: item),
    );
    
    // Always restore dock visibility when sheet closes
    container.read(isDockSuppressedProvider.notifier).state = false;
    
    return result ?? false;
  }

  @override
  ConsumerState<BorrowRequestSheet> createState() => _BorrowRequestSheetState();
}

class _BorrowRequestSheetState extends ConsumerState<BorrowRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(isDockSuppressedProvider.notifier).state = true;
    });
    
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _contactCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _orgCtrl = TextEditingController(text: user?.organization ?? '');
    _purposeCtrl = TextEditingController(text: '');
    _notesCtrl = TextEditingController(text: '');

    Future.microtask(() {
      if (!mounted) return;
      ref.read(borrowRequestProvider.notifier).initiateWithItem(widget.item);
    });
  }

  @override
  void dispose() {
    // Note: Dock visibility is restored in the show() method after sheet closes
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _orgCtrl.dispose();
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    final n = ref.read(borrowRequestProvider.notifier);
    n.updateBorrowerName(_nameCtrl.text.trim());
    n.updateBorrowerContact(_contactCtrl.text.trim());
    n.updateBorrowerEmail(_emailCtrl.text.trim());
    n.updateBorrowerOrganization(_orgCtrl.text.trim());
    n.updatePurpose(_purposeCtrl.text.trim());
    n.updateNotes(_notesCtrl.text.trim());
    n.proceedToReview();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(borrowRequestProvider);
    final notifier = ref.read(borrowRequestProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              _buildHeader(state.currentStep),
              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _buildStep(state, notifier, scrollController),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BorrowStep step) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StepPill(label: '1 Details', isActive: step == BorrowStep.form, isDone: step != BorrowStep.form),
              const Gap(6),
              StepPill(label: '2 Review', isActive: step == BorrowStep.review, isDone: step == BorrowStep.success),
              const Gap(6),
              StepPill(label: '3 Done', isActive: step == BorrowStep.success, isDone: false),
            ],
          ),
          const Gap(16),
          const Text('Request Equipment', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.8)),
          const Gap(4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(widget.item.category.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, letterSpacing: 0.8)),
              ),
              const Gap(8),
              Flexible(child: Text(widget.item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          if (widget.item.available < 5 && widget.item.available > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFD97706)),
                    const Gap(6),
                    Text('Only ${widget.item.available} unit(s) remaining', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(BorrowRequestState state, BorrowRequestNotifier notifier, ScrollController scrollController) {
    if (state.currentStep == BorrowStep.form) {
      return _buildFormStep(state, notifier, scrollController);
    } else if (state.currentStep == BorrowStep.review) {
      return _buildReviewStep(state, notifier, scrollController);
    } else {
      return _buildSuccessStep();
    }
  }

  Widget _buildFormStep(BorrowRequestState state, BorrowRequestNotifier notifier, ScrollController scrollController) {
    return Form(
      key: _formKey,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _buildSectionLabel('YOUR DETAILS', Icons.person_rounded),
          const Gap(10),
          PremiumField(controller: _nameCtrl, label: 'Full Name', icon: Icons.badge_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Full name is required' : null),
          const Gap(12),
          Row(
            children: [
              Expanded(child: PremiumField(controller: _contactCtrl, label: 'Contact No.', icon: Icons.phone_rounded, inputType: TextInputType.phone, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null)),
              const Gap(12),
              Expanded(child: PremiumField(controller: _emailCtrl, label: 'Email (optional)', icon: Icons.email_rounded, inputType: TextInputType.emailAddress)),
            ],
          ),
          const Gap(12),
          PremiumField(controller: _orgCtrl, label: 'Office / Organization', hint: 'e.g. CDRRMO, BFP, CSWD', icon: Icons.account_balance_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Office / Org is required' : null),
          const Gap(20),
          _buildSectionLabel('REQUEST DETAILS', Icons.assignment_rounded),
          const Gap(10),
          QuantityStepper(value: state.quantity, maxValue: state.selectedItem?.available ?? 5, onChanged: notifier.updateQuantity),
          const Gap(12),
          _buildDatePicker(state, notifier),
          const Gap(12),
          PremiumField(controller: _purposeCtrl, label: 'Purpose of Borrowing', hint: 'e.g., Emergency drill, Training exercise', icon: Icons.description_rounded, maxLines: 3, validator: (v) => (v == null || v.isEmpty) ? 'Please describe your purpose' : null),
          const Gap(12),
          PremiumField(controller: _notesCtrl, label: 'Additional Notes (optional)', icon: Icons.edit_note_rounded, maxLines: 2),
          const Gap(32),
          PrimaryButton(label: 'Review Request', icon: Icons.arrow_forward_rounded, onPressed: _onNextPressed),
          const Gap(80),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
      ),
    );
  }

  Widget _buildReviewStep(BorrowRequestState state, BorrowRequestNotifier notifier, ScrollController scrollController) {
    final item = state.selectedItem;
    final returnDate = state.expectedReturnDate ?? DateTime.now().add(const Duration(days: 7));

    if (item == null) return const Center(child: CircularProgressIndicator.adaptive());

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Borrow Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const Gap(16),
              _buildReviewRow('Item', item.name),
              _buildReviewRow('Category', item.category),
              _buildReviewRow('Quantity', '${state.quantity} ${item.unit}'),
              _buildReviewRow('Borrower', state.borrowerName),
              _buildReviewRow('Contact', state.borrowerContact),
              _buildReviewRow('Organization', state.borrowerOrganization),
              _buildReviewRow('Purpose', state.purpose),
              _buildReviewRow('Expected Return', '${returnDate.day}/${returnDate.month}/${returnDate.year}'),
              if (state.notes.isNotEmpty) _buildReviewRow('Notes', state.notes),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2))),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primaryBlue),
              Gap(10),
              Expanded(child: Text('Your request will be reviewed by CDRRMO Admin before approval. You will be notified of the status.', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.5))),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        if (state.submissionError != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
                  const Gap(8),
                  Expanded(child: Text(state.submissionError!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
            ).animate().fadeIn().shake(),
          ),
        const Gap(32),
        PrimaryButton(label: state.isSubmitting ? 'Submitting...' : 'Confirm & Submit', icon: state.isSubmitting ? null : Icons.check_rounded, isLoading: state.isSubmitting, onPressed: state.isSubmitting ? null : notifier.submitRequest),
        const Gap(8),
        TextButton(onPressed: state.isSubmitting ? null : notifier.goBackToForm, child: const Text('← Edit Details', style: TextStyle(color: Color(0xFF64748B)))),
        const Gap(80),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, size: 56, color: Color(0xFF10B981)),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const Gap(24),
          const Text('Request Submitted!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)), textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
          const Gap(12),
          const Text('Your borrow request has been sent to CDRRMO Admin for review. You will be notified of the approval status.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6), textAlign: TextAlign.center).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const Gap(40),
          PrimaryButton(label: 'Done', icon: Icons.done_all_rounded, onPressed: () => Navigator.of(context).pop(true)).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryBlue),
        const Gap(6),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, letterSpacing: 1.0)),
        const Gap(8),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildDatePicker(BorrowRequestState state, BorrowRequestNotifier notifier) {
    final selectedDate = state.expectedReturnDate ?? DateTime.now().add(const Duration(days: 7));
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue)),
              child: child!,
            );
          },
        );
        if (date != null) notifier.updateReturnDate(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF64748B)),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expected Return Date', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }
}
