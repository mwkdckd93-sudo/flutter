import 'package:intl/intl.dart';

/// Currency formatting utilities for Iraqi Dinar
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _iqdFormat = NumberFormat.decimalPattern('ar');

  /// Format price in Iraqi Dinar
  static String formatIQD(double amount) {
    return '${_iqdFormat.format(amount)} د.ع';
  }

  /// Format price with abbreviation (K, M)
  static String formatIQDShort(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} م د.ع';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} ألف د.ع';
    }
    return formatIQD(amount);
  }

  /// Parse price string to double
  static double? parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }
}
