import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ToggleSwitch change state accordingly', (tester) async {
    var toggleSwitchValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ToggleSwitch(
              checked: toggleSwitchValue,
              onChanged: (value) {
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

  testWidgets('ToggleSwitch can drag (LTR)', (tester) async {
    var value = false;

    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: ToggleSwitch(
                checked: value,
                onChanged: (newValue) {
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

    await tester.drag(find.byType(ToggleSwitch), const Offset(-30, 0));

    expect(value, isFalse);

    await tester.drag(find.byType(ToggleSwitch), const Offset(30, 0));

    expect(value, isTrue);

    await tester.pump();
    await tester.drag(find.byType(ToggleSwitch), const Offset(30, 0));

    expect(value, isTrue);

    await tester.pump();
    await tester.drag(find.byType(ToggleSwitch), const Offset(-30, 0));

    expect(value, isFalse);
  });
}
