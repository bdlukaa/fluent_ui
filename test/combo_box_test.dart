import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

List<ComboBoxItem<String>> _items({int count = 4}) => [
  for (var index = 0; index < count; index++)
    ComboBoxItem<String>(
      key: Key('item-$index'),
      value: '$index',
      child: Text('Option $index'),
    ),
];

void main() {
  testWidgets('renders a placeholder and controlled selected value', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          placeholder: const Text('Select item', key: Key('placeholder')),
          items: _items(count: 2),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('placeholder')), findsOneWidget);

    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          value: '1',
          placeholder: const Text('Select item', key: Key('placeholder')),
          items: _items(count: 2),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Option 1'), findsOneWidget);
    expect(find.byKey(const Key('placeholder')), findsNothing);
  });

  testWidgets('pointer selection commits the value and dismisses the popup', (
    tester,
  ) async {
    String? selectedValue;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          items: _items(count: 2),
          onChanged: (value) => selectedValue = value,
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('item-0')));
    await tester.pumpAndSettle();

    expect(selectedValue, '0');
    expect(find.byKey(const Key('item-1')), findsNothing);
  });

  testWidgets('disabled controls and disabled items do not commit', (
    tester,
  ) async {
    String? selectedValue;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          items: const [
            ComboBoxItem(
              value: 'disabled',
              enabled: false,
              child: Text('Disabled'),
            ),
            ComboBoxItem(value: 'enabled', child: Text('Enabled')),
          ],
          onChanged: (value) => selectedValue = value,
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selectedValue, 'enabled');

    await tester.pumpWidget(
      wrapApp(child: ComboBox<String>(items: _items(count: 2))),
    );
    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-0')), findsNothing);
  });

  testWidgets('popup opening animation starts when the portal mounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(items: _items(count: 2), onChanged: (_) {}),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pump();
    final revealFinder = find.byKey(const Key('combo-box-popup-reveal'));
    expect(revealFinder, findsOneWidget);
    final initialClipper = tester.widget<ClipRect>(revealFinder).clipper!;
    final listSize = tester.getSize(find.byType(ListView));
    final initialClip = initialClipper.getClip(listSize);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midClipper = tester.widget<ClipRect>(revealFinder).clipper!;
    final midClip = midClipper.getClip(listSize);
    expect(midClip.height, greaterThan(initialClip.height));

    final transitionFinder = find.byKey(const Key('combo-box-popup-fade'));
    expect(transitionFinder, findsOneWidget);
    final transition = tester.widget<FadeTransition>(transitionFinder);
    expect(transition.opacity.value, greaterThan(0));

    await tester.pumpAndSettle();
    final settledTransition = tester.widget<FadeTransition>(transitionFinder);
    expect(settledTransition.opacity.value, 1);
  });

  testWidgets('hovering an item does not reposition the popup', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(items: _items(count: 8), onChanged: (_) {}),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    final before = tester.getRect(find.byType(ListView));
    final gesture = await tester.createGesture();
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('item-1'))));
    await tester.pump();
    final after = tester.getRect(find.byType(ListView));
    await gesture.removePointer();

    expect(after, before);
  });

  testWidgets('open and close callbacks fire once for each lifecycle', (
    tester,
  ) async {
    var opens = 0;
    var closes = 0;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          items: _items(count: 2),
          onChanged: (_) {},
          onOpen: () => opens++,
          onClose: () => closes++,
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(opens, 1);
    expect(closes, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(closes, 1);

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('item-0')));
    await tester.pumpAndSettle();
    expect(opens, 2);
    expect(closes, 2);
  });

  testWidgets('clicking outside dismisses the popup', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: Column(
          children: [
            const SizedBox(key: Key('outside'), height: 200, width: 2000),
            ComboBox<String>(items: _items(count: 2), onChanged: (_) {}),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-0')), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-0')), findsNothing);
  });

  testWidgets(
    'keyboard navigation highlights before committing and restores focus',
    (tester) async {
      String? selectedValue;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        wrapApp(
          child: ComboBox<String>(
            autofocus: true,
            focusNode: focusNode,
            items: _items(count: 3),
            onChanged: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('item-0')), findsOneWidget);
      expect(selectedValue, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selectedValue, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selectedValue, '1');
      expect(focusNode.hasPrimaryFocus, isTrue);
    },
  );

  testWidgets('type-ahead is case-insensitive and skips disabled items', (
    tester,
  ) async {
    String? selectedValue;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          autofocus: true,
          items: const [
            ComboBoxItem(
              value: 'disabled',
              enabled: false,
              child: Text('Blue'),
            ),
            ComboBoxItem(value: 'enabled', child: Text('Black')),
          ],
          onChanged: (value) => selectedValue = value,
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pump();
    expect(selectedValue, 'enabled');
  });

  testWidgets('custom search labels support type-ahead', (tester) async {
    String? selectedValue;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          autofocus: true,
          items: const [
            ComboBoxItem(
              value: 'second',
              searchLabel: 'Searchable second',
              child: Icon(WindowsIcons.search),
            ),
          ],
          onChanged: (value) => selectedValue = value,
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    expect(selectedValue, 'second');
  });

  testWidgets('editable ComboBox uses the shared popup architecture', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: EditableComboBox<String>(
          value: '0',
          items: _items(count: 2),
          onChanged: (_) {},
          onFieldSubmitted: (text) => text,
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('variable-height items respect large text scaling', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: ComboBox<String>(
            items: const [
              ComboBoxItem(value: 'short', child: Text('Short')),
              ComboBoxItem(
                value: 'long',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A multiline option with a larger text scale'),
                    Text('A caption below the option'),
                  ],
                ),
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('A caption below the option'), findsOneWidget);
  });

  testWidgets('constrained popup anchors correctly with large text scaling', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: ComboBox<String>(
            value: '8',
            popupConstraints: const BoxConstraints(maxHeight: 220),
            items: _items(count: 30),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();

    final control = tester.getRect(find.text('Option 8').first);
    final selected = tester.getRect(find.byKey(const Key('item-8')).last);
    final popup = tester.getRect(find.byType(ListView));
    expect(selected.top, greaterThanOrEqualTo(popup.top));
    expect(selected.bottom, lessThanOrEqualTo(popup.bottom));
    expect((selected.center.dy - control.center.dy).abs(), lessThan(24));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected item remains visible near the lower viewport edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 220);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapApp(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ComboBox<String>(
            value: '25',
            items: _items(count: 50),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();

    final selectedItems = find.byKey(const Key('item-25'));
    expect(selectedItems, findsNWidgets(2));
    final popupItemRect = tester.getRect(selectedItems.at(1));
    expect(popupItemRect.top, greaterThanOrEqualTo(0));
    expect(popupItemRect.bottom, lessThanOrEqualTo(220));
    expect(tester.takeException(), isNull);
  });

  testWidgets('popup constraints are capped by the viewport', (tester) async {
    tester.view.physicalSize = const Size(240, 180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          popupConstraints: const BoxConstraints(
            minWidth: 120,
            maxWidth: 500,
            minHeight: 120,
            maxHeight: 500,
          ),
          items: _items(count: 100),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();

    final list = find.byType(ListView);
    expect(list, findsOneWidget);
    final size = tester.getSize(list);
    expect(size.width, lessThanOrEqualTo(240));
    expect(size.height, lessThanOrEqualTo(180));
    expect(tester.takeException(), isNull);
  });

  testWidgets('constrained popup anchors its selected item to the control', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          value: '8',
          popupConstraints: const BoxConstraints(minWidth: 180, maxHeight: 220),
          items: _items(count: 30),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    final control = tester.getRect(find.text('Option 8').first);
    final selected = tester.getRect(find.byKey(const Key('item-8')).last);
    final popup = tester.getRect(find.byType(ListView));
    expect(popup.top, greaterThanOrEqualTo(0));
    expect(popup.bottom, lessThanOrEqualTo(tester.view.physicalSize.height));
    expect(selected.top, greaterThanOrEqualTo(popup.top));
    expect(selected.bottom, lessThanOrEqualTo(popup.bottom));
    expect((selected.center.dy - control.center.dy).abs(), lessThan(24));
    expect(tester.takeException(), isNull);
  });

  testWidgets('popup stays in bounds in RTL', (tester) async {
    tester.view.physicalSize = const Size(240, 180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapApp(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.topRight,
            child: ComboBox<String>(
              items: _items(count: 12),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    final popupItemRect = tester.getRect(find.byKey(const Key('item-0')).last);
    expect(popupItemRect.left, greaterThanOrEqualTo(0));
    expect(popupItemRect.right, lessThanOrEqualTo(240));
    expect(tester.takeException(), isNull);
  });

  testWidgets('popup portal is above a ContentDialog barrier', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: Builder(
          builder: (context) => Button(
            child: const Text('Show dialog'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ContentDialog(
                  content: ComboBox<String>(
                    items: _items(count: 2),
                    onChanged: (_) {},
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('item-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover does not move the indicator, keyboard movement does', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          value: '0',
          items: _items(count: 3),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('combo-box-selection-indicator')),
      findsOneWidget,
    );

    final gesture = await tester.createGesture();
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('item-2'))));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('combo-box-selection-indicator')),
      findsOneWidget,
    );
    await gesture.removePointer();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('combo-box-selection-indicator')),
      findsNWidgets(2),
    );

    expect(
      find.byKey(const ValueKey('combo-box-selection-indicator')),
      findsNWidgets(2),
    );
  });

  testWidgets('placeholder uses the secondary text color', (tester) async {
    Color? placeholderColor;
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          placeholder: Builder(
            builder: (context) {
              placeholderColor = DefaultTextStyle.of(context).style.color;
              return const Text('Select an item');
            },
          ),
          items: _items(count: 2),
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      placeholderColor,
      FluentTheme.of(
        tester.element(find.byType(ComboBox<String>)),
      ).resources.textFillColorSecondary,
    );
  });

  testWidgets('scrolling the popup does not move its rectangle', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(
          value: '8',
          popupConstraints: const BoxConstraints(maxHeight: 220),
          items: _items(count: 30),
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    final before = tester.getRect(list);
    await tester.drag(list, const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(tester.getRect(list), before);
  });

  testWidgets('popup item content is centered in the compact row', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ComboBox<String>(items: _items(count: 2), onChanged: (_) {}),
      ),
    );

    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();

    final row = tester.getRect(find.byKey(const Key('item-0')));
    final text = tester.getRect(find.text('Option 0'));
    expect(row.height, lessThanOrEqualTo(kComboBoxItemHeight));
    expect((row.center.dy - text.center.dy).abs(), lessThanOrEqualTo(1));
  });
}
