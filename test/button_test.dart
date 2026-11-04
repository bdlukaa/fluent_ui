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

  testWidgets('Button style textStyle color overrides foreground color', (
    tester,
  ) async {
    await tester.pumpWidget(
      FluentApp(
        theme: FluentThemeData(),
        home: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              style: const ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () {},
              child: const Text('Press me'),
            ),
            FilledButton(
              style: const ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: Colors.black),
                ),
              ),
              onPressed: () {},
              child: const Text('Press Me'),
            ),
          ],
        ),
      ),
    );

    expect(_renderedTextStyle(tester, find.byType(Button)).color, Colors.black);
    expect(
      _renderedTextStyle(tester, find.byType(FilledButton)).color,
      Colors.black,
    );
  });

  group('IconButton theme styles', () {
    const largeKey = Key('large');
    const smallKey = Key('small');
    const tinyKey = Key('tiny');
    const inheritedKey = Key('inherited');
    const iconButtonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsetsDirectional.all(20)),
    );
    const smallIconButtonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsetsDirectional.all(1)),
    );

    Future<void> pumpIconButtons(
      WidgetTester tester,
      ButtonThemeData buttonTheme,
    ) async {
      await tester.pumpWidget(
        FluentApp(
          theme: FluentThemeData(buttonTheme: buttonTheme),
          home: Column(
            children: [
              IconButton(
                key: largeKey,
                icon: const Icon(FluentIcons.add),
                onPressed: () {},
              ),
              IconButton(
                key: smallKey,
                iconButtonMode: IconButtonMode.small,
                icon: const Icon(FluentIcons.add),
                onPressed: () {},
              ),
              IconButton(
                key: tinyKey,
                iconButtonMode: IconButtonMode.tiny,
                icon: const Icon(FluentIcons.add),
                onPressed: () {},
              ),
              SmallIconButton(
                child: IconButton(
                  key: inheritedKey,
                  icon: const Icon(FluentIcons.add),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The horizontal padding around the icon of the button with [key].
    double paddingOf(WidgetTester tester, Key key) {
      final button = tester.getRect(find.byKey(key));
      final icon = tester.getRect(
        find.descendant(of: find.byKey(key), matching: find.byType(Icon)),
      );
      return icon.left - button.left;
    }

    testWidgets('iconButtonStyle applies to every mode by default', (
      tester,
    ) async {
      await pumpIconButtons(
        tester,
        const ButtonThemeData(iconButtonStyle: iconButtonStyle),
      );

      for (final key in [largeKey, smallKey, tinyKey, inheritedKey]) {
        expect(paddingOf(tester, key), 20, reason: '$key');
      }
    });

    testWidgets('smallIconButtonStyle applies to small and tiny buttons', (
      tester,
    ) async {
      await pumpIconButtons(
        tester,
        const ButtonThemeData(
          iconButtonStyle: iconButtonStyle,
          smallIconButtonStyle: smallIconButtonStyle,
        ),
      );

      expect(paddingOf(tester, largeKey), 20);
      for (final key in [smallKey, tinyKey, inheritedKey]) {
        expect(paddingOf(tester, key), 1, reason: '$key');
      }
    });
  });
}
