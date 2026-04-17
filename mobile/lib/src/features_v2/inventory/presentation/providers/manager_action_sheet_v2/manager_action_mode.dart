import 'package:flutter/material.dart';
import 'package:mobile/src/core/design_system/app_theme.dart';

// Matches the new Terminal UI order: IDENTITY -> RESTOCK -> HAND OVER -> RESERVE
enum ManagerMode { edit, restock, handover, reserve }

extension ManagerModeX on ManagerMode {
  String get toggleLabel {
    switch (this) {
      case ManagerMode.restock:
        return 'LOGISTICS';
      case ManagerMode.handover:
        return 'HAND OVER';
      case ManagerMode.reserve:
        return 'RESERVE';
      case ManagerMode.edit:
        return 'IDENTITY';
    }
  }

  Color get activeColor {
    switch (this) {
      case ManagerMode.restock:
        return AppTheme.emeraldGreen;
      case ManagerMode.handover:
        return AppTheme.onyxBlack;
      case ManagerMode.reserve:
        return AppTheme.warningAmber;
      case ManagerMode.edit:
        return const Color(0xFF1E293B);
    }
  }

  String get submitLabel {
    switch (this) {
      case ManagerMode.restock:
        return 'SAVE NEW STOCK';
      case ManagerMode.handover:
        return 'CONFIRM DISPATCH';
      case ManagerMode.reserve:
        return 'CONFIRM RESERVATION';
      case ManagerMode.edit:
        return 'SAVE EQUIPMENT CHANGES';
    }
  }

  IconData get submitIcon {
    switch (this) {
      case ManagerMode.restock:
        return Icons.add_business_rounded;
      case ManagerMode.handover:
        return Icons.outbox_rounded;
      case ManagerMode.reserve:
        return Icons.calendar_month_rounded;
      case ManagerMode.edit:
        return Icons.save_alt_rounded;
    }
  }

  String get noteHint {
    switch (this) {
      case ManagerMode.restock:
        return 'Reason for restocking (required)';
      case ManagerMode.edit:
        return 'Audit reason for equipment changes (required)';
      case ManagerMode.handover:
      case ManagerMode.reserve:
        return 'Additional audit notes (required)';
    }
  }
}
