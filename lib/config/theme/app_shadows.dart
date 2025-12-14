import 'package:flutter/material.dart';

/// Premium shadow system for depth and luxury feel
class AppShadows {
  AppShadows._();

  // ═══════════════════════════════════════════════════════════════════════════
  // STANDARD SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard card shadow - subtle depth
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Floating element shadow - more prominent
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 32,
      offset: Offset(0, 16),
      spreadRadius: -8,
    ),
  ];
  
  /// Subtle shadow for small elements
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // GOLD GLOW SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard gold glow - for gold buttons and accents
  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x40F7D66A),
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Intense gold glow - for hero elements and jackpot
  static const List<BoxShadow> goldGlowIntense = [
    BoxShadow(
      color: Color(0x60F7D66A),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x30F7D66A),
      blurRadius: 64,
      offset: Offset(0, 16),
    ),
  ];
  
  /// Subtle gold glow - for hover states
  static const List<BoxShadow> goldGlowSubtle = [
    BoxShadow(
      color: Color(0x25F7D66A),
      blurRadius: 16,
      offset: Offset(0, 2),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // RED GLOW SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Red glow - for hot badges and alerts
  static const List<BoxShadow> redGlow = [
    BoxShadow(
      color: Color(0x40A70020),
      blurRadius: 24,
      offset: Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // INNER SHADOWS (Using gradient overlay technique)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Inner shadow decoration for pressed states
  static BoxDecoration get innerShadowDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.15),
        Colors.transparent,
        Colors.transparent,
        Colors.white.withOpacity(0.05),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Bottom navigation shadow (upward)
  static const List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 20,
      offset: Offset(0, -10),
    ),
  ];
  
  /// Top bar shadow (downward)
  static const List<BoxShadow> topBarShadow = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
