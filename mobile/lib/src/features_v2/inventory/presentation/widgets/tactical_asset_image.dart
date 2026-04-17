import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/app_theme.dart';
import '../providers/inventory_provider.dart';

/// 🏗️ TACTICAL ASSET IMAGE (Senior Reusable Component)
/// Handles Equipment Visuals with direct Supabase Bucket Resolution.
class TacticalAssetImage extends ConsumerWidget {
  final int? assetId;
  final String? path;
  final double? width;
  final double? height;
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const TacticalAssetImage({
    super.key,
    this.assetId,
    this.path,
    this.width,
    this.height,
    this.size = 80,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🛡️ RESOLUTION STRATEGY: Path Override -> Catalog Lookup
    String finalUrl = '';

    if (path != null && path!.isNotEmpty) {
      finalUrl = _resolveSupabaseUrl(path!);
    } else if (assetId != null) {
      final imageMap = ref.watch(inventoryImageMapProvider);
      final rawPath = imageMap[assetId] ?? '';
      if (rawPath.isNotEmpty) {
        finalUrl = _resolveSupabaseUrl(rawPath);
      }
    }

    // 🛡️ Guard: Tactical Placeholder if URL is missing in Registry
    if (finalUrl.isEmpty) return _buildPlaceholder();

    // 🛡️ Guard: Defensive URI check for 'No Host' error
    try {
      final uri = Uri.parse(finalUrl);
      if (uri.host.isEmpty) return _buildPlaceholder();
    } catch (e) {
      return _buildPlaceholder();
    }

    final w = width ?? size;
    final h = height ?? size;
    final flat = borderRadius <= 0;

    // Full-bleed tile (e.g. alert cards): no inner rounded gray frame — parent clips.
    if (flat) {
      return SizedBox(
        width: w,
        height: h,
        child: ClipRect(
          child: CachedNetworkImage(
            imageUrl: finalUrl,
            fit: fit,
            memCacheWidth: w.isFinite ? (w * 2).toInt() : null,
            memCacheHeight: h.isFinite ? (h * 2).toInt() : null,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: const Color(0xFFE2E8F0),
              highlightColor: Colors.white,
              child: Container(color: const Color(0xFFF1F4F9)),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
        ),
      );
    }

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: CachedNetworkImage(
          imageUrl: finalUrl,
          fit: fit,
          memCacheWidth: w.isFinite ? (w * 2).toInt() : null,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: Colors.white,
            child: Container(color: Colors.white),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  /// 🏛️ SENIOR ASSET HYDRATION: Paths -> Supabase Public URLs
  String _resolveSupabaseUrl(String input) {
    if (input.isEmpty) return '';
    
    // If it's already a full URL, return it
    if (input.startsWith('http')) return input;

    // Clean the path (remove bucket prefix if present)
    const bucketName = 'item-images';
    String cleanPath = input;
    if (cleanPath.startsWith('$bucketName/')) {
      cleanPath = cleanPath.replaceFirst('$bucketName/', '');
    }
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    try {
      final storage = Supabase.instance.client.storage;
      return storage.from(bucketName).getPublicUrl(cleanPath);
    } catch (e) {
      debugPrint('🚨 [AssetResolver] Supabase resolution failed: $e');
      return '';
    }
  }

  Widget _buildPlaceholder() {
    final displayWidth = width ?? size;
    final displayHeight = height ?? size;
    final flat = borderRadius <= 0;
    final iconDim = displayHeight == double.infinity
        ? size * 0.45
        : (displayHeight * 0.45).clamp(20.0, 48.0);

    return Container(
      width: displayWidth,
      height: displayHeight,
      decoration: BoxDecoration(
        color: flat ? const Color(0xFFF1F4F9) : Colors.white,
        borderRadius: flat ? BorderRadius.zero : BorderRadius.circular(borderRadius),
        border: flat ? null : Border.all(color: AppTheme.neutralGray200, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.category_rounded, // High-Contrast Ghost
          size: iconDim,
          color: Colors.black, // Solid Black
        ),
      ),
    );
  }
}
