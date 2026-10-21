import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

const _tabViewKey = ValueKey<String>('tab-view');

void main() {
  testWidgets('TabView normal tab strip', (tester) async {
    await tester.pumpWidget(_tabView(width: 600));

    await expectLater(
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/normal.png'),
    );
  });

  testWidgets('TabView actively dragged tab strip', (tester) async {
    await tester.pumpWidget(_tabView(width: 600));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('A')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/dragging.png'),
    );

    await gesture.up();
  });

  testWidgets('TabView scrollable tab strip', (tester) async {
    await tester.pumpWidget(_tabView(width: 240, tabCount: 8));

    await expectLater(
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/scrollable.png'),
    );
  });
}

Widget _tabView({required double width, int tabCount = 3}) {
  final tabs = List.generate(
    tabCount,
    (index) => Tab(
      text: Text(String.fromCharCode(65 + index)),
      body: const SizedBox(),
    ),
  );
  return MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.noScaling),
    child: FluentApp(
      theme: FluentThemeData.light(),
      home: Center(
        child: RepaintBoundary(
          key: _tabViewKey,
          child: SizedBox(
            width: width,
            height: 80,
            child: TabView(
              currentIndex: 0,
              tabs: tabs,
              onReorder: (oldIndex, newIndex) {},
            ),
          ),
        ),
      ),
    ),
  );
}
