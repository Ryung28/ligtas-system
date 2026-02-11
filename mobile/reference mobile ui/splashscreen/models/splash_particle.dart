import 'package:flutter/material.dart';

/// Particle model for animated background effects
class SplashParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  SplashParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.size = 10.0,
  });
}

