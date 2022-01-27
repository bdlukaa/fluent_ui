import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ToggleSwitch change state accordingly',
      (WidgetTester tester) async {
    bool toggleSwitchValue = false;

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
}
