import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

// 🛡️ TACTILE STEPPER: Visual Mission Progress Tracker
class TactileStepper extends StatelessWidget {
  final int currentStep;
  final SentinelColors sentinel;

  const TactileStepper({
    super.key,
    required this.currentStep,
    required this.sentinel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildCircle(1, currentStep >= 1),
            _buildLine(currentStep > 1),
            _buildCircle(2, currentStep >= 2),
            _buildLine(currentStep > 2),
            _buildCircle(3, currentStep >= 3),
          ],
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('LOGISTICS'),
            _buildLabel('REVIEW'),
            _buildLabel('MISSION'),
          ],
        ),
      ],
    );
  }

  Widget _buildCircle(int n, bool active) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      color: active ? sentinel.navy : Colors.white,
      shape: BoxShape.circle,
      boxShadow: active 
        ? [] 
        : [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFFA2B1C6).withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
    ),
    child: Center(
      child: Text(
        '$n', 
        style: TextStyle(
          color: active ? Colors.white : sentinel.navy.withOpacity(0.3), 
          fontSize: 13, 
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  Widget _buildLine(bool active) => Expanded(
    child: Container(
      height: 3, 
      margin: const EdgeInsets.symmetric(horizontal: 4), 
      decoration: BoxDecoration(
        color: active ? sentinel.navy : const Color(0xFFF1F5F9), 
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildLabel(String text) => Text(
    text, 
    style: GoogleFonts.plusJakartaSans(
      fontSize: 10, 
      fontWeight: FontWeight.w800, 
      color: sentinel.navy.withOpacity(0.4), 
      letterSpacing: 0.5,
    ),
  );
}
