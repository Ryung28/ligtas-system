import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TacticalImageViewer {
  static void show(BuildContext context, {required String url, required String title, String? heroTag}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: _TacticalImageViewerDialog(
          url: url,
          title: title,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _TacticalImageViewerDialog extends StatelessWidget {
  final String url;
  final String title;
  final String? heroTag;

  const _TacticalImageViewerDialog({
    required this.url,
    required this.title,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── TACTICAL IMAGE (HERO SYNCED) ──
          Center(
            child: heroTag != null
                ? Hero(
                    tag: heroTag!,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white24),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    ),
                  ),
          ),

          // ── OVERLAY HEADER ──
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
