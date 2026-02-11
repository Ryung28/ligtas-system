import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/splash_particle.dart';

/// Service for managing splash screen particle animations
class SplashParticleService {
  final List<SplashParticle> particles;
  final math.Random _random = math.Random();
  final int screenWidth;
  final int screenHeight;

  SplashParticleService({
    required this.particles,
    this.screenWidth = 400,
    this.screenHeight = 800,
  });

  /// Initialize particles with themed colors
  static List<SplashParticle> initializeParticles({
    int count = 15,
    int screenWidth = 400,
    int screenHeight = 800,
    List<Color>? colors,
  }) {
    final random = math.Random();
    final particleColors =
        colors ??
        [
          Colors.blue.withOpacity(0.3),
          Colors.lightBlue.withOpacity(0.2),
          Colors.cyan.withOpacity(0.2),
          Colors.teal.withOpacity(0.3),
        ];

    return List.generate(count, (index) {
      return SplashParticle(
        position: Offset(
          random.nextDouble() * screenWidth,
          random.nextDouble() * screenHeight,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.8,
          (random.nextDouble() - 0.5) * 0.8,
        ),
        color: particleColors[random.nextInt(particleColors.length)],
        size: 5.0 + random.nextDouble() * 15,
      );
    });
  }

  /// Update particle positions
  void updateParticles() {
    for (final particle in particles) {
      particle.position = Offset(
        particle.position.dx + particle.velocity.dx,
        particle.position.dy + particle.velocity.dy,
      );

      if (particle.position.dx < -20 ||
          particle.position.dx > screenWidth + 20 ||
          particle.position.dy < -20 ||
          particle.position.dy > screenHeight + 20) {
        particle.position = Offset(
          _random.nextDouble() * screenWidth,
          _random.nextDouble() * screenHeight,
        );
      }
    }
  }
}
