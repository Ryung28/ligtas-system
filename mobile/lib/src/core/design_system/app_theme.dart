import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

// 🛡️ TACTILE NEUROMORPHISM SPECIFICATION: Native Optimized Edition
// We use dual native Flutter 'BoxShadow' to create the "Tactile" look.
class TactileDesign {
  final List<BoxShadow> raised;    
  final List<BoxShadow> recessed;  
  final List<BoxShadow> card;      
  final List<BoxShadow> active;    
  final Color baseColor;           

  const TactileDesign({
    required this.raised,
    required this.recessed,
    required this.card,
    required this.active,
    required this.baseColor,
  });

  static final standard = TactileDesign(
    baseColor: const Color(0xFFF8FAFC),
    raised: [
      const BoxShadow(
        color: Colors.white,
        offset: Offset(-3, -3), // 🛡️ SHARPER: 3px for ultra-stable raster
        blurRadius: 6,
      ),
      BoxShadow(
        color: const Color(0xFFA2B1C6).withOpacity(0.25),
        offset: const Offset(3, 3),
        blurRadius: 6,
      ),
    ],
    card: [
      // 🛡️ THE GOLD STANDARD MALI-G610 PROFILE
      // These values (6/8) ensure the GPU clears the Frame in <8ms even when throttled.
      const BoxShadow(
        color: Colors.white,
        offset: Offset(-5, -5),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: const Color(0xFF001A33).withOpacity(0.04), // Lighter opacity to prevent ink bleed
        offset: const Offset(5, 5),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
    active: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(0, 0),
        blurRadius: 0,
      ),
    ],
    recessed: [
      inset.BoxShadow(
        color: const Color(0xFFA2B1C6).withOpacity(0.35),
        offset: const Offset(3, 3),
        blurRadius: 5,
        spreadRadius: -1,
        inset: true,
      ),
    ],
  );

  static TactileDesign lerp(TactileDesign? a, TactileDesign? b, double t) {
    if (a == null && b == null) return standard;
    
    return TactileDesign(
      baseColor: Color.lerp(a?.baseColor, b?.baseColor, t) ?? standard.baseColor,
      raised: BoxShadow.lerpList(a?.raised, b?.raised, t) ?? standard.raised,
      recessed: BoxShadow.lerpList(a?.recessed, b?.recessed, t) ?? standard.recessed,
      card: BoxShadow.lerpList(a?.card, b?.card, t) ?? standard.card,
      active: BoxShadow.lerpList(a?.active, b?.active, t) ?? standard.active,
    );
  }
}

/// 🛡️ TACTICAL BRIDGE: SentinelColors is now LigtasColors
typedef SentinelColors = LigtasColors;

class LigtasColors extends ThemeExtension<LigtasColors> {
  final Color navy;
  final Color surface;
  final Color containerLow;
  final Color containerLowest;
  final Color onSurfaceVariant;
  final Color shadowColor;
  final Color primary;
  final Color primaryFixed;
  final Color onPrimaryFixedVariant;
  final Color error;
  final TactileDesign tactile;
  final BoxDecoration glass;

  const LigtasColors({
    required this.navy,
    required this.surface,
    required this.containerLow,
    required this.containerLowest,
    required this.onSurfaceVariant,
    required this.shadowColor,
    required this.primary,
    required this.primaryFixed,
    required this.onPrimaryFixedVariant,
    required this.error,
    required this.tactile,
    required this.glass,
  });

  @override
  LigtasColors copyWith({
    Color? navy,
    Color? surface,
    Color? containerLow,
    Color? containerLowest,
    Color? onSurfaceVariant,
    Color? shadowColor,
    Color? primary,
    Color? primaryFixed,
    Color? onPrimaryFixedVariant,
    Color? error,
    TactileDesign? tactile,
    BoxDecoration? glass,
  }) {
    return LigtasColors(
      navy: navy ?? this.navy,
      surface: surface ?? this.surface,
      containerLow: containerLow ?? this.containerLow,
      containerLowest: containerLowest ?? this.containerLowest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      shadowColor: shadowColor ?? this.shadowColor,
      primary: primary ?? this.primary,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      error: error ?? this.error,
      tactile: tactile ?? this.tactile,
      glass: glass ?? this.glass,
    );
  }

