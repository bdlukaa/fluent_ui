import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('RadioButton initializes with correct selected value', (
    tester,
  ) async {
    const radioButtonValue = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton(
              checked: radioButtonValue,
              onChanged: (value) {},
            ),
          );
        },
      ),
    );

    expect(
      tester.widget<RadioButton>(find.byType(RadioButton)).checked,
      radioButtonValue,
    );
  });
  testWidgets('RadioButton change state accordingly', (tester) async {
    var radioButtonValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton(
              checked: radioButtonValue,
              onChanged: (value) {
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
  testWidgets('Radio Button can be focused and selected with keyboard', (
    tester,
  ) async {
    var radioButtonValue = false;
    final focusNode = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton(
              focusNode: focusNode,
              onChanged: (value) {
                setState(() {
                  radioButtonValue = value;
                });
              },
              checked: radioButtonValue,
            ),
          );
        },
      ),
    );
    final radioButtonFinder = find.byType(RadioButton);

    expect(radioButtonFinder, findsOneWidget);
    expect(focusNode.hasFocus, false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(focusNode.hasFocus, true);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(radioButtonValue, true);
  });

  testWidgets('Disabled RadioButton cannot be selected', (tester) async {
    const radioButtonValue = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: const RadioButton(
              onChanged: null,
              checked: radioButtonValue,
            ),
          );
        },
      ),
    );
    final radioButtonFinder = find.byType(RadioButton);
    final radioButtonWidget = tester.widget<RadioButton>(radioButtonFinder);

    expect(radioButtonWidget.checked, false);
    await tester.tap(radioButtonFinder);
    await tester.pumpAndSettle();
    expect(radioButtonValue, false);
  });
  testWidgets('Focus moves between RadioButtons in correct order', (
    tester,
  ) async {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                RadioButton(
                  autofocus: true,
                  key: const Key('radioButton1'),
                  focusNode: focusNode1,
                  onChanged: (value) {},
                  checked: true,
                ),
                RadioButton(
                  key: const Key('radioButton2'),
                  focusNode: focusNode2,
                  onChanged: (value) {},
                  checked: false,
                ),
              ],
            ),
          );
        },
      ),
    );
    final radioButton1Finder = find.byKey(const Key('radioButton1'));
    final radioButton2Finder = find.byKey(const Key('radioButton2'));

    expect(radioButton1Finder, findsOneWidget);
    expect(radioButton2Finder, findsOneWidget);

    expect(focusNode1.hasFocus, true);
    expect(focusNode2.hasFocus, false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(focusNode2.hasFocus, isTrue);
  });
}
