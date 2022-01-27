import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Checkbox change state accordingly', (WidgetTester tester) async {
    bool? checkBoxValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return wrapApp(
            child: Checkbox(
              checked: checkBoxValue,
              onChanged: (bool? value) {
                setState(() {
                  checkBoxValue = value;
                });
              },
            ),
          );
        },
      ),
    );

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).checked, false);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checkBoxValue, true);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checkBoxValue, false);
  });
}
