import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../../core/design_system/app_theme.dart';

class GlassFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? sentinel.containerLowest 
                : sentinel.containerLow,
            borderRadius: BorderRadius.circular(9999), // full roundedness for chips
            boxShadow: isSelected ? sentinel.raisedShadow : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check_rounded, size: 14, color: sentinel.navy),
                const Gap(6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? sentinel.navy : sentinel.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: isSelected ? -0.2 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
