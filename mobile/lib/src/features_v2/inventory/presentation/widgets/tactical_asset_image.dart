import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Container(
      width: width ?? size,
      height: height ?? size,
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
          memCacheWidth: ((width ?? size) * 2).toInt(),
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
    final bgColor = fallbackColor?.withOpacity(0.12) ?? AppTheme.neutralGray100;
    final iconColor = fallbackColor ?? AppTheme.neutralGray400;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.inventory_2_rounded, 
          size: size * 0.45, 
          color: iconColor
        ),
      ),
    );
  }
}
