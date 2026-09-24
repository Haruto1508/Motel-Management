import 'package:flutter_test/flutter_test.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/utils/validators.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats positive amounts correctly into VND format', () {
      final formatted = CurrencyFormatter.format(3000000);
      expect(formatted.contains('3.000.000'), isTrue);
      expect(formatted.contains('₫'), isTrue);
    });

    test('handles null amounts gracefully by returning 0 ₫', () {
      expect(CurrencyFormatter.format(null), '0 ₫');
    });

    test('parses formatted string back into double', () {
      final parsed = CurrencyFormatter.parse('3.500.000 ₫');
      expect(parsed, 3500000.0);
    });
  });

  group('DateFormatter Tests', () {
    test('formats DateTime into dd/MM/yyyy', () {
      final date = DateTime(2026, 9, 23);
      expect(DateFormatter.format(date), '23/09/2026');
    });

    test('formats DateTime into billing month MM/yyyy', () {
      final date = DateTime(2026, 9, 1);
      expect(DateFormatter.formatMonthYear(date), '09/2026');
    });

    test('parses dd/MM/yyyy string into DateTime', () {
      final parsed = DateFormatter.parse('23/09/2026');
      expect(parsed, isNotNull);
      expect(parsed!.day, 23);
      expect(parsed.month, 9);
      expect(parsed.year, 2026);
    });
  });

  group('Validators Tests', () {
    test('validates Vietnamese phone numbers correctly', () {
      expect(Validators.phone('0912345678'), isNull);
      expect(Validators.phone('0398765432'), isNull);
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('0123456789'), isNotNull);
    });

    test('validates email addresses', () {
      expect(Validators.email('owner@property.vn'), isNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('validates CCCD/CMND numbers', () {
      expect(Validators.identityNumber('012345678901'), isNull); // 12 digits
      expect(Validators.identityNumber('123456789'), isNull); // 9 digits
      expect(Validators.identityNumber('12345'), isNotNull);
    });

    test('validates meter reading sequence', () {
      expect(
        Validators.meterReadingSequence(
          previousReading: 100,
          currentReading: 120,
        ),
        isNull,
      );

      expect(
        Validators.meterReadingSequence(
          previousReading: 120,
          currentReading: 100,
        ),
        isNotNull,
      );
    });
  });
}
