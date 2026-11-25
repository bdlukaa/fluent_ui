import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AcrylicHelper.getTintOpacityModifier', () {
    test('matches WinUI suppression for primary colors and neutrals', () {
      expect(
        AcrylicHelper.getTintOpacityModifier(Colors.white),
        closeTo(0.45, 1e-6),
      );
      expect(
        AcrylicHelper.getTintOpacityModifier(Colors.black),
        closeTo(0.85, 1e-6),
      );
      expect(
        AcrylicHelper.getTintOpacityModifier(const Color(0xFF808080)),
        closeTo(0.8982, 0.001),
      );
      expect(
        AcrylicHelper.getTintOpacityModifier(Colors.red),
        closeTo(0.9, 1e-6),
      );
      expect(
        AcrylicHelper.getTintOpacityModifier(Colors.blue),
        closeTo(0.9, 1e-6),
      );
    });

    test('uses absolute HSV value deviation for intermediate neutrals', () {
      expect(
        AcrylicHelper.getTintOpacityModifier(const Color(0xFF404040)),
        closeTo(0.875, 0.002),
      );
      expect(
        AcrylicHelper.getTintOpacityModifier(const Color(0xFFBFBFBF)),
        closeTo(0.676, 0.002),
      );
    });
  });

  group('AcrylicHelper tint and luminosity', () {
    test('includes tint opacity and only modifies automatic tint opacity', () {
      final automatic = AcrylicHelper.getEffectiveTintColor(Colors.white, 0.5);
      final explicit = AcrylicHelper.getEffectiveTintColor(
        Colors.white,
        0.5,
        luminosityOpacity: 0.8,
      );

      expect(automatic.a, closeTo(0.225, 1e-6));
      expect(explicit.a, closeTo(0.5, 1e-6));
    });

    test('derives automatic luminosity from the original tint opacity', () {
      final color = AcrylicHelper.getLuminosityColor(
        const Color(0xFF808080),
        null,
        0.5,
      );

      expect(color.r, closeTo(0.502, 0.002));
      expect(color.g, closeTo(0.502, 0.002));
      expect(color.b, closeTo(0.502, 0.002));
      expect(color.a, closeTo(0.59, 0.003));
    });

    test('explicit luminosity opacity overrides automatic calculation', () {
      final color = AcrylicHelper.getLuminosityColor(
        const Color(0xFFFF0000),
        0.25,
        0.5,
      );

      expect(color.r, closeTo(1, 1e-6));
      expect(color.g, closeTo(0, 1e-6));
      expect(color.b, closeTo(0, 1e-6));
      expect(color.a, closeTo(0.25, 1e-6));
    });

    test('clamps tint and luminosity alpha values', () {
      final tint = AcrylicHelper.getEffectiveTintColor(
        Colors.white,
        2,
        luminosityOpacity: 2,
      );
      final luminosity = AcrylicHelper.getLuminosityColor(Colors.white, -1, 2);

      expect(tint.a, closeTo(1, 1e-6));
      expect(luminosity.a, closeTo(0, 1e-6));
    });
  });

  group('Acrylic widget', () {
    testWidgets('blend stages sample the backdrop across repaint boundaries', (
      tester,
    ) async {
      const key = ValueKey('composition');
      const acrylic = Acrylic(
        tint: Color(0xFF808080),
        tintAlpha: 0.2,
        luminosityAlpha: 0.85,
        blurAmount: 0,
        child: SizedBox.expand(),
      );
      await tester.pumpWidget(
        const FluentApp(
          home: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 320,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: Color(0xFFFF0000)),
                    Row(
                      children: [
                        Expanded(child: acrylic),
                        Expanded(child: RepaintBoundary(child: acrylic)),
                      ],
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
      final image = (await tester.runAsync(boundary.toImage))!;
      final bytes = (await tester.runAsync(image.toByteData))!;
      final left = (60 * image.width + 80) * 4;
      final right = (60 * image.width + 240) * 4;
      expect(bytes.getUint8(left), closeTo(228, 3));
      expect(bytes.getUint8(left + 1), closeTo(74, 3));
      for (var channel = 0; channel < 3; channel++) {
        expect(
          bytes.getUint8(right + channel),
          closeTo(bytes.getUint8(left + channel), 2),
          reason:
              'Material blend operations must not target a transparent intermediate canvas.',
        );
      }
      image.dispose();
    });
    testWidgets(
      'keeps automatic luminosity and resolves native theme resources',
      (tester) async {
        AcrylicProperties? properties;
        await tester.pumpWidget(
          FluentApp(
            home: Acrylic(
              child: Builder(
                builder: (context) {
                  properties = AcrylicProperties.of(context);
                  return const SizedBox(width: 80, height: 40);
                },
              ),
            ),
          ),
        );

        expect(properties?.luminosityAlpha, isNull);
        expect(properties?.tint, const Color(0xFFFCFCFC));
        expect(properties?.tintAlpha, 0.0);
        expect(properties?.fallbackColor, const Color(0xFFF9F9F9));
        expect(find.byType(BackdropFilter), findsOneWidget);
      },
    );

    testWidgets(
      'only fully opaque effective tint skips filtering and retains noise',
      (tester) async {
        Future<void> check({
          required Color tint,
          required double? luminosityAlpha,
          required bool opaque,
          double tintAlpha = 1,
        }) async {
          await tester.pumpWidget(
            FluentApp(
              home: Center(
                child: Acrylic(
                  tint: tint,
                  tintAlpha: tintAlpha,
                  luminosityAlpha: luminosityAlpha,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const SizedBox(
                    width: 80,
                    height: 40,
                    child: Text('content'),
                  ),
                ),
              ),
            ),
          );
          final surface = find.byType(Acrylic);
          expect(
            find.descendant(of: surface, matching: find.byType(BackdropFilter)),
            opaque ? findsNothing : findsOneWidget,
          );
          final noise = tester.widget<Opacity>(
            find.descendant(of: surface, matching: find.byType(Opacity)),
          );
          expect(noise.opacity, 0.02);
          expect(find.text('content'), findsOneWidget);
          expect(
            find.descendant(of: surface, matching: find.byType(ClipPath)),
            findsOneWidget,
          );
          if (opaque) {
            final fill = tester.widget<ColoredBox>(
              find.descendant(of: surface, matching: find.byType(ColoredBox)),
            );
            expect(fill.color, tint);
          }
        }

        await check(tint: Colors.white, luminosityAlpha: 0.85, opaque: true);
        // tintAlpha == 1 is not enough: automatic white tint is suppressed to 0.45.
        await check(tint: Colors.white, luminosityAlpha: null, opaque: false);
        await check(
          tint: Colors.white.withValues(alpha: 0.5),
          luminosityAlpha: 0.85,
          opaque: false,
        );
        await check(
          tint: const Color(0xFF0078D4),
          luminosityAlpha: 0.85,
          opaque: true,
        );
        await check(
          tint: const Color(0xFF0078D4),
          tintAlpha: 0.9,
          luminosityAlpha: 0.85,
          opaque: false,
        );
      },
    );

    testWidgets('disabled Acrylic is an opaque fallback without filtering', (
      tester,
    ) async {
      await tester.pumpWidget(
        FluentApp(
          home: DisableAcrylic(
            child: Acrylic(
              fallbackColor: Colors.green.withValues(alpha: 0.2),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);

      expect(find.byType(ClipPath), findsOneWidget);
      final fallback = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ClipPath),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (fallback.decoration as BoxDecoration).color,
        Colors.green.withValues(alpha: 1),
      );
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('explicit brush parameters override custom theme resources', (
      tester,
    ) async {
      AcrylicProperties? properties;
      await tester.pumpWidget(
        FluentApp(
          theme: FluentThemeData(
            acrylicTintOpacity: 0.7,
            acrylicLuminosityOpacity: 0.9,
          ),
          home: Acrylic(
            tint: const Color(0xFF123456),
            tintAlpha: 0.4,
            luminosityAlpha: 0.6,
            fallbackColor: const Color(0xFF654321),
            child: Builder(
              builder: (context) {
                properties = AcrylicProperties.of(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      expect(properties?.tint, const Color(0xFF123456));
      expect(properties?.tintAlpha, 0.4);
      expect(properties?.luminosityAlpha, 0.6);
      expect(properties?.fallbackColor, const Color(0xFF654321));
    });

    testWidgets('theme changes update Acrylic resources', (tester) async {
      Color? fallbackColor;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FluentTheme(
            data: FluentThemeData.light(),
            child: Acrylic(
              child: Builder(
                builder: (context) {
                  fallbackColor = AcrylicProperties.of(context).fallbackColor;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(fallbackColor, const Color(0xFFF9F9F9));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FluentTheme(
            data: FluentThemeData.dark(),
            child: Acrylic(
              child: Builder(
                builder: (context) {
                  fallbackColor = AcrylicProperties.of(context).fallbackColor;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(fallbackColor, const Color(0xFF2C2C2C));
    });

    testWidgets('AnimatedAcrylic retains a child above its material', (
      tester,
    ) async {
      await tester.pumpWidget(
        const FluentApp(
          home: AnimatedAcrylic(
            duration: Duration(milliseconds: 100),
            tintAlpha: 0,
            child: Text('content above acrylic'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('content above acrylic'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
