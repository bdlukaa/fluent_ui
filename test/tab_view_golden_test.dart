@Tags(<String>['golden'])
library;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

const _tabViewKey = ValueKey<String>('tab-view');

void main() {
  testWidgets('TabView normal tab strip', (tester) async {
    _configureGoldenEnvironment(tester);
    await tester.pumpWidget(_tabView(width: 600));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/normal.png'),
    );
  });

  testWidgets('TabView actively dragged tab strip', (tester) async {
    _configureGoldenEnvironment(tester);
    await tester.pumpWidget(_tabView(width: 600));
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
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/dragging.png'),
    );

    await gesture.up();
  });

  testWidgets('TabView scrollable tab strip', (tester) async {
    _configureGoldenEnvironment(tester);
    await tester.pumpWidget(_tabView(width: 240, tabCount: 8));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_tabViewKey),
      matchesGoldenFile('goldens/tab_view/scrollable.png'),
    );
  });
}

void _configureGoldenEnvironment(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 600)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Widget _tabView({required double width, int tabCount = 3}) {
  final controller = TabViewController(
    tabs: List.generate(
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
          key: _tabViewKey,
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
