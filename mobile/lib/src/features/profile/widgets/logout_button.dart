import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system/app_theme.dart';
import 'package:gap/gap.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).extension<LigtasColors>()!;

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.errorRed.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.errorRed.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: AppTheme.errorRed.withOpacity(0.8),
                    size: 20,
                  ),
                  const Gap(12),
                  Text(
                    'SIGN OUT',
                    style: GoogleFonts.lexend(
                      color: AppTheme.errorRed.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


