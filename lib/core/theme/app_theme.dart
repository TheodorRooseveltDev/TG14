import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Complete Theme Configuration for Casino Dealer's Flow
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Primary color scheme
      primaryColor: AppColors.feltGreen,
      scaffoldBackgroundColor: AppColors.feltGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textOnGreen,
        error: AppColors.redVelvet,
        onError: AppColors.textOnGreen,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.displaySmall,
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          elevation: 4,
          textStyle: AppTypography.buttonText,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.buttonText,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.slateGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.slateGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: AppColors.redVelvet),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.slateGray,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.gold,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        titleMedium: AppTypography.cardTitle,
        labelLarge: AppTypography.buttonText,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.gold,
        size: 24,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.deepBlack,
        elevation: 6,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.slateGray,
        thickness: 1,
        space: 16,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.feltGreen,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.slateGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
        titleTextStyle: AppTypography.displaySmall,
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBackground,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return AppColors.slateGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold.withOpacity(0.5);
          }
          return AppColors.slateGray.withOpacity(0.3);
        }),
      ),
      
      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.slateGray,
        thumbColor: AppColors.gold,
        overlayColor: Color(0x33F7D66A),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.slateGray,
      ),
    );
  }
  
  // System UI configuration
  static void setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.feltGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  // Private constructor
  AppTheme._();
}
