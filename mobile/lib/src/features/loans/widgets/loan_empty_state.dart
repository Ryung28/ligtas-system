import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoanEmptyState extends StatelessWidget {
  final String statusType;

  const LoanEmptyState({super.key, required this.statusType});

  @override
  Widget build(BuildContext context) {
    String message = 'No active items';
    if (statusType == 'overdue') message = 'No overdue items';
    if (statusType == 'history') message = 'No history yet';
    if (statusType == 'pending') message = 'No pending requests';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 60,
            color: Colors.grey[300],
          ),
          const Gap(16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
