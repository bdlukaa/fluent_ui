import 'package:fluent_ui/fluent_ui.dart';
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
