import 'package:flutter/material.dart';

/// Animation constants for consistent motion throughout the app
class AppAnimations {
  AppAnimations._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Fast animation - micro-interactions (150ms)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Normal animation - standard transitions (250ms)
  static const Duration normal = Duration(milliseconds: 250);
  
  /// Slow animation - emphasis transitions (400ms)
  static const Duration slow = Duration(milliseconds: 400);
  
  /// Dramatic animation - reveals, celebrations (600ms)
  static const Duration dramatic = Duration(milliseconds: 600);
  
  /// Very slow - splash animations, shimmer loops (1000ms)
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  /// Splash total duration
  static const Duration splashDuration = Duration(milliseconds: 3000);
  
  /// Page transition duration
  static const Duration pageTransition = Duration(milliseconds: 300);

  // ═══════════════════════════════════════════════════════════════════════════
  // CURVES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard ease out - most UI transitions
  static const Curve defaultCurve = Curves.easeOutCubic;
  
  /// Bouncy - playful elements
  static const Curve bouncyCurve = Curves.elasticOut;
  
  /// Smooth - buttons, press states
  static const Curve smoothCurve = Curves.easeInOut;
  
  /// Dramatic - reveals, celebrations
  static const Curve dramaticCurve = Curves.easeOutExpo;
  
  /// Fast out - quick exits
  static const Curve fastOutCurve = Curves.fastOutSlowIn;
  
  /// Decelerate - settling animations
  static const Curve decelerateCurve = Curves.decelerate;

  // ═══════════════════════════════════════════════════════════════════════════
  // SCALE VALUES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Button press scale
  static const double buttonPressScale = 0.95;
  
  /// Card tap scale
  static const double cardTapScale = 0.98;
  
  /// Pulse scale min
  static const double pulseScaleMin = 1.0;
  
  /// Pulse scale max
  static const double pulseScaleMax = 1.02;
  
  /// Breathing scale max (for floating elements)
  static const double breathingScaleMax = 1.03;

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFSETS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Slide up offset for reveals
  static const Offset slideUpOffset = Offset(0, 0.05);
  
  /// Slide down offset for dismissals
  static const Offset slideDownOffset = Offset(0, -0.05);
  
  /// No offset (target)
  static const Offset zeroOffset = Offset.zero;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Create interval for staggered animations
  static CurvedAnimation createInterval(
    AnimationController controller, {
    required double begin,
    required double end,
    Curve curve = Curves.easeOut,
  }) {
    return CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: curve),
    );
  }
}
