import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium typography system for the casino app
/// - Playfair Display: Display text (heroes, jackpots)
/// - Inter: UI text (labels, body)
/// - DM Sans: Numbers (tabular figures)
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPLAY - Hero sections, jackpots
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
  );
  
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.2,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADLINES - Section titles
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY - Content text
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABELS - Buttons, captions
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMBERS - Tabular figures for alignment
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get numberDisplay => GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numberLarge => GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numberMedium => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  
  static TextStyle get numberSmall => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // JACKPOT - Special style for big numbers
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextStyle get jackpotDisplay => GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
