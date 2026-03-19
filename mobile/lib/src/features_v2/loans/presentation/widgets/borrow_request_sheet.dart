import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/core/design_system/widgets/premium_field.dart';
import 'package:mobile/src/core/design_system/widgets/quantity_stepper.dart';
import 'package:mobile/src/core/design_system/widgets/step_pill.dart';
import 'package:mobile/src/core/design_system/widgets/primary_button.dart';
import 'package:mobile/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import '../providers/borrow_request_state.dart';
import '../providers/borrow_request_provider.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';

class BorrowRequestSheet extends ConsumerStatefulWidget {
  final InventoryItem item;

  const BorrowRequestSheet({super.key, required this.item});

  static Future<bool> show(BuildContext context, {required InventoryItem item}) async {
    final container = ProviderScope.containerOf(context);
    container.read(borrowRequestNotifierProvider.notifier).reset();
    
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => BorrowRequestSheet(item: item),
    );
    
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
      ref.read(borrowRequestNotifierProvider.notifier).initiateWithItem(widget.item);
    });
  }

  @override
  void dispose() {
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
    final n = ref.read(borrowRequestNotifierProvider.notifier);
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
    final state = ref.watch(borrowRequestNotifierProvider);
    final notifier = ref.read(borrowRequestNotifierProvider.notifier);

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
              _buildHeader(state.currentStep),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
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
              _buildStepIndicator(1, 'Request', step == BorrowStep.form),
              _buildConnector(step != BorrowStep.form),
              _buildStepIndicator(2, 'Review', step == BorrowStep.review),
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
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int number, String label, bool isActive) {
    final color = isActive ? AppTheme.primaryBlue : const Color(0xFFCBD5E1);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        const Gap(8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildConnector(bool isDone) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDone ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildStep(BorrowRequestState state, BorrowRequestNotifier notifier, ScrollController scrollController) {
    if (state.currentStep == BorrowStep.form) return _buildFormStep(state, notifier, scrollController);
    if (state.currentStep == BorrowStep.review) return _buildReviewStep(state, notifier, scrollController);
    return _buildSuccessStep();
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
          PremiumField(controller: _nameCtrl, label: 'Full Name', icon: Icons.badge_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null),
          const Gap(12),
          PremiumField(controller: _contactCtrl, label: 'Contact No.', icon: Icons.phone_rounded),
          const Gap(12),
          PremiumField(controller: _orgCtrl, label: 'Office / Organization', icon: Icons.account_balance_rounded),
          const Gap(20),
          _buildSectionLabel('REQUEST DETAILS', Icons.assignment_rounded),
          const Gap(10),
          QuantityStepper(value: state.quantity, maxValue: widget.item.availableStock, onChanged: notifier.updateQuantity),
          const Gap(12),
          _buildDatePicker(state, notifier),
          const Gap(12),
          PremiumField(controller: _purposeCtrl, label: 'Purpose', icon: Icons.description_rounded, maxLines: 2),
          const Gap(32),
          PrimaryButton(label: 'Review Request', icon: Icons.arrow_forward_rounded, onPressed: _onNextPressed),
          const Gap(80),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
      ),
    );
  }

  Widget _buildReviewStep(BorrowRequestState state, BorrowRequestNotifier notifier, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        if (state.submissionError != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                const Gap(10),
                Expanded(child: Text(state.submissionError!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))),
              ],
            ),
          ).animate().shake(),
          
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const Gap(20),
              _buildReviewRow('Item', widget.item.name, icon: Icons.inventory_2_rounded),
              _buildReviewRow('Quantity', '${state.quantity} ${widget.item.unit}', icon: Icons.unfold_more_rounded),
              _buildReviewRow('Borrower', state.borrowerName, icon: Icons.person_rounded),
              _buildReviewRow('Email', state.borrowerEmail, icon: Icons.email_rounded),
              _buildReviewRow('Organization', state.borrowerOrganization, icon: Icons.corporate_fare_rounded),
              if (state.purpose.isNotEmpty)
                _buildReviewRow('Purpose', state.purpose, icon: Icons.description_rounded),
              _buildReviewRow('Return By', '${state.expectedReturnDate?.day}/${state.expectedReturnDate?.month}/${state.expectedReturnDate?.year}', icon: Icons.calendar_today_rounded),
            ],
          ),
        ),
        const Gap(32),
        PrimaryButton(
          label: state.isSubmitting ? 'Processing Request...' : 'Confirm & Submit Request', 
          icon: state.isSubmitting ? null : Icons.send_rounded, 
          isLoading: state.isSubmitting, 
          onPressed: state.isSubmitting ? null : () async {
            HapticFeedback.mediumImpact();
            await notifier.submitRequest();
          }
        ),
        const Gap(12),
        Center(
          child: TextButton(
            onPressed: notifier.goBackToForm, 
            child: const Text('Back to Edit', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700))
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, size: 80, color: Color(0xFF10B981)),
        const Gap(24),
        const Text('Request Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Gap(40),
        PrimaryButton(label: 'Done', onPressed: () => Navigator.of(context).pop(true)),
      ],
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
            Text('Return Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
            const Gap(12),
          ],
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }
}
