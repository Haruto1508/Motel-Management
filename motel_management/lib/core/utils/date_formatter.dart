import 'package:intl/intl.dart';

/// Utility class for formatting and parsing dates across the rental management application.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  /// Formats [DateTime] into "dd/MM/yyyy"
  static String format(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  /// Formats [DateTime] into "dd/MM/yyyy HH:mm"
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  /// Formats [DateTime] into billing month "MM/yyyy" (e.g. "09/2026")
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormat.format(date);
  }

  /// Formats [DateTime] into ISO date string "yyyy-MM-dd" for API payloads
  static String toApiDate(DateTime? date) {
    if (date == null) return '';
    return _apiDateFormat.format(date);
  }

  /// Parses "dd/MM/yyyy" into [DateTime]
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return _dateFormat.parse(dateStr.trim());
    } catch (_) {
      return null;
    }
  }

  /// Parses "MM/yyyy" into [DateTime] (1st day of the month)
  static DateTime? parseMonthYear(String? monthYearStr) {
    if (monthYearStr == null || monthYearStr.trim().isEmpty) return null;
    try {
      return _monthYearFormat.parse(monthYearStr.trim());
    } catch (_) {
      return null;
    }
  }

  /// Parses ISO 8601 string or returns null
  static DateTime? parseIso(String? isoStr) {
    if (isoStr == null || isoStr.trim().isEmpty) return null;
    try {
      return DateTime.parse(isoStr.trim());
    } catch (_) {
      return null;
    }
  }
}
