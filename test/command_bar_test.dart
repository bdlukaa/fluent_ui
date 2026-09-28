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

  testWidgets('overflow menu uses WinUI presenter dimensions and resources', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 320,
          child: CommandBar(
            primaryItems: [],
            secondaryItems: [
              CommandBarButton(label: Text('More actions'), onPressed: null),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.more));
    await tester.pumpAndSettle();

    final presenter = tester.widget<FlyoutContent>(find.byType(FlyoutContent));
    final theme = FluentTheme.of(tester.element(find.byType(CommandBar)));
    expect(
      presenter.constraints,
      const BoxConstraints(minWidth: 160, maxWidth: 480, maxHeight: 198),
    );
    expect(presenter.color, theme.resources.layerOnAcrylicFillColorDefault);
    final shape = presenter.shape! as RoundedRectangleBorder;
    expect(shape.side.color, theme.resources.surfaceStrokeColorFlyout);
    expect(shape.side.width, 1);
  });

  testWidgets('overflow menu aligns to the command bar end', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const SizedBox(
          width: 320,
          child: CommandBar(
            primaryItems: [],
            secondaryItems: [
              CommandBarButton(label: Text('More actions'), onPressed: null),
            ],
          ),
        ),
      ),
    );

    final button = find.widgetWithIcon(IconButton, FluentIcons.more);
    await tester.tap(button);
    await tester.pumpAndSettle();

    final menu = find.byType(FlyoutContent);
    expect(menu, findsOneWidget);
    expect(
      tester.getTopRight(menu).dx,
      closeTo(tester.getTopRight(find.byType(CommandBar)).dx, 0.1),
    );
  });

  testWidgets('outside taps dismiss the overflow without activating the page', (
    tester,
  ) async {
    var pressed = false;
    const outsideKey = Key('outside-command');
    await tester.pumpWidget(
      wrapApp(
        child: Column(
          children: [
            CommandBar(
              primaryItems: const [],
              secondaryItems: [
                CommandBarButton(
                  label: const Text('Secondary action'),
                  onPressed: () {},
                ),
              ],
            ),
            Button(
              key: outsideKey,
              onPressed: () => pressed = true,
              child: const Text('Outside'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.more));
    await tester.pumpAndSettle();
    expect(find.text('Secondary action'), findsOneWidget);

    await tester.tap(find.byKey(outsideKey), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Secondary action'), findsNothing);
    expect(pressed, isFalse);

    await tester.tap(find.byKey(outsideKey), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

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
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));
    final tooltip = find.text('Save your work');
    expect(tooltip, findsOneWidget);
  });
  testWidgets(
    'secondary CommandBarButton retains tooltip in the overflow menu',
    (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const SizedBox(
            width: 180,
            child: CommandBar(
              primaryItems: [],
              secondaryItems: [
                CommandBarButton(
                  icon: Icon(FluentIcons.save),
                  label: Text('Export'),
                  tooltip: 'Export all operations',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.more));
      await tester.pumpAndSettle();
      final item = find.text('Export');
      expect(item, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(item));
      await tester.pumpAndSettle(const Duration(milliseconds: 1200));
      expect(find.text('Export all operations'), findsNWidgets(2));
    },
  );

  testWidgets('dynamically overflowed primary item retains tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: ScaffoldPage(
          header: SizedBox(
            width: 100,
            child: CommandBar(
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.save),
                  label: const Text('Save'),
                  tooltip: 'Save your work',
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.edit),
                  label: const Text('Edit'),
                  tooltip: 'Edit your work',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.more));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNWidgets(2));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.text('Edit').last));
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));
    expect(find.text('Edit your work'), findsNWidgets(2));
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
