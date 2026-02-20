import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_theme.dart';
import '../models/loan_model.dart';

/// Premium loan card component - clean, modern, premium
class PremiumLoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final bool isOverdue;
  final bool showHistory;

  const PremiumLoanCard({
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getCardBorderColor(effectiveOverdue),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Item name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.itemName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neutralGray900,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_rounded,
                              size: 14,
                              color: AppTheme.neutralGray500,
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              loan.itemCode,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.neutralGray600,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  _buildStatusBadge(context, effectiveOverdue),
                ],
              ),

              const Gap(AppSpacing.lg),

              // Key info row
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.person_rounded,
                    loan.borrowerName,
                    AppTheme.primaryBlue,
                  ),
                  const Gap(AppSpacing.sm),
                  _buildInfoChip(
                    context,
                    Icons.inventory_rounded,
                    'Qty ${loan.quantityBorrowed}',
                    AppTheme.neutralGray600,
                  ),
                ],
              ),

              const Gap(AppSpacing.sm),

              // Timing info
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: effectiveOverdue ? AppTheme.errorRed : AppTheme.neutralGray500,
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _formatTimingInfo(effectiveOverdue),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: effectiveOverdue ? AppTheme.errorRed : AppTheme.neutralGray600,
                        fontWeight: effectiveOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),

              // Purpose (truncated)
              if (loan.purpose.isNotEmpty) ...[
                const Gap(AppSpacing.sm),
                Text(
                  loan.purpose,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // History return status
              if (showHistory && loan.actualReturnDate != null) ...[
                const Gap(AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppTheme.successGreen,
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        'Returned',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Overdue warning badge
              if (effectiveOverdue && loan.status == LoanStatus.active) ...[
                const Gap(AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 16,
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
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400), delay: animationDelay)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          delay: animationDelay,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatusBadge(BuildContext context, bool isOverdue) {
    if (isOverdue && loan.status == LoanStatus.active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 14,
              color: Colors.white,
            ),
            const Gap(AppSpacing.xs),
            Text(
              'OVERDUE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    switch (loan.status) {
      case LoanStatus.active:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.warningAmber.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppTheme.warningAmber,
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Active',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.warningAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case LoanStatus.returned:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.successGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_rounded,
                size: 14,
                color: AppTheme.successGreen,
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Returned',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case LoanStatus.overdue:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.errorRed.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.errorRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 14,
                color: AppTheme.errorRed,
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Overdue',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case LoanStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.neutralGray200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neutralGray300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_rounded,
                size: 14,
                color: AppTheme.neutralGray500,
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Cancelled',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.neutralGray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case LoanStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.warningAmber.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 14,
                color: AppTheme.warningAmber,
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Pending',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.warningAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: iconColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const Gap(AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimingInfo(bool isOverdue) {
    if (showHistory && loan.actualReturnDate != null) {
      final duration = loan.actualReturnDate!.difference(loan.borrowDate).inDays;
      return '$duration day${duration != 1 ? 's' : ''} borrowed';
    }

    if (loan.status == LoanStatus.active) {
      return 'Borrowed ${loan.daysBorrowed} day${loan.daysBorrowed != 1 ? 's' : ''} ago';
    }

    return 'Borrowed on ${_formatDate(loan.borrowDate)}';
  }

  Color _getCardBorderColor(bool isOverdue) {
    if (isOverdue) return AppTheme.errorRed.withOpacity(0.3);
    if (loan.status == LoanStatus.returned) return AppTheme.successGreen.withOpacity(0.2);
    return AppTheme.neutralGray100;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
