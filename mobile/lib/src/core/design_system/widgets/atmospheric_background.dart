import 'dart:ui';
import 'package:flutter/material.dart';

class AtmosphericBackground extends StatelessWidget {
  final Widget? child;
  final bool isDark;
  
  const AtmosphericBackground({
    super.key, 
    this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // ── Premium Atmospheric Background ──
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF1976D2) : const Color(0xFFFFE0B2)).withValues(alpha: 0.6), 
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFFE53935) : const Color(0xFFE1F5FE)).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
            ),
          ),
          // Blur Mesh to create "Atmosphere"
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2)),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
