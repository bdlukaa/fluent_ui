import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Flyout open and close with FlyoutController', (tester) async {
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );
    expect(controller.isAttached, isTrue);

    controller.showFlyout<void>(
      builder: (context) => const FlyoutContent(child: Text('Flyout')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Flyout'), findsOneWidget);
    expect(controller.isOpen, isTrue);

    // Close flyout
    controller.close<void>();
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(find.text('Flyout'), findsNothing);
  });

  testWidgets(
    'Flyout closes when clicking outside if barrierDismissible is true',
    (tester) async {
      final controller = FlyoutController();
      await tester.pumpWidget(
        wrapApp(
          child: Center(
            child: FlyoutTarget(
              controller: controller,
              child: const Text('Target'),
            ),
          ),
        ),
      );

      controller.showFlyout<void>(
        builder: (context) => const FlyoutContent(child: Text('Flyout')),
      );
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      // Tap outside the flyout to dismiss (top-left corner of the screen)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
      expect(find.text('Flyout'), findsNothing);
    },
  );

  testWidgets('MenuFlyout displays items and responds to tap', (tester) async {
    var pressed = false;
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutItem(
            text: const Text('Item 1'),
            onPressed: () {
              pressed = true;
            },
          ),
          const MenuFlyoutSeparator(),
          MenuFlyoutItem(text: const Text('Item 2'), onPressed: () {}),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('MenuFlyoutItem disables onPressed when null', (tester) async {
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutItem(text: const Text('Disabled Item'), onPressed: null),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final item = find.text('Disabled Item');
    expect(item, findsOneWidget);

    await tester.tap(item);
    await tester.pumpAndSettle();
    // Should still be open since item is disabled
    expect(controller.isOpen, isTrue);
    expect(find.text('Disabled Item'), findsOneWidget);
  });

  testWidgets('ToggleMenuFlyoutItem toggles value and calls onChanged', (
    tester,
  ) async {
    bool? value;
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          ToggleMenuFlyoutItem(
            text: const Text('Toggle'),
            value: false,
            onChanged: (v) => value = v,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('RadioMenuFlyoutItem calls onChanged with correct value', (
    tester,
  ) async {
    String? selected;
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          RadioMenuFlyoutItem<String>(
            text: const Text('A'),
            value: 'A',
            groupValue: 'B',
            onChanged: (v) => selected = v,
          ),
          RadioMenuFlyoutItem<String>(
            text: const Text('B'),
            value: 'B',
            groupValue: 'B',
            onChanged: (v) => selected = v,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(selected, 'A');
  });

  testWidgets('MenuFlyoutItemBuilder builds custom widget', (tester) async {
    final controller = FlyoutController();

    await tester.pumpWidget(
      wrapApp(
        child: FlyoutTarget(
          controller: controller,
          child: const Text('Target'),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutItemBuilder(
            builder: (context) => const Text('Custom Item'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom Item'), findsOneWidget);
  });

  testWidgets(
    'MenuFlyoutSubItem hover does not throw TypeError on findRenderObject',
    (tester) async {
      final controller = FlyoutController();

      await tester.pumpWidget(
        wrapApp(
          child: Center(
            child: FlyoutTarget(
              controller: controller,
              child: const Text('Target'),
            ),
          ),
        ),
      );

      controller.showFlyout<void>(
        builder: (context) => MenuFlyout(
          items: [
            MenuFlyoutSubItem(
              text: const Text('Sub Menu'),
              items: (context) => [
                MenuFlyoutItem(
                  text: const Text('Sub Item 1'),
                  onPressed: () {},
                ),
              ],
            ),
            MenuFlyoutItem(text: const Text('Item 2'), onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sub Menu'), findsOneWidget);

      // Hover over the sub-menu item to trigger its display
      final subMenuFinder = find.text('Sub Menu');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(subMenuFinder));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // The sub-menu should now be showing
      expect(find.text('Sub Item 1'), findsOneWidget);

      // Move the mouse away from the sub-item to trigger the onHover code path
      // that calls findRenderObject() on the parent. This is the code path that
      // previously had a bug (missing parentheses on findRenderObject).
      await gesture.moveTo(tester.getCenter(find.text('Item 2')));
      await tester.pumpAndSettle();

      // Should not have thrown a TypeError
      await gesture.removePointer();
    },
  );

  testWidgets(
    'MenuFlyoutSubItem shows chevron_right trailing icon in LTR context',
    (tester) async {
      final controller = FlyoutController();

      await tester.pumpWidget(
        wrapApp(
          child: Center(
            child: FlyoutTarget(
              controller: controller,
              child: const Text('Target'),
            ),
          ),
        ),
      );

      controller.showFlyout<void>(
        builder: (context) => MenuFlyout(
          items: [
            MenuFlyoutSubItem(
              text: const Text('Sub Menu'),
              items: (context) => [],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Find all WindowsIcon widgets in the tree and verify the sub-item
      // trailing uses chevron_right in LTR mode.
      final icons = tester.widgetList<WindowsIcon>(find.byType(WindowsIcon));
      expect(
        icons.any((icon) => icon.icon == WindowsIcons.chevron_right),
        isTrue,
        reason:
            'MenuFlyoutSubItem should show chevron_right trailing icon in LTR',
      );
      expect(
        icons.any((icon) => icon.icon == WindowsIcons.chevron_left),
        isFalse,
        reason:
            'MenuFlyoutSubItem should not show chevron_left trailing icon in LTR',
      );
    },
  );

  testWidgets(
    'MenuFlyoutSubItem shows chevron_left trailing icon in RTL context',
    (tester) async {
      final controller = FlyoutController();

      await tester.pumpWidget(
        FluentApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: FlyoutTarget(
                controller: controller,
                child: const Text('Target'),
              ),
            ),
          ),
        ),
      );

      controller.showFlyout<void>(
        builder: (context) => MenuFlyout(
          items: [
            MenuFlyoutSubItem(
              text: const Text('Sub Menu'),
              items: (context) => [],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Find all WindowsIcon widgets in the tree and verify the sub-item
      // trailing uses chevron_left in RTL mode.
      final icons = tester.widgetList<WindowsIcon>(find.byType(WindowsIcon));
      expect(
        icons.any((icon) => icon.icon == WindowsIcons.chevron_left),
        isTrue,
        reason:
            'MenuFlyoutSubItem should show chevron_left trailing icon in RTL',
      );
      expect(
        icons.any((icon) => icon.icon == WindowsIcons.chevron_right),
        isFalse,
        reason:
            'MenuFlyoutSubItem should not show chevron_right trailing icon in RTL',
      );
    },
  );

  testWidgets('MenuFlyoutSubItem sub-menu opens to the left in RTL context', (
    tester,
  ) async {
    final controller = FlyoutController();

    await tester.pumpWidget(
      FluentApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: FlyoutTarget(
              controller: controller,
              child: const Text('Target'),
            ),
          ),
        ),
      ),
    );

    controller.showFlyout<void>(
      builder: (context) => MenuFlyout(
        items: [
          MenuFlyoutSubItem(
            text: const Text('Sub Menu'),
            items: (context) => [
              MenuFlyoutItem(text: const Text('Sub Item 1'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sub Menu'), findsOneWidget);
    final subMenuParentRect = tester.getRect(find.text('Sub Menu'));

    // Hover over the sub-menu item to trigger its display
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('Sub Menu')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // The sub-menu should now be showing
    expect(find.text('Sub Item 1'), findsOneWidget);

    // In RTL mode, the sub-menu should appear to the LEFT of the parent item.
    final subItemRect = tester.getRect(find.text('Sub Item 1'));
    expect(
      subItemRect.left,
      lessThan(subMenuParentRect.left),
      reason: 'In RTL, sub-menu should open to the left of the parent item',
    );

    await gesture.removePointer();
  });
}
