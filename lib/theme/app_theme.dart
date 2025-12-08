import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color cardBackground = Color(0xFF141B2D);
  static const Color surfaceLight = Color(0xFF1E2642);
  
  // Accent colors
  static const Color cyan = Color(0xFF4ECDC4);
  static const Color magenta = Color(0xFFE040FB);
  static const Color pink = Color(0xFFFF6B9D);
  static const Color purple = Color(0xFF9C27B0);
  static const Color blue = Color(0xFF3D5AFE);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);
  
  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient magentaGradient = LinearGradient(
    colors: [Color(0xFFE040FB), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF1A1F35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Box shadows
  static List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: cyan.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> magentaGlow = [
    BoxShadow(
      color: magenta.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;
}
