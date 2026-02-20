import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Atmospheric Background - Exactly matching the "My Borrowed Items" tab.
/// Uses soft peach and sky-blue bloom effects with heavy gaussian diffusion 
/// to create a calm, professional dashboard atmosphere.
class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Blob 1: Top-right Peach Glow ──
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
                  const Color(0xFFFFE0B2).withOpacity(0.6), // Soft Orange/Peach
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),

        // ── Blob 2: Mid-left Soft Blue ──
        Positioned(
          top: 100,
          left: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE1F5FE).withOpacity(0.5), // Soft Blue
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),

        // ── Heavy Silky Diffusion Layer ──
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
