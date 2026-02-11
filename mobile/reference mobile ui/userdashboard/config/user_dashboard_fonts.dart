import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized font configuration for the user dashboard
/// All user dashboard components should use these font styles for consistency
class UserDashboardFonts {
  // Primary font family - Roboto (optimized for dashboards)
  static const String primaryFontFamily = 'Roboto';

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

  // Predefined text styles using Roboto
  static TextStyle get extraSmallText => GoogleFonts.roboto(
        fontSize: extraSmallSize,
        fontWeight: regular,
      );

  static TextStyle get smallText => GoogleFonts.roboto(
        fontSize: smallSize,
        fontWeight: regular,
      );

  static TextStyle get bodyText => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: regular,
      );

  static TextStyle get bodyTextMedium => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: medium,
      );

  static TextStyle get largeText => GoogleFonts.roboto(
        fontSize: largeSize,
        fontWeight: regular,
      );

  static TextStyle get largeTextMedium => GoogleFonts.roboto(
        fontSize: largeSize,
        fontWeight: medium,
      );

  static TextStyle get largeTextSemiBold => GoogleFonts.roboto(
        fontSize: largeSize,
        fontWeight: semiBold,
      );

  static TextStyle get extraLargeText => GoogleFonts.roboto(
        fontSize: extraLargeSize,
        fontWeight: regular,
      );

  static TextStyle get extraLargeTextMedium => GoogleFonts.roboto(
        fontSize: extraLargeSize,
        fontWeight: medium,
      );

  static TextStyle get extraLargeTextSemiBold => GoogleFonts.roboto(
        fontSize: extraLargeSize,
        fontWeight: semiBold,
      );

  static TextStyle get titleText => GoogleFonts.roboto(
        fontSize: titleSize,
        fontWeight: semiBold,
      );

  static TextStyle get titleTextBold => GoogleFonts.roboto(
        fontSize: titleSize,
        fontWeight: bold,
      );

  static TextStyle get headingText => GoogleFonts.roboto(
        fontSize: headingSize,
        fontWeight: semiBold,
      );

  static TextStyle get headingTextBold => GoogleFonts.roboto(
        fontSize: headingSize,
        fontWeight: bold,
      );

  static TextStyle get largeHeadingText => GoogleFonts.roboto(
        fontSize: largeHeadingSize,
        fontWeight: bold,
      );

  static TextStyle get extraLargeHeadingText => GoogleFonts.roboto(
        fontSize: extraLargeHeadingSize,
        fontWeight: bold,
      );

  // Helper method to create custom Roboto text style
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize ?? mediumSize,
      fontWeight: fontWeight ?? regular,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // Helper method for button text styles
  static TextStyle get buttonText => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: semiBold,
      );

  static TextStyle get buttonTextLarge => GoogleFonts.roboto(
        fontSize: largeSize,
        fontWeight: semiBold,
      );

  // Helper method for navigation text styles
  static TextStyle get navigationText => GoogleFonts.roboto(
        fontSize: smallSize,
        fontWeight: medium,
      );

  // Helper method for card title styles
  static TextStyle get cardTitle => GoogleFonts.roboto(
        fontSize: largeSize,
        fontWeight: semiBold,
      );

  // Helper method for card subtitle styles
  static TextStyle get cardSubtitle => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: regular,
      );

  // Helper method for form label styles
  static TextStyle get formLabel => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: medium,
      );

  // Helper method for form hint styles
  static TextStyle get formHint => GoogleFonts.roboto(
        fontSize: mediumSize,
        fontWeight: regular,
      );
}
