import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized font configuration - Roboto for dashboard/content
/// Inter for splash/intro (reference UI style)
class AppFonts {
  AppFonts._();

  // Primary font families
  static const String roboto = 'Roboto';
  static const String inter = 'Inter';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Font sizes
  static const double extraSmallSize = 10.0;
  static const double smallSize = 12.0;
  static const double mediumSize = 14.0;
  static const double largeSize = 16.0;
  static const double extraLargeSize = 18.0;
  static const double titleSize = 20.0;
  static const double headingSize = 24.0;
  static const double largeHeadingSize = 28.0;
  static const double extraLargeHeadingSize = 32.0;

  // Roboto text styles (content/dashboard)
  static TextStyle get robotoExtraSmall =>
      GoogleFonts.roboto(fontSize: extraSmallSize, fontWeight: regular);

  static TextStyle get robotoSmall =>
      GoogleFonts.roboto(fontSize: smallSize, fontWeight: regular);

  static TextStyle get robotoBody =>
      GoogleFonts.roboto(fontSize: mediumSize, fontWeight: regular);

  static TextStyle get robotoBodyMedium =>
      GoogleFonts.roboto(fontSize: mediumSize, fontWeight: medium);

  static TextStyle get robotoLarge =>
      GoogleFonts.roboto(fontSize: largeSize, fontWeight: regular);

  static TextStyle get robotoLargeSemiBold =>
      GoogleFonts.roboto(fontSize: largeSize, fontWeight: semiBold);

  static TextStyle get robotoHeading =>
      GoogleFonts.roboto(fontSize: headingSize, fontWeight: semiBold);

  static TextStyle get robotoHeadingBold =>
      GoogleFonts.roboto(fontSize: headingSize, fontWeight: bold);

  static TextStyle get robotoCardTitle =>
      GoogleFonts.roboto(fontSize: largeSize, fontWeight: semiBold);

  static TextStyle get robotoCardSubtitle =>
      GoogleFonts.roboto(fontSize: mediumSize, fontWeight: regular);

  // Inter text styles (splash/intro - reference UI)
  static TextStyle interCustom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? mediumSize,
      fontWeight: fontWeight ?? regular,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle get interButton => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static TextStyle get interTitle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle get interBody => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.7,
    letterSpacing: -0.1,
  );
}
