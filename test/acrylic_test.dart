import 'package:fluent_ui/fluent_ui.dart';

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

    testWidgets('disabled Acrylic is an opaque fallback without filtering', (
      tester,
    ) async {
      await tester.pumpWidget(
        FluentApp(
          home: DisableAcrylic(
            child: Acrylic(
              fallbackColor: Colors.green,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);

      expect(find.byType(ClipPath), findsOneWidget);
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
