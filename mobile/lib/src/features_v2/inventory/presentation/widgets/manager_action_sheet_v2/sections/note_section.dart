import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_controller.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';

/// The forensic note field shared across all modes.
/// Uses a local [TextEditingController] to avoid rebuild storms on each
/// keystroke while still syncing to the Riverpod controller via [onChanged].
class NoteSection extends ConsumerStatefulWidget {
  final InventoryItem item;

  const NoteSection({super.key, required this.item});

  @override
  ConsumerState<NoteSection> createState() => _NoteSectionState();
}

class _NoteSectionState extends ConsumerState<NoteSection> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final note = ref.read(managerActionControllerProvider(widget.item)).note;
    _ctrl = TextEditingController(text: note);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentinel = Theme.of(context).sentinel;
    final mode = ref.watch(
      managerActionControllerProvider(widget.item).select((s) => s.mode),
    );
    final notifier = ref.read(managerActionControllerProvider(widget.item).notifier);

    return TextField(
      controller: _ctrl,
      maxLines: 2,
      onChanged: notifier.setNote,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: mode.noteHint,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: sentinel.onSurfaceVariant.withOpacity(0.4),
          fontSize: 13,
        ),
        filled: true,
        fillColor: sentinel.containerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
