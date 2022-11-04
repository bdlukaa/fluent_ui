import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'NavigationAppBar takes viewPadding into consideration',
    (WidgetTester tester) async {
      final navigationViewKey = GlobalKey();
      await tester.pumpWidget(FluentApp(
        builder: (context, child) {
          return MediaQuery(
            data: const MediaQueryData(
              viewPadding: EdgeInsets.only(top: 27.0),
            ),
            child: child!,
          );
        },
        home: NavigationView(
          key: navigationViewKey,
          pane: NavigationPane(),
        ),
      ));

      const appBar = NavigationAppBar();
      expect(
        appBar.finalHeight(navigationViewKey.currentContext!),
        // _kDefaultAppBarHeight
        50 + 27,
      );
    },
  );

  testWidgets(
      'Either content or PaneItems with bodies - case "content", no items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: FluentApp(
          home: NavigationView(
            content: const Text("ContentWidget"),
          ),
        ),
      ),
    );

    expect(find.text('ContentWidget'), findsOneWidget);
  });

  testWidgets(
      'Either content or PaneItems with bodies - case "content", items with no bodies',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: FluentApp(
          home: NavigationView(
            content: const Text("ContentWidget"),
            pane: NavigationPane(selected: 0, items: [
              PaneItem(
                icon: const Icon(FluentIcons.add),
                title: const Text("Item1"),
              ),
              PaneItemExpander(
                  icon: const Icon(FluentIcons.add),
                  title: const Text("Expander 1"),
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.add),
                      title: const Text("Item1-1"),
                    ),
                  ])
            ]),
          ),
        ),
      ),
    );

    expect(find.text('ContentWidget'), findsOneWidget);
    expect(find.text('Item1-1'), findsNothing);
    expect(find.text('Item1-1'), findsNothing);
  });

  testWidgets(
      'Either content or PaneItems with bodies - case "content", items with bodies',
      (WidgetTester tester) async {
    expect(
        () async => await tester.pumpWidget(
              FluentApp(
                home: FluentApp(
                  home: NavigationView(
                    content: const Text("ContentWidget"),
                    pane: NavigationPane(selected: 0, items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.add),
                        title: const Text("Item1"),
                        body: const Text("Body Item1"),
                      ),
                      PaneItemExpander(
                          icon: const Icon(FluentIcons.add),
                          title: const Text("Expander 1"),
                          body: const Text("Body Expander 1"),
                          items: [
                            PaneItem(
                              icon: const Icon(FluentIcons.add),
                              title: const Text("Item1-1"),
                              body: const Text("Body Item1-1"),
                            ),
                          ])
                    ]),
                  ),
                ),
              ),
            ),
        throwsAssertionError);
  });

  testWidgets(
      'Either content or PaneItems with bodies - case without "content", items without bodies',
      (WidgetTester tester) async {
    expect(
        () async => await tester.pumpWidget(
              FluentApp(
                home: FluentApp(
                  home: NavigationView(
                    pane: NavigationPane(selected: 0, items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.add),
                        title: const Text("Item1"),
                      ),
                      PaneItemExpander(
                          icon: const Icon(FluentIcons.add),
                          title: const Text("Expander 1"),
                          body: const Text("Body Expander 1"),
                          items: [
                            PaneItem(
                              icon: const Icon(FluentIcons.add),
                              title: const Text("Item1-1"),
                            ),
                          ])
                    ]),
                  ),
                ),
              ),
            ),
        throwsAssertionError);
  });

  testWidgets(
      'Either content or PaneItems with bodies - case without "content", items with bodies',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: FluentApp(
          home: NavigationView(
            pane: NavigationPane(selected: 0, items: [
              PaneItem(
                icon: const Icon(FluentIcons.add),
                title: const Text("Item1"),
                body: const Text("Body Item1"),
              ),
              PaneItemExpander(
                  icon: const Icon(FluentIcons.add),
                  title: const Text("Expander 1"),
                  body: const Text("Body Expander 1"),
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.add),
                      title: const Text("Item1-1"),
                      body: const Text("Body Item1-1"),
                    ),
                  ])
            ]),
          ),
        ),
      ),
    );

    expect(find.text('Body Item1'), findsOneWidget);
    expect(find.text('Body Expander 1'), findsNothing);
    expect(find.text('Body Item1-1'), findsNothing);
  });

  testWidgets(
      'Either content or PaneItems with bodies - case without "content", items with bodies, expander selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: FluentApp(
          home: NavigationView(
            pane: NavigationPane(selected: 1, items: [
              PaneItem(
                icon: const Icon(FluentIcons.add),
                title: const Text("Item1"),
                body: const Text("Body Item1"),
              ),
              PaneItemExpander(
                  icon: const Icon(FluentIcons.add),
                  title: const Text("Expander 1"),
                  body: const Text("Body Expander 1"),
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.add),
                      title: const Text("Item1-1"),
                      body: const Text("Body Item1-1"),
                    ),
                  ])
            ]),
          ),
        ),
      ),
    );

    expect(find.text('Body Item1'), findsNothing);
    expect(find.text('Body Expander 1'), findsOneWidget);
    expect(find.text('Body Item1-1'), findsNothing);
  });
}
