import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  group('FlyoutListTile', () {
    testWidgets('can be used outside of a Flyout', (tester) async {
      await tester.pumpWidget(
        wrapApp(child: const FlyoutListTile(text: Text('Copy'))),
      );
    });

    testWidgets('renders with icon, text, and trailing', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutListTile(
            icon: Icon(FluentIcons.copy),
            text: Text('Copy'),
            trailing: Text('Ctrl+C'),
          ),
        ),
      );
      expect(find.byIcon(FluentIcons.copy), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Ctrl+C'), findsOneWidget);
    });

    testWidgets('calls onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrapApp(
          child: FlyoutListTile(
            text: const Text('Press me'),
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.tap(find.text('Press me'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('calls onLongPress', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        wrapApp(
          child: FlyoutListTile(
            text: const Text('Long Press me'),
            onLongPress: () => longPressed = true,
          ),
        ),
      );
      await tester.longPress(find.text('Long Press me'));
      await tester.pumpAndSettle();
      expect(longPressed, isTrue);
    });

    testWidgets('shows tooltip', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutListTile(
            text: Text('Tooltip Tile'),
            tooltip: 'Tooltip Text',
          ),
        ),
      );
      final gesture = await tester.createGesture();
      await gesture.moveTo(tester.getCenter(find.text('Tooltip Tile')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('applies margin', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutListTile(
            text: Text('Margin'),
            margin: EdgeInsetsDirectional.all(20),
          ),
        ),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(FlyoutListTile),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, const EdgeInsetsDirectional.all(20));
    });

    testWidgets('passes semanticLabel', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutListTile(
            text: Text('Semantic'),
            semanticLabel: 'semantic-label',
          ),
        ),
      );
      // Just ensure it builds, as semanticLabel is passed to HoverButton
      expect(find.text('Semantic'), findsOneWidget);
    });
  });

  group('FlyoutContent', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        wrapApp(child: const FlyoutContent(child: Text('Flyout Child'))),
      );
      expect(find.text('Flyout Child'), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: FlyoutContent(color: Colors.red, child: const Text('Colored')),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FlyoutContent),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as ShapeDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('applies custom shape', (tester) async {
      final shape = ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      );
      await tester.pumpWidget(
        wrapApp(
          child: FlyoutContent(shape: shape, child: const Text('Shaped')),
        ),
      );
      final acrylic = tester.widget<Acrylic>(find.byType(Acrylic));
      expect(acrylic.shape, shape);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutContent(
            padding: EdgeInsetsDirectional.all(30),
            child: Text('Padded'),
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FlyoutContent),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, const EdgeInsetsDirectional.all(30));
    });

    testWidgets('applies custom constraints', (tester) async {
      const constraints = BoxConstraints(minWidth: 200, minHeight: 50);
      await tester.pumpWidget(
        wrapApp(
          child: const FlyoutContent(
            constraints: constraints,
            child: Text('Constrained'),
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FlyoutContent),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints, constraints);
    });
  });
}
