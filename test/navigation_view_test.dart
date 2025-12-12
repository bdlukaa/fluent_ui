import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationView', () {
    testWidgets('NavigationAppBar takes viewPadding into consideration', (
      tester,
    ) async {
      final navigationViewKey = GlobalKey();
      await tester.pumpWidget(
        FluentApp(
          builder: (context, child) {
            return MediaQuery(
              data: const MediaQueryData(padding: EdgeInsets.only(top: 27)),
              child: child!,
            );
          },
          home: NavigationView(key: navigationViewKey, pane: NavigationPane()),
        ),
      );

      const appBar = NavigationAppBar();
      expect(
        appBar.finalHeight(navigationViewKey.currentContext!),
        // _kDefaultAppBarHeight
        50 + 27,
      );
    });

    testWidgets('NavigationView renders with basic pane items', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        FluentApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 1200,
                height: 800,
                child: NavigationView(
                  pane: NavigationPane(
                    selected: selectedIndex,
                    onChanged: (index) => setState(() => selectedIndex = index),
                    displayMode: PaneDisplayMode.open,
                    items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.home),
                        title: const Text('Home'),
                        body: const Center(child: Text('Home Page')),
                      ),
                      PaneItem(
                        icon: const Icon(FluentIcons.settings),
                        title: const Text('Settings'),
                        body: const Center(child: Text('Settings Page')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the navigation view renders
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('NavigationView handles PaneItemExpander', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        FluentApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 1200,
                height: 800,
                child: NavigationView(
                  pane: NavigationPane(
                    selected: selectedIndex,
                    onChanged: (index) => setState(() => selectedIndex = index),
                    displayMode: PaneDisplayMode.open,
                    items: [
                      PaneItemExpander(
                        icon: const Icon(FluentIcons.folder),
                        title: const Text('Files'),
                        body: const Center(child: Text('Files Page')),
                        initiallyExpanded: true,
                        items: [
                          PaneItem(
                            icon: const Icon(FluentIcons.document),
                            title: const Text('Documents'),
                            body: const Center(child: Text('Documents Page')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the navigation view renders with expander
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('NavigationAppBar layoutBuilder works', (tester) async {
      bool layoutBuilderCalled = false;

      await tester.pumpWidget(
        FluentApp(
          home: NavigationView(
            appBar: NavigationAppBar(
              title: const Text('Custom Layout'),
              layoutBuilder: (context, data) {
                layoutBuilderCalled = true;
                return Row(
                  children: [
                    data.leading,
                    Expanded(child: Center(child: data.title)),
                    if (data.actions != null) data.actions!,
                  ],
                );
              },
            ),
            content: const Center(child: Text('Content')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(layoutBuilderCalled, isTrue);
      expect(find.text('Custom Layout'), findsOneWidget);
    });

    testWidgets('StickyNavigationIndicator renders correctly', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.open,
                indicator: const StickyNavigationIndicator(),
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const Center(child: Text('Home')),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const Center(child: Text('Settings')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the navigation view renders without errors
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('EndNavigationIndicator renders correctly', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.open,
                indicator: const EndNavigationIndicator(),
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const Center(child: Text('Home')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('NavigationView display modes work', (tester) async {
      for (final mode in [
        PaneDisplayMode.open,
        PaneDisplayMode.compact,
        PaneDisplayMode.minimal,
        PaneDisplayMode.top,
      ]) {
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 1200,
              height: 800,
              child: NavigationView(
                pane: NavigationPane(
                  selected: 0,
                  displayMode: mode,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(NavigationView), findsOneWidget);
      }
    });
  });
}