  @override
  LigtasColors lerp(ThemeExtension<LigtasColors>? other, double t) {
    if (other is! LigtasColors) return this;
    return LigtasColors(
      navy: Color.lerp(navy, other.navy, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      containerLow: Color.lerp(containerLow, other.containerLow, t)!,
      containerLowest: Color.lerp(containerLowest, other.containerLowest, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      onPrimaryFixedVariant: Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      tactile: TactileDesign.lerp(tactile, other.tactile, t),
      glass: BoxDecoration.lerp(glass, other.glass, t) as BoxDecoration,
    );
  }

  List<BoxShadow> get recessedShadow => tactile.recessed;
  List<BoxShadow> get raisedShadow => tactile.raised;
  BoxDecoration get glassDecoration => glass;

  static final light = LigtasColors(
    navy: const Color(0xFF001A33),
    surface: const Color(0xFFF7F9FD),
    containerLow: const Color(0xFFF2F4F8),
    containerLowest: const Color(0xFFFFFFFF),
    onSurfaceVariant: const Color(0xFF43474D),
    shadowColor: const Color(0xFF001A33),
    primary: const Color(0xFF1976D2),
    primaryFixed: const Color(0xFFD2E4FF),
    onPrimaryFixedVariant: const Color(0xFF324863),
    error: const Color(0xFFE53935),
    tactile: TactileDesign.standard,
    glass: BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    ),
  );
}

extension SentinelTheme on ThemeData {
  LigtasColors get sentinel => extension<LigtasColors>() ?? LigtasColors.light;
}

class AppAnimations {
  // 🛡️ PREMIUM GOLD STANDARD CURVE: Optimized for 120Hz displays
  static const premiumCurve = Cubic(0.05, 0.7, 0.1, 1.0);
  
  // Standard durations
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration standard = Duration(milliseconds: 400);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Stagger delays for list items (100ms per item)
  static Duration stagger(int index) => Duration(milliseconds: 100 * index);
  
  // Common animation combinations
  static const Duration fadeInDuration = Duration(milliseconds: 400);
  static const Duration slideInDuration = Duration(milliseconds: 500);
  static const Duration shimmerDuration = Duration(milliseconds: 1200);
}

class AppTheme {
  // ── TACTICAL SPECTRUM (V4 - PREMIUM) ──
  static const Color primaryBlue = Color(0xFF0EA5E9); // Tactical Blue (Active)
  static const Color primaryBlueDark = Color(0xFF0284C7);
  static const Color primaryBlueLight = Color(0xFF7DD3FC);
  
  static const Color warningOrange = Color(0xFFFFB020); // Tactical Amber (Pending)
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color warningAmberLight = Color(0xFFFFD580);
  
  static const Color errorRed = Color(0xFFE63946); // Blood Crimson (Critical)
  static const Color destructiveRed = Color(0xFFE63946);
  
  static const Color successGreen = Color(0xFF06D6A0); // Emerald Glass (Verified)
  static const Color emeraldGreen = Color(0xFF06D6A0);
  static const Color emeraldGreenDark = Color(0xFF05B08A);
  
  static const Color secondaryOrange = Color(0xFFFF6B35);
  static const Color secondaryOrangeLight = Color(0xFFFF8A65);
  
  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF5F5F5);
  static const Color neutralGray200 = Color(0xFFEEEEEE);
  static const Color neutralGray300 = Color(0xFFE0E0E0);
  static const Color neutralGray400 = Color(0xFFBDBDBD);
  static const Color neutralGray500 = Color(0xFF9E9E9E);
  static const Color neutralGray600 = Color(0xFF757575);
  static const Color neutralGray700 = Color(0xFF616161);
  static const Color neutralGray800 = Color(0xFF424242);
  static const Color neutralGray900 = Color(0xFF212121);
  
  // Tactical Semantic Colors
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color scaffoldBackground = Color(0xFFF8FAFC);

  static TextTheme get textTheme => GoogleFonts.robotoTextTheme().copyWith(
    displayLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: neutralGray900),
    displayMedium: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.25, color: neutralGray900),
    displaySmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0, color: neutralGray900),
    headlineLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0, color: neutralGray900),
    headlineMedium: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: neutralGray900),
    headlineSmall: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: neutralGray900),
    titleLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: neutralGray900),
    titleMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: neutralGray900),
    titleSmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: neutralGray700),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: neutralGray800),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: neutralGray800),
    bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: neutralGray600),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: neutralGray700),
    labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: neutralGray700),
    labelSmall: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: neutralGray600),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: [
      LigtasColors.light,
    ],
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: secondaryOrange,
      onSecondary: Colors.white,
      error: errorRed,
      onError: Colors.white,
      surface: LigtasColors.light.surface,
      onSurface: neutralGray900,
      surfaceContainerHighest: neutralGray100,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.white,
      foregroundColor: neutralGray900,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutralGray900,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: neutralGray900.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: neutralGray300,
        disabledForegroundColor: neutralGray500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: neutralGray500,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: neutralGray900,
      contentTextStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: neutralGray200,
      thickness: 1,
      space: 1,
    ),
  );
}
