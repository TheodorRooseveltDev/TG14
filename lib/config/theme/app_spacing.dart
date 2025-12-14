import 'package:flutter/material.dart';

/// Consistent spacing system throughout the app
class AppSpacing {
  AppSpacing._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BASE SPACING VALUES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// 4px - Extra small spacing
  static const double xs = 4;
  
  /// 8px - Small spacing
  static const double sm = 8;
  
  /// 16px - Medium spacing (default)
  static const double md = 16;
  
  /// 24px - Large spacing
  static const double lg = 24;
  
  /// 32px - Extra large spacing
  static const double xl = 32;
  
  /// 48px - Double extra large spacing
  static const double xxl = 48;
  
  /// 64px - Triple extra large spacing
  static const double xxxl = 64;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON PADDING PRESETS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard screen horizontal padding (20px)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  
  /// Screen padding with vertical component
  static const EdgeInsets screenPaddingAll = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  
  /// Standard card padding (16px all around)
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  
  /// Large card padding (20px all around)
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);
  
  /// Compact card padding (12px all around)
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12);
  
  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );
  
  /// Small button padding
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION GAPS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Gap between major sections
  static const double sectionGap = 32;
  
  /// Gap between subsections
  static const double subsectionGap = 24;
  
  /// Gap between list items
  static const double listItemGap = 12;

  // ═══════════════════════════════════════════════════════════════════════════
  // GAME CARD DIMENSIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard game card width
  static const double gameCardWidth = 140;
  
  /// Standard game card height
  static const double gameCardHeight = 200;
  
  /// Game card image height
  static const double gameCardImageHeight = 130;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENT HEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard button height
  static const double buttonHeight = 56;
  
  /// Small button height
  static const double buttonHeightSmall = 44;
  
  /// Hero section height
  static const double heroHeight = 400;
  
  /// Bottom navigation height
  static const double bottomNavHeight = 80;
  
  /// Top app bar height
  static const double topBarHeight = 56;
  
  /// Mystery picker height
  static const double mysteryPickerHeight = 140;
}
