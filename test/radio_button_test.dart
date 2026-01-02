import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('RadioButton initializes with correct selected value', (
    tester,
  ) async {
    const radioButtonValue = 1;
    const groupValue = 1;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton<int>(
              value: radioButtonValue,
              groupValue: groupValue,
              onChanged: (value) {},
            ),
          );
        },
      ),
    );

    expect(
      tester.widget<RadioButton<int>>(find.byType(RadioButton<int>)).value,
      radioButtonValue,
    );
    expect(
      tester.widget<RadioButton<int>>(find.byType(RadioButton<int>)).groupValue,
      groupValue,
    );
  });
  testWidgets('RadioButton change state accordingly', (tester) async {
    int? radioButtonValue;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton<int>(
              value: 1,
              groupValue: radioButtonValue,
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

    expect(tester.widget<RadioButton<int>>(find.byType(RadioButton<int>)).groupValue, null);

    await tester.tap(find.byType(RadioButton<int>));
    await tester.pumpAndSettle();
    expect(radioButtonValue, 1);

    // Tapping again should not change value (radio buttons don't toggle off by default)
    await tester.tap(find.byType(RadioButton<int>));
    await tester.pumpAndSettle();
    expect(radioButtonValue, 1);
  });
  
  testWidgets('RadioButton toggleable allows deselection', (tester) async {
    int? radioButtonValue = 1;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton<int>(
              value: 1,
              groupValue: radioButtonValue,
              toggleable: true,
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

    expect(radioButtonValue, 1);

    // Tapping when selected should deselect with toggleable
    await tester.tap(find.byType(RadioButton<int>));
    await tester.pumpAndSettle();
    expect(radioButtonValue, null);
  });
  
  testWidgets('Radio Button can be focused and selected with keyboard', (
    tester,
  ) async {
    int? radioButtonValue;
    final focusNode = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton<int>(
              value: 1,
              groupValue: radioButtonValue,
              focusNode: focusNode,
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
    final radioButtonFinder = find.byType(RadioButton<int>);

    expect(radioButtonFinder, findsOneWidget);
    expect(focusNode.hasFocus, false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(focusNode.hasFocus, true);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(radioButtonValue, 1);
  });

  testWidgets('Disabled RadioButton cannot be selected', (tester) async {
    int? radioButtonValue;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioButton<int>(
              value: 1,
              groupValue: radioButtonValue,
              onChanged: null,
            ),
          );
        },
      ),
    );
    final radioButtonFinder = find.byType(RadioButton<int>);
    final radioButtonWidget = tester.widget<RadioButton<int>>(radioButtonFinder);

    expect(radioButtonWidget.groupValue, null);
    await tester.tap(radioButtonFinder);
    await tester.pumpAndSettle();
    expect(radioButtonValue, null);
  });
  testWidgets('Focus moves between RadioButtons in correct order', (
    tester,
  ) async {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();
    int? selectedValue;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                RadioButton<int>(
                  autofocus: true,
                  key: const Key('radioButton1'),
                  value: 1,
                  groupValue: selectedValue,
                  focusNode: focusNode1,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                ),
                RadioButton<int>(
                  key: const Key('radioButton2'),
                  value: 2,
                  groupValue: selectedValue,
                  focusNode: focusNode2,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
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
  
  testWidgets('RadioButton group works correctly', (tester) async {
    int? selectedValue;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                RadioButton<int>(
                  key: const Key('radio1'),
                  value: 1,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                  content: const Text('Option 1'),
                ),
                RadioButton<int>(
                  key: const Key('radio2'),
                  value: 2,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                  content: const Text('Option 2'),
                ),
                RadioButton<int>(
                  key: const Key('radio3'),
                  value: 3,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                  content: const Text('Option 3'),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(selectedValue, null);

    // Select first radio button
    await tester.tap(find.byKey(const Key('radio1')));
    await tester.pumpAndSettle();
    expect(selectedValue, 1);

    // Select second radio button
    await tester.tap(find.byKey(const Key('radio2')));
    await tester.pumpAndSettle();
    expect(selectedValue, 2);

    // Select third radio button
    await tester.tap(find.byKey(const Key('radio3')));
    await tester.pumpAndSettle();
    expect(selectedValue, 3);
  });
}
