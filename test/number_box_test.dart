import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('NumberBox Test', () {
    testWidgets('is displayed correctly', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<int>(
            value: 0,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(NumberBox<int>), findsOneWidget);
    });

    testWidgets('is increased and decreased by suffix icon button taps',
        (tester) async {
      final numberBoxKey = LabeledGlobalKey('number_box_key');
      var value = 0;

      await tester.pumpWidget(
        wrapApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return NumberBox<int>(
                key: numberBoxKey,
                value: value,
                mode: SpinButtonPlacementMode.inline,
                onChanged: (newValue) {
                  if (newValue == null) return;
                  setState(() {
                    value = newValue;
                  });
                },
              );
            },
          ),
        ),
      );

      expect(find.byType(NumberBox<int>), findsOneWidget);
      var numberBox = numberBoxKey.currentWidget as NumberBox<int>;

      // Default value should be 0
      expect(numberBox.value, 0);

      final incrementWidget = find.byIcon(FluentIcons.chevron_up);
      expect(incrementWidget, findsOneWidget);

      await tester.tap(incrementWidget);
      await tester.pumpAndSettle();

      // NumberBox value should increase
      numberBox = numberBoxKey.currentWidget as NumberBox<int>;
      expect(numberBox.value, 1);
      expect(value, 1);

      final decrementWidget = find.byIcon(FluentIcons.chevron_down);
      expect(decrementWidget, findsOneWidget);

      await tester.tap(decrementWidget);
      await tester.pumpAndSettle();

      // NumberBox value should decrease
      numberBox = numberBoxKey.currentWidget as NumberBox<int>;
      expect(numberBox.value, 0);
      expect(value, 0);
    });

    testWidgets(
      'is increased and decreased by keyboard keys',
      (tester) async {
        final numberBoxKey = LabeledGlobalKey('number_box_key');
        var value = 0;

        await tester.pumpWidget(
          wrapApp(
            child: StatefulBuilder(
              builder: (context, setState) {
                return NumberBox<int>(
                  key: numberBoxKey,
                  value: value,
                  mode: SpinButtonPlacementMode.inline,
                  onChanged: (newValue) {
                    if (newValue == null) return;
                    setState(() {
                      value = newValue;
                    });
                  },
                );
              },
            ),
          ),
        );

        expect(find.byType(NumberBox<int>), findsOneWidget);

        await tester.showKeyboard(find.byType(NumberBox<int>));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        // On LogicalKeyboardKey.arrowUp, NumberBox should get incremented
        // by `min` which is 1 in our case
        var numberBox = numberBoxKey.currentWidget as NumberBox<int>;
        expect(numberBox.value, 1);
        expect(value, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // On LogicalKeyboardKey.arrowDown, NumberBox should get decremented
        // by `min` which is 1 in our case
        numberBox = numberBoxKey.currentWidget as NumberBox<int>;
        expect(numberBox.value, 0);
        expect(value, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pumpAndSettle();

        // On LogicalKeyboardKey.pageUp, NumberBox should get incremented
        // by `max` which is 10 in our case
        numberBox = numberBoxKey.currentWidget as NumberBox<int>;
        expect(numberBox.value, 10);
        expect(value, 10);

        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();

        // On LogicalKeyboardKey.pageDown, NumberBox should get decremented
        // by `max` which is 10 in our case
        numberBox = numberBoxKey.currentWidget as NumberBox<int>;
        expect(numberBox.value, 0);
        expect(value, 0);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        // NumberBox should ignore alphabetic key events
        numberBox = numberBoxKey.currentWidget as NumberBox<int>;
        expect(numberBox.value, 0);
        expect(value, 0);
      },
    );
  });
}
