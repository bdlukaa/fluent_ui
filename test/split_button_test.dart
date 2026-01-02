import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('SplitButton displays child and flyout', (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      wrapApp(
        child: SplitButton(
          flyout: const SizedBox(
            key: Key('flyout-content'),
            width: 100,
            height: 100,
          ),
          onInvoked: () => invoked = true,
          child: const Text('Primary'),
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);

    await tester.tap(find.text('Primary'));
    await tester.pumpAndSettle();
    expect(invoked, isTrue);

    await tester.tap(find.byType(ChevronDown));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('flyout-content')), findsOneWidget);
  });

  testWidgets('SplitButton invokes onInvoked when primary button is tapped', (
    tester,
  ) async {
    var invoked = false;
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: SplitButton(
            flyout: const SizedBox(key: Key('flyout')),
            onInvoked: () {
              invoked = true;
            },
            child: const Text('Invoke Me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Invoke Me'));
    await tester.pumpAndSettle();
    expect(invoked, isTrue);
  });

  testWidgets('SplitButton uses secondaryBuilder', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: Center(
            child: SplitButton(
              flyout: const SizedBox(
                key: Key('custom-flyout'),
                width: 80,
                height: 80,
              ),
              secondaryBuilder: (context, showFlyout, controller) {
                return IconButton(
                  key: const Key('custom-secondary-button'),
                  icon: const Icon(FluentIcons.add),
                  onPressed: showFlyout,
                );
              },
              child: const Text('Custom Secondary'),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('custom-secondary-button')), findsOneWidget);

    expect(find.byType(ChevronDown), findsNothing);
  });

  testWidgets('SplitButton disables buttons when enabled is false', (
    tester,
  ) async {
    var invoked = false;
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          content: SplitButton(
            enabled: false,
            flyout: const SizedBox(key: Key('disabled-flyout')),
            onInvoked: () {
              invoked = true;
            },
            child: const Text('Disabled'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();
    expect(invoked, isFalse);

    await tester.tap(find.byType(ChevronDown));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('disabled-flyout')), findsNothing);
  });
}
