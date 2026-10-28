import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExtension', () {
    group('isSameDay', () {
      test('returns true for the exact same DateTime', () {
        final date = DateTime(2024, 5, 10, 14, 30);
        expect(date.isSameDay(date), isTrue);
      });

      test('returns true for same day with different times', () {
        final morning = DateTime(2024, 5, 10, 8);
        final evening = DateTime(2024, 5, 10, 22, 45);
        expect(morning.isSameDay(evening), isTrue);
        expect(evening.isSameDay(morning), isTrue);
      });

      test('returns false for different days in same month', () {
        final day1 = DateTime(2024, 5, 10);
        final day2 = DateTime(2024, 5, 11);
        expect(day1.isSameDay(day2), isFalse);
      });

      test('returns false for same day in different months or years', () {
        final date1 = DateTime(2024, 5, 10);
        final date2 = DateTime(2024, 6, 10);
        final date3 = DateTime(2023, 5, 10);
        expect(date1.isSameDay(date2), isFalse);
        expect(date1.isSameDay(date3), isFalse);
      });

      test('returns false when other is null', () {
        final date = DateTime(2024, 5, 10);
        expect(date.isSameDay(null), isFalse);
      });
    });

    group('isSameMonth', () {
      test('returns true for same month and year regardless of day', () {
        final start = DateTime(2024, 3);
        final end = DateTime(2024, 3, 31);
        expect(start.isSameMonth(end), isTrue);
      });

      test('returns false for different months in same year', () {
        final march = DateTime(2024, 3, 15);
        final april = DateTime(2024, 4, 15);
        expect(march.isSameMonth(april), isFalse);
      });

      test('returns false for same month in different years', () {
        final y2023 = DateTime(2023, 3, 15);
        final y2024 = DateTime(2024, 3, 15);
        expect(y2023.isSameMonth(y2024), isFalse);
      });

      test('returns false when other is null', () {
        final date = DateTime(2024, 3, 15);
        expect(date.isSameMonth(null), isFalse);
      });
    });

    group('addDays', () {
      test('adds positive and negative days across month boundaries', () {
        final date = DateTime(2024, 1, 30);
        expect(date.addDays(3), DateTime(2024, 2, 2));
        expect(date.addDays(-31), DateTime(2023, 12, 30));
      });

      test('handles leap years correctly', () {
        final feb28Leap = DateTime(2024, 2, 28);
        expect(feb28Leap.addDays(1), DateTime(2024, 2, 29));
        expect(feb28Leap.addDays(2), DateTime(2024, 3));

        final feb28NonLeap = DateTime(2023, 2, 28);
        expect(feb28NonLeap.addDays(1), DateTime(2023, 3));
      });

      test('preserves isUtc property', () {
        final localDate = DateTime(2024, 5, 10);
        final localAdded = localDate.addDays(5);
        expect(localAdded.isUtc, isFalse);
        expect(localAdded, DateTime(2024, 5, 15));

        final utcDate = DateTime.utc(2024, 5, 10);
        final utcAdded = utcDate.addDays(5);
        expect(utcAdded.isUtc, isTrue);
        expect(utcAdded, DateTime.utc(2024, 5, 15));
      });
    });

    group('daysInMonth', () {
      test('returns 31 for months with 31 days', () {
        const months31 = [1, 3, 5, 7, 8, 10, 12];
        for (final m in months31) {
          expect(DateTime(2024, m).daysInMonth, 31);
        }
      });

      test('returns 30 for months with 30 days', () {
        const months30 = [4, 6, 9, 11];
        for (final m in months30) {
          expect(DateTime(2024, m).daysInMonth, 30);
        }
      });

      test('returns 29 for February in leap year and 28 in non-leap year', () {
        expect(DateTime(2024, 2).daysInMonth, 29);
        expect(DateTime(2023, 2).daysInMonth, 28);
        expect(DateTime(2000, 2).daysInMonth, 29); // Century leap year
        expect(DateTime(1900, 2).daysInMonth, 28); // Non-leap century year
      });
    });
  });
}
