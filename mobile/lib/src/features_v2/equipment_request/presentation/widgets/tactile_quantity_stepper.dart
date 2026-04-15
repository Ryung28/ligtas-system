import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'tactile_buttons.dart';

/// 🛡️ TACTILE QUANTITY STEPPER: [ - ] 02 [ + ]
class TactileQuantityStepper extends StatelessWidget {
  final int value;
  final String label;
  final Function(int) onChanged;
  final int min;
  final int max;

  const TactileQuantityStepper({
    super.key,
    required this.value,
    this.label = 'units',
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TactileCircleButton(
          icon: Icons.remove_rounded,
          sentinel: sentinel,
          size: 28,
          onTap: value > min ? () => onChanged(value - 1) : () {},
        ),
        const Gap(12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, 
                fontWeight: FontWeight.w800, 
                color: sentinel.navy,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8, 
                fontWeight: FontWeight.w800, 
                color: sentinel.navy.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const Gap(12),
        TactileCircleButton(
          icon: Icons.add_rounded,
          sentinel: sentinel,
          size: 28,
          onTap: value < max ? () => onChanged(value + 1) : () {},
        ),
      ],
    );
  }
}
