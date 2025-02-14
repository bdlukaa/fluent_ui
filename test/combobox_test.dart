import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('ComboBox', () {
    testWidgets('is displayed correctly', (tester) async {
      var selectedValue = 0;

      await tester.pumpWidget(
        wrapApp(
          child: ComboBox<int>(
            value: selectedValue,
            items: [1, 2, 3].map((e) {
              return ComboBoxItem(
                value: e,
                child: Text('$e'),
              );
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(ComboBox<int>), findsOneWidget);
    });

    testWidgets('is selected correctly', (tester) async {
      var selectedValue = -1;
      final comboBoxKey = LabeledGlobalKey('combo_box');

      await tester.pumpWidget(
        wrapApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return ComboBox<int>(
                value: selectedValue,
                key: comboBoxKey,
                items: [0, 1, 2].map((e) {
                  return ComboBoxItem<int>(
                    key: ValueKey('$e'),
                    value: e,
                    child: Text('${e + 1}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedValue = value;
                  });
                },
              );
            },
          ),
        ),
      );

      // Find ComboBox widget
      final comboBox = find.byKey(comboBoxKey);

      expect(comboBox, findsOneWidget);

      // The ComboBoxItems are not visible yet
      expect(find.byType(ComboBoxItem<int>), findsNothing);

      // Tap the ComboBox
      await tester.tap(find.byKey(comboBoxKey));
      await tester.pumpAndSettle();

      // ComboBoxItems are visible
      final comboBoxItems = find.byType(ComboBoxItem<int>);
      expect(comboBoxItems, findsNWidgets(3));

      final comboBoxItem1 = find.byKey(const ValueKey('0'));
      final comboBoxItem2 = find.byKey(const ValueKey('1'));
      final comboBoxItem3 = find.byKey(const ValueKey('2'));

      expect(comboBoxItem1, findsOneWidget);
      expect(comboBoxItem2, findsOneWidget);
      expect(comboBoxItem3, findsOneWidget);

      // Select a ComboBoxItem
      await tester.tap(comboBoxItem1);
      await tester.pumpAndSettle();

      // The selected ComboBoxItem is founds and the rest are not found
      expect(find.byKey(const ValueKey('0')), findsOneWidget);
      expect(find.byKey(const ValueKey('1')), findsNothing);
      expect(find.byKey(const ValueKey('2')), findsNothing);
    });
  });
}
