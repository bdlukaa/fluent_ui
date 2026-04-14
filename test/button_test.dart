import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

TextStyle _renderedTextStyle(WidgetTester tester, Finder buttonFinder) {
  final richTextFinder = find.descendant(
    of: buttonFinder,
    matching: find.byType(RichText),
  );
  return tester.widget<RichText>(richTextFinder).text.style!;
}

void main() {
  testWidgets('Test constraints', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FluentTheme(
          data: FluentThemeData(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 10,
                maxWidth: 100,
                minHeight: 20,
                maxHeight: 200,
              ),
              child: Button(child: const SizedBox.shrink(), onPressed: () {}),
            ),
          ),
        ),
      ),
    );

    final buttonBox = tester.firstRenderObject<RenderBox>(find.byType(Button));
    final innerBox = tester.firstRenderObject<RenderBox>(find.byType(SizedBox));

    expect(
      buttonBox.constraints,
      const BoxConstraints(
        minWidth: 10,
        maxWidth: 100,
        minHeight: 20,
        maxHeight: 200,
      ),
    );
    expect(buttonBox.size.width, greaterThanOrEqualTo(10));
    expect(buttonBox.size.height, greaterThanOrEqualTo(20));

    expect(innerBox.constraints.smallest, Size.zero);
    expect(innerBox.constraints.maxWidth, lessThanOrEqualTo(100));
    expect(innerBox.constraints.maxHeight, lessThanOrEqualTo(200));
    expect(innerBox.size, Size.zero);
  });

  testWidgets(
    'Button and FilledButton use default foreground when themed styles omit '
    'textStyle',
    (tester) async {
      await tester.pumpWidget(
        FluentApp(
          theme: FluentThemeData(),
          home: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(onPressed: () {}, child: const Text('Press me')),
              FilledButton(onPressed: () {}, child: const Text('Press Me')),
            ],
          ),
        ),
      );

      final buttonContext = tester.element(find.byType(Button));
      final filledButtonContext = tester.element(find.byType(FilledButton));
      final theme = FluentTheme.of(buttonContext);

      final expectedButtonColor = ButtonThemeData.buttonForegroundColor(
        buttonContext,
        {},
      );
      final expectedFilledButtonColor = FilledButton.foregroundColor(theme, {});

      final renderedButtonColor = _renderedTextStyle(
        tester,
        find.byType(Button),
      ).color;
      final renderedFilledButtonColor = _renderedTextStyle(
        tester,
        find.byType(FilledButton),
      ).color;

      expect(renderedButtonColor, expectedButtonColor);
      expect(renderedFilledButtonColor, expectedFilledButtonColor);

      // Keep the second context in use to ensure both are bound to the same theme.
      expect(FluentTheme.of(filledButtonContext), same(theme));
    },
  );

  testWidgets('Button uses inherited TextStyle color', (tester) async {
    await tester.pumpWidget(
      FluentApp(
        theme: FluentThemeData(
          buttonTheme: ButtonThemeData(
            defaultButtonStyle: ButtonStyle(
              textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.blue)),
            ),
            filledButtonStyle: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                TextStyle(color: Colors.yellow),
              ),
            ),
          ),
        ),
        home: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(onPressed: () {}, child: const Text('Press me')),
            FilledButton(onPressed: () {}, child: const Text('Press Me')),
          ],
        ),
      ),
    );

    expect(_renderedTextStyle(tester, find.byType(Button)).color, Colors.blue);
    expect(
      _renderedTextStyle(tester, find.byType(FilledButton)).color,
      Colors.yellow,
    );
  });
}
