import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/navigation/providers/navigation_provider.dart';

/// 🛡️ TACTICAL UI EXTENSIONS
/// Unified patterns for handling global UI states like Dock Suppression.
extension TacticalUIExtension on BuildContext {
  
  /// Displays a modal bottom sheet while automatically managing the 
  /// global Navigation Dock suppression state.
  /// 
  /// The [ref] is required to update the [isDockSuppressedProvider].
  Future<T?> showTacticalSheet<T>({
    required WidgetRef ref,
    required Widget child,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.transparent,
    bool useRootNavigator = false,
  }) async {
    // 1. 🛡️ ACTIVATE SHIELD: Suppress the dock
    ref.read(isDockSuppressedProvider.notifier).state = true;

    try {
      // 2. 🎭 EXECUTE MODAL
      return await showModalBottomSheet<T>(
        context: this,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        useRootNavigator: useRootNavigator,
        builder: (context) => child,
      );
    } finally {
      // 3. 🔓 RELEASE SHIELD: Restore the dock regardless of how the sheet closed
      // Senior Dev Safety: Check if context is still mounted to avoid "deactivated widget" error
      if (ref.context.mounted) {
        ref.read(isDockSuppressedProvider.notifier).state = false;
      }
    }
  }
}
