import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TabView renders tabs and bodies', (tester) async {
    final controller = TabViewController(
      initialTabs: [
        Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
        Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
      ],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Body 1'), findsOneWidget);
    expect(find.text('Body 2'), findsNothing);
  });

  testWidgets('TabView switches tabs on tap', (tester) async {
    int? selectedIndex;
    final controller = TabViewController(
      initialTabs: [
        Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
        Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
      ],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          onChanged: (index) => selectedIndex = index,
        ),
      ),
    );
    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
    expect(find.text('Body 2'), findsOneWidget);
  });

  testWidgets(
    'TabViewController synchronizes user and programmatic selection',
    (tester) async {
      var changedIndex = -1;
      final controller = TabViewController(
        initialTabs: [
          Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
          Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
        ],
      );
      addTearDown(controller.dispose);

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
    },
  );

  test('TabViewController manages tabs and preserves selected identity', () {
    final a = _controllerTab('A');
    final b = _controllerTab('B');
    final c = _controllerTab('C');
    final inserted = _controllerTab('Inserted');
    final controller = TabViewController(initialTabs: [a, b], initialIndex: 1);
    addTearDown(controller.dispose);

    expect(controller.tabs, [a, b]);
    expect(controller.selectedIndex, 1);
    expect(controller.tabs[controller.selectedIndex], same(b));

    controller.add(c, select: false);
    controller.insert(0, inserted, select: false);
    expect(controller.tabs, [inserted, a, b, c]);
    expect(controller.selectedIndex, 2);
    expect(controller.tabs[controller.selectedIndex], same(b));

    controller.move(2, 0);
    expect(controller.tabs, [b, inserted, a, c]);
    expect(controller.selectedIndex, 0);
    expect(controller.tabs[controller.selectedIndex], same(b));

    controller.removeAt(1);
    expect(controller.tabs, [b, a, c]);
    expect(controller.tabs[controller.selectedIndex], same(b));

    controller.replaceTabs([c, b]);
    expect(controller.tabs, [c, b]);
    expect(controller.selectedIndex, 1);
    expect(controller.tabs[controller.selectedIndex], same(b));
  });

  test('TabViewController selects and notifies only for state changes', () {
    final a = _controllerTab('A');
    final b = _controllerTab('B');
    final controller = TabViewController(initialTabs: [a, b]);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.select(0);
    expect(notifications, 0);

    controller.select(1);
    expect(controller.selectedIndex, 1);
    expect(controller.tabs[controller.selectedIndex], same(b));
    expect(notifications, 1);

    controller.add(_controllerTab('C'));
    controller.insert(0, _controllerTab('Inserted'));
    controller.removeAt(0);
    controller.move(1, 0);
    controller.replaceTabs([a, b]);
    expect(notifications, 6);
  });

  test('TabViewController handles an empty collection', () {
    final controller = TabViewController();
    addTearDown(controller.dispose);

    expect(controller.tabs, isEmpty);
    expect(controller.selectedIndex, 0);

    final tab = _controllerTab('First');
    controller.add(tab);
    expect(controller.tabs, [tab]);
    expect(controller.selectedIndex, 0);
    controller.removeAt(0);
    expect(controller.tabs, isEmpty);
    expect(controller.selectedIndex, 0);

    controller.replaceTabs(const []);
    expect(controller.tabs, isEmpty);
    expect(controller.selectedIndex, 0);
  });

  testWidgets('TabView renders tabs owned by its controller', (tester) async {
    final controller = TabViewController(
      initialTabs: [_controllerTab('A'), _controllerTab('B')],
      initialIndex: 1,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));
    expect(find.text('Body B'), findsOneWidget);

    controller.insert(0, _controllerTab('Inserted'), select: false);
    await tester.pumpAndSettle();
    expect(find.text('Inserted'), findsOneWidget);
    expect(find.text('Body B'), findsOneWidget);

    controller.select(0);
    await tester.pumpAndSettle();
    expect(find.text('Body Inserted'), findsOneWidget);
  });

  testWidgets(
    'TabView swaps externally owned controllers without disposing them',
    (tester) async {
      final first = TabViewController(initialTabs: [_controllerTab('First')]);
      final second = TabViewController(
        initialTabs: [_controllerTab('Second A'), _controllerTab('Second B')],
        initialIndex: 1,
      );
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await tester.pumpWidget(wrapApp(child: TabView(controller: first)));
      expect(find.text('Body First'), findsOneWidget);

      await tester.pumpWidget(wrapApp(child: TabView(controller: second)));
      expect(find.text('Body Second B'), findsOneWidget);

      first.add(_controllerTab('First added'));
      second.select(0);
      await tester.pumpAndSettle();

      expect(find.text('Body Second A'), findsOneWidget);
      expect(find.text('First added'), findsNothing);
    },
  );

  testWidgets('TabView calls onNewPressed when add button is tapped', (
    tester,
  ) async {
    var pressed = false;
    final controller = TabViewController(
      initialTabs: [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          newTabIcon: const Icon(FluentIcons.add),
          onNewPressed: () {
            pressed = true;
          },
        ),
      ),
    );
    await tester.tap(find.byIcon(FluentIcons.add));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('TabView shows header and footer', (tester) async {
    final controller = TabViewController(
      initialTabs: [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          header: const Text('Header'),
          footer: const Text('Footer'),
        ),
      ),
    );
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
  });

  testWidgets('TabView calls onClosed when close button is tapped', (
    tester,
  ) async {
    var closed = false;
    final tabs = [
      Tab(
        text: const Text('Tab 1'),
        body: const Text('Body 1'),
        onClosed: () {
          closed = true;
        },
        closeIcon: const Icon(FluentIcons.cancel),
      ),
    ];
    final controller = TabViewController(initialTabs: tabs);
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));
    // Find the close button (IconButton with tooltip 'Close')
    final closeButton = find.byIcon(FluentIcons.cancel);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('TabView disables shortcuts when shortcutsEnabled is false', (
    tester,
  ) async {
    var pressed = false;
    final controller = TabViewController(
      initialTabs: [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          onNewPressed: () => pressed = true,
          shortcutsEnabled: false,
        ),
      ),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
    expect(pressed, isFalse);
  });

  testWidgets('TabView keeps each body glued to its tab across a reorder', (
    tester,
  ) async {
    // PageView parks non-visible pages offstage, so search offstage too.
    Finder body(String text) => find.text(text, skipOffstage: false);

    await tester.pumpWidget(wrapApp(child: const _ReorderHarness()));
    await tester.pumpAndSettle();
    expect(body('B:0'), findsOneWidget);

    // Give tab "B" some state the plain widget config can't carry.
    await tester.tap(find.widgetWithText(Button, 'inc B'));
    await tester.pumpAndSettle();
    expect(body('B:1'), findsOneWidget);

    // Move B in front of A and keep it selected.
    await tester.tap(find.widgetWithText(Button, 'reorder'));
    await tester.pumpAndSettle();

    // The reorder changed only the tab order — B's state must ride along, not
    // stay parked at the slot it used to occupy.
    expect(body('B:1'), findsOneWidget);
    expect(body('B:0'), findsNothing);
  });

  testWidgets(
    'TabView preserves a reused body when a tab is inserted ahead of it',
    (tester) async {
      Finder body(String text) => find.text(text, skipOffstage: false);

      await tester.pumpWidget(wrapApp(child: const _ReorderHarness()));
      await tester.tap(find.widgetWithText(Button, 'inc B'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Button, 'insert'));
      await tester.pumpAndSettle();

      expect(body('B:1'), findsOneWidget);
      expect(body('A:1'), findsNothing);
    },
  );

  testWidgets(
    'TabView preserves bodies when tabs are rebuilt as new instances',
    (tester) async {
      Finder body(String text) => find.text(text, skipOffstage: false);

      await tester.pumpWidget(wrapApp(child: const _RebuiltTabsHarness()));
      await tester.tap(find.widgetWithText(Button, 'inc A'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Button, 'rebuild'));
      await tester.pumpAndSettle();

      expect(body('A:1'), findsOneWidget);
    },
  );

  testWidgets(
    'TabView does not recreate the body it switches away from when tabs are '
    'rebuilt as new instances',
    (tester) async {
      final initializedBodies = <String>[];
      await tester.pumpWidget(
        wrapApp(
          child: _RebuiltTabsHarness(
            buildBody: (name) => _LifecycleBody(name, initializedBodies),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(initializedBodies, ['A', 'B']);
    },
  );

  testWidgets(
    'TabView keeps keyed rebuilt bodies with their tabs after reordering',
    (tester) async {
      Finder body(String text) => find.text(text, skipOffstage: false);

      await tester.pumpWidget(
        wrapApp(child: const _RebuiltTabsHarness(keyed: true)),
      );
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Button, 'inc B'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Button, 'reorder'));
      await tester.pumpAndSettle();

      expect(body('B:1'), findsOneWidget);
      expect(body('B:0'), findsNothing);
    },
  );

  testWidgets('TabView reorders tabs in both directions with a mouse drag', (
    tester,
  ) async {
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(wrapApp(child: _DragReorderHarness(key: key)));

    await _dragTab(tester, 'A', 'C');
    expect(key.currentState!.reorders, [(0, 1)]);
    expect(key.currentState!.tabNames, ['B', 'A', 'C']);

    final reverseKey = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(
      wrapApp(child: _DragReorderHarness(key: reverseKey)),
    );
    await _dragTab(tester, 'C', 'A');
    expect(reverseKey.currentState!.reorders, [(2, 1)]);
    expect(reverseKey.currentState!.tabNames, ['A', 'C', 'B']);
  });

  testWidgets('TabView reorders correctly in RTL', (tester) async {
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(
      wrapApp(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: _DragReorderHarness(key: key),
        ),
      ),
    );

    await _dragTab(tester, 'A', 'C');
    expect(key.currentState!.reorders, [(0, 1)]);
    expect(key.currentState!.tabNames, ['B', 'A', 'C']);
  });

  testWidgets('TabView scrolls and reorders with a supplied controller', (
    tester,
  ) async {
    final controller = ScrollPosController(itemCount: 8);
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(
      wrapApp(
        child: _DragReorderHarness(
          key: key,
          controller: controller,
          tabCount: 8,
          width: 240,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.hasClients, isTrue);

    await _dragTab(tester, 'A', 'C');
    expect(key.currentState!.reorders, [(0, 1)]);
  });

  testWidgets('TabView retains selection and close actions after reordering', (
    tester,
  ) async {
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(wrapApp(child: _DragReorderHarness(key: key)));

    await _dragTab(tester, 'A', 'C');
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentIndex, 2);

    await tester.tap(find.byIcon(FluentIcons.cancel).at(2));
    await tester.pumpAndSettle();
    expect(key.currentState!.closed, ['C']);
  });

  testWidgets('TabView reordering does not require Material localizations', (
    tester,
  ) async {
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(
      _fluentOnlyApp(child: _DragReorderHarness(key: key)),
    );

    await _dragTab(tester, 'A', 'C');
    expect(key.currentState!.reorders, [(0, 1)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TabView stays within a narrow layout while reordering', (
    tester,
  ) async {
    final key = GlobalKey<_DragReorderHarnessState>();
    await tester.pumpWidget(
      wrapApp(child: _DragReorderHarness(key: key, width: 120)),
    );

    expect(find.byType(ReorderableList), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TabView supports custom stripBuilder', (tester) async {
    final controller = TabViewController(
      initialTabs: [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))],
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          controller: controller,
          stripBuilder: (context, strip) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Custom Strip'),
              Expanded(child: strip),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Custom Strip'), findsOneWidget);
  });

  testWidgets('TabViewController updates selection and notifies callbacks', (
    tester,
  ) async {
    var changedIndex = -1;
    final tabs = [
      Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
      Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
    ];
    final controller = TabViewController(initialTabs: tabs);
    addTearDown(controller.dispose);

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
  });

  test('add and insert select new tabs by default', () {
    final a = Tab(text: const Text('A'), body: const Text('Body A'));
    final b = Tab(text: const Text('B'), body: const Text('Body B'));
    final c = Tab(text: const Text('C'), body: const Text('Body C'));
    final controller = TabViewController(initialTabs: [a]);
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
      initialTabs: [
        Tab(text: const Text('A'), body: const Text('Body A')),
        Tab(text: const Text('B'), body: const Text('Body B')),
      ],
    );
    final firstScrollController = ScrollPosController();
    final secondScrollController = ScrollPosController();
    addTearDown(controller.dispose);
    addTearDown(firstScrollController.dispose);
    addTearDown(secondScrollController.dispose);

    Widget build(ScrollPosController scrollController) => wrapApp(
      child: SizedBox(
        height: 100,
        width: 300,
        child: TabView(
          controller: controller,
          scrollController: scrollController,
        ),
      ),
    );

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

  testWidgets('TabView honors programmatic selection before attachment', (
    tester,
  ) async {
    final controller = TabViewController(
      initialIndex: 1,
      initialTabs: [
        Tab(text: const Text('A'), body: const Text('Body A')),
        Tab(text: const Text('B'), body: const Text('Body B')),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));

    expect(find.text('Body A'), findsNothing);
    expect(find.text('Body B'), findsOneWidget);
  });

  testWidgets('TabView renders an empty tab list without a body', (
    tester,
  ) async {
    final controller = TabViewController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));

    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TabView gives explicit tab keys distinct pages', (tester) async {
    var rebuild = false;
    List<Tab> tabs() => [
      Tab(
        key: const ValueKey('A'),
        text: const Text('A'),
        body: _IdentityCounterBody('A-$rebuild'),
      ),
      Tab(
        key: const ValueKey('B'),
        text: const Text('B'),
        body: _IdentityCounterBody('B-$rebuild'),
      ),
    ];
    final controller = TabViewController(initialTabs: tabs());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Button(
                onPressed: () => setState(() {
                  rebuild = true;
                  controller.replaceTabs(tabs());
                }),
                child: const Text('rebuild'),
              ),
              Expanded(child: TabView(controller: controller)),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(Button, 'increment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Button, 'rebuild'));
    await tester.pumpAndSettle();

    expect(find.text('A-true:1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TabView keeps lazy tab bodies alive by default', (tester) async {
    final controller = TabViewController(
      initialTabs: [
        Tab(text: const Text('A'), body: const _KeepAliveTestCounterBody('A')),
        Tab(text: const Text('B'), body: const _KeepAliveTestCounterBody('B')),
        Tab(text: const Text('C'), body: const _KeepAliveTestCounterBody('C')),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(wrapApp(child: TabView(controller: controller)));

    await tester.tap(find.widgetWithText(Button, 'increment A'));
    await tester.pump();
    expect(find.text('A:1'), findsOneWidget);

    controller.select(2);
    await tester.pumpAndSettle();
    expect(find.text('C:0'), findsOneWidget);

    controller.select(0);
    await tester.pumpAndSettle();

    expect(find.text('A:1'), findsOneWidget);
  });

  testWidgets('TabView disposes plain lazy tab bodies when keep alive is off', (
    tester,
  ) async {
    final controller = TabViewController(
      initialTabs: [
        Tab(text: const Text('A'), body: const _KeepAliveTestCounterBody('A')),
        Tab(text: const Text('B'), body: const _KeepAliveTestCounterBody('B')),
        Tab(text: const Text('C'), body: const _KeepAliveTestCounterBody('C')),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapApp(
        child: TabView(controller: controller, automaticallyKeepAlive: false),
      ),
    );

    await tester.tap(find.widgetWithText(Button, 'increment A'));
    await tester.pump();
    expect(find.text('A:1'), findsOneWidget);

    controller.select(2);
    await tester.pumpAndSettle();
    controller.select(0);
    await tester.pumpAndSettle();

    expect(find.text('A:0'), findsOneWidget);
  });

  testWidgets(
    'TabView keeps opt-in lazy tab bodies alive when keep alive is off',
    (tester) async {
      final controller = TabViewController(
        initialTabs: [
          Tab(
            text: const Text('A'),
            body: const _OptInKeepAliveTestCounterBody('A'),
          ),
          Tab(
            text: const Text('B'),
            body: const _OptInKeepAliveTestCounterBody('B'),
          ),
          Tab(
            text: const Text('C'),
            body: const _OptInKeepAliveTestCounterBody('C'),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapApp(
          child: TabView(controller: controller, automaticallyKeepAlive: false),
        ),
      );

      await tester.tap(find.widgetWithText(Button, 'increment A'));
      await tester.pump();
      expect(find.text('A:1'), findsOneWidget);

      controller.select(2);
      await tester.pumpAndSettle();
      controller.select(0);
      await tester.pumpAndSettle();

      expect(find.text('A:1'), findsOneWidget);
    },
  );

  testWidgets('TabView applies keep-alive changes after rebuilding', (
    tester,
  ) async {
    final controller = TabViewController(
      initialTabs: [
        Tab(text: const Text('A'), body: const _KeepAliveTestCounterBody('A')),
        Tab(text: const Text('B'), body: const _KeepAliveTestCounterBody('B')),
        Tab(text: const Text('C'), body: const _KeepAliveTestCounterBody('C')),
      ],
    );
    addTearDown(controller.dispose);
    final keepAlive = ValueNotifier(true);
    addTearDown(keepAlive.dispose);

    await tester.pumpWidget(
      wrapApp(
        child: ValueListenableBuilder<bool>(
          valueListenable: keepAlive,
          builder: (context, value, child) =>
              TabView(controller: controller, automaticallyKeepAlive: value),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(Button, 'increment A'));
    await tester.pump();
    controller.select(2);
    await tester.pumpAndSettle();

    keepAlive.value = false;
    await tester.pumpAndSettle();
    controller.select(0);
    await tester.pumpAndSettle();

    expect(find.text('A:0'), findsOneWidget);
  });

  testWidgets('TabView normal tab strip', (tester) async {
    _configureTabViewGoldenEnvironment(tester);
    await tester.pumpWidget(_goldenTabView(width: 600));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_goldenTabViewKey),
      matchesGoldenFile('goldens/tab_view/normal.png'),
    );
  }, tags: 'golden');

  testWidgets('TabView actively dragged tab strip', (tester) async {
    _configureTabViewGoldenEnvironment(tester);
    await tester.pumpWidget(_goldenTabView(width: 600));
    await tester.pumpAndSettle();

    final initialTabPosition = tester.getCenter(find.text('A'));
    final gesture = await tester.startGesture(
      initialTabPosition,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester.getCenter(find.text('A')).dx,
      greaterThan(initialTabPosition.dx),
    );

    await expectLater(
      find.byKey(_goldenTabViewKey),
      matchesGoldenFile('goldens/tab_view/dragging.png'),
    );

    await gesture.up();
  }, tags: 'golden');

  testWidgets('TabView scrollable tab strip', (tester) async {
    _configureTabViewGoldenEnvironment(tester);
    await tester.pumpWidget(_goldenTabView(width: 240, tabCount: 8));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_goldenTabViewKey),
      matchesGoldenFile('goldens/tab_view/scrollable.png'),
    );
  }, tags: 'golden');
}

Tab _controllerTab(String name) {
  return Tab(text: Text(name), body: Text('Body $name'));
}

/// Drives a two-tab [TabView] whose bodies hold state (a counter) that no
/// widget config carries, plus buttons to bump B's counter, to move B in
/// front of A, and to insert a new tab X in front of both. Used to prove the
/// body element follows its tab across reorders and insertions.
class _ReorderHarness extends StatefulWidget {
  const _ReorderHarness();

  @override
  State<_ReorderHarness> createState() => _ReorderHarnessState();
}

class _ReorderHarnessState extends State<_ReorderHarness> {
  late final controller = TabViewController(
    initialIndex: 1,
    initialTabs: [
      Tab(text: const Text('A'), body: const _CounterBody('A')),
      Tab(text: const Text('B'), body: const _CounterBody('B')),
    ],
  );

  int get currentIndex => controller.selectedIndex;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Button(
              onPressed: () => controller.move(1, 0),
              child: const Text('reorder'),
            ),
            Button(
              onPressed: () => controller.insert(
                0,
                Tab(text: const Text('X'), body: const _CounterBody('X')),
                select: false,
              ),
              child: const Text('insert'),
            ),
          ],
        ),
        Expanded(child: TabView(controller: controller)),
      ],
    );
  }
}

/// Drives a two-tab [TabView] that creates new [Tab] instances on every build,
/// as most apps do, plus buttons to rebuild and to move the last tab in front
/// of the first.
class _RebuiltTabsHarness extends StatefulWidget {
  const _RebuiltTabsHarness({
    this.keyed = false,
    this.buildBody = _CounterBody.new,
  });

  /// Whether each [Tab] is given a key derived from its name.
  final bool keyed;

  final Widget Function(String name) buildBody;

  @override
  State<_RebuiltTabsHarness> createState() => _RebuiltTabsHarnessState();
}

class _RebuiltTabsHarnessState extends State<_RebuiltTabsHarness> {
  final names = ['A', 'B'];
  late final TabViewController controller;

  @override
  void initState() {
    super.initState();
    controller = TabViewController(initialTabs: _tabs());
  }

  List<Tab> _tabs() => [
    for (final name in names)
      Tab(
        key: widget.keyed ? ValueKey(name) : null,
        text: Text(name),
        body: widget.buildBody(name),
      ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Button(
              onPressed: () => controller.replaceTabs(_tabs()),
              child: const Text('rebuild'),
            ),
            Button(
              onPressed: () {
                names.insert(0, names.removeLast());
                controller.replaceTabs(_tabs());
              },
              child: const Text('reorder'),
            ),
          ],
        ),
        Expanded(child: TabView(controller: controller)),
      ],
    );
  }
}

