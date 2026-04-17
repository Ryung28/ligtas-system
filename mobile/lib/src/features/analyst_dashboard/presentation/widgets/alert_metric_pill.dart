import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_theme.dart';

class AlertMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final LigtasColors sentinel;

  const AlertMetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.sentinel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: sentinel.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: sentinel.navy,
          ),
        ),
      ],
    );
  }
}
