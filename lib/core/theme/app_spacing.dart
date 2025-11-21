import 'package:flutter/material.dart';

/// Spacing & Layout System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  
  // Private constructor
  AppSpacing._();
}

/// Border Radius System
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 999.0;
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(999.0));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(20.0),
  );
  
  // Private constructor
  AppRadius._();
}

/// Component-specific styles
class AppDecoration {
  // Card Decoration with gold top border
  static BoxDecoration get card => BoxDecoration(
    color: const Color(0xFF0A2E16),
    borderRadius: AppRadius.cardRadius,
    border: const Border(
      top: BorderSide(color: Color(0xFFF7D66A), width: 2),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Felt Background
  static BoxDecoration get feltBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0C3B1B), Color(0xFF061F0F)],
    ),
  );
  
  // Input Field Decoration
  static InputDecoration inputDecoration({
    required String hint,
    String? label,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0A2E16),
      border: OutlineInputBorder(
        borderRadius: AppRadius.buttonRadius,
        borderSide: const BorderSide(color: Color(0xFF798883)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.buttonRadius,
        borderSide: const BorderSide(color: Color(0xFF798883)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.buttonRadius,
        borderSide: const BorderSide(color: Color(0xFFF7D66A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.buttonRadius,
        borderSide: const BorderSide(color: Color(0xFFA70020)),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF798883),
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFFF7D66A),
        fontSize: 14,
      ),
    );
  }
  
  // Private constructor
  AppDecoration._();
}
