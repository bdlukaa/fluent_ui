import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TabViewController updates selection and notifies callbacks', (
    tester,
  ) async {
    var changedIndex = -1;
    final tabs = [
      Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
      Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
    ];

    final controller = TabViewController(tabs: tabs);

    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          onChanged: (index) => changedIndex = index,
        ),
      ),
    );

    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 1);
    expect(changedIndex, 1);
    expect(find.text('Body 2'), findsOneWidget);

    controller.select(0);
    await tester.pumpAndSettle();
    expect(find.text('Body 1'), findsOneWidget);

    controller.dispose();
  });

  test('add and insert select new tabs by default', () {
    final a = Tab(text: const Text('A'), body: const Text('Body A'));
    final b = Tab(text: const Text('B'), body: const Text('Body B'));
    final c = Tab(text: const Text('C'), body: const Text('Body C'));
    final controller = TabViewController(tabs: [a]);
    addTearDown(controller.dispose);

    controller.add(b);
    expect(controller.selectedTab, same(b));

    controller.insert(0, c);
    expect(controller.selectedIndex, 0);
    expect(controller.selectedTab, same(c));

    controller.select(2);
    controller.insert(
      0,
      Tab(text: const Text('Preserved'), body: const Text('Body Preserved')),
      select: false,
    );
    expect(controller.selectedTab, same(b));
  });

  testWidgets('updates and replaces an external scroll controller', (
    tester,
  ) async {
    final controller = TabViewController(
      tabs: [
        Tab(text: const Text('A'), body: const Text('Body A')),
        Tab(text: const Text('B'), body: const Text('Body B')),
      ],
    );
    final firstScrollController = ScrollPosController();
    final secondScrollController = ScrollPosController();
    addTearDown(controller.dispose);
    addTearDown(firstScrollController.dispose);
    addTearDown(secondScrollController.dispose);

    Widget build(ScrollPosController scrollController) {
      return wrapApp(
        child: SizedBox(
          height: 100,
          width: 300,
          child: TabView(
            controller: controller,
            scrollController: scrollController,
          ),
        ),
      );
    }

    await tester.pumpWidget(build(firstScrollController));
    expect(firstScrollController.itemCount, 2);

    controller.add(Tab(text: const Text('C'), body: const Text('Body C')));
    await tester.pump();
    expect(firstScrollController.itemCount, 3);

    await tester.pumpWidget(build(secondScrollController));
    expect(secondScrollController.itemCount, 3);
    expect(secondScrollController.hasClients, isTrue);
    expect(firstScrollController.hasClients, isFalse);
  });
}
