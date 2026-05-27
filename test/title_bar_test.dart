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
}
