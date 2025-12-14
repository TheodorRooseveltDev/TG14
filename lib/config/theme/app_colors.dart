import 'package:flutter/material.dart';

/// Premium casino color palette
/// Dark, moody atmosphere with gold accents that feel like real gold
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main background - casino felt green
  static const Color feltGreen = Color(0xFF0C3B1B);
  
  /// Cards, elevated surfaces
  static const Color cardBackground = Color(0xFF0A2E16);
  
  /// Text, icons, shadows - deep black
  static const Color deepBlack = Color(0xFF000000);
  
  /// Darker felt for depth
  static const Color darkFelt = Color(0xFF061F0F);

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS - GOLD
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary buttons, CTAs - the hero gold
  static const Color gold = Color(0xFFF7D66A);
  
  /// Hover states, highlights - lighter gold
  static const Color goldLight = Color(0xFFFFE89D);
  
  /// Inactive buttons - muted gold
  static const Color disabledGold = Color(0xFFB89F5A);
  
  /// Dark gold for depth in gradients
  static const Color goldDark = Color(0xFFD4A94A);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Alerts, hot badges - red velvet
  static const Color redVelvet = Color(0xFFA70020);
  
  /// Secondary text - slate gray
  static const Color slateGray = Color(0xFF798883);
  
  /// Win states - success green
  static const Color successGreen = Color(0xFF2E7D32);
  
  /// Text on dark backgrounds
  static const Color textLight = Color(0xFFFAF8F3);
  
  /// White for pure highlights
  static const Color white = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main felt background gradient - top to bottom darkening
  static const LinearGradient feltGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [feltGreen, darkFelt],
  );
  
  /// Standard gold gradient for buttons
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );
  
  /// Premium gold gradient with multiple stops
  static const LinearGradient premiumGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark, gold],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Shimmer gold gradient for animated effects
  static const LinearGradient shimmerGold = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      goldDark,
      goldLight,
      gold,
      goldLight,
      goldDark,
    ],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
  );
  
  /// Radial gradient for hero section
  static const RadialGradient heroRadialGradient = RadialGradient(
    center: Alignment(0, -0.3),
    radius: 1.2,
    colors: [
      Color(0xFF1A4D2E), // Lighter center
      feltGreen,
      darkFelt,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Gold glow effect for premium elements
  static BoxShadow goldGlow = BoxShadow(
    color: gold.withOpacity(0.4),
    blurRadius: 20,
    spreadRadius: 2,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get gold with opacity
  static Color goldWithOpacity(double opacity) => gold.withOpacity(opacity);
  
  /// Get text light with opacity
  static Color textLightWithOpacity(double opacity) => textLight.withOpacity(opacity);
  
  /// Get slate gray with opacity
  static Color slateGrayWithOpacity(double opacity) => slateGray.withOpacity(opacity);
}
