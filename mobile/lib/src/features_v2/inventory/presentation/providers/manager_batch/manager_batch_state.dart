import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/manager_action_sheet_v2/manager_action_mode.dart';

class ManagerBatchLine {
  const ManagerBatchLine({
    required this.item,
    required this.quantity,
  });

  final InventoryItem item;
  final int quantity;

  ManagerBatchLine copyWith({int? quantity}) {
    return ManagerBatchLine(
      item: item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ManagerBatchFailure {
  const ManagerBatchFailure({
    required this.itemName,
    required this.error,
  });

  final String itemName;
  final String error;
}

class ManagerBatchState {
  const ManagerBatchState({
    this.activeMode,
    this.lines = const {},
    this.isSubmitting = false,
    this.submitError,
    this.lastFailures = const [],
    this.lastSuccessCount = 0,
  });

  final ManagerMode? activeMode;
  final Map<int, ManagerBatchLine> lines;
  final bool isSubmitting;
  final String? submitError;
  final List<ManagerBatchFailure> lastFailures;
  final int lastSuccessCount;

  bool get isActive => activeMode == ManagerMode.handover || activeMode == ManagerMode.reserve;
  bool get isReserveMode => activeMode == ManagerMode.reserve;
  int get selectedItems => lines.length;
  int get totalQuantity => lines.values.fold(0, (sum, line) => sum + line.quantity);

  ManagerBatchState copyWith({
    ManagerMode? activeMode,
    Map<int, ManagerBatchLine>? lines,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    List<ManagerBatchFailure>? lastFailures,
    int? lastSuccessCount,
  }) {
    return ManagerBatchState(
      activeMode: activeMode ?? this.activeMode,
      lines: lines ?? this.lines,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      lastFailures: lastFailures ?? this.lastFailures,
      lastSuccessCount: lastSuccessCount ?? this.lastSuccessCount,
    );
  }
}