/// A body that records its name each time its [State] is created.
class _LifecycleBody extends StatefulWidget {
  const _LifecycleBody(this.name, this.initializedBodies);

  final String name;
  final List<String> initializedBodies;

  @override
  State<_LifecycleBody> createState() => _LifecycleBodyState();
}

class _LifecycleBodyState extends State<_LifecycleBody> {
  @override
  void initState() {
    super.initState();
    widget.initializedBodies.add(widget.name);
  }

  @override
  Widget build(BuildContext context) => Text('Body ${widget.name}');
}

/// A body whose displayed count lives only in [State] — reused-by-position
/// reconciliation would strand it while the tab header moves.
Future<void> _dragTab(WidgetTester tester, String source, String target) async {
  final sourceCenter = tester.getCenter(find.text(source));
  final targetCenter = tester.getCenter(find.text(target));
  final gesture = await tester.startGesture(
    sourceCenter,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump();
  await gesture.moveTo(targetCenter + (targetCenter - sourceCenter) * 0.25);
  await tester.pump(const Duration(seconds: 1));
  await gesture.up();
  await tester.pumpAndSettle();
}

Widget _fluentOnlyApp({required Widget child}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Localizations(
      locale: const Locale('en'),
      delegates: const [
        FluentLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      child: MediaQuery(
        data: const MediaQueryData(),
        child: FluentTheme(
          data: FluentThemeData.light(),
          child: Overlay(
            initialEntries: [OverlayEntry(builder: (context) => child)],
          ),
        ),
      ),
    ),
  );
}

class _DragReorderHarness extends StatefulWidget {
  const _DragReorderHarness({
    this.controller,
    this.tabCount = 3,
    this.width = 600,
    super.key,
  });

  final ScrollPosController? controller;
  final int tabCount;
  final double width;

  @override
  State<_DragReorderHarness> createState() => _DragReorderHarnessState();
}

class _DragReorderHarnessState extends State<_DragReorderHarness> {
  late final TabViewController controller;
  final List<(int, int)> reorders = [];
  final List<String> closed = [];

  int get currentIndex => controller.selectedIndex;

  List<String> get tabNames =>
      controller.tabs.map((tab) => (tab.text as Text).data!).toList();

  @override
  void initState() {
    super.initState();
    controller = TabViewController(
      initialTabs: List.generate(widget.tabCount, _createTab),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Tab _createTab(int index) {
    final name = String.fromCharCode(65 + index);
    return Tab(
      text: Text(name),
      body: Text('Body $name'),
      closeIcon: const Icon(FluentIcons.cancel),
      onClosed: () {
        closed.add(name);
        controller.removeAt(
          controller.tabs.indexWhere((tab) => (tab.text as Text).data == name),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 160,
      child: TabView(
        controller: controller,
        scrollController: widget.controller,
        onReorder: (oldIndex, newIndex) {
          reorders.add((oldIndex, newIndex));
        },
      ),
    );
  }
}

class _CounterBody extends StatefulWidget {
  final String name;
  const _CounterBody(this.name);

  @override
  State<_CounterBody> createState() => _CounterBodyState();
}

class _CounterBodyState extends State<_CounterBody>
    with AutomaticKeepAliveClientMixin {
  int count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.name}:$count'),
        Button(
          onPressed: () => setState(() => count++),
          child: Text('inc ${widget.name}'),
        ),
      ],
    );
  }
}

class _IdentityCounterBody extends StatefulWidget {
  const _IdentityCounterBody(this.label);

  final String label;

  @override
  State<_IdentityCounterBody> createState() => _IdentityCounterBodyState();
}

class _IdentityCounterBodyState extends State<_IdentityCounterBody>
    with AutomaticKeepAliveClientMixin {
  var _count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.label}:$_count'),
        Button(
          onPressed: () => setState(() => _count++),
          child: const Text('increment'),
        ),
      ],
    );
  }
}

