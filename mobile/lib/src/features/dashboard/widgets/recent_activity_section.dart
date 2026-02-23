import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/design_system/app_theme.dart';
import '../../loans/models/loan_model.dart';

class RecentActivitySection extends StatelessWidget {
  final List<LoanModel> loans;

  const RecentActivitySection({super.key, required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) return const _EmptyActivityState();

    final theme = Theme.of(context);
    
    // Sort by most recent borrow date and take top 10
    final recent = List<LoanModel>.from(loans)
      ..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
    final topItems = recent.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralGray500,
                  letterSpacing: 2.0,
                  fontSize: 10,
                ),
              ),
              if (loans.length > 10)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'LATEST 10',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
        const Gap(14),
        
        // Glassmorphic Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.35),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topItems.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  itemBuilder: (context, index) {
                    return _ActivityListTile(
                      item: topItems[index],
                      delay: 500 + (index * 40),
                    );
                  },
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.03, end: 0),
      ],
    );
  }
}

class _ActivityListTile extends StatelessWidget {
  final LoanModel item;
  final int delay;

  const _ActivityListTile({required this.item, required this.delay});

  String _getStatusText(LoanStatus status, int overdueDays) {
    if (overdueDays > 0) return 'OVERDUE';
    switch (status) {
      case LoanStatus.active: return 'ACTIVE';
      case LoanStatus.returned: return 'RETURNED';
      case LoanStatus.pending: return 'PENDING';
      case LoanStatus.overdue: return 'OVERDUE';
      case LoanStatus.cancelled: return 'VOIDED';
    }
  }

  Color _getStatusColor(LoanStatus status, int overdueDays) {
    if (overdueDays > 0) return AppTheme.errorRed;
    switch (status) {
      case LoanStatus.active: return AppTheme.primaryBlue;
      case LoanStatus.returned: return AppTheme.successGreen;
      case LoanStatus.pending: return AppTheme.warningAmber;
      case LoanStatus.overdue: return AppTheme.errorRed;
      case LoanStatus.cancelled: return AppTheme.neutralGray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(item.status, item.daysOverdue);
    
    // Determine icon based on category/name
    IconData icon = Icons.inventory_2_outlined;
    final n = item.itemName.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) icon = Icons.sensors_rounded;
    else if (n.contains('drone')) icon = Icons.flight_takeoff_rounded;
    else if (n.contains('generator') || n.contains('bolt')) icon = Icons.bolt_rounded;
    else if (n.contains('medical') || n.contains('kit')) icon = Icons.medical_services_rounded;

    // Senior Dev: Use timeago directly. If the UI says "now" for 10m ago, 
    // it's usually because the DateTime object has an incorrect timezone offset.
    final timeStr = timeago.format(item.borrowDate, locale: 'en_short');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: statusColor, size: 18),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutralGray900,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                const Gap(2),
                Text(
                  '${item.borrowerName.split(' ')[0]} • Operation Unit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.neutralGray500,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralGray400,
                  fontSize: 10,
                ),
              ),
              const Gap(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(item.status, item.daysOverdue),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms);
  }
}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 36, color: AppTheme.neutralGray200),
          const Gap(16),
          Text(
            'LOGS EMPTY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.neutralGray400,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
