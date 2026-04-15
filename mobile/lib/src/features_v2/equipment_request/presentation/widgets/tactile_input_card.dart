import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

// 🛡️ TACTILE INPUT CARD: Raised White Surface for Data Entry
class TactileInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final SentinelColors sentinel;

  const TactileInputCard({
    super.key,
    required this.label,
    required this.controller,
    required this.sentinel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // 🛡️ NATIVE RAISED SHADOWS: Eliminates flutter_inset_shadow dependency
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: const Color(0xFFA2B1C6).withOpacity(0.18),
            offset: const Offset(3, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11, 
              fontWeight: FontWeight.w600, 
              color: sentinel.navy.withOpacity(0.4),
            ),
          ),
          const Gap(4),
          TextFormField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15, 
              fontWeight: FontWeight.w800, 
              color: sentinel.navy,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              isDense: true, 
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
