import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Partizo design tokens — "party ticket" system.
///
/// The subject is a house-party night: string lights, torn admission
/// stubs, a secret badge passed hand to hand. Backgrounds sit in a warm
/// ink-plum (never pure black/navy), with two accent temperatures that
/// stand in for the two moods of the game — a cool, honest emerald for
/// Truth/safety, and a bold violet for Dare/secrets.
class AppTheme {
  // ---- Core surfaces ----
  static const Color background = Color(0xFF150D1F);
  static const Color backgroundDeep = Color(0xFF0B0712);
  static const Color cardBackground = Color(0xFF241531);
  static const Color surfaceLight = Color(0xFF35223F);

  // ---- Accents ----
  // "Truth" — calm, honest, cool. Also the Civilian / safe role color.
  static const Color cyan = Color(0xFF3EDBA0);
  // "Dare" / secrets — bold, mischievous. Also the Undercover accent.
  static const Color magenta = Color(0xFF9B6BFF);
  // Warm string-light amber — ambient glow, stamps, highlights.
  static const Color amber = Color(0xFFFFB648);
  // Spice — reserved for danger/spicy emphasis in copy accents.
  static const Color pink = Color(0xFFFF6B5B);
  static const Color purple = Color(0xFF6339C4);
  static const Color blue = Color(0xFFFFB648); // alias kept for compatibility

  // ---- Text ----
  static const Color textPrimary = Color(0xFFFBF6FF);
  static const Color textSecondary = Color(0xFFC7B9D9);
  static const Color textMuted = Color(0xFF8A7398);

  // ---- Gradients ----
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF5FE8B7), Color(0xFF1FA971)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient magentaGradient = LinearGradient(
    colors: [Color(0xFFB08CFF), Color(0xFF6339C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFCB77), Color(0xFFFF9B4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1C1128), backgroundDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---- Glows ----
  static List<BoxShadow> cyanGlow = [
    BoxShadow(color: cyan.withOpacity(0.35), blurRadius: 24, spreadRadius: 1),
  ];

  static List<BoxShadow> magentaGlow = [
    BoxShadow(color: magenta.withOpacity(0.38), blurRadius: 24, spreadRadius: 1),
  ];

  static List<BoxShadow> amberGlow = [
    BoxShadow(color: amber.withOpacity(0.32), blurRadius: 24, spreadRadius: 1),
  ];

  // ---- Radii ----
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;

  // ---- Type scale ----
  // Display: Unbounded — blocky, stamped, poster-like. Used sparingly for
  // wordmarks and screen headlines only.
  static TextStyle display({
    double fontSize = 40,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w800,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.unbounded(
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Body: Manrope — warm, humanist, legible at small party-lighting sizes.
  static TextStyle body({
    double fontSize = 16,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.manrope(
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Mono: Space Mono — ticket-stub numerals, timers, round counters.
  static TextStyle mono({
    double fontSize = 16,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  // Convenience named styles (used by restored gameplay screens).
  static TextStyle get displayMedium => display(fontSize: 30, weight: FontWeight.w800);
  static TextStyle get headlineLarge => body(fontSize: 26, weight: FontWeight.w700, height: 1.35);
  static TextStyle get bodyMedium => body(fontSize: 16, color: textSecondary, weight: FontWeight.w600);
  static TextStyle get labelLarge =>
      body(fontSize: 13, weight: FontWeight.w700, letterSpacing: 1.5);

  static TextTheme textTheme(TextTheme base) =>
      GoogleFonts.manropeTextTheme(base).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      );
}