class _KeepAliveTestCounterBody extends StatefulWidget {
  const _KeepAliveTestCounterBody(this.label);

  final String label;

  @override
  State<_KeepAliveTestCounterBody> createState() =>
      _KeepAliveTestCounterBodyState();
}

class _KeepAliveTestCounterBodyState extends State<_KeepAliveTestCounterBody> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.label}:$_count'),
        Button(
          onPressed: () => setState(() => _count++),
          child: Text('increment ${widget.label}'),
        ),
      ],
    );
  }
}

class _OptInKeepAliveTestCounterBody extends StatefulWidget {
  const _OptInKeepAliveTestCounterBody(this.label);

  final String label;

  @override
  State<_OptInKeepAliveTestCounterBody> createState() =>
      _OptInKeepAliveTestCounterBodyState();
}

class _OptInKeepAliveTestCounterBodyState
    extends State<_OptInKeepAliveTestCounterBody>
    with AutomaticKeepAliveClientMixin {
  var _count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.label}:$_count'),
        Button(
          onPressed: () => setState(() => _count++),
          child: Text('increment ${widget.label}'),
        ),
      ],
    );
  }
}

const _goldenTabViewKey = ValueKey<String>('tab-view');

void _configureTabViewGoldenEnvironment(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 600)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Widget _goldenTabView({required double width, int tabCount = 3}) {
  final controller = TabViewController(
    initialTabs: List.generate(
      tabCount,
      (index) => Tab(
        text: Text(String.fromCharCode(65 + index)),
        body: const SizedBox(),
      ),
    ),
  );
  addTearDown(controller.dispose);
  return MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.noScaling),
    child: FluentApp(
      theme: FluentThemeData.light(),
      home: Center(
        child: RepaintBoundary(
          key: _goldenTabViewKey,
          child: SizedBox(
            width: width,
            height: 80,
            child: TabView(controller: controller, onReorder: (_, _) {}),
          ),
        ),
      ),
    ),
  );
}
