import 'package:flutter/material.dart';

/// Animation durations for consistent timing across the app
class AnimationDurations {
  AnimationDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Animation curves for smooth, professional motion
class AnimationCurves {
  AnimationCurves._();

  static const Curve standard = Curves.easeInOut;
  static const Curve standardCubic = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeOut;
}
