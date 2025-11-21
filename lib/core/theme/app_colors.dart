import 'package:flutter/material.dart';

/// Casino Dealer's Flow Color Palette
/// EXACT VALUES - DO NOT MODIFY
class AppColors {
  // Primary Colors
  static const Color feltGreen = Color(0xFF0C3B1B);
  static const Color gold = Color(0xFFF7D66A);
  static const Color deepBlack = Color(0xFF000000);
  
  // Secondary Colors
  static const Color redVelvet = Color(0xFFA70020);
  static const Color slateGray = Color(0xFF798883);
  
  // Gradient Definitions
  static const LinearGradient feltGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C3B1B), Color(0xFF061F0F)],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7D66A), Color(0xFFD4A94A)],
  );
  
  // Utility Colors
  static const Color cardBackground = Color(0xFF0A2E16);
  static const Color textOnGreen = Color(0xFFFAF8F3);
  static const Color disabledGold = Color(0xFFB89F5A);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color goldLight = Color(0xFFFFE89D);
  
  // Shadows
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow goldGlow = BoxShadow(
    color: gold.withOpacity(0.3),
    blurRadius: 10,
    spreadRadius: 2,
  );
  
  // Private constructor to prevent instantiation
  AppColors._();
}
