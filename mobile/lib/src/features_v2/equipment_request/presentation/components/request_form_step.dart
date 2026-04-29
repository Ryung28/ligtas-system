import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_state.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_provider.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/recessed_hub_card.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/tactile_mission_progress.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/tactile_quantity_stepper.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/tactile_calendar_modal.dart';

class RequestFormStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController emailController;
  final TextEditingController officeController;
  final TextEditingController purposeController;
  final BorrowRequestState state;
  final BorrowRequestNotifier notifier;

  const RequestFormStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.contactController,
    required this.emailController,
    required this.officeController,
    required this.purposeController,
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<RequestFormStep> createState() => _RequestFormStepState();
}

class _RequestFormStepState extends ConsumerState<RequestFormStep> {
  bool _isEditingRequester = false;

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionHeader(context, sentinel),
          const Gap(24),
          TactileMissionProgress(currentStep: 1, sentinel: sentinel),
          const Gap(32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(text: 'REQUESTER DETAILS', sentinel: sentinel),
              if (!_isEditingRequester)
                GestureDetector(
                  onTap: () => setState(() => _isEditingRequester = true),
                  child: Text(
                    'EDIT INFO',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: sentinel.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(16),
          
          if (_isEditingRequester)
            _buildEditableRequester(sentinel)
          else
            _buildStaticRequester(sentinel),

          const Gap(32),

          // 📦 ITEM LIST
          _SectionLabel(text: 'ITEMS FOR BORROWING', sentinel: sentinel),
          const Gap(16),
          if (widget.state.cartItems.isEmpty) 
            _buildEmptyCart(sentinel)
          else
            ...widget.state.cartItems.map((cartItem) {
            final itemId = cartItem.item.id.toString();
            final pickupDate = widget.state.itemPickupDates[itemId];
            final isNotToday = pickupDate != null && DateUtils.isSameDay(pickupDate, DateTime.now()) == false;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecessedHubCard(
                label: cartItem.item.name.toUpperCase(),
                sentinel: sentinel,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'QTY:', 
                          style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: sentinel.navy.withOpacity(0.4)),
                        ),
                        const Gap(8),
                        TactileQuantityStepper(
                          value: cartItem.quantity,
                          label: cartItem.item.unit,
                          max: cartItem.item.displayStock,
                          onChanged: (val) {
                            widget.notifier.updateItemQuantity(itemId, val);
                          },
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _showDatePicker(
                          context: context,
                          initialDate: pickupDate ?? DateTime.now(),
                          minDate: DateTime.now(),
                          title: 'Pickup Schedule',
                          onDateSelected: (day) => widget.notifier.updateItemPickupDate(itemId, day),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isNotToday ? sentinel.navy : sentinel.navy.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isNotToday ? Icons.schedule_rounded : Icons.flash_on_rounded, 
                              size: 10, 
                              color: isNotToday ? Colors.white : sentinel.navy.withOpacity(0.4),
                            ),
                            const Gap(6),
                            Text(
                              isNotToday 
                                ? DateFormat('MMM dd').format(pickupDate).toUpperCase()
                                : 'TODAY',
                              style: GoogleFonts.lexend(
                                fontSize: 9, 
                                fontWeight: FontWeight.w800, 
                                color: isNotToday ? Colors.white : sentinel.navy.withOpacity(0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Gap(24),

          _SectionLabel(text: 'REQUEST DETAILS', sentinel: sentinel),
          const Gap(16),
          
          RecessedHubCard(
            label: 'Estimated Return Date',
            sentinel: sentinel,
            height: 85,
            onTap: () => _showDatePicker(
              context: context,
              initialDate: widget.state.expectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
              minDate: DateTime.now().add(const Duration(days: 1)),
              onDateSelected: (day) => widget.notifier.updateReturnDate(day),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.state.expectedReturnDate != null 
                    ? DateFormat('MMMM dd, yyyy').format(widget.state.expectedReturnDate!)
                    : 'Select Return Date',
                  style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w800, color: sentinel.navy),
                ),
                Icon(Icons.calendar_today_outlined, size: 16, color: sentinel.navy.withOpacity(0.5)),
              ],
            ),
          ),
          const Gap(16),
          
          RecessedHubCard(
            label: 'Purpose of Request',
            sentinel: sentinel,
            child: TextFormField(
              controller: widget.purposeController,
              maxLines: 2,
              validator: (v) => (v == null || v.isEmpty) ? 'Purpose required' : null,
              style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy),
              decoration: InputDecoration(
                hintText: 'Specify use case or reason...',
                hintStyle: GoogleFonts.lexend(color: sentinel.navy.withOpacity(0.3)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRequester(SentinelColors sentinel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: Column(
        children: [
          _SummaryRow(icon: Icons.person_outline_rounded, text: widget.nameController.text, sentinel: sentinel),
          const Gap(12),
          _SummaryRow(icon: Icons.business_center_outlined, text: widget.officeController.text, sentinel: sentinel),
          const Gap(12),
          _SummaryRow(icon: Icons.phone_android_rounded, text: widget.contactController.text, sentinel: sentinel),
        ],
      ),
    );
  }

  Widget _buildEditableRequester(SentinelColors sentinel) {
    return Column(
      children: [
        RecessedHubCard(
          label: 'Full Name',
          sentinel: sentinel,
          child: TextFormField(
            controller: widget.nameController,
            validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy),
            decoration: InputDecoration(
              hintText: 'Your full name...',
              hintStyle: GoogleFonts.lexend(color: sentinel.navy.withOpacity(0.3)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4),
            ),
          ),
        ),
        const Gap(16),
        RecessedHubCard(
          label: 'Contact Number',
          sentinel: sentinel,
          child: TextFormField(
            controller: widget.contactController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Contact required';
              if (v.length != 11) return 'Must be 11 digits';
              if (!v.startsWith('09')) return 'Must start with 09';
              return null;
            },
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy),
            decoration: InputDecoration(
              hintText: '09XX XXX XXXX',
              hintStyle: GoogleFonts.lexend(color: sentinel.navy.withOpacity(0.3)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4),
            ),
          ),
        ),
        const Gap(16),
        RecessedHubCard(
          label: 'Department / Office',
          sentinel: sentinel,
          child: TextFormField(
            controller: widget.officeController,
            validator: (v) => (v == null || v.isEmpty) ? 'Office required' : null,
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy),
            decoration: InputDecoration(
              hintText: 'e.g. CDRRMO, BFP...',
              hintStyle: GoogleFonts.lexend(color: sentinel.navy.withOpacity(0.3)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4),
            ),
          ),
        ),
        const Gap(20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (widget.formKey.currentState!.validate()) {
                setState(() => _isEditingRequester = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: sentinel.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'SAVE CHANGES',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionHeader(BuildContext context, SentinelColors sentinel) {
    return Row(
      children: [
        IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close_rounded, color: sentinel.navy)),
        Expanded(
          child: Center(
            child: Text(
              'Request Items', 
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800, color: sentinel.navy),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  void _showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime) onDateSelected,
    DateTime? minDate,
    String? title,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        height: 520,
        padding: const EdgeInsets.all(24),
        child: TactileCalendarModal(
          initialDate: initialDate,
          minDate: minDate,
          title: title,
          onDateSelected: onDateSelected,
        ),
      ),
    );
  }

  Widget _buildEmptyCart(SentinelColors sentinel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: sentinel.navy.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sentinel.navy.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 40, color: sentinel.navy.withOpacity(0.2)),
          const Gap(16),
          Text(
            'NO ITEMS SELECTED',
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.4), letterSpacing: 1),
          ),
          const Gap(4),
          Text(
            'Go back to inventory to add equipment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: sentinel.navy.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final SentinelColors sentinel;
  const _SectionLabel({required this.text, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: sentinel.navy, borderRadius: BorderRadius.circular(2))),
        const Gap(8),
        Text(text, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.5), letterSpacing: 1.5)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final SentinelColors sentinel;
  const _SummaryRow({required this.icon, required this.text, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: sentinel.navy.withOpacity(0.4)),
        const Gap(12),
        Expanded(
          child: Text(
            text.isEmpty ? 'Not Provided' : text, 
            style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: sentinel.navy),
          ),
        ),
      ],
    );
  }
}

