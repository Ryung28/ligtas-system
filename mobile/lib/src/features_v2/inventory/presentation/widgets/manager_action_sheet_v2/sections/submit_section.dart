import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_validation_provider.dart';

/// The submit button row. It is intentionally dumb — it only reads
/// [managerActionCanSubmitProvider] and calls [ManagerActionController.submit].
/// All label / icon / colour logic lives in the mode extension on [ManagerMode].
class SubmitSection extends ConsumerWidget {
  final InventoryItem item;

  const SubmitSection({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      managerActionControllerProvider(item).select((s) => s.mode),
    );
    final canSubmit = ref.watch(managerActionCanSubmitProvider(item));
    final error = ref.watch(
      managerActionControllerProvider(item).select((s) => s.submitError),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              error,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ),
          const Gap(12),
        ],
        _ActionButton(
          label: mode.submitLabel,
          icon: mode.submitIcon,
          color: mode.activeColor,
          enabled: canSubmit,
          onTap: canSubmit
              ? () async {
                  HapticFeedback.heavyImpact();
                  final ctrl =
                      ref.read(managerActionControllerProvider(item).notifier);
                  final success = await ctrl.submit();
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                          const Gap(12),
                          const Text('Inventory Registry Updated'),
                        ]),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = enabled ? color : Colors.black26;
    return Material(
      color: enabled ? color.withOpacity(0.08) : Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: enabled ? color.withOpacity(0.2) : Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, color: activeColor, size: 20),
              const Gap(16),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: activeColor),
            ],
          ),
        ),
      ),
    );
  }
}
