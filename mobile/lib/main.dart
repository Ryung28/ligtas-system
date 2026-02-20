import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/core/local_storage/isar_service.dart';
import 'src/core/networking/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Senior Dev Tip: Enable 120Hz/High Refresh Rate for smooth UI on Android
  if (Platform.isAndroid) {
    await _setHighRefreshRate();
  }
  
  // Initialize Isar for high-performance local storage
  await IsarService.init();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: LigtasApp(),
    ),
  );
}

Future<void> _setHighRefreshRate() async {
  try {
    // Senior Dev Aggressive Strategy: Instead of just requesting, 
    // we inventory all hardware modes and force-lock the highest Hz available.
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
    
    debugPrint("🚀 LIGTAS Optimization: Locking Display at ${optimalMode.refreshRate.round()}Hz (${optimalMode.width}x${optimalMode.height})");
    
    await FlutterDisplayMode.setPreferredMode(optimalMode);
  } catch (e) {
    // Dynamic fallback to system default if force-lock fails
    debugPrint("Failed to set optimal display mode: $e");
  }
}