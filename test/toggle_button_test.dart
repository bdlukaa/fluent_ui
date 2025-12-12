import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ToggleButton change state accordingly', (tester) async {
    var toggleButtonValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ToggleButton(
              checked: toggleButtonValue,
              onChanged: (value) {
                setState(() {
                  toggleButtonValue = value;
                });
              },
            ),
          );
        },
      ),
    );

    expect(
      tester.widget<ToggleButton>(find.byType(ToggleButton)).checked,
      false,
    );

    await tester.tap(find.byType(ToggleButton));
    await tester.pumpAndSettle();
    expect(toggleButtonValue, true);

    await tester.tap(find.byType(ToggleButton));
    await tester.pumpAndSettle();
    expect(toggleButtonValue, false);
  });
}
