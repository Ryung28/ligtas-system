import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A dedicated widget for the wave animation background
/// This separates the animation logic from the main UI
class WaveAnimationBackground extends StatefulWidget {
  final bool isDark;
  final Size screenSize;

  const WaveAnimationBackground({
    Key? key,
    required this.isDark,
    required this.screenSize,
  }) : super(key: key);

  @override
  State<WaveAnimationBackground> createState() =>
      _WaveAnimationBackgroundState();
}

class _WaveAnimationBackgroundState extends State<WaveAnimationBackground> {
  @override
  Widget build(BuildContext context) {
    final Color waveColor =
        widget.isDark ? Colors.blueGrey.shade700 : Colors.blueGrey.shade200;

    final Color secondaryWaveColor =
        widget.isDark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade100;

    return Stack(
      children: [
        CustomPaint(
          painter: StaticWavePainter(
            isDark: widget.isDark,
            primaryColor: waveColor,
            secondaryColor: secondaryWaveColor,
          ),
          size: widget.screenSize,
        ),
      ],
    );
  }
}

class StaticWavePainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  const StaticWavePainter({
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Wave amplitude parameters (smaller for better performance)
    final amplitude1 = height * 0.025;
    final amplitude2 = height * 0.02;
    final amplitude3 = height * 0.015;

    // Wave period parameters
    final period1 = width * 1.2;
    final period2 = width * 1.4;
    final period3 = width * 1.0;

    // Wave base height (positioned at bottom of screen)
    final baseHeight1 = height * 0.85;
    final baseHeight2 = height * 0.88;
    final baseHeight3 = height * 0.91;

    // Animation offset calculation - set to a constant for static appearance
    final double animationOffset =
        width * 0.1; // Example static offset, can be 0.0 or other value

    // Create path objects for each wave
    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    // Optimize the number of points in the wave (increase step for better performance)
    const double step =
        8.0; // Larger step = fewer calculations and better performance

    // Draw first wave
    path1.moveTo(0, baseHeight1);
    for (double x = 0; x <= width; x += step) {
      final y = baseHeight1 -
          amplitude1 *
              math.sin(2 * math.pi * ((x + animationOffset * 1.0) / period1) +
                  math.pi * 0.5) -
          amplitude1 *
              0.3 *
              math.sin(4 * math.pi * ((x - animationOffset * 0.4) / period1));
      path1.lineTo(x, y);
    }
    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();

    // Draw second wave
    path2.moveTo(0, baseHeight2);
    for (double x = 0; x <= width; x += step) {
      final y = baseHeight2 -
          amplitude2 *
              math.sin(2 * math.pi * ((x - animationOffset * 0.7) / period2) +
                  math.pi * 0.2) -
          amplitude2 *
              0.4 *
              math.cos(3 * math.pi * ((x + animationOffset * 0.3) / period2));
      path2.lineTo(x, y);
    }
    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    // Draw third wave
    path3.moveTo(0, baseHeight3);
    for (double x = 0; x <= width; x += step) {
      final y = baseHeight3 -
          amplitude3 *
              math.sin(2 * math.pi * ((x + animationOffset * 0.5) / period3)) -
          amplitude3 *
              0.5 *
              math.cos(5 * math.pi * ((x - animationOffset * 0.2) / period3) +
                  math.pi * 0.8);
      path3.lineTo(x, y);
    }
    path3.lineTo(width, height);
    path3.lineTo(0, height);
    path3.close();

    // Calculate transparency based on theme
    final double opacity1 = isDark ? 0.12 : 0.20;
    final double opacity2 = isDark ? 0.09 : 0.15;
    final double opacity3 = isDark ? 0.06 : 0.10;

    // Set up paint objects
    final paint1 = Paint()
      ..color = primaryColor.withOpacity(opacity1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = secondaryColor.withOpacity(opacity2)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = primaryColor.withOpacity(opacity3)
      ..style = PaintingStyle.fill;

    // Draw paths in correct order (back to front)
    canvas.drawPath(path3, paint3);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant StaticWavePainter oldDelegate) =>
      isDark != oldDelegate.isDark ||
      primaryColor != oldDelegate.primaryColor ||
      secondaryColor != oldDelegate.secondaryColor;
}
