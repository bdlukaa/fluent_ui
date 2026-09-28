import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('default padding surrounds header, content, and footer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 600,
          child: ScaffoldPage(
            header: SizedBox(key: Key('header'), height: 40),
            content: SizedBox(key: Key('content')),
            footer: SizedBox(key: Key('footer'), height: 40),
          ),
        ),
      ),
    );

    final header = tester.getRect(find.byKey(const Key('header')));
    final content = tester.getRect(find.byKey(const Key('content')));
    final footer = tester.getRect(find.byKey(const Key('footer')));

    expect(header, const Rect.fromLTWH(24, 24, 752, 40));
    expect(content.left, 24);
    expect(content.right, 776);
    expect(footer, const Rect.fromLTWH(24, 536, 752, 40));
  });

  testWidgets('explicit padding applies every side exactly once', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 600,
          child: ScaffoldPage(
            padding: EdgeInsets.fromLTRB(7, 11, 13, 17),
            header: SizedBox(key: Key('header'), height: 40),
            content: SizedBox(key: Key('content')),
            footer: SizedBox(key: Key('footer'), height: 40),
          ),
        ),
      ),
    );

    expect(
      tester.getRect(find.byKey(const Key('header'))),
      const Rect.fromLTWH(7, 11, 780, 40),
    );
    expect(
      tester.getRect(find.byKey(const Key('footer'))),
      const Rect.fromLTWH(7, 543, 780, 40),
    );
  });

  testWidgets('default horizontal padding adapts to the page width', (
    tester,
  ) async {
    Future<Offset> contentOffset(double width) async {
      await tester.pumpWidget(
        wrapApp(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 200,
              child: const ScaffoldPage(content: SizedBox(key: Key('content'))),
            ),
          ),
        ),
      );
      return tester.getTopLeft(find.byKey(const Key('content')));
    }

    expect(await contentOffset(640), const Offset(12, 24));
    expect(await contentOffset(641), const Offset(24, 24));
  });

  testWidgets('directional padding follows RTL', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 800,
            height: 200,
            child: ScaffoldPage(
              padding: EdgeInsetsDirectional.only(start: 7, end: 13),
              content: SizedBox(key: Key('content')),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const Key('content'))),
      const Offset(13, 0),
    );
    expect(tester.getSize(find.byKey(const Key('content'))).width, 780);
  });

  testWidgets('scrollable uses the same page geometry as regular content', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: SizedBox(
          width: 800,
          height: 600,
          child: ScaffoldPage.scrollable(
            header: const SizedBox(key: Key('header'), height: 40),
            footer: const SizedBox(key: Key('footer'), height: 40),
            children: const [SizedBox(height: 1000)],
          ),
        ),
      ),
    );

    final list = tester.getRect(find.byType(ListView));
    expect(list, const Rect.fromLTWH(24, 64, 752, 472));
    expect(
      tester.getRect(find.byKey(const Key('footer'))),
      const Rect.fromLTWH(24, 536, 752, 40),
    );
  });

  testWidgets('viewInsets resize the page only when enabled', (tester) async {
    Future<double> contentHeight(bool resize) async {
      await tester.pumpWidget(
        wrapApp(
          child: MediaQuery(
            data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 80)),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                height: 300,
                child: ScaffoldPage(
                  padding: EdgeInsets.zero,
                  resizeToAvoidBottomInset: resize,
                  content: const SizedBox(key: Key('content')),
                ),
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byKey(const Key('content'))).height;
    }

    expect(await contentHeight(true), 220);
    expect(await contentHeight(false), 300);
  });

  testWidgets('page remains transparent inside NavigationView', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 800,
          height: 600,
          child: NavigationView(content: ScaffoldPage()),
        ),
      ),
    );

    final micaSurfaces = tester.widgetList<Mica>(find.byType(Mica));
    expect(
      micaSurfaces.any(
        (surface) => surface.backgroundColor == Colors.transparent,
      ),
      isTrue,
    );
  });

  testWidgets('header remains usable at large text scales', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              height: 240,
              child: ScaffoldPage(
                header: PageHeader(
                  title: Text('A long page title'),
                  commandBar: SizedBox(width: 40, height: 40),
                ),
                content: SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('footer is kept outside the scrollable body', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: SizedBox(
          width: 400,
          height: 300,
          child: ScaffoldPage.scrollable(
            footer: const SizedBox(key: Key('footer'), height: 48),
            children: const [SizedBox(height: 1000)],
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byKey(const Key('footer')),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('footer')), findsOneWidget);
  });
}
