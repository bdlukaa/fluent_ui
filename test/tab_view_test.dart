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
