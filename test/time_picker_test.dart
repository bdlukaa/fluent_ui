import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TimePicker displays selected time in 24-hour format', (
    tester,
  ) async {
    final selectedTime = DateTime(2023, 1, 1, 14, 30);
    await tester.pumpWidget(
      wrapApp(
        child: TimePicker(
          hourFormat: HourFormat.HH,
          selected: selectedTime,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('14'), findsOneWidget); // hour
    expect(find.text('30'), findsOneWidget); // minute
    expect(find.text('AM'), findsNothing); // AM/PM indicator
    expect(find.text('PM'), findsNothing); // AM/PM indicator
  });

  testWidgets('TimePicker displays selected time in 12-hour format', (
    tester,
  ) async {
    final selectedTime = DateTime(2023, 1, 1, 15, 30);
    await tester.pumpWidget(
      wrapApp(
        child: TimePicker(selected: selectedTime, onChanged: (_) {}),
      ),
    );

    expect(find.text('03'), findsOneWidget); // hour
    expect(find.text('30'), findsOneWidget); // minute
    expect(find.text('PM'), findsOneWidget); // AM/PM indicator
  });
  testWidgets('TimePicker calls onChanged when time is changed', (
    tester,
  ) async {
    DateTime? changedTime;
    final selectedTime = DateTime(2023, 1, 1, 10, 15);
    await tester.pumpWidget(
      wrapApp(
        child: TimePicker(
          selected: selectedTime,
          onChanged: (time) {
            changedTime = time;
          },
        ),
      ),
    );
    // Open the picker
    await tester.tap(find.byType(TimePicker));
    await tester.pumpAndSettle();

    // Simulate selecting a new hour (e.g., 11)
    final hourTile = find.text('11').first;
    await tester.tap(hourTile);
    await tester.pumpAndSettle();

    // Confirm selection
    await tester.tap(find.byIcon(FluentIcons.check_mark));
    await tester.pumpAndSettle();

    expect(changedTime?.hour, 11);
  });

  testWidgets('TimePicker is disabled when onChanged is null', (tester) async {
    final selectedTime = DateTime(2023, 1, 1, 8);
    await tester.pumpWidget(wrapApp(child: TimePicker(selected: selectedTime)));
    // Open the picker
    await tester.tap(find.byType(TimePicker));
    await tester.pumpAndSettle();
    // Check that the picker is disabled
    expect(find.byIcon(FluentIcons.check_mark), findsNothing);
  });

  testWidgets('TimePicker shows header when provided', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: TimePicker(
          selected: DateTime(2023, 1, 1, 9, 45),
          onChanged: (_) {},
          header: 'Pick a time',
        ),
      ),
    );

    expect(find.text('Pick a time'), findsOneWidget);
  });

  testWidgets('TimePicker respects minuteIncrement', (tester) async {
    final selectedTime = DateTime(2023, 1, 1, 1);
    await tester.pumpWidget(
      wrapApp(
        child: TimePicker(
          selected: selectedTime,
          onChanged: (_) {},
          minuteIncrement: 13,
        ),
      ),
    );

    // Open the picker
    await tester.tap(find.byType(TimePicker));
    await tester.pumpAndSettle();

    // Only multiples of 13 should be present
    expect(find.text('00').first, findsOneWidget); // 00 is a multiple of 13
    expect(find.text('13').first, findsOneWidget);
    expect(find.text('26').first, findsOneWidget);
    expect(find.text('39').first, findsOneWidget);

    expect(find.text('14'), findsNothing); // 14 is not a multiple of 13
  });
}
