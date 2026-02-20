import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Reusable step indicator pill
class StepPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const StepPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? const Color(0xFF10B981) // Emerald
        : isActive
            ? AppTheme.primaryBlue
            : const Color(0xFFE2E8F0); // Slate 200
    final Color fg = (isDone || isActive) ? Colors.white : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? '✓' : label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
