import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

// 🛡️ RECESSED HUB CARD: Simulated Inset Shell using Native Gradients
class RecessedHubCard extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final SentinelColors sentinel;
  final double? height;

  const RecessedHubCard({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
    required this.sentinel,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label, 
            style: GoogleFonts.lexend(
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              color: sentinel.navy.withOpacity(0.5), 
              letterSpacing: 1.2
            )
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // 🛡️ THE NATIVE INSET SIMULATION:
              // Darker base (F1F5F9) + Sub-pixel Shadow Boarder
              color: const Color(0xFFF1F5F9), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withOpacity(0.04),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
