import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('DatePicker displays selected date', (tester) async {
    final selectedDate = DateTime(2022, 5, 15);

    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(selected: selectedDate, onChanged: (_) {}),
      ),
    );

    // Should display the selected month, day, and year
    expect(find.text('May'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
  });

  testWidgets('DatePicker opens popup and changes date', (tester) async {
    DateTime? picked;
    final selectedDate = DateTime(2022, 5, 15);

    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(
          selected: selectedDate,
          onChanged: (date) {
            picked = date;
          },
        ),
      ),
    );

    // Tap to open the picker popup
    await tester.tap(find.byType(DatePicker));
    await tester.pumpAndSettle();

    // Tap on a different day
    final dayTile = find.text('16');
    await tester.tap(dayTile);
    await tester.pumpAndSettle();

    // Confirm selection
    await tester.tap(find.byIcon(FluentIcons.check_mark));
    await tester.pumpAndSettle();

    expect(picked?.day, 16);
    expect(picked?.month, 5);
    expect(picked?.year, 2022);
  });

  testWidgets('DatePicker is disabled when onChanged is null', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: DatePicker(selected: DateTime(2022))),
    );

    await tester.tap(find.byType(DatePicker));
    await tester.pumpAndSettle();
    // date picker should not open
    expect(find.byIcon(FluentIcons.check_mark), findsNothing);
  });

  testWidgets('DatePicker respects showDay/showMonth/showYear', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(
          selected: DateTime(2022),
          onChanged: (_) {},
          showDay: false,
          showYear: false,
        ),
      ),
    );

    expect(find.text('January'), findsOneWidget);
    expect(find.text('2022'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('DatePicker header is displayed', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(
          selected: DateTime(2022),
          onChanged: (_) {},
          header: 'Pick a date',
        ),
      ),
    );

    expect(find.text('Pick a date'), findsOneWidget);
    expect(find.byType(InfoLabel), findsOneWidget);
  });

  testWidgets('DatePicker onCancel is called when dismissed', (tester) async {
    var cancelled = false;
    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(
          selected: DateTime(2022),
          onChanged: (_) {},
          onCancel: () {
            cancelled = true;
          },
        ),
      ),
    );

    await tester.tap(find.byType(DatePicker));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FluentIcons.chrome_close));
    await tester.pumpAndSettle();

    expect(cancelled, isTrue);
  });

  testWidgets('DatePicker respects startDate and endDate', (tester) async {
    final start = DateTime(2020);
    final end = DateTime(2020, 12, 31);
    await tester.pumpWidget(
      wrapApp(
        child: DatePicker(
          selected: DateTime(2020, 6, 15),
          onChanged: (_) {},
          startDate: start,
          endDate: end,
        ),
      ),
    );

    await tester.tap(find.byType(DatePicker));
    await tester.pumpAndSettle();

    // Only year 2020 should be available
    expect(find.text('2020'), findsWidgets);
    expect(find.text('2019'), findsNothing);
    expect(find.text('2021'), findsNothing);
  });
}
