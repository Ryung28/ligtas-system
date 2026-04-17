import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/config/env.dart';
import 'package:path/path.dart' as p;

/// 📸 Tactical Image Picker
/// Provides a streamlined, fast-action camera interface for Analysts
/// to capture equipment damage or status and sync directly to Supabase.
class TacticalImagePicker {
  static final ImagePicker _picker = ImagePicker();

  /// Prompts the camera, uploads the image, and returns the public URL.
  /// Converts the raw file into a standardized LIGTAS item identifier.
  static Future<String?> captureAndUpload(BuildContext context, {required int itemId}) async {
    try {
      HapticFeedback.mediumImpact();
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // CRUSH: Aggressive compression for tactical storage
        maxWidth: 800,    // DOWNSIZE: Optimized for mobile viewing & kilobyte savings
      );

      if (image == null) return null; // Analyst cancelled

      // 1. Prepare Cargo
      final file = File(image.path);
      final extension = p.extension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadPath = 'mobile_field_scans/item_${itemId}_$timestamp$extension';
      
      // 2. Uplink to Supabase Storage
      await Supabase.instance.client.storage
          .from(Environment.itemImagesBucket)
          .upload(uploadPath, file);

      // 3. Resolve Public URL for cross-platform visibility
      final publicUrl = Supabase.instance.client.storage
          .from(Environment.itemImagesBucket)
          .getPublicUrl(uploadPath);

      HapticFeedback.heavyImpact();
      return publicUrl;
      
    } catch (e) {
      debugPrint('[Tactical Camera Error] $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🛑 Camera Upload Failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return null;
    }
  }
}
