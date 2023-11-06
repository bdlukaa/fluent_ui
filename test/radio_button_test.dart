import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('RadioButton Test', () {
    testWidgets('RadioButton is displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: RadioButton(checked: true, onChanged: (_) {}),
        ),
      );

      final radioFinder = find.byType(RadioButton);
      expect(radioFinder, findsOneWidget);
    });

    testWidgets('RadioButton is selectable', (WidgetTester tester) async {
      var selectedIndex = -1;

      final firstKey = LabeledGlobalKey('0');
      final secondKey = LabeledGlobalKey('1');
      final thirdKey = LabeledGlobalKey('2');

      final keys = [firstKey, secondKey, thirdKey];

      await tester.pumpWidget(
        wrapApp(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: List.generate(3, (index) {
                  return RadioButton(
                    key: keys[index],
                    checked: index == selectedIndex,
                    onChanged: (bool value) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                }),
              );
            },
          ),
        ),
      );

      // Check for 3 RadioButton widgets
      final radioFinder = find.byType(RadioButton);
      expect(radioFinder, findsNWidgets(3));

      var firstRadio = firstKey.currentWidget as RadioButton;
      var secondRadio = secondKey.currentWidget as RadioButton;
      var thirdRadio = thirdKey.currentWidget as RadioButton;

      // Check for initial states
      expect(firstRadio.checked, false);
      expect(secondRadio.checked, false);
      expect(thirdRadio.checked, false);

      // Update state by tapping on the first RadioButton
      await tester.tap(find.byKey(firstKey));
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);

      firstRadio = firstKey.currentWidget as RadioButton;
      secondRadio = secondKey.currentWidget as RadioButton;
      thirdRadio = thirdKey.currentWidget as RadioButton;

      // Check checked state for all RadioButton widgets
      expect(firstRadio.checked, true);
      expect(secondRadio.checked, false);
      expect(thirdRadio.checked, false);

      // Tap on third RadioButton
      await tester.tap(find.byKey(thirdKey));
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);

      firstRadio = firstKey.currentWidget as RadioButton;
      secondRadio = secondKey.currentWidget as RadioButton;
      thirdRadio = thirdKey.currentWidget as RadioButton;

      // Check state of all RadioButton widgets
      expect(firstRadio.checked, false);
      expect(secondRadio.checked, false);
      expect(thirdRadio.checked, true);
    });
  });
}
