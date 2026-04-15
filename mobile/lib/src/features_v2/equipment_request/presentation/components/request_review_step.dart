import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_state.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/borrow_request_provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features_v2/equipment_request/presentation/widgets/tactile_mission_progress.dart';

class RequestReviewStep extends ConsumerWidget {
  final BorrowRequestState state;
  final BorrowRequestNotifier notifier;

  const RequestReviewStep({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentinel = Theme.of(context).sentinel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionHeader(sentinel),
        const Gap(24),
        TactileMissionProgress(currentStep: 2, sentinel: sentinel),
        const Gap(32),
        _Heading(text: 'REQUEST SUMMARY', sentinel: sentinel),
        const Gap(16),
        _UnifiedReviewCard(state: state, sentinel: sentinel),
      ],
    );
  }

  Widget _buildActionHeader(SentinelColors sentinel) {
    return Row(
      children: [
        IconButton(onPressed: () => notifier.goBackToForm(), icon: Icon(Icons.arrow_back_rounded, color: sentinel.navy)),
        Expanded(child: Center(child: Text('Review Details', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800, color: sentinel.navy)))),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _UnifiedReviewCard extends StatelessWidget {
  final BorrowRequestState state;
  final SentinelColors sentinel;
  const _UnifiedReviewCard({required this.state, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: sentinel.tactile.recessed,
      ),
      child: Column(
        children: [
          ...state.cartItems.map((cartItem) {
            final itemId = cartItem.item.id.toString();
            final pickupDate = state.itemPickupDates[itemId];
            final isNotToday = pickupDate != null && DateUtils.isSameDay(pickupDate, DateTime.now()) == false;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cartItem.item.name, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: sentinel.navy)),
                      if (isNotToday)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 10, color: sentinel.navy.withOpacity(0.4)),
                              const Gap(4),
                              Text(
                                'PICKUP: ${DateFormat('MMM dd, yyyy').format(pickupDate!)}',
                                style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w800, color: sentinel.navy.withOpacity(0.4)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text('${cartItem.quantity} ${cartItem.item.unit.toUpperCase()}', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: sentinel.navy)),
                ],
              ),
            );
          }),
          Divider(height: 32, color: sentinel.navy.withOpacity(0.05)),
          
          _ReviewRow(label: 'Borrower', value: state.borrowerName, sentinel: sentinel),
          _ReviewRow(label: 'Organization', value: state.borrowerOrganization, sentinel: sentinel),
          _ReviewRow(label: 'Return Date', value: state.expectedReturnDate != null ? DateFormat('MMM dd, yyyy').format(state.expectedReturnDate!) : 'Not set', sentinel: sentinel),
          Divider(height: 32, color: sentinel.navy.withOpacity(0.05)),
          
          _ReviewRow(label: 'Purpose', value: state.purpose, sentinel: sentinel),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final SentinelColors sentinel;
  const _ReviewRow({required this.label, required this.value, required this.sentinel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: sentinel.navy.withOpacity(0.4))),
          const Gap(16),
          Flexible(child: Text(value, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: sentinel.navy), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  final SentinelColors sentinel;
  const _Heading({required this.text, required this.sentinel});

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
