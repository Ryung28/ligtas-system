import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_batch/manager_batch_provider.dart';
import 'manager_command_sheet.dart';

class ManagerCommandHubFab extends StatelessWidget {
  final ManagerBatchController controller;

  const ManagerCommandHubFab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 88,
      child: GestureDetector(
        onTap: () {
          ManagerCommandSheet.show(context: context, controller: controller);
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.apps_rounded, color: Colors.white, size: 18),
              const Gap(8),
              Text(
                'HUB',
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

