import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('CalendarView does not duplicate days during DST transition', (tester) async {
    // October 2026 contains a DST fall-back transition in many timezones (Oct 25, 2026).
    // Test that day 25 is rendered only once in the visible month.
    final testDate = DateTime(2026, 10, 15);

    await tester.pumpWidget(
      wrapApp(
        child: SizedBox(
          width: 400,
          height: 400,
          child: CalendarView(
            selectionMode: CalendarViewSelectionMode.single,
            initialStart: testDate,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Day 25 should appear exactly once in the calendar
    expect(find.text('25'), findsOneWidget);
    // Day 26 should also appear exactly once
    expect(find.text('26'), findsOneWidget);
  });
}
