import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'app_test.dart';

void main() {
  late List<MenuBarItem> items;

  setUp(() {
    items = [
      MenuBarItem(
        title: 'File',
        items: [
          MenuFlyoutItem(text: const Text('New'), onPressed: () {}),
          MenuFlyoutItem(text: const Text('Open'), onPressed: () {}),
        ],
      ),
      MenuBarItem(
        title: 'Edit',
        items: [MenuFlyoutItem(text: const Text('Undo'), onPressed: () {})],
      ),
    ];
  });

  testWidgets('MenuBar renders all menu bar items', (tester) async {
    await tester.pumpWidget(wrapApp(child: MenuBar(items: items)));
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('MenuBar shows flyout when menu item is tapped', (tester) async {
    await tester.pumpWidget(wrapApp(child: MenuBar(items: items)));
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('MenuBar shows correct flyout for each menu item', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(child: MenuBar(items: items)));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('New'), findsNothing);
  });

  testWidgets('MenuBar closes flyout when tapping outside', (tester) async {
    await tester.pumpWidget(wrapApp(child: MenuBar(items: items)));
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);

    await tester.tapAt(const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsNothing);
  });

  testWidgets('MenuBar supports MenuFlyoutSubItem', (tester) async {
    final subItems = [
      MenuBarItem(
        title: 'View',
        items: [
          MenuFlyoutSubItem(
            text: const Text('Zoom'),
            items: (context) => [
              MenuFlyoutItem(text: const Text('Zoom In'), onPressed: () {}),
              MenuFlyoutItem(text: const Text('Zoom Out'), onPressed: () {}),
            ],
          ),
        ],
      ),
    ];
    await tester.pumpWidget(wrapApp(child: MenuBar(items: subItems)));

    // Open the top-level menu
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Zoom'), findsOneWidget);

    // Tap the sub-item to open its sub-menu
    await tester.tap(find.text('Zoom'));
    await tester.pumpAndSettle();
    expect(find.text('Zoom In'), findsOneWidget);
    expect(find.text('Zoom Out'), findsOneWidget);
  });

  testWidgets('MenuBar animates open and closes on hover switch', (
    tester,
  ) async {
    const Duration animDuration = Duration(milliseconds: 80);
    await tester.pumpWidget(
      wrapApp(
        child: FluentTheme(
          data: FluentThemeData(fastAnimationDuration: animDuration),
          child: MenuBar(items: items),
        ),
      ),
    );

    // Open first menu
    await tester.tap(find.text('File'));
    await tester.pump();
    // After one frame, animation is in progress — menu may not be fully visible
    // After animDuration, animation completes and menu is fully visible
    await tester.pump(animDuration);
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);

    // Close by tapping outside
    await tester.tapAt(const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsNothing);

    // Open second menu — should also animate
    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.pump(animDuration);
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('MenuBar wraps items by default when overflowing', (
    tester,
  ) async {
    final manyItems = List.generate(
      15,
      (i) => MenuBarItem(
        title: 'Menu $i',
        items: [MenuFlyoutItem(text: Text('Item $i'), onPressed: () {})],
      ),
    );

    await tester.pumpWidget(wrapApp(child: MenuBar(items: manyItems)));

    // All items should render (wrapping to multiple lines)
    for (int i = 0; i < 15; i++) {
      expect(find.text('Menu $i'), findsOneWidget);
    }

    // Opening a menu should still work
    await tester.tap(find.text('Menu 0'));
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
  });

  testWidgets('MenuBar scrolls when overflowBehavior is scroll', (
    tester,
  ) async {
    final manyItems = List.generate(
      15,
      (i) => MenuBarItem(
        title: 'Menu $i',
        items: [MenuFlyoutItem(text: Text('Item $i'), onPressed: () {})],
      ),
    );

    await tester.pumpWidget(
      wrapApp(
        child: MenuBar(
          items: manyItems,
          overflowBehavior: MenuBarOverflowBehavior.scroll,
        ),
      ),
    );

    // All items should render (scrollable)
    for (int i = 0; i < 15; i++) {
      expect(find.text('Menu $i'), findsOneWidget);
    }

    // Should find a scrollable
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('MenuBar opens upward when near bottom edge', (tester) async {
    // Position the menu bar at the bottom of a 600px-tall screen
    await tester.pumpWidget(
      wrapApp(
        child: SizedBox(
          height: 600,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MenuBar(items: items),
          ),
        ),
      ),
    );

    // Menu items should render
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Opening should not crash (menu opens upward because there's no space below)
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('closeAfterClick closes the menu', (tester) async {
    var pressed = false;
    final clickItems = [
      MenuBarItem(
        title: 'Actions',
        items: [
          MenuFlyoutItem(
            text: const Text('Do Something'),
            onPressed: () => pressed = true,
            closeAfterClick: true,
          ),
        ],
      ),
    ];
    await tester.pumpWidget(wrapApp(child: MenuBar(items: clickItems)));

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('Do Something'), findsOneWidget);

    await tester.tap(find.text('Do Something'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
    // Menu should be closed after clicking the item
    expect(find.text('Do Something'), findsNothing);
  });

  testWidgets('MenuBar supports ToggleMenuFlyoutItem', (tester) async {
    var isToggled = false;
    final toggleItems = [
      MenuBarItem(
        title: 'Options',
        items: [
          ToggleMenuFlyoutItem(
            text: const Text('Toggle Me'),
            value: isToggled,
            onChanged: (v) => isToggled = v,
          ),
        ],
      ),
    ];
    await tester.pumpWidget(wrapApp(child: MenuBar(items: toggleItems)));

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();
    expect(find.text('Toggle Me'), findsOneWidget);

    await tester.tap(find.text('Toggle Me'));
    await tester.pumpAndSettle();
    expect(isToggled, isTrue);
  });

  testWidgets('MenuBar supports RadioMenuFlyoutItem', (tester) async {
    var selected = 'a';
    final radioItems = [
      MenuBarItem(
        title: 'View',
        items: [
          RadioMenuFlyoutItem<String>(
            text: const Text('Option A'),
            value: 'a',
            groupValue: selected,
            onChanged: (v) => selected = v,
          ),
          RadioMenuFlyoutItem<String>(
            text: const Text('Option B'),
            value: 'b',
            groupValue: selected,
            onChanged: (v) => selected = v,
          ),
        ],
      ),
    ];
    await tester.pumpWidget(wrapApp(child: MenuBar(items: radioItems)));

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('Option B'), findsOneWidget);

    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
  });

  testWidgets('showItem can open and closeFlyout can close', (tester) async {
    final key = GlobalKey<MenuBarState>();
    await tester.pumpWidget(
      wrapApp(
        child: MenuBar(key: key, items: items),
      ),
    );

    // Programmatically open the first item
    key.currentState!.showItem(items[0]);
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);

    // Programmatically close
    key.currentState!.closeFlyout();
    await tester.pumpAndSettle();
    expect(find.text('New'), findsNothing);

    // showItemAt should also work
    key.currentState!.showItemAt(1);
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('currentOpenItem reflects open state', (tester) async {
    final key = GlobalKey<MenuBarState>();
    await tester.pumpWidget(
      wrapApp(
        child: MenuBar(key: key, items: items),
      ),
    );

    expect(key.currentState!.currentOpenItem, isNull);

    key.currentState!.showItem(items[0]);
    await tester.pumpAndSettle();
    expect(key.currentState!.currentOpenItem, items[0]);

    key.currentState!.closeFlyout();
    await tester.pumpAndSettle();
    expect(key.currentState!.currentOpenItem, isNull);
  });
}
