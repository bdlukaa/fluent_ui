import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('RadioButton change state accordingly',
      (WidgetTester tester) async {
    var radioButtonValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return wrapApp(
            child: RadioButton(
              checked: radioButtonValue,
              onChanged: (bool value) {
                setState(() {
                  radioButtonValue = value;
                });
              },
            ),
          );
        },
      ),
    );

    expect(tester.widget<RadioButton>(find.byType(RadioButton)).checked, false);

    await tester.tap(find.byType(RadioButton));
    await tester.pumpAndSettle();
    expect(radioButtonValue, true);

    await tester.tap(find.byType(RadioButton));
    await tester.pumpAndSettle();
    expect(radioButtonValue, false);
  });
}
