import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme configuration for splash and intro screens
/// Provides consistent colors for light/dark modes
class ThemeConfig {
  ThemeConfig._();

  // Light mode
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightAccent = Color(0xFF42A5F5);
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF212121);
  static const Color lightGradientStart = Color(0xFFF8FAFC);
  static const Color lightGradientEnd = Color(0xFFE8EEF4);

  // Dark mode
  static const Color darkPrimary = Color(0xFF42A5F5);
  static const Color darkAccent = Color(0xFF64B5F6);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);
}
