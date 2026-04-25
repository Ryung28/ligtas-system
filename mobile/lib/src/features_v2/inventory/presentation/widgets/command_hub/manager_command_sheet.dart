import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_batch/manager_batch_provider.dart';
import 'add_item_sheet.dart';

class ManagerCommandSheet {
  static Future<void> show({
    required BuildContext context,
    required ManagerBatchController controller,
  }) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ManagerCommandSheetBody(controller: controller);
      },
    );
  }
}

class _ManagerCommandSheetBody extends StatelessWidget {
  final ManagerBatchController controller;

  const _ManagerCommandSheetBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF001A33).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              Text(
                'COMMAND HUB',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF001A33),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const Gap(20),
              _ActionCard(
                icon: Icons.assignment_ind_rounded,
                title: 'BORROW',
                subtitle: 'Issue items immediately to personnel',
                onTap: () {
                  Navigator.pop(context);
                  controller.start(ManagerMode.handover);
                },
              ),
              const Gap(12),
              _ActionCard(
                icon: Icons.calendar_today_rounded,
                title: 'RESERVE',
                subtitle: 'Stage for scheduled pickup and prep',
                onTap: () {
                  Navigator.pop(context);
                  controller.start(ManagerMode.reserve);
                },
              ),
              const Gap(12),
              _ActionCard(
                icon: Icons.add_box_rounded,
                title: 'ADD ITEM',
                subtitle: 'Register a new inventory item',
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddItemSheet(),
                  );
                },
              ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const onyx = Color(0xFF001A33);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: onyx.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: onyx.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: onyx, size: 24),
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        color: onyx,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

