import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/components/app_card.dart';
import '../models/loan_model.dart';

/// Professional loan card component
class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final bool isOverdue;
  final bool showHistory;

  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.isOverdue = false,
    this.showHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLoanOverdue = loan.daysOverdue > 0;
    final effectiveOverdue = isOverdue || isLoanOverdue;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      animate: true,
      animationDelay: animationDelay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with item name and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.itemName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      'Code: ${loan.itemCode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.sm),
              _buildStatusChip(effectiveOverdue),
            ],
          ),
          
          const Gap(AppSpacing.md),
          
          // Borrower info
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: AppSizing.iconSm,
                color: AppTheme.neutralGray600,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  loan.borrowerName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray100,
                  borderRadius: AppRadius.allSm,
                ),
                child: Text(
                  'Qty: ${loan.quantityBorrowed}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const Gap(AppSpacing.sm),
          
          // Contact and timing info
          Row(
            children: [
              Icon(
                Icons.phone_rounded,
                size: AppSizing.iconSm,
                color: AppTheme.neutralGray600,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  loan.borrowerContact,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _buildTimingInfo(context, effectiveOverdue),
            ],
          ),
          
          const Gap(AppSpacing.sm),
          
          // Purpose
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                size: AppSizing.iconSm,
                color: AppTheme.neutralGray600,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  loan.purpose,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Additional info for history view
          if (showHistory && loan.actualReturnDate != null) ...[
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: AppSizing.iconSm,
                  color: AppTheme.successGreen,
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Returned on ${_formatDate(loan.actualReturnDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Overdue warning
          if (effectiveOverdue && loan.status == LoanStatus.active) ...[
            const Gap(AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: AppRadius.allSm,
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: AppSizing.iconSm,
                    color: AppTheme.errorRed,
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Overdue by ${loan.daysOverdue} day${loan.daysOverdue != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
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

  Widget _buildStatusChip(bool isOverdue) {
    if (isOverdue && loan.status == LoanStatus.active) {
      return AppStatusChip.error('OVERDUE', icon: Icons.warning_rounded);
    }
    
    switch (loan.status) {
      case LoanStatus.active:
        return AppStatusChip.warning('ACTIVE', icon: Icons.schedule_rounded);
      case LoanStatus.returned:
        return AppStatusChip.success('RETURNED', icon: Icons.check_circle_rounded);
      case LoanStatus.overdue:
        return AppStatusChip.error('OVERDUE', icon: Icons.warning_rounded);
      case LoanStatus.cancelled:
        return AppStatusChip.info('CANCELLED', icon: Icons.cancel_rounded);
      case LoanStatus.pending:
        return AppStatusChip.info('PENDING', icon: Icons.hourglass_empty_rounded);
    }
  }

  Widget _buildTimingInfo(BuildContext context, bool isOverdue) {
    if (showHistory && loan.actualReturnDate != null) {
      final duration = loan.actualReturnDate!.difference(loan.borrowDate).inDays;
      return Text(
        '$duration day${duration != 1 ? 's' : ''} duration',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.neutralGray600,
        ),
      );
    }
    
    if (loan.status == LoanStatus.active) {
      return Text(
        '${loan.daysBorrowed} day${loan.daysBorrowed != 1 ? 's' : ''} ago',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isOverdue ? AppTheme.errorRed : AppTheme.neutralGray600,
          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }
    
    return Text(
      _formatDate(loan.borrowDate),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.neutralGray600,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}