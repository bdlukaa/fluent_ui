import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
    'CommandBarCard renders child and applies margin, padding, borderRadius, borderColor, and backgroundColor',
    (tester) async {
      const testKey = Key('test-child');
      await tester.pumpWidget(
        wrapApp(
          child: CommandBarCard(
            margin: const EdgeInsetsDirectional.all(8),
            padding: const EdgeInsetsDirectional.all(12),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderColor: Colors.red,
            backgroundColor: Colors.green,
            child: Container(key: testKey),
          ),
        ),
      );
      expect(find.byKey(testKey), findsOneWidget);
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsetsDirectional.all(8));
      expect(card.padding, const EdgeInsetsDirectional.all(12));
      expect(card.borderRadius, const BorderRadius.all(Radius.circular(10)));
      expect(card.borderColor, Colors.red);
      expect(card.backgroundColor, Colors.green);
    },
  );

  testWidgets('CommandBar renders primary items', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: CommandBar(
          primaryItems: [
            CommandBarButton(
              key: const Key('primary-btn'),
              icon: const Icon(FluentIcons.add),
              label: const Text('Add'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    expect(find.byKey(const Key('primary-btn')), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets(
    'CommandBar renders secondary items and shows flyout on overflow button tap',
    (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrapApp(
          child: SizedBox(
            width: 100, // Force overflow by limiting width
            child: ScaffoldPage(
              header: CommandBar(
                primaryItems: [
                  CommandBarButton(
                    key: const Key('primary-btn'),
                    icon: const Icon(FluentIcons.add),
                    label: const Text('Add'),
                    onPressed: () {},
                  ),
                  CommandBarButton(
                    key: const Key('primary-btn-2'),
                    icon: const Icon(FluentIcons.edit),
                    label: const Text('Edit'),
                    onPressed: () {},
                  ),
                  CommandBarButton(
                    key: const Key('primary-btn-3'),
                    icon: const Icon(FluentIcons.settings),
                    label: const Text('Settings'),
                    onPressed: () {},
                  ),
                  CommandBarButton(
                    key: const Key('primary-btn-4'),
                    icon: const Icon(FluentIcons.help),
                    label: const Text('Help'),
                    onPressed: () {},
                  ),
                  CommandBarButton(
                    key: const Key('primary-btn-5'),
                    icon: const Icon(FluentIcons.info),
                    label: const Text('About'),
                    onPressed: () {},
                  ),
                ],
                secondaryItems: [
                  CommandBarButton(
                    key: const Key('secondary-btn'),
                    icon: const Icon(FluentIcons.delete),
                    label: const Text('Delete'),
                    onPressed: () {
                      pressed = true;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsNothing);

      final overflowButton = find.widgetWithIcon(IconButton, FluentIcons.more);
      expect(overflowButton, findsOneWidget);

      await tester.tap(overflowButton);
      await tester.pumpAndSettle();
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    },
  );

  testWidgets('CommandBarButton displays tooltip', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: CommandBar(
          primaryItems: [
            CommandBarButton(
              key: const Key('tooltip-btn'),
              icon: const Icon(FluentIcons.save),
              label: const Text('Save'),
              onPressed: () {},
              tooltip: 'Save your work',
            ),
          ],
        ),
      ),
    );
    final finder = find.byKey(const Key('tooltip-btn'));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await tester.pump();
    await gesture.moveTo(tester.getCenter(finder));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    final tooltip = find.text('Save your work');
    expect(tooltip, findsOneWidget);
  });
  testWidgets('CommandBarButton hides label and shows icon in compact mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: CommandBar(
          isCompact: true,
          primaryItems: [
            CommandBarButton(
              key: const Key('compact-btn'),
              icon: const Icon(FluentIcons.delete),
              label: const Text('Delete'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    // The label should not be found
    expect(find.text('Delete'), findsNothing);
    // The icon should be found
    expect(find.byIcon(FluentIcons.delete), findsOneWidget);
  });
}
