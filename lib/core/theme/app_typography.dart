import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography System for Casino Dealer's Flow
/// Uses SF Pro (iOS native fonts)
class AppTypography {
  static const String primaryFont = 'SF Pro Display';
  static const String secondaryFont = 'SF Pro Text';
  
  // Display Styles (for headers/titles)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnGreen,
    height: 1.3,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnGreen,
    height: 1.4,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnGreen,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnGreen,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnGreen,
    height: 1.4,
  );
  
  // Special Styles
  static const TextStyle goldAccent = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 0.5,
  );
  
  static const TextStyle chipLabel = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.deepBlack,
    letterSpacing: 1.2,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnGreen,
    height: 1.3,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGray,
    height: 1.4,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.deepBlack,
    letterSpacing: 0.5,
  );
  
  static const TextStyle captionText = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGray,
    height: 1.3,
  );
  
  // Private constructor
  AppTypography._();
}
