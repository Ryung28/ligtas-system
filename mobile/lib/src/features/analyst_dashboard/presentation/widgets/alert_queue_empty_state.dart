import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_theme.dart';

class AlertQueueEmptyState extends StatelessWidget {
  const AlertQueueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.verified_user_outlined, size: 56, color: AppTheme.neutralGray200),
            const Gap(12),
            Text(
              'ALL SYSTEMS STABLE',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.neutralGray400,
                letterSpacing: 1.0,
              ),
            ),
            const Gap(4),
            Text(
              'Nothing to review right now.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.neutralGray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
