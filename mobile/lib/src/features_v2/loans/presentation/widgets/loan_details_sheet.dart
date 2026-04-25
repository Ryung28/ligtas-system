import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';
import 'package:mobile/src/core/design_system/widgets/tactical_forensic_detail_sheet.dart';
import 'package:mobile/src/features/navigation/providers/navigation_provider.dart';
import '../../domain/entities/loan_item.dart';
import '../../../../core/design_system/app_theme.dart';
import 'package:gap/gap.dart';

class LoanDetailsSheet extends ConsumerWidget {
  final LoanItem loan;
  final bool readOnly;

  const LoanDetailsSheet({
    super.key,
    required this.loan,
    this.readOnly = true, 
  });

  /// 🛡️ PROTECTED INVOCATION: Orchestrates dock suppression for loan forensics.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetRef ref,
    required LoanItem loan,
    bool readOnly = true,
  }) async {
    ref.read(isDockSuppressedProvider.notifier).state = true;
    
    final result = await showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoanDetailsSheet(loan: loan, readOnly: readOnly),
    );

    ref.read(isDockSuppressedProvider.notifier).state = false;
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPending = loan.status == LoanStatus.pending;
    final bool isApproved = loan.status == LoanStatus.active && loan.handedBy == null;

    final statusInfo = _getStatusInfo(loan.status);

    return TacticalForensicDetailSheet(
      id: loan.id,
      title: loan.itemName,
      referenceId: 'ASSET-${loan.itemCode}',
      statusLabel: statusInfo.label,
      accentColor: statusInfo.color,
      isAlertStatus: statusInfo.isAlert,
      statusIcon: statusInfo.icon,
      imageUrl: loan.imageUrl,
      heroTagPrefix: 'loan',
      purpose: loan.purpose,
      details: [
        DetailRowData(
          icon: Icons.person_outline_rounded,
          label: 'Borrower',
          value: loan.borrowerName,
        ),
        DetailRowData(
          icon: Icons.calendar_today_rounded,
          label: 'Borrow Date',
          value: _formatDate(loan.borrowDate),
        ),
        DetailRowData(
          icon: Icons.event_available_rounded,
          label: 'Expected Return',
          value: _formatDate(loan.expectedReturnDate),
        ),
      ],
      actionHub: _buildActionHub(context, ref, isPending, isApproved, loan.status == LoanStatus.staged),
      heroHeight: 190,
    );
  }

  Widget _buildActionHub(BuildContext context, WidgetRef ref, bool isPending, bool isApproved, bool isStaged) {
    if (!readOnly && isPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('DECLINE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
          ),
          const Gap(16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(managerLoansNotifierProvider.notifier).approveRequest(loan.id);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('AUTHORIZE', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    } else if (!readOnly && isStaged) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await ref.read(managerLoansNotifierProvider.notifier).releaseReservation(int.parse(loan.id));
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.handshake_rounded),
          label: const Text('RELEASE TO PERSONNEL', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    } else if (!readOnly && isApproved) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await ref.read(managerLoansNotifierProvider.notifier).confirmHandoff(loan.id);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.handshake_rounded),
          label: const Text('READY FOR DISPATCH', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('ACKNOWLEDGE', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
    }
  }

  _StatusInfo _getStatusInfo(LoanStatus status) {
    String label = status.name.toUpperCase();
    Color color = Colors.grey;
    IconData icon = Icons.info_outline_rounded;
    bool isAlert = false;

    switch (status) {
      case LoanStatus.pending:
        label = 'AWAITING APPROVAL';
        color = const Color(0xFF92400E);
        icon = Icons.access_time_filled_rounded;
        isAlert = true;
        break;
      case LoanStatus.active:
        if (loan.handedBy == null) {
          label = 'READY FOR DISPATCH';
          color = AppTheme.successGreen;
          icon = Icons.local_shipping_rounded;
        } else {
          label = 'IN USE';
          color = AppTheme.primaryBlue;
          icon = Icons.check_circle_rounded;
        }
        break;
      case LoanStatus.overdue:
        label = 'OVERDUE NOTICE';
        color = Colors.redAccent;
        icon = Icons.warning_amber_rounded;
        isAlert = true;
        break;
      case LoanStatus.returned:
        label = 'RETURNED & STORED';
        color = Colors.grey[600]!;
        icon = Icons.inventory_2_rounded;
        break;
      case LoanStatus.cancelled:
        label = 'CANCELLED';
        color = Colors.grey[400]!;
        icon = Icons.cancel_outlined;
        break;
      case LoanStatus.staged:
        label = 'STAGED & READY';
        color = AppTheme.primaryBlue;
        icon = Icons.assignment_turned_in_rounded;
        isAlert = true;
        break;
      default:
        break;
    }

    return _StatusInfo(label: label, color: color, icon: icon, isAlert: isAlert);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy, hh:mm a').format(date).toUpperCase();
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;
  final bool isAlert;

  _StatusInfo({required this.label, required this.color, required this.icon, required this.isAlert});
}
