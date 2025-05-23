import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'app_test.dart';

void main() {
  testWidgets('NumberBox renders with initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(
      child: NumberBox<int>(
        value: 42,
        onChanged: (value) {},
      ),
    ));

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('NumberBox updates value when text changes',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 10,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextBox), '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(newValue, equals(20));
  });

  testWidgets('NumberBox shows clear button when focused',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
          child: NumberBox<int>(
        value: 5,
        onChanged: (value) {},
        clearButton: true,
      )),
    );

    await tester.tap(find.byType(TextBox));
    await tester.pump();

    expect(find.byIcon(FluentIcons.clear), findsOneWidget);
  });

  testWidgets('NumberBox clears value when clear button is pressed',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 15,
          onChanged: (value) {
            newValue = value;
          },
          clearButton: true,
        ),
      ),
    );

    await tester.tap(find.byType(NumberBox<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FluentIcons.clear));
    await tester.pumpAndSettle();

    expect(newValue, isNull);
    expect(find.text('15'), findsNothing);
  });

  testWidgets('NumberBox shows increment and decrement buttons in inline mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          onChanged: (value) {},
          mode: SpinButtonPlacementMode.inline,
        ),
      ),
    );

    expect(find.byIcon(FluentIcons.chevron_up), findsOneWidget);
    expect(find.byIcon(FluentIcons.chevron_down), findsOneWidget);
  });

  testWidgets('NumberBox increments value when increment button is pressed',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          onChanged: (value) {
            newValue = value;
          },
          mode: SpinButtonPlacementMode.inline,
        ),
      ),
    );

    await tester.tap(find.byIcon(FluentIcons.chevron_up));
    await tester.pumpAndSettle();

    expect(newValue, equals(1));
  });

  testWidgets('NumberBox decrements value when decrement button is pressed',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          onChanged: (value) {
            newValue = value;
          },
          mode: SpinButtonPlacementMode.inline,
        ),
      ),
    );

    await tester.tap(find.byIcon(FluentIcons.chevron_down));
    await tester.pumpAndSettle();

    expect(newValue, equals(-1));
  });

  testWidgets('NumberBox respects min value', (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 5,
          min: 0,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextBox), '-5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(newValue, equals(0));
  });

  testWidgets('NumberBox respects max value', (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 5,
          max: 10,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextBox), '15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(newValue, equals(10));
  });

  testWidgets('NumberBox evaluates expressions when allowExpressions is true',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 1,
          allowExpressions: true,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextBox), '2+3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(newValue, equals(5));
  });

  testWidgets('NumberBox responds to keyboard arrow keys',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.tap(find.byType(TextBox));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    expect(newValue, equals(1));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(newValue, equals(0));
  });

  testWidgets('NumberBox responds to page up/down keys',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          largeChange: 5,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    await tester.tap(find.byType(TextBox));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();

    expect(newValue, equals(5));

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();

    expect(newValue, equals(0));
  });

  testWidgets('NumberBox responds to mouse wheel scroll',
      (WidgetTester tester) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          onChanged: (value) {
            newValue = value;
          },
        ),
      ),
    );

    final numberBoxFinder = find.byType(NumberBox<int>);
    await tester.tap(numberBoxFinder);
    await tester.pumpAndSettle();

    final box = tester.getRect(numberBoxFinder);
    final center = box.center;

    await tester.sendEventToBinding(PointerScrollEvent(
      position: center,
      scrollDelta: const Offset(0, -10),
    ));

    await tester.pumpAndSettle();

    expect(newValue, equals(1));

    await tester.sendEventToBinding(PointerScrollEvent(
      position: center,
      scrollDelta: const Offset(0, 10),
    ));
    await tester.pumpAndSettle();

    expect(newValue, equals(0));
  });

  testWidgets('NumberBox formats double values with specified precision',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: NumberBox<double>(
            value: 3.14159,
            precision: 2,
            onChanged: (value) {},
          ),
        ),
      ),
    );

    expect(find.text('3.14'), findsOneWidget);
  });

  testWidgets('NumberBox shows placeholder when value is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: null,
          placeholder: 'Enter a number',
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.text('Enter a number'), findsOneWidget);
  });

  testWidgets('NumberBox shows leading icon when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 0,
          leadingIcon: const Icon(FluentIcons.number_field),
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.byIcon(FluentIcons.number_field), findsOneWidget);
  });
}
