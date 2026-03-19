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
                ? AppTheme.primaryBlue 
                : Colors.white.withOpacity(0.6),
            borderRadius: isSelected
                ? const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  )
                : BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryBlue 
                  : Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4), // 🛡️ Tactical Soft Neumorphism
              ),
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                const Gap(6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
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
