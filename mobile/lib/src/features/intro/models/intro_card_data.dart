import 'package:flutter/material.dart';

/// Data model for intro/onboarding cards
class IntroCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const IntroCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
