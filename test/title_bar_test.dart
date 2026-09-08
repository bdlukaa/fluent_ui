import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TextStyle richTextStyle(WidgetTester tester, Finder textFinder) {
    final richTextFinder = find.descendant(
      of: textFinder,
      matching: find.byType(RichText),
    );
    return tester.widget<RichText>(richTextFinder).text.style!;
  }

  testWidgets('TitleBar renders title and subtitle with theme colors', (
    tester,
  ) async {
    const title = Text('The Title');
    const subtitle = Text('The Subtitle');

    await tester.pumpWidget(
      const FluentApp(
        home: NavigationView(
          titleBar: TitleBar(title: title, subtitle: subtitle),
          content: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tbContext = tester.element(find.byType(TitleBar));
    final theme = FluentTheme.of(tbContext);

    final titleColor = richTextStyle(tester, find.text('The Title')).color;
    final subtitleColor = richTextStyle(
      tester,
      find.text('The Subtitle'),
    ).color;

    expect(titleColor, theme.resources.textFillColorPrimary);
    expect(subtitleColor, theme.resources.textFillColorSecondary);
  });

  testWidgets('TitleBar shows and hides PaneBackButton', (tester) async {
    const tb = TitleBar();
    await tester.pumpWidget(
      const FluentApp(
        home: NavigationView(titleBar: tb, content: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaneBackButton), findsOneWidget);

    const tb2 = TitleBar(isBackButtonVisible: false);
    await tester.pumpWidget(
      const FluentApp(
        home: NavigationView(titleBar: tb2, content: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaneBackButton), findsNothing);
  });

  testWidgets('TitleBar.calculateHeight respects explicit height and content', (
    tester,
  ) async {
    const tb = TitleBar(height: 42);
    await tester.pumpWidget(
      const FluentApp(
        home: NavigationView(titleBar: tb, content: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(TitleBar));
    final paddingTop = MediaQuery.of(ctx).padding.top;
    expect(TitleBar.calculateHeight(ctx, tb), 42 + paddingTop);

    const tb2 = TitleBar(content: SizedBox.shrink());
    await tester.pumpWidget(
      const FluentApp(
        home: NavigationView(titleBar: tb2, content: SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    final ctx2 = tester.element(find.byType(TitleBar));
    final paddingTop2 = MediaQuery.of(ctx2).padding.top;
    expect(TitleBar.calculateHeight(ctx2, tb2), 48 + paddingTop2);

    // Null titleBar should return 0
    expect(TitleBar.calculateHeight(ctx2, null), 0);
  });

  testWidgets('an initially hidden title has no semantics until it fits', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(200, 600);
    addTearDown(tester.view.reset);
    const searchLabel = 'Search settings';

    try {
      await tester.pumpWidget(
        FluentApp(
          home: NavigationView(
            titleBar: TitleBar(
              isBackButtonVisible: false,
              title: Semantics(
                label: searchLabel,
                button: true,
                child: const SizedBox(
                  width: searchLabel.length * 16,
                  height: 32,
                ),
              ),
            ),
            content: const SizedBox.shrink(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(searchLabel), findsNothing);

      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(searchLabel), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'a dirty title can be hidden and restored with semantics enabled',
    (tester) async {
      final handle = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);

      FluentApp buildApp(String title) => FluentApp(
        home: NavigationView(
          titleBar: TitleBar(
            isBackButtonVisible: false,
            title: Semantics(
              label: title,
              button: true,
              child: SizedBox(width: title.length * 16, height: 32),
            ),
          ),
          content: const SizedBox.shrink(),
        ),
      );

      try {
        await tester.pumpWidget(buildApp('Search'));
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Search'), findsOneWidget);

        tester.view.physicalSize = const Size(200, 600);
        await tester.pumpWidget(buildApp('Search settings'));
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Search settings'), findsNothing);

        tester.view.physicalSize = const Size(800, 600);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Search settings'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    },
  );
}
