import '../config/env.dart';

/// 🏗️ STORAGE UTILS (Senior Architect Choice)
/// Centralized logic for asset resolution across the entire Mobile ResQTrack ecosystem.
class StorageUtils {
  /// Resolves a raw image URL or path into a fully-qualified Public CDN URL.
  /// 
  /// 1. If [pathOrUrl] is empty, returns an empty string.
  /// 2. If [pathOrUrl] is a full URL (Legacy), it cleans up signed tokens.
  /// 3. If [pathOrUrl] is a relative path, it hydrates it using the item-images bucket.
  static String resolveAssetUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return '';
    
    // 🛡️ LEGACY SUPPORT: If it's already a full URL
    if (pathOrUrl.startsWith('http')) {
      // Clean up signed URLs to public ones for resilience
      if (pathOrUrl.contains('/storage/v1/object/sign/')) {
        return pathOrUrl
            .replaceAll('/storage/v1/object/sign/', '/storage/v1/object/public/')
            .split('?token=')[0]
            .split('&token=')[0];
      }
      return pathOrUrl;
    }
    
    // 🛡️ CANONICAL HYDRATION: Construct Public URL for item-images bucket
    return '${Environment.supabaseUrl}/storage/v1/object/public/${Environment.itemImagesBucket}/$pathOrUrl';
  }
}
