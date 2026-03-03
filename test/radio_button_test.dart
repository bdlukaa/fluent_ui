import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('RadioButton initializes with correct selected value', (
    tester,
  ) async {
    const selectedValue = 1;

    await tester.pumpWidget(
      wrapApp(
        child: RadioGroup<int>(
          groupValue: selectedValue,
          onChanged: (_) {},
          child: const Column(
            children: [
              RadioButton<int>(value: 0, content: Text('Option 1')),
              RadioButton<int>(value: selectedValue, content: Text('Option 2')),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('RadioButton changes state on tap', (tester) async {
    var groupValue = 0;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioGroup<int>(
              groupValue: groupValue,
              onChanged: (value) =>
                  setState(() => groupValue = value ?? groupValue),
              child: const Column(
                children: [
                  RadioButton<int>(value: 0, content: Text('Option 1')),
                  RadioButton<int>(value: 1, content: Text('Option 2')),
                ],
              ),
            ),
          );
        },
      ),
    );

    expect(groupValue, 0);

    await tester.tap(find.byType(RadioButton<int>).last);
    await tester.pumpAndSettle();
    expect(groupValue, 1);

    // Tapping the already-selected button does not deselect it (no-toggle behaviour)
    await tester.tap(find.byType(RadioButton<int>).last);
    await tester.pumpAndSettle();
    expect(groupValue, 1);
  });

  testWidgets('RadioButton can be focused and selected', (tester) async {
    var groupValue = 1;
    final focusNode = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioGroup<int>(
              groupValue: groupValue,
              onChanged: (value) =>
                  setState(() => groupValue = value ?? groupValue),
              child: Column(
                children: [
                  RadioButton<int>(
                    value: 0,
                    focusNode: focusNode,
                    content: const Text('Option 1'),
                  ),
                  const RadioButton<int>(value: 1, content: Text('Option 2')),
                ],
              ),
            ),
          );
        },
      ),
    );

    expect(find.byType(RadioButton<int>), findsNWidgets(2));
    expect(focusNode.hasFocus, false);

    // Directly request focus
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, true);

    // Select via tap
    await tester.tap(find.text('Option 1'));
    await tester.pumpAndSettle();
    expect(groupValue, 0);
  });

  testWidgets('Disabled RadioButton cannot be selected', (tester) async {
    var groupValue = 0;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioGroup<int>(
              groupValue: groupValue,
              onChanged: (value) =>
                  setState(() => groupValue = value ?? groupValue),
              child: const RadioButton<int>(
                value: 1,
                enabled: false,
                content: Text('Option'),
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.byType(RadioButton<int>));
    await tester.pumpAndSettle();
    expect(groupValue, 0);
  });

  testWidgets('Focus moves between RadioButtons', (tester) async {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: RadioGroup<int>(
              groupValue: 0,
              onChanged: (_) {},
              child: Column(
                children: [
                  RadioButton<int>(
                    autofocus: true,
                    key: const Key('radioButton1'),
                    value: 0,
                    focusNode: focusNode1,
                    content: const Text('Option 1'),
                  ),
                  RadioButton<int>(
                    key: const Key('radioButton2'),
                    value: 1,
                    focusNode: focusNode2,
                    content: const Text('Option 2'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('radioButton1')), findsOneWidget);
    expect(find.byKey(const Key('radioButton2')), findsOneWidget);

    // autofocus should give first radio button focus
    expect(focusNode1.hasFocus, true);
    expect(focusNode2.hasFocus, false);

    // Move focus to second radio button directly
    focusNode2.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode2.hasFocus, isTrue);
    expect(focusNode1.hasFocus, isFalse);
  });
}
