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
}
