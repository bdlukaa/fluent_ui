import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AutoSuggestBox basics testing', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: AutoSuggestBox(
          items: [
            AutoSuggestBoxItem<String>(label: 'One', value: 'one'),
            AutoSuggestBoxItem<String>(label: 'Two', value: 'two'),
            AutoSuggestBoxItem<String>(label: 'Three', value: 'three'),
          ],
          leadingIcon: const Icon(FluentIcons.number),
          placeholder: 'Numbers',
        ),
      ),
    );
    expect(find.text('Numbers'), findsOneWidget);
    expect(find.byIcon(FluentIcons.number), findsOneWidget);
    expect(find.text('One'), findsNothing);
    expect(find.text('Two'), findsNothing);
    expect(find.text('Three'), findsNothing);
  });

  testWidgets('AutoSuggestBox popupDirection defaults to below', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: AutoSuggestBox<String>(
          items: [AutoSuggestBoxItem<String>(label: 'One', value: 'one')],
        ),
      ),
    );

    final box = tester.widget<AutoSuggestBox<String>>(
      find.byType(AutoSuggestBox<String>),
    );
    expect(box.popupDirection, PopupDirection.below);
  });

  testWidgets('AutoSuggestBox accepts custom popupDirection', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: AutoSuggestBox<String>(
          popupDirection: PopupDirection.auto,
          items: [AutoSuggestBoxItem<String>(label: 'One', value: 'one')],
        ),
      ),
    );

    final box = tester.widget<AutoSuggestBox<String>>(
      find.byType(AutoSuggestBox<String>),
    );
    expect(box.popupDirection, PopupDirection.auto);
  });

  testWidgets(
    'AutoSuggestBox positions overlay above when PopupDirection.above',
    (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AutoSuggestBox<String>(
              popupDirection: PopupDirection.above,
              items: [AutoSuggestBoxItem<String>(label: 'One', value: 'one')],
            ),
          ),
        ),
      );

      final box = tester.widget<AutoSuggestBox<String>>(
        find.byType(AutoSuggestBox<String>),
      );
      expect(box.popupDirection, PopupDirection.above);

      await tester.enterText(find.byType(TextBox), 'o');
      await tester.pumpAndSettle();
      expect(find.byType(CompositedTransformFollower), findsOneWidget);
      final follower = tester.widget<CompositedTransformFollower>(
        find.byType(CompositedTransformFollower),
      );
      expect(follower.offset.dy, lessThan(0));
    },
  );

  testWidgets('AutoSuggestBox renders TextBox', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: AutoSuggestBox<String>(
          items: [AutoSuggestBoxItem<String>(label: 'One', value: 'one')],
        ),
      ),
    );

    expect(find.byType(TextBox), findsOneWidget);
  });

  testWidgets('AutoSuggestBox renders TextFormBox when validator provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: AutoSuggestBox<String>.form(
          items: [AutoSuggestBoxItem<String>(label: 'One', value: 'one')],
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ),
    );

    expect(find.byType(TextFormBox), findsOneWidget);
  });
}
