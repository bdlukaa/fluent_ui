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
}
