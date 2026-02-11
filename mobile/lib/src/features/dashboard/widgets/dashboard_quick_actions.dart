import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_theme.dart';

/// Quick action chips (reference: _buildQuickActionButtons)
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key, required this.onOpenScanner});

  final VoidCallback onOpenScanner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionChip(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            color: AppTheme.primaryBlue,
            onTap: onOpenScanner,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.list_alt_rounded,
            label: 'My Items',
            color: AppTheme.primaryBlueDark,
            onTap: () => context.go('/loans'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Borrow',
            color: AppTheme.secondaryOrange,
            onTap: () => context.go('/loans/create'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutralGray800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
