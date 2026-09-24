import 'package:intl/intl.dart';

/// Utility class for formatting currency and parsing money strings in Vietnamese Dong (VND).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(
    locale: 'vi_VN',
  );

  /// Formats a num or double into standard VND currency string (e.g., "3.500.000 ₫")
  static String format(num? amount) {
    if (amount == null) return '0 ₫';
    return _vndFormat.format(amount);
  }

  /// Formats a num into compact VND currency string (e.g., "3,5 Tr")
  static String formatCompact(num? amount) {
    if (amount == null) return '0 ₫';
    return '${_compactFormat.format(amount)} ₫';
  }

  /// Parses a formatted currency string into a double, removing dots and symbol.
  static double parse(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}
