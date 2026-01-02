import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
    'ComboBox should display placeholder text when no value is selected',
    (tester) async {
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return wrapApp(
              child: ComboBox<String>(
                placeholder: const Text('Select item', key: Key('placeholder')),
                items: const [
                  ComboBoxItem(
                    value: 'combo-box-item-1',
                    child: Text('combo-box-item-1'),
                  ),
                  ComboBoxItem(
                    value: 'combo-box-item-2',
                    child: Text('combo-box-item-2'),
                  ),
                ],
                onChanged: (value) {},
              ),
            );
          },
        ),
      );
      final placeHolderFinder = find.byKey(const Key('placeholder'));

      expect(placeHolderFinder, findsOneWidget);
    },
  );

  testWidgets('ComboBox should show the correct initial value when provided', (
    tester,
  ) async {
    const selectedValue = 'combo-box-item-1';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ComboBox<String>(
              value: selectedValue,
              placeholder: const Text('Select item', key: Key('placeholder')),
              items: const [
                ComboBoxItem(
                  value: 'combo-box-item-1',
                  child: Text('combo-box-item-1'),
                ),
                ComboBoxItem(
                  value: 'combo-box-item-2',
                  child: Text('combo-box-item-2'),
                ),
              ],
              onChanged: (value) {},
            ),
          );
        },
      ),
    );
    final combBoxFinder = find.byType(Text);

    expect(combBoxFinder, findsOneWidget);

    expect(tester.widget<Text>(combBoxFinder).data, selectedValue);
  });

  testWidgets(
    'ComboBox should update selected value when an option is chosen',
    (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return wrapApp(
              child: ComboBox<String>(
                autofocus: true,
                placeholder: const Text('Select item', key: Key('placeholder')),
                items: const [
                  ComboBoxItem(
                    key: Key('combo-box-item-1'),
                    value: 'combo-box-item-1',
                    child: Text('combo-box-item-1'),
                  ),
                  ComboBoxItem(
                    key: Key('combo-box-item-2'),
                    value: 'combo-box-item-2',
                    child: Text('combo-box-item-2'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(ComboBox<String>));

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('combo-box-item-1')));
      await tester.pumpAndSettle();

      expect(selectedValue, 'combo-box-item-1');
    },
  );
  testWidgets('ComboBox should open dropdown when clicked/tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ComboBox<String>(
              placeholder: const Text('Select item', key: Key('placeholder')),
              items: const [
                ComboBoxItem(
                  key: Key('combo-box-item-1'),
                  value: 'combo-box-item-1',
                  child: Text('combo-box-item-1'),
                ),
                ComboBoxItem(
                  key: Key('combo-box-item-2'),
                  value: 'combo-box-item-2',
                  child: Text('combo-box-item-2'),
                ),
              ],
              onChanged: (value) {},
            ),
          );
        },
      ),
    );
    final combBoxFinder = find.byType(ComboBox<String>);
    expect(combBoxFinder, findsOneWidget);
    await tester.tap(combBoxFinder);
    await tester.pumpAndSettle();
    final combBoxItem1Finder = find.byKey(const Key('combo-box-item-1'));

    final combBoxItem2Finder = find.byKey(const Key('combo-box-item-2'));
    expect(combBoxItem1Finder, findsOneWidget);
    expect(combBoxItem2Finder, findsOneWidget);
  });

  testWidgets('ComboBox should close dropdown when clicking outside', (
    tester,
  ) async {
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: Column(
              children: [
                const SizedBox(
                  key: Key('empty-area'),
                  height: 200,
                  width: 2000,
                ),
                ComboBox<String>(
                  placeholder: const Text(
                    'Select item',
                    key: Key('placeholder'),
                  ),
                  items: const [
                    ComboBoxItem(
                      key: Key('combo-box-item-1'),
                      value: 'combo-box-item-1',
                      child: Text('combo-box-item-1'),
                    ),
                    ComboBoxItem(
                      key: Key('combo-box-item-2'),
                      value: 'combo-box-item-2',
                      child: Text('combo-box-item-2'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
          );
        },
      ),
    );
    final combBoxFinder = find.byType(ComboBox<String>);
    expect(combBoxFinder, findsOneWidget);
    await tester.tap(combBoxFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('combo-box-item-1')), findsOneWidget);
    final emptyAreaFinder = find.byKey(const Key('empty-area'));

    expect(emptyAreaFinder, findsOneWidget);
    await tester.tap(emptyAreaFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo-box-item-1')), findsNothing);
  });

  testWidgets('ComboBox should close dropdown after selecting an item', (
    tester,
  ) async {
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ComboBox<String>(
              placeholder: const Text('Select item', key: Key('placeholder')),
              items: const [
                ComboBoxItem(
                  key: Key('combo-box-item-1'),
                  value: 'combo-box-item-1',
                  child: Text('combo-box-item-1'),
                ),
                ComboBoxItem(
                  key: Key('combo-box-item-2'),
                  value: 'combo-box-item-2',
                  child: Text('combo-box-item-2'),
                ),
              ],
              onChanged: (value) {},
            ),
          );
        },
      ),
    );
    final combBoxFinder = find.byType(ComboBox<String>);
    expect(combBoxFinder, findsOneWidget);
    await tester.tap(combBoxFinder);
    await tester.pumpAndSettle();
    final comboBoxItem1Finder = find.byKey(const Key('combo-box-item-1'));
    expect(comboBoxItem1Finder, findsOneWidget);

    await tester.tap(comboBoxItem1Finder);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('combo-box-item-1')), findsNothing);
  });

  testWidgets('ComboBox should open dropdown when pressing enter key', (
    tester,
  ) async {
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return wrapApp(
            child: ComboBox<String>(
              autofocus: true,
              placeholder: const Text('Select item', key: Key('placeholder')),
              items: const [
                ComboBoxItem(
                  key: Key('combo-box-item-1'),
                  value: 'combo-box-item-1',
                  child: Text('combo-box-item-1'),
                ),
                ComboBoxItem(
                  key: Key('combo-box-item-2'),
                  value: 'combo-box-item-2',
                  child: Text('combo-box-item-2'),
                ),
              ],
              onChanged: (value) {},
            ),
          );
        },
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    await tester.pumpAndSettle();
    final comboBoxItem1Finder = find.byKey(const Key('combo-box-item-1'));
    expect(comboBoxItem1Finder, findsOneWidget);
  });
}
