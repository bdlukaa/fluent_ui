import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'app_test.dart';

void main() {
  testWidgets('NumberBox renders with initial value', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: NumberBox<int>(value: 42, onChanged: (value) {})),
    );

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('NumberBox updates value when text changes', (tester) async {
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

  testWidgets('NumberBox shows clear button when focused', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: NumberBox<int>(value: 5, onChanged: (value) {})),
    );

    await tester.tap(find.byType(TextBox));
    await tester.pump();

    expect(find.byIcon(FluentIcons.clear), findsOneWidget);
  });

  testWidgets('NumberBox clears value when clear button is pressed', (
    tester,
  ) async {
    int? newValue;
    await tester.pumpWidget(
      wrapApp(
        child: NumberBox<int>(
          value: 15,
          onChanged: (value) {
            newValue = value;
          },
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

  testWidgets(
    'NumberBox shows increment and decrement buttons in inline mode',
    (tester) async {
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
    },
  );

  testWidgets('NumberBox increments value when increment button is pressed', (
    tester,
  ) async {
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

  testWidgets('NumberBox decrements value when decrement button is pressed', (
    tester,
  ) async {
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

  testWidgets('NumberBox respects min value', (tester) async {
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

  testWidgets('NumberBox respects max value', (tester) async {
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

  testWidgets('NumberBox evaluates expressions when allowExpressions is true', (
    tester,
  ) async {
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

  testWidgets('NumberBox responds to keyboard arrow keys', (tester) async {
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

  testWidgets('NumberBox responds to page up/down keys', (tester) async {
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

  testWidgets('NumberBox responds to mouse wheel scroll', (tester) async {
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

    await tester.sendEventToBinding(
      PointerScrollEvent(position: center, scrollDelta: const Offset(0, -10)),
    );

    await tester.pumpAndSettle();

    expect(newValue, equals(1));

    await tester.sendEventToBinding(
      PointerScrollEvent(position: center, scrollDelta: const Offset(0, 10)),
    );
    await tester.pumpAndSettle();

    expect(newValue, equals(0));
  });

  testWidgets('NumberBox formats double values with specified precision', (
    tester,
  ) async {
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

  testWidgets('NumberBox shows placeholder when value is null', (tester) async {
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

  testWidgets('NumberBox shows leading icon when provided', (tester) async {
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

  group('NumberBox with custom format and parse functions', () {
    testWidgets('NumberBox displays formatted value with custom format', (
      tester,
    ) async {
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 1234.56,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
            onChanged: (value) {},
          ),
        ),
      );

      // The value should be formatted as currency
      expect(find.textContaining(r'$'), findsOneWidget);
      expect(find.textContaining('1,234'), findsOneWidget);
    });

    testWidgets('NumberBox increments correctly with custom parse function', (
      tester,
    ) async {
      double? newValue;
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 100,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
            mode: SpinButtonPlacementMode.inline,
            onChanged: (value) {
              newValue = value;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(FluentIcons.chevron_up));
      await tester.pumpAndSettle();

      expect(newValue, equals(101.0));
    });

    testWidgets('NumberBox decrements correctly with custom parse function', (
      tester,
    ) async {
      double? newValue;
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 100,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
            mode: SpinButtonPlacementMode.inline,
            onChanged: (value) {
              newValue = value;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(FluentIcons.chevron_down));
      await tester.pumpAndSettle();

      expect(newValue, equals(99.0));
    });

    testWidgets(
      'NumberBox handles keyboard arrows with custom parse function',
      (tester) async {
        double? newValue;
        final currencyFormat = NumberFormat.currency(symbol: r'$');

        await tester.pumpWidget(
          wrapApp(
            child: NumberBox<double>(
              value: 50,
              format: (number) =>
                  number == null ? null : currencyFormat.format(number),
              parse: (text) {
                try {
                  return currencyFormat.parse(text).toDouble();
                } catch (_) {
                  return null;
                }
              },
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

        expect(newValue, equals(51.0));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();

        expect(newValue, equals(50.0));
      },
    );

    testWidgets('NumberBox handles page up/down with custom parse function', (
      tester,
    ) async {
      double? newValue;
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 100,
            largeChange: 50,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
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

      expect(newValue, equals(150.0));

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();

      expect(newValue, equals(100.0));
    });

    testWidgets('NumberBox handles mouse scroll with custom parse function', (
      tester,
    ) async {
      double? newValue;
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 200,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
            onChanged: (value) {
              newValue = value;
            },
          ),
        ),
      );

      final numberBoxFinder = find.byType(NumberBox<double>);
      await tester.tap(numberBoxFinder);
      await tester.pumpAndSettle();

      final box = tester.getRect(numberBoxFinder);
      final center = box.center;

      await tester.sendEventToBinding(
        PointerScrollEvent(position: center, scrollDelta: const Offset(0, -10)),
      );
      await tester.pumpAndSettle();

      expect(newValue, equals(201.0));

      await tester.sendEventToBinding(
        PointerScrollEvent(position: center, scrollDelta: const Offset(0, 10)),
      );
      await tester.pumpAndSettle();

      expect(newValue, equals(200.0));
    });

    testWidgets('NumberBox respects min/max with custom parse function', (
      tester,
    ) async {
      double? newValue;
      final currencyFormat = NumberFormat.currency(symbol: r'$');

      await tester.pumpWidget(
        wrapApp(
          child: NumberBox<double>(
            value: 50,
            min: 0,
            max: 100,
            format: (number) =>
                number == null ? null : currencyFormat.format(number),
            parse: (text) {
              try {
                return currencyFormat.parse(text).toDouble();
              } catch (_) {
                return null;
              }
            },
            mode: SpinButtonPlacementMode.inline,
            onChanged: (value) {
              newValue = value;
            },
          ),
        ),
      );

      // Try to exceed max
      await tester.enterText(find.byType(TextBox), r'$150.00');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(newValue, equals(100.0));

      // Try to go below min
      await tester.enterText(find.byType(TextBox), r'-$50.00');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(newValue, equals(0.0));
    });

    testWidgets(
      'NumberBox with thousand separators formats and parses correctly',
      (tester) async {
        int? newValue;
        final numberFormat = NumberFormat('#,###');

        await tester.pumpWidget(
          wrapApp(
            child: NumberBox<int>(
              value: 1000000,
              format: (number) =>
                  number == null ? null : numberFormat.format(number),
              parse: (text) {
                try {
                  return numberFormat.parse(text).toInt();
                } catch (_) {
                  return null;
                }
              },
              mode: SpinButtonPlacementMode.inline,
              onChanged: (value) {
                newValue = value;
              },
            ),
          ),
        );

        // Should display with thousand separators
        expect(find.text('1,000,000'), findsOneWidget);

        // Increment should work
        await tester.tap(find.byIcon(FluentIcons.chevron_up));
        await tester.pumpAndSettle();

        expect(newValue, equals(1000001));
      },
    );
  });
}
