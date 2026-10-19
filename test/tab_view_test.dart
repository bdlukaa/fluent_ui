import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('TabView renders tabs and bodies', (tester) async {
    final tabs = [
      Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
      Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
    ];
    await tester.pumpWidget(
      wrapApp(child: TabView(currentIndex: 0, tabs: tabs)),
    );
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Body 1'), findsOneWidget);
    expect(find.text('Body 2'), findsNothing);
  });

  testWidgets('TabView switches tabs on tap', (tester) async {
    int? selectedIndex;
    final tabs = [
      Tab(text: const Text('Tab 1'), body: const Text('Body 1')),
      Tab(text: const Text('Tab 2'), body: const Text('Body 2')),
    ];
    await tester.pumpWidget(
      wrapApp(
        child: StatefulBuilder(
          builder: (context, setState) => TabView(
            currentIndex: selectedIndex ?? 0,
            tabs: tabs,
            onChanged: (i) => setState(() {
              selectedIndex = i;
            }),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
    expect(find.text('Body 2'), findsOneWidget);
  });

  testWidgets('TabView calls onNewPressed when add button is tapped', (
    tester,
  ) async {
    var pressed = false;
    final tabs = [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))];
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          newTabIcon: const Icon(FluentIcons.add),
          currentIndex: 0,
          tabs: tabs,
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
    final tabs = [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))];
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          currentIndex: 0,
          tabs: tabs,
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
    await tester.pumpWidget(
      wrapApp(child: TabView(currentIndex: 0, tabs: tabs)),
    );
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
    final tabs = [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))];
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          currentIndex: 0,
          tabs: tabs,
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
    final tabs = [Tab(text: const Text('Tab 1'), body: const Text('Body 1'))];
    await tester.pumpWidget(
      wrapApp(
        child: TabView(
          currentIndex: 0,
          tabs: tabs,
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
}

/// Drives a two-tab [TabView] whose bodies hold state (a counter) that no
/// widget config carries, plus buttons to bump B's counter and to move B in
/// front of A. Used to prove the body element follows its tab across reorders.
class _ReorderHarness extends StatefulWidget {
  const _ReorderHarness();

  @override
  State<_ReorderHarness> createState() => _ReorderHarnessState();
}

class _ReorderHarnessState extends State<_ReorderHarness> {
  late final List<Tab> tabs = [
    Tab(text: const Text('A'), body: const _CounterBody('A')),
    Tab(text: const Text('B'), body: const _CounterBody('B')),
  ];
  int currentIndex = 1; // start on B so its body is mounted

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Button(
              onPressed: () => setState(() {
                final b = tabs.removeAt(1);
                tabs.insert(0, b);
                currentIndex = 0;
              }),
              child: const Text('reorder'),
            ),
          ],
        ),
        Expanded(
          child: TabView(
            currentIndex: currentIndex,
            tabs: tabs,
            onChanged: (i) => setState(() => currentIndex = i),
          ),
        ),
      ],
    );
  }
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
  late final List<Tab> tabs = List.generate(widget.tabCount, _createTab);
  final List<(int, int)> reorders = [];
  final List<String> closed = [];
  int currentIndex = 0;

  List<String> get tabNames =>
      tabs.map((tab) => (tab.text as Text).data!).toList();

  Tab _createTab(int index) {
    final name = String.fromCharCode(65 + index);
    return Tab(
      text: Text(name),
      body: Text('Body $name'),
      closeIcon: const Icon(FluentIcons.cancel),
      onClosed: () => setState(() {
        closed.add(name);
        tabs.removeWhere((tab) => (tab.text as Text).data == name);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 160,
      child: TabView(
        currentIndex: currentIndex,
        tabs: tabs,
        scrollController: widget.controller,
        onChanged: (index) => setState(() => currentIndex = index),
        onReorder: (oldIndex, newIndex) => setState(() {
          reorders.add((oldIndex, newIndex));
          final tab = tabs.removeAt(oldIndex);
          tabs.insert(newIndex, tab);
          currentIndex = tabs.indexOf(tab);
        }),
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
