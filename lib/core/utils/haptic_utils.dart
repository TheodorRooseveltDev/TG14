import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class HapticUtils {
  HapticUtils._();

  /// Light haptic - for subtle interactions
  static void light() => HapticFeedback.lightImpact();

  /// Medium haptic - for standard buttons
  static void medium() => HapticFeedback.mediumImpact();

  /// Heavy haptic - for important actions
  static void heavy() => HapticFeedback.heavyImpact();

  /// Selection haptic - for selections
  static void selection() => HapticFeedback.selectionClick();

  /// Vibrate - for wins/celebrations
  static void vibrate() => HapticFeedback.vibrate();
}
