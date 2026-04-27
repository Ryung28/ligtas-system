import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/app_theme.dart';

class AlertMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final LigtasColors sentinel;
  final double labelSize;
  final double valueSize;

  const AlertMetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.sentinel,
    this.labelSize = 7,
    this.valueSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: labelSize,
            fontWeight: FontWeight.w800,
            color: sentinel.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: valueSize,
            fontWeight: FontWeight.w900,
            color: sentinel.navy,
          ),
        ),
      ],
    );
  }
}
