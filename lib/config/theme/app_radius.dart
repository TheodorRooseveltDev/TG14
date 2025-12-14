import 'package:flutter/material.dart';

/// Border radius constants for consistent rounded corners
class AppRadius {
  AppRadius._();

  // ═══════════════════════════════════════════════════════════════════════════
  // RAW VALUES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// 4px - Extra small radius
  static const double xs = 4;
  
  /// 8px - Small radius
  static const double sm = 8;
  
  /// 12px - Medium radius
  static const double md = 12;
  
  /// 16px - Large radius
  static const double lg = 16;
  
  /// 20px - Extra large radius
  static const double xl = 20;
  
  /// 24px - Double extra large radius
  static const double xxl = 24;
  
  /// 32px - Triple extra large radius
  static const double xxxl = 32;
  
  /// Full/pill radius
  static const double full = 999;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS PRESETS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Card border radius (16px)
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  
  /// Button border radius (12px)
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(md));
  
  /// Large button border radius (16px)
  static const BorderRadius buttonRadiusLarge = BorderRadius.all(Radius.circular(lg));
  
  /// Chip/pill border radius (full)
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(full));
  
  /// Game card border radius (20px)
  static const BorderRadius gameCardRadius = BorderRadius.all(Radius.circular(xl));
  
  /// Hero section border radius (24px)
  static const BorderRadius heroRadius = BorderRadius.all(Radius.circular(xxl));
  
  /// Small component radius (8px)
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(sm));
  
  /// Badge radius (8px)
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(sm));

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIFIC RADIUSES FOR COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Top only radius for cards with image on top
  static BorderRadius topOnlyRadius(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );
  
  /// Bottom only radius
  static BorderRadius bottomOnlyRadius(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );
}
