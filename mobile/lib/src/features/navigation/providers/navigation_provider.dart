import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to control whether the floating navigation dock should be forced to hide.
/// 
/// This is used when showing modals or detail sheets that would otherwise conflict
/// with the dock position or where the user should focus on the specific content.
final isDockSuppressedProvider = StateProvider<bool>((ref) => false);
