import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AutoSuggestBox basics testing', (tester) async {
    await tester.pumpWidget(wrapApp(
      child: AutoSuggestBox(
        items: [
          AutoSuggestBoxItem<String>(label: 'One', value: 'one'),
          AutoSuggestBoxItem<String>(label: 'Two', value: 'two'),
          AutoSuggestBoxItem<String>(label: 'Three', value: 'three'),
        ],
        leadingIcon: const Icon(FluentIcons.number),
        placeholder: 'Numbers',
      ),
    ));
    // Placeholder is shown
    expect(find.text('Numbers'), findsOneWidget);
    // Icon is shown
    expect(find.byIcon(FluentIcons.number), findsOneWidget);
    // No items shown
    expect(find.text('One'), findsNothing);
    expect(find.text('Two'), findsNothing);
    expect(find.text('Three'), findsNothing);
  });

  testWidgets(
    'AutoSuggestBox search testing',
    (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: DisableAcrylic(
            child: AutoSuggestBox<String>(
              items: [
                AutoSuggestBoxItem<String>(label: 'One', value: 'one'),
                AutoSuggestBoxItem<String>(label: 'Two', value: 'two'),
                AutoSuggestBoxItem<String>(label: 'Three', value: 'three'),
              ],
              leadingIcon: const Icon(FluentIcons.number),
              placeholder: 'Numbers',
            ),
          ),
        ),
      );

      /// Summary of Test -> Type 'o', then 'n' ('on'), then back to 'o' and finally back to empty ''

      await tester.pump();

      // AutoSuggestBox should react
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsNothing);
      expect(find.text('Three'), findsNothing);

      // Expect a valid Textbox
      expect(find.byType(TextBox), findsOneWidget);

      // Tap to show items
      await tester.tap(find.byType(TextBox));
      await tester.pump(const Duration(seconds: 1));
      // FIXME 🐛 This fails because Flyout is not shown
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);

      // Field = 'o' --> One + Two
      await tester.enterText(find.byType(TextBox), 'o');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsNothing);
      // Field = 'on' --> One
      await tester.enterText(find.byType(TextBox), 'n');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsNothing);
      expect(find.text('Three'), findsNothing);
      // Backspace U+2408 character
      // Field = 'o' --> One + Two again
      await tester.enterText(find.byType(TextBox), '\u2408');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsNothing);
      // Backspace U+2408 character
      // Field = '' --> One + Two + Three
      await tester.enterText(find.byType(TextBox), '\u2408');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    },
    // DISABLE THIS TEST UNTIL IT'S FIXED
    skip: true,
  );
}
