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

    // Sort by most recent borrow date and take top 5
    final recent = List<LoanModel>.from(loans)
      ..sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
    final top5 = recent.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.neutralGray800,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 700.ms),
        const Gap(12),
        ...top5.asMap().entries.map((entry) {
          return _ActivityListTile(
            item: entry.value,
            delay: 800 + (entry.key * 100),
          );
        }),
      ],
    );
  }
}

class _ActivityListTile extends StatelessWidget {
  final LoanModel item;
  final int delay;

  const _ActivityListTile({required this.item, required this.delay});

  @override
  Widget build(BuildContext context) {
    // Determine icon and color based on item name
    IconData icon = Icons.inventory_2_outlined;
    Color color = Colors.grey[700]!;

    final n = item.itemName.toLowerCase();
    if (n.contains('radio') || n.contains('comms')) {
      icon = Icons.settings_input_antenna_rounded;
      color = Colors.blueGrey[700]!;
    } else if (n.contains('drone')) {
      icon = Icons.flight_takeoff_rounded;
      color = Colors.indigo[400]!;
    } else if (n.contains('generator')) {
      icon = Icons.bolt_rounded;
      color = Colors.amber[600]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neutralGray900,
                  ),
                ),
                Text(
                  'User ${item.borrowerName.split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralGray500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeago.format(item.borrowDate),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutralGray400,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
          const Gap(16),
          Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
