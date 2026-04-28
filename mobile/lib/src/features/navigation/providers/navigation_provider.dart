import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DockSuppressionReason {
  scanner,
  fastDispatch,
  modalSheet,
  detailSheet,
  fullScreenFlow,
}

class DockSuppressionState {
  final Map<DockSuppressionReason, int> activeReasons;

  const DockSuppressionState({this.activeReasons = const {}});

  bool get isSuppressed => activeReasons.isNotEmpty;
}

class DockSuppressionController extends Notifier<DockSuppressionState> {
  @override
  DockSuppressionState build() => const DockSuppressionState();

  void suppress(DockSuppressionReason reason) {
    final next = Map<DockSuppressionReason, int>.from(state.activeReasons);
    next.update(reason, (count) => count + 1, ifAbsent: () => 1);
    state = DockSuppressionState(activeReasons: next);
  }

  void release(DockSuppressionReason reason) {
    final current = state.activeReasons[reason];
    if (current == null) return;

    final next = Map<DockSuppressionReason, int>.from(state.activeReasons);
    if (current <= 1) {
      next.remove(reason);
    } else {
      next[reason] = current - 1;
    }
    state = DockSuppressionState(activeReasons: next);
  }
}

final dockSuppressionControllerProvider =
    NotifierProvider<DockSuppressionController, DockSuppressionState>(
  DockSuppressionController.new,
);

/// Backward-compatible read provider used by the shell to hide/show dock.
final isDockSuppressedProvider = Provider<bool>(
  (ref) => ref.watch(dockSuppressionControllerProvider).isSuppressed,
);
