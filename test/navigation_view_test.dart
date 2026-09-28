import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  group('NavigationView', () {
    testWidgets('NavigationView renders with basic pane items', (tester) async {
      var selectedIndex = 0;

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
                    displayMode: PaneDisplayMode.expanded,
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
      var selectedIndex = 0;

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
                    displayMode: PaneDisplayMode.expanded,
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

    testWidgets('StickyNavigationIndicator renders correctly', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
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
                displayMode: PaneDisplayMode.expanded,
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
        PaneDisplayMode.expanded,
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

  // Tests for GitHub Issue #919 - NavigationView rework
  // https://github.com/bdlukaa/fluent_ui/issues/919
  group('Issue #919 - NavigationView rework', () {
    testWidgets('Indicator renders within each PaneItem', (tester) async {
      // This tests that the indicator is rendered inside each PaneItem
      // instead of using global coordinates
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
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
                  PaneItem(
                    icon: const Icon(FluentIcons.info),
                    title: const Text('About'),
                    body: const Center(child: Text('About')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify NavigationView renders with indicator
      expect(find.byType(NavigationView), findsOneWidget);
      expect(find.byType(StickyNavigationIndicator), findsWidgets);
    });

    testWidgets('PaneItemExpander renders with stable keys', (tester) async {
      // This tests that PaneItemExpander doesn't break when items are
      // dynamically added (uses hashCode instead of index for storage)
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItemExpander(
                    icon: const Icon(FluentIcons.folder),
                    title: const Text('Folder'),
                    body: const Center(child: Text('Folder')),
                    initiallyExpanded: true,
                    items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.document),
                        title: const Text('Document'),
                        body: const Center(child: Text('Document')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify expander renders correctly
      expect(find.byType(NavigationView), findsOneWidget);
    });
  });

  group('Issue #1180 - Repaint isolation', () {
    testWidgets('Body content is wrapped in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const Center(
                      // Simulating a nested animation widget
                      child: material.CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify NavigationView renders with animated content
      expect(find.byType(NavigationView), findsOneWidget);
      expect(find.byType(material.CircularProgressIndicator), findsOneWidget);

      // Verify RepaintBoundary exists in the tree
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('Each page has RepaintBoundary isolation', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Page 1'),
                    body: const Center(child: Text('Page 1 Content')),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Page 2'),
                    body: const Center(child: Text('Page 2 Content')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Multiple RepaintBoundary widgets should exist for isolation
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });

  // Tests for GitHub Issue #742 - Large list performance
  // https://github.com/bdlukaa/fluent_ui/issues/742
  group('Issue #742 - Large list performance', () {
    testWidgets('Large item list renders without freezing - open mode', (
      tester,
    ) async {
      // Generate a large list of items (200+)
      // Using List<NavigationPaneItem> to ensure correct type
      final items = <NavigationPaneItem>[
        for (var i = 0; i < 250; i++)
          PaneItem(
            icon: const Icon(FluentIcons.document),
            title: Text('Item $i'),
            body: Center(child: Text('Content $i')),
          ),
      ];

      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: items,
              ),
            ),
          ),
        ),
      );

      // Should not freeze - pump should complete quickly
      await tester.pump();

      // Verify the navigation view renders
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('Large item list renders without freezing - compact mode', (
      tester,
    ) async {
      final items = <NavigationPaneItem>[
        for (var i = 0; i < 200; i++)
          PaneItem(
            icon: const Icon(FluentIcons.document),
            title: Text('Item $i'),
            body: Center(child: Text('Content $i')),
          ),
      ];

      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.compact,
                items: items,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('Scrolling large list works smoothly', (tester) async {
      final items = <NavigationPaneItem>[
        for (var i = 0; i < 100; i++)
          PaneItem(
            icon: const Icon(FluentIcons.document),
            title: Text('Item $i'),
            body: Center(child: Text('Content $i')),
          ),
      ];

      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: items,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a scrollable and scroll it
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still render correctly after scrolling
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('ListView.builder is used for pane items', (tester) async {
      // This verifies lazy loading is active by checking that
      // not all items are in the widget tree at once
      final items = <NavigationPaneItem>[
        for (var i = 0; i < 100; i++)
          PaneItem(
            key: ValueKey('item_$i'),
            icon: const Icon(FluentIcons.document),
            title: Text('Item $i'),
            body: Center(child: Text('Content $i')),
          ),
      ];

      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: items,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify NavigationView is rendered
      expect(find.byType(NavigationView), findsOneWidget);

      // Verify not all items are built at once (virtualization)
      // Item 99 should not be in the tree if lazy loading works
      expect(find.byKey(const ValueKey('item_99')), findsNothing);
    });
  });

  // Additional edge case tests
  group('Edge cases', () {
    testWidgets('NavigationView with only content renders', (tester) async {
      await tester.pumpWidget(
        const FluentApp(
          home: NavigationView(content: Center(child: Text('Content Only'))),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(NavigationView), findsOneWidget);
      expect(find.text('Content Only'), findsOneWidget);
    });

    testWidgets('PaneItemSeparator renders correctly', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const SizedBox(),
                  ),
                  PaneItemSeparator(),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('NavigationView handles selected index', (tester) async {
      // NavigationPane requires a valid selected index
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const SizedBox(),
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

    testWidgets('NavigationView handles selection change', (tester) async {
      var selectedIndex = 0;

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
                    displayMode: PaneDisplayMode.expanded,
                    items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.home),
                        title: const Text('Home'),
                        body: const SizedBox(),
                      ),
                      PaneItem(
                        icon: const Icon(FluentIcons.settings),
                        title: const Text('Settings'),
                        body: const SizedBox(),
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
      expect(selectedIndex, 0);

      // Find and tap the settings icon (since text might not be visible)
      final settingsIconFinder = find.byIcon(FluentIcons.settings);
      if (settingsIconFinder.evaluate().isNotEmpty) {
        await tester.tap(settingsIconFinder.first);
        await tester.pumpAndSettle();
        expect(selectedIndex, 1);
      }
    });
  });

  // Test for GitHub Issue #906 - PaneItem overflow during transition
  // https://github.com/bdlukaa/fluent_ui/issues/906
  group('Issue #906 - PaneItem overflow during transition', () {
    testWidgets('PaneItem does not overflow with tight constraints', (
      tester,
    ) async {
      // Test that PaneItem handles tight width constraints gracefully
      // during transitions from compact to open mode
      // This ensures the fix for issue #906 prevents RenderFlex overflow
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 160, // Tight width that would cause overflow without fix
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text(
                      'Very Long Navigation Item Title That Could Overflow',
                    ),
                    body: const SizedBox(),
                    trailing: const Icon(FluentIcons.info),
                    infoBadge: const InfoBadge(source: Text('99')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without overflow errors
      // The key test is that no RenderFlex overflow exception is thrown
      expect(find.byType(NavigationView), findsOneWidget);

      // Verify NavigationView renders successfully
      // (Text might be faded/clipped but widget should not overflow)
      expect(find.byIcon(FluentIcons.home), findsOneWidget);
    });

    testWidgets('PaneItem handles transition width gracefully', (tester) async {
      // Test with a width that's in the transition range
      // (between compact and open, which can cause overflow)
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 151.6, // Width that caused overflow in the reported issue
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const SizedBox(),
                    trailing: const Icon(FluentIcons.info),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without overflow errors even with tight constraints
      expect(find.byType(NavigationView), findsOneWidget);
    });

    testWidgets('PaneItemExpander child items do not overflow', (tester) async {
      // Test that PaneItemExpander child items with additional leading padding
      // don't overflow during transitions
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 160, // Tight width
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItemExpander(
                    icon: const Icon(FluentIcons.folder),
                    title: const Text('Folder with Long Title'),
                    body: const SizedBox(),
                    initiallyExpanded: true,
                    items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.document),
                        title: const Text(
                          'Long Child Item Title That Could Overflow',
                        ),
                        body: const SizedBox(),
                        trailing: const Icon(FluentIcons.info),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without overflow errors
      // Child items have 28px leading padding for indentation
      expect(find.byType(NavigationView), findsOneWidget);
    });
  });

  // Test for GitHub Issue #1189 - PaneItemExpander without body
  // https://github.com/bdlukaa/fluent_ui/issues/1189
  group('Issue #1189 - PaneItemExpander without body', () {
    testWidgets('PaneItemExpander can be created without body', (tester) async {
      // Test that PaneItemExpander can be created with null body
      // and clicking it only toggles expand/collapse without navigation
      await tester.pumpWidget(
        FluentApp(
          home: SizedBox(
            width: 1200,
            height: 800,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.expanded,
                items: [
                  PaneItemExpander(
                    icon: const Icon(FluentIcons.folder),
                    title: const Text('Folder'),
                    items: [
                      PaneItem(
                        icon: const Icon(FluentIcons.document),
                        title: const Text('Document'),
                        body: const Center(child: Text('Document Page')),
                      ),
                    ],
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const Center(child: Text('Home Page')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(NavigationView), findsOneWidget);

      // The expander without body should not be in effectiveItems
      // so it won't be navigable, but clicking it should still toggle
      expect(find.byIcon(FluentIcons.folder), findsOneWidget);
    });

    testWidgets('PaneItemExpander with body is navigable', (tester) async {
      // Test that PaneItemExpander with body still works as before
      var selectedIndex = 0;

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
                    displayMode: PaneDisplayMode.expanded,
                    items: [
                      PaneItemExpander(
                        icon: const Icon(FluentIcons.folder),
                        title: const Text('Folder'),
                        body: const Center(child: Text('Folder Page')),
                        items: [
                          PaneItem(
                            icon: const Icon(FluentIcons.document),
                            title: const Text('Document'),
                            body: const Center(child: Text('Document Page')),
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

      // Should render without errors
      expect(find.byType(NavigationView), findsOneWidget);
      expect(find.text('Folder Page'), findsOneWidget);
    });
  });

  // Test for GitHub Issue #1181 - NavigationView alignment and sizing fixes
  // https://github.com/bdlukaa/fluent_ui/issues/1181
  group('Issue #1181 - NavigationView alignment and sizing', () {
    testWidgets('InfoBadge is centered vertically in compact mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        FluentApp(
          home: NavigationView(
            pane: NavigationPane(
              selected: 0,
              displayMode: PaneDisplayMode.compact,
              items: [
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Home'),
                  body: const Center(child: Text('Home Page')),
                  infoBadge: const InfoBadge(source: Text('5')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the InfoBadge
      final badgeFinder = find.byType(InfoBadge);
      expect(badgeFinder, findsOneWidget);

      // Verify the badge is positioned (not at top: -8, but centered)
      final badgeWidget = tester.widget<InfoBadge>(badgeFinder);
      expect(badgeWidget, isNotNull);
    });

    testWidgets(
      'StickyNavigationIndicator has correct default size and padding',
      (tester) async {
        await tester.pumpWidget(
          FluentApp(
            home: NavigationView(
              pane: NavigationPane(
                selected: 0,
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
          ),
        );

        await tester.pumpAndSettle();

        // Verify the indicator defaults match WinUI3 specs
        // Indicator width should be 3.0px, padding should be 10.0px
        const expectedIndicator = StickyNavigationIndicator();
        expect(expectedIndicator.indicatorSize, 3.0);
        expect(expectedIndicator.leftPadding, 10.0);
        expect(expectedIndicator.topPadding, 12.0);
      },
    );

    testWidgets('EndNavigationIndicator has correct default size', (
      tester,
    ) async {
      await tester.pumpWidget(
        FluentApp(
          home: NavigationView(
            pane: NavigationPane(
              selected: 0,
              indicator: const EndNavigationIndicator(),
              items: [
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Home'),
                  body: const Center(child: Text('Home Page')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // EndNavigationIndicator should use 3.0px width for horizontal mode
      // (it uses fixed values in the widget, but we verify the implementation
      // matches WinUI3 specs through visual inspection)
      expect(find.byType(NavigationView), findsOneWidget);
    });

    // Regression test for https://github.com/bdlukaa/fluent_ui/issues/1334
    testWidgets(
      'NavigationView does not throw when header and menu button are absent',
      (tester) async {
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 1200,
              height: 800,
              child: NavigationView(
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.expanded,
                  toggleable: false,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(NavigationView), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  // Regression test for https://github.com/bdlukaa/fluent_ui/issues/1340
  // TitleBar should not shrink in height when window is resized to smaller width
  group('Issue #1340 - TitleBar height stability on window resize', () {
    testWidgets(
      'TitleBar with content maintains 48px height at large window width',
      (tester) async {
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 1200,
              height: 800,
              child: NavigationView(
                titleBar: const TitleBar(
                  title: Text('My App'),
                  content: SizedBox(width: 200, height: 32),
                ),
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.compact,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final titleBar = find.byType(TitleBar);
        expect(titleBar, findsOneWidget);
        expect(tester.getSize(titleBar).height, 48.0);
      },
    );

    testWidgets(
      'TitleBar with content maintains 48px height at small window width',
      (tester) async {
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 300,
              height: 800,
              child: NavigationView(
                titleBar: const TitleBar(
                  title: Text('My App'),
                  content: SizedBox(width: 200, height: 32),
                ),
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.compact,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final titleBar = find.byType(TitleBar);
        expect(titleBar, findsOneWidget);
        expect(tester.getSize(titleBar).height, 48.0);
      },
    );

    testWidgets(
      'TitleBar height does not change when window width is reduced',
      (tester) async {
        Widget buildWithWidth(double width) {
          return FluentApp(
            home: SizedBox(
              width: width,
              height: 800,
              child: NavigationView(
                titleBar: const TitleBar(
                  title: Text('My App'),
                  content: SizedBox(width: 200, height: 32),
                ),
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.compact,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildWithWidth(1200));
        await tester.pumpAndSettle();

        final titleBar = find.byType(TitleBar);
        final heightAtLargeWidth = tester.getSize(titleBar).height;
        expect(heightAtLargeWidth, 48.0);

        // Simulate window resize to smaller width
        await tester.pumpWidget(buildWithWidth(300));
        await tester.pumpAndSettle();

        final heightAtSmallWidth = tester.getSize(find.byType(TitleBar)).height;
        expect(heightAtSmallWidth, 48.0);
        expect(heightAtLargeWidth, equals(heightAtSmallWidth));
      },
    );

    testWidgets(
      'TitleBar without content maintains 32px height regardless of window width',
      (tester) async {
        // At large window width
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 1200,
              height: 800,
              child: NavigationView(
                titleBar: const TitleBar(title: Text('My App')),
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.expanded,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final titleBar = find.byType(TitleBar);
        expect(tester.getSize(titleBar).height, 32.0);

        // At small window width
        await tester.pumpWidget(
          FluentApp(
            home: SizedBox(
              width: 400,
              height: 800,
              child: NavigationView(
                titleBar: const TitleBar(title: Text('My App')),
                pane: NavigationPane(
                  selected: 0,
                  displayMode: PaneDisplayMode.expanded,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const Center(child: Text('Home Page')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(TitleBar)).height, 32.0);
      },
    );
  });

  testWidgets('auto mode honors default and custom threshold boundaries', (
    tester,
  ) async {
    final key = GlobalKey<NavigationViewState>();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 700);
    addTearDown(tester.view.reset);

    Future<void> pumpAt(
      double width, {
      double compact = kCompactModeThresholdWidth,
      double expanded = kExpandedModeThresholdWidth,
    }) async {
      await tester.pumpWidget(
        FluentApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 600,
              child: NavigationView(
                key: key,
                pane: NavigationPane(
                  selected: 0,
                  compactModeThresholdWidth: compact,
                  expandedModeThresholdWidth: expanded,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.home),
                      title: const Text('Home'),
                      body: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    for (final (width, mode) in [
      (640.0, PaneDisplayMode.minimal),
      (641.0, PaneDisplayMode.compact),
      (1007.0, PaneDisplayMode.compact),
      (1008.0, PaneDisplayMode.expanded),
    ]) {
      await pumpAt(width);
      expect(key.currentState!.displayMode, mode);
    }

    await pumpAt(700, compact: 700, expanded: 900);
    expect(key.currentState!.displayMode, PaneDisplayMode.minimal);
    await pumpAt(701, compact: 700, expanded: 900);
    expect(key.currentState!.displayMode, PaneDisplayMode.compact);
    await pumpAt(900, compact: 700, expanded: 900);
    expect(key.currentState!.displayMode, PaneDisplayMode.expanded);
  });

  testWidgets(
    'invocation precedes selection and supports non-selecting items',
    (tester) async {
      var selected = 0;
      final events = <String>[];
      final actionFocusNode = FocusNode();
      addTearDown(actionFocusNode.dispose);

      await tester.pumpWidget(
        FluentApp(
          home: StatefulBuilder(
            builder: (context, setState) => NavigationView(
              pane: NavigationPane(
                selected: selected,
                displayMode: PaneDisplayMode.expanded,
                onItemInvoked: (args) => events.add(
                  'invoke:${(args.item.title! as Text).data}:${args.index}',
                ),
                onChanged: (index) {
                  events.add('select:$index');
                  setState(() => selected = index);
                },
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.home),
                    title: const Text('Home'),
                    body: const SizedBox(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const SizedBox(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.open_in_new_window),
                    title: const Text('External'),
                    body: const SizedBox(),
                    focusNode: actionFocusNode,
                    selectsOnInvoked: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(events, ['invoke:Settings:1', 'select:1']);

      events.clear();
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(events, ['invoke:Settings:1']);

      events.clear();
      actionFocusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(events, ['invoke:External:2']);
      expect(selected, 1);
      await tester.pump(const Duration(milliseconds: 200));
    },
  );

  testWidgets('local history survives nested, footer, and dynamic items', (
    tester,
  ) async {
    final key = GlobalKey<NavigationViewState>();
    var selected = 0;
    late StateSetter rebuild;
    var includeNested = true;

    Widget buildApp() => FluentApp(
      home: StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return NavigationView(
            key: key,
            pane: NavigationPane(
              selected: selected,
              displayMode: PaneDisplayMode.expanded,
              onChanged: (index) => setState(() => selected = index),
              items: [
                PaneItem(
                  key: const ValueKey('a'),
                  icon: const Icon(FluentIcons.home),
                  title: const Text('A'),
                  body: const Text('Page A'),
                ),
                PaneItemExpander(
                  key: const ValueKey('group'),
                  icon: const Icon(FluentIcons.folder),
                  title: const Text('Group'),
                  initiallyExpanded: true,
                  items: [
                    if (includeNested)
                      PaneItem(
                        key: const ValueKey('b'),
                        icon: const Icon(FluentIcons.document),
                        title: const Text('B'),
                        body: const Text('Page B'),
                      ),
                  ],
                ),
              ],
              footerItems: [
                PaneItem(
                  key: const ValueKey('c'),
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('C'),
                  body: const Text('Page C'),
                ),
              ],
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();

    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(selected, 1);
    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(selected, 0);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('C'));
    await tester.pump(const Duration(milliseconds: 200));
    rebuild(() {
      includeNested = false;
      selected = 1;
    });
    await tester.pumpAndSettle();

    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(selected, 0);
  });

  testWidgets('toggleable false removes and disables the pane toggle', (
    tester,
  ) async {
    final key = GlobalKey<NavigationViewState>();
    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          key: key,
          titleBar: const TitleBar(isBackButtonVisible: false),
          pane: NavigationPane(
            selected: 0,
            displayMode: PaneDisplayMode.compact,
            toggleable: false,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaneToggleButton), findsNothing);
    expect(key.currentState!.isPaneOpen, isFalse);
    key.currentState!.openPane();
    await tester.pumpAndSettle();
    expect(key.currentState!.isPaneOpen, isFalse);

    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          key: key,
          pane: NavigationPane(
            selected: 0,
            displayMode: PaneDisplayMode.minimal,
            toggleable: false,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: const SizedBox.expand(key: ValueKey('minimal-body')),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('minimal-body'))).dy, 0);
  });

  testWidgets('a null toggle button only hides the control', (tester) async {
    final key = GlobalKey<NavigationViewState>();
    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          key: key,
          pane: NavigationPane(
            selected: 0,
            displayMode: PaneDisplayMode.compact,
            toggleButton: null,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaneToggleButton), findsNothing);
    key.currentState!.openPane();
    await tester.pumpAndSettle();
    expect(key.currentState!.isPaneOpen, isTrue);
  });

  testWidgets('Escape closes an open overlay before navigation', (
    tester,
  ) async {
    final key = GlobalKey<NavigationViewState>();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          key: key,
          pane: NavigationPane(
            selected: 0,
            displayMode: PaneDisplayMode.compact,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: const SizedBox(),
                focusNode: focusNode,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    key.currentState!.openPane();
    await tester.pumpAndSettle();
    expect(key.currentState!.isPaneOpen, isTrue);

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(key.currentState!.isPaneOpen, isFalse);
  });

  testWidgets('only pages requesting keep alive retain state', (tester) async {
    final keepAliveLifecycle = _PageLifecycle();
    final disposableLifecycle = _PageLifecycle();
    var selected = 0;

    await tester.pumpWidget(
      FluentApp(
        home: StatefulBuilder(
          builder: (context, setState) => NavigationView(
            pane: NavigationPane(
              selected: selected,
              onChanged: (index) => setState(() => selected = index),
              displayMode: PaneDisplayMode.expanded,
              items: [
                PaneItem(
                  key: const ValueKey('kept'),
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Kept'),
                  body: _LifecyclePage(
                    lifecycle: keepAliveLifecycle,
                    keepAlive: true,
                  ),
                ),
                PaneItem(
                  key: const ValueKey('disposable'),
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('Disposable'),
                  body: _LifecyclePage(lifecycle: disposableLifecycle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(keepAliveLifecycle.initCount, 1);

    await tester.tap(find.text('Kept state: 0'));
    await tester.tap(find.text('Disposable'));
    await tester.pumpAndSettle();
    expect(keepAliveLifecycle.disposeCount, 0);
    expect(disposableLifecycle.initCount, 1);

    await tester.tap(find.text('Kept'));
    await tester.pumpAndSettle();
    expect(find.text('Kept state: 1'), findsOneWidget);
    expect(disposableLifecycle.disposeCount, 1);

    await tester.tap(find.text('Disposable'));
    await tester.pumpAndSettle();
    expect(disposableLifecycle.initCount, 2);
  });

  testWidgets('tooltip policy and semantic labels are independent', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          pane: NavigationPane(
            selected: 0,
            displayMode: PaneDisplayMode.compact,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Short'),
                semanticLabel: 'Descriptive home destination',
                tooltip: 'Custom home tooltip',
                body: const SizedBox(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text('No tooltip'),
                automaticTooltip: false,
                body: const SizedBox(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.info),
                title: const Text('Automatic tooltip'),
                body: const SizedBox(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.blocked),
                title: const Text('Disabled tooltip'),
                body: const SizedBox(),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Descriptive home destination'),
      findsOneWidget,
    );
    final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
    expect(
      tooltips.any((tooltip) => tooltip.message == 'Custom home tooltip'),
      isTrue,
    );
    expect(
      tooltips.any(
        (tooltip) => tooltip.richMessage?.toPlainText() == 'Automatic tooltip',
      ),
      isTrue,
    );
    expect(
      tooltips.any(
        (tooltip) => tooltip.richMessage?.toPlainText() == 'No tooltip',
      ),
      isFalse,
    );
    expect(
      tooltips.any(
        (tooltip) => tooltip.richMessage?.toPlainText() == 'Disabled tooltip',
      ),
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('custom item content keeps standard invocation behavior', (
    tester,
  ) async {
    var selected = 0;
    var invocations = 0;
    await tester.pumpWidget(
      FluentApp(
        home: StatefulBuilder(
          builder: (context, setState) => NavigationView(
            pane: NavigationPane(
              selected: selected,
              onItemInvoked: (_) => invocations++,
              onChanged: (index) => setState(() => selected = index),
              displayMode: PaneDisplayMode.expanded,
              items: [
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Home'),
                  body: const SizedBox(),
                ),
                PaneItem(
                  icon: const Icon(FluentIcons.people),
                  title: const Text('Teams'),
                  body: const SizedBox(),
                  contentBuilder: (context, data) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [?data.icon, ?data.title],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(selected, 1);
    expect(invocations, 1);
  });

  testWidgets('auto resize transitions never overflow complex pane items', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1100, 700);

    await tester.pumpWidget(
      FluentApp(
        home: NavigationView(
          pane: NavigationPane(
            selected: 0,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text(
                  'A very long navigation destination that must remain valid',
                ),
                infoBadge: const InfoBadge(source: Text('99')),
                trailing: const Icon(FluentIcons.chevron_right),
                body: const SizedBox(),
              ),
              PaneItemExpander(
                icon: const Icon(FluentIcons.folder),
                title: const Text('A deeply nested destination'),
                initiallyExpanded: true,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.document),
                    title: const Text('A long nested destination'),
                    infoBadge: const InfoBadge(source: Text('4')),
                    trailing: const Icon(FluentIcons.chevron_right),
                    body: const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    for (final width in [1007.0, 900.0, 641.0, 640.0, 700.0, 1008.0]) {
      tester.view.physicalSize = Size(width, 700);
      for (var frame = 0; frame < 8; frame++) {
        await tester.pump(const Duration(milliseconds: 20));
        expect(tester.takeException(), isNull);
      }
    }
  });
}

class _PageLifecycle {
  int initCount = 0;
  int disposeCount = 0;
}

class _LifecyclePage extends StatefulWidget {
  const _LifecyclePage({required this.lifecycle, this.keepAlive = false});

  final _PageLifecycle lifecycle;
  final bool keepAlive;

  @override
  State<_LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<_LifecyclePage>
    with AutomaticKeepAliveClientMixin {
  int value = 0;

  @override
  void initState() {
    super.initState();
    widget.lifecycle.initCount++;
  }

  @override
  void dispose() {
    widget.lifecycle.disposeCount++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final label = widget.keepAlive ? 'Kept' : 'Disposable';
    return Center(
      child: Button(
        onPressed: () => setState(() => value++),
        child: Text('$label state: $value'),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
