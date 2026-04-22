import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class PerformanceUtils {
  /// 🛡️ THE OS-LEVEL ENFORCER (120Hz)
  /// Forces the Android OS to lock the highest available refresh rate.
  /// Call this in main() and on app resume.
  static Future<void> enforceHighRefreshRate() async {
    if (!Platform.isAndroid || kIsWeb) return;

    try {
      final List<DisplayMode> modes = await FlutterDisplayMode.supported;
      if (modes.isEmpty) return;

      // Filter and sort by refresh rate descending (120 -> 90 -> 60)
      // We also prefer higher resolution if Hz is identical.
      modes.sort((a, b) {
        final int hzCompare = b.refreshRate.round().compareTo(a.refreshRate.round());
        if (hzCompare != 0) return hzCompare;
        return b.width.compareTo(a.width);
      });

      final DisplayMode optimalMode = modes.first;
      
      debugPrint("🚀 ResQTrack-Performance: Locking Display at ${optimalMode.refreshRate.round()}Hz (${optimalMode.width}x${optimalMode.height})");
      
      await FlutterDisplayMode.setPreferredMode(optimalMode);
    } catch (e) {
      debugPrint("⚠️ Failed to set optimal display mode: $e");
    }
  }
}
