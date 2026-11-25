import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
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
    for (final brightness in Brightness.values) {
      for (final disabled in [false, true]) {
        testWidgets('${brightness.name} transient recipe, disabled=$disabled', (
          tester,
        ) async {
          final theme = FluentThemeData(
            brightness: brightness,
            acrylicBackgroundColor: const Color(0xFF336699),
            acrylicTintOpacity: 0.3,
            acrylicLuminosityOpacity: 0.7,
            acrylicFallbackColor: const Color(0xFF445566),
          );
          AcrylicProperties? properties;
          final surface = FlyoutContent(
            child: Builder(
              builder: (context) {
                properties = AcrylicProperties.of(context);
                return const Text('Custom theme');
              },
            ),
          );
          await tester.pumpWidget(
            FluentApp(
              theme: theme,
              home: Center(
                child: disabled ? DisableAcrylic(child: surface) : surface,
              ),
            ),
          );
          expect(properties?.tint, theme.acrylicBackgroundColor);
          expect(properties?.tintAlpha, theme.acrylicTintOpacity);
          expect(properties?.luminosityAlpha, theme.acrylicLuminosityOpacity);
          expect(properties?.fallbackColor, theme.acrylicFallbackColor);
          expect(
            find.byType(BackdropFilter),
            disabled ? findsNothing : findsOneWidget,
          );
          expect(find.byType(Image), findsNothing);
          final container = tester.widget<Container>(
            find.descendant(
              of: find.byType(FlyoutContent),
              matching: find.byType(Container),
            ),
          );
          expect(container.color, isNull);
          expect(
            container.decoration,
            isNull,
            reason: 'No extra tint or second shape border.',
          );
          final physical = tester.widget<PhysicalModel>(
            find.byType(PhysicalModel),
          );
          expect(physical.elevation, 8);
        });
      }
    }
    testWidgets('light material suppresses backdrop brightness without hiding it', (
      tester,
    ) async {
      const key = ValueKey('surface-pixels');
      await tester.pumpWidget(
        FluentApp(
          theme: FluentThemeData.light(),
          home: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 400,
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: ColoredBox(color: Colors.black)),
                        Expanded(child: ColoredBox(color: Colors.white)),
                      ],
                    ),
                    const Positioned.fill(
                      child: FlyoutContent(
                        elevation: 0,
                        child: SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final image = (await tester.runAsync(() => boundary.toImage()))!;
      final bytes = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      double meanRed(int x) {
        var total = 0;
        for (var y = 50; y < 110; y++) {
          for (var dx = 0; dx < 20; dx++) {
            total += bytes.getUint8((y * image.width + x + dx) * 4);
          }
        }
        return total / 1200;
      }

      final overBlack = meanRed(40);
      final overWhite = meanRed(340);
      image.dispose();
      expect(
        overBlack,
        greaterThan(210),
        reason:
            'The explicit transient luminosity must suppress dark content and shadows.',
      );
      expect(
        overWhite - overBlack,
        inExclusiveRange(5, 45),
        reason:
            'Retain subtle translucency, not the old muddy high-contrast surface.',
      );
    });
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
      expect(container.color, Colors.red);
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
      expect(
        container.padding,
        const EdgeInsetsDirectional.all(30).add(const EdgeInsets.all(1)),
      );
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
