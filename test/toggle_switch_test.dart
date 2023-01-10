import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ToggleSwitch change state accordingly',
      (WidgetTester tester) async {
    var toggleSwitchValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return wrapApp(
            child: ToggleSwitch(
              checked: toggleSwitchValue,
              onChanged: (bool value) {
                setState(() {
                  toggleSwitchValue = value;
                });
              },
            ),
          );
        },
      ),
    );

    expect(
      tester.widget<ToggleSwitch>(find.byType(ToggleSwitch)).checked,
      false,
    );

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();
    expect(toggleSwitchValue, true);

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();
    expect(toggleSwitchValue, false);
  });

  testWidgets('ToggleSwitch can drag (LTR)', (WidgetTester tester) async {
    var value = false;

    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: ToggleSwitch(
                checked: value,
                onChanged: (bool newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    expect(value, isFalse);

    await tester.drag(find.byType(ToggleSwitch), const Offset(-30.0, 0.0));

    expect(value, isFalse);

    await tester.drag(find.byType(ToggleSwitch), const Offset(30.0, 0.0));

    expect(value, isTrue);

    await tester.pump();
    await tester.drag(find.byType(ToggleSwitch), const Offset(30.0, 0.0));

    expect(value, isTrue);

    await tester.pump();
    await tester.drag(find.byType(ToggleSwitch), const Offset(-30.0, 0.0));

    expect(value, isFalse);
  });
}
