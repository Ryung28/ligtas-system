import 'package:flutter/material.dart';

/// Professional spacing system based on 8px grid
class AppSpacing {
  // Base unit (8px)
  static const double unit = 8.0;
  
  // Spacing values
  static const double xs = unit * 0.5;    // 4px
  static const double sm = unit * 1;      // 8px
  static const double md = unit * 2;      // 16px
  static const double lg = unit * 3;      // 24px
  static const double xl = unit * 4;      // 32px
  static const double xxl = unit * 6;     // 48px
  static const double xxxl = unit * 8;    // 64px
  
  // Semantic spacing
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double sectionSpacing = lg;
  static const double componentSpacing = sm;
  
  // Edge Insets shortcuts
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
}

/// Professional border radius system
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  
  // Semantic radius
  static const double button = md;
  static const double card = lg;
  static const double sheet = xl;
  static const double chip = xxl;
  
  // BorderRadius shortcuts
  static const BorderRadius allXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
}

/// Professional elevation system
class AppElevation {
  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 12;
  static const double xxl = 16;
  
  // Semantic elevations
  static const double card = sm;
  static const double fab = lg;
  static const double modal = xl;
  static const double tooltip = xxl;
}

/// Professional sizing system
class AppSizing {
  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  
  // Button heights
  static const double buttonSm = 32.0;
  static const double buttonMd = 40.0;
  static const double buttonLg = 48.0;
  
  // Input heights
  static const double inputSm = 36.0;
  static const double inputMd = 44.0;
  static const double inputLg = 52.0;
  
  // Touch targets (minimum 44px for accessibility)
  static const double touchTarget = 44.0;
  
  // Common component sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  
  static const double chipHeight = 32.0;
  static const double tabHeight = 48.0;
  static const double listItemHeight = 56.0;
}