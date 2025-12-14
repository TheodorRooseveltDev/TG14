import 'package:intl/intl.dart';

/// Utility class for number formatting
class NumberUtils {
  NumberUtils._();

  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  static final NumberFormat _integerFormat = NumberFormat('#,###');
  static final NumberFormat _compactFormat = NumberFormat.compact();

  /// Format number as currency (e.g., 1,234,567.89)
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Format number with commas (e.g., 1,234,567)
  static String formatInteger(int value) {
    return _integerFormat.format(value);
  }

  /// Format number in compact form (e.g., 1.2M)
  static String formatCompact(num value) {
    return _compactFormat.format(value);
  }

  /// Format coin balance with dollar sign
  static String formatCoinBalance(int value) {
    return '\$ ${_currencyFormat.format(value.toDouble())}';
  }

  /// Format jackpot value
  static String formatJackpot(double value) {
    return '\$ ${_currencyFormat.format(value)}';
  }
}
