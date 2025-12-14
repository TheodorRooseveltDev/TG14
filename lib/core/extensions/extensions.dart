import 'package:flutter/material.dart';

/// Extensions on BuildContext
extension BuildContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get safe area padding
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
}

/// Extensions on Color
extension ColorExtensions on Color {
  /// Create a linear gradient with this color
  LinearGradient toGradient({Color? endColor, AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [this, endColor ?? withOpacity(0.7)],
    );
  }
}

/// Extensions on Widget
extension WidgetExtensions on Widget {
  /// Add padding around widget
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// Add horizontal padding
  Widget withHorizontalPadding(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Add vertical padding
  Widget withVerticalPadding(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Center widget
  Widget centered() => Center(child: this);

  /// Wrap in Expanded
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wrap in SizedBox with width
  Widget withWidth(double width) => SizedBox(width: width, child: this);

  /// Wrap in SizedBox with height
  Widget withHeight(double height) => SizedBox(height: height, child: this);

  /// Add opacity
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Clip with border radius
  Widget clipped(BorderRadius radius) {
    return ClipRRect(borderRadius: radius, child: this);
  }
}

/// Extensions on String
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

/// Extensions on num
extension NumExtensions on num {
  /// Create SizedBox with this height
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Create SizedBox with this width
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
