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
          child: Column(
            children: [
              const Text('Click outside to dismiss'),
              FlyoutTarget(controller: controller, child: const Text('Target')),
            ],
          ),
        ),
      );

      controller.showFlyout<void>(
        builder: (context) => const FlyoutContent(child: Text('Flyout')),
      );
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      // Tap outside to dismiss
      await tester.tap(find.text('Click outside to dismiss'));
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
}
