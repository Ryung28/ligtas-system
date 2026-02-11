import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/splash_particle.dart';

/// Background effects painter for splash screen
class SplashBackgroundEffects {
  /// Creates a painter for particles
  static CustomPaint buildParticlePainter(List<SplashParticle> particles) {
    return CustomPaint(
      painter: _ParticlePainter(particles: particles),
    );
  }

  /// Creates a painter for radial gradient glow
  static CustomPaint buildRadialGradientGlow({
    required Offset center,
    required List<Color> colors,
    required double radius,
  }) {
    return CustomPaint(
      painter: _RadialGradientPainter(
        center: center,
        colors: colors,
        radius: radius,
      ),
    );
  }

  /// Creates a painter for wave effects
  static CustomPaint buildWavePainter({
    required double waveAnimation,
    required Color color1,
    required Color color2,
  }) {
    return CustomPaint(
      painter: _WavePainter(
        waveAnimation: waveAnimation,
        color1: color1,
        color2: color2,
      ),
    );
  }

  /// Creates a painter for subtle background pattern
  static CustomPaint buildSubtlePattern({
    required Color color,
  }) {
    return CustomPaint(
      painter: _SubtleBackgroundPainter(color: color),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<SplashParticle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RadialGradientPainter extends CustomPainter {
  final Offset center;
  final List<Color> colors;
  final double radius;

  _RadialGradientPainter({
    required this.center,
    required this.colors,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: const [0.0, 1.0],
        radius: 1.0,
      ).createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color color1;
  final Color color2;

  _WavePainter({
    required this.waveAnimation,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(
        0,
        height * 0.85 +
            25 * math.sin(waveAnimation * 2 * math.pi - math.pi / 2));
    for (double i = 0; i <= width; i++) {
      path1.lineTo(
          i,
          height * 0.85 +
              25 *
                  math.sin((i / width) * 3.5 * math.pi +
                      waveAnimation * 2 * math.pi));
    }
    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();

    path2.moveTo(
        0,
        height * 0.9 +
            20 * math.sin(waveAnimation * 2 * math.pi + math.pi / 3));
    for (double i = 0; i <= width; i++) {
      path2.lineTo(
          i,
          height * 0.9 +
              20 *
                  math.sin((i / width) * 4 * math.pi +
                      waveAnimation * 2 * math.pi +
                      math.pi));
    }
    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SubtleBackgroundPainter extends CustomPainter {
  final Color color;

  _SubtleBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double step = 35.0;

    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
          Offset(i, 0), Offset(i - size.height, size.height), paint);
      canvas.drawLine(
          Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

