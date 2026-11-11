@Tags(<String>['golden'])
library;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart' show debugDisableShadows;

void main() {
  setUp(() => debugDisableShadows = false);

  for (final brightness in Brightness.values) {
    final name = brightness.name;
    final theme = FluentThemeData(brightness: brightness);
    testWidgets('$name Flyout materials', (tester) async {
      const flyout = FlyoutContent(child: SizedBox.expand());
      await tester.pumpWidget(
        FluentApp(
          theme: theme,
          home: Center(
            child: RepaintBoundary(
              key: _acrylicKey,
              child: SizedBox(
                width: 720,
                height: 540,
                child: Wrap(
                  children: [
                    const _FlyoutSample(backdrop: Colors.white, child: flyout),
                    const _FlyoutSample(backdrop: Colors.black, child: flyout),
                    const _FlyoutSample(child: flyout),
                    const _FlyoutSample(child: DisableAcrylic(child: flyout)),
                    _FlyoutSample(
                      child: FluentTheme(
                        data: theme.copyWith(
                          acrylicBackgroundColor: const Color(0xFF0078D4),
                          acrylicTintOpacity: 0.4,
                          acrylicLuminosityOpacity: 0.75,
                        ),
                        child: flyout,
                      ),
                    ),
                    _FlyoutSample(
                      child: FlyoutContent(
                        color: const Color(0x4080C080),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const _FlyoutSample(
                      child: FlyoutContent(
                        useAcrylic: false,
                        child: Text('Solid fallback'),
                      ),
                    ),
                    const _FlyoutSample(
                      child: Acrylic(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: Color(0x80808080)),
                        ),
                        luminosityAlpha: 0.85,
                        child: SizedBox.expand(),
                      ),
                    ),
                    const _FlyoutSample(
                      backdrop: Colors.white,
                      child: DisableAcrylic(child: flyout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _expectGolden(tester, find.byKey(_acrylicKey), 'flyouts_$name.png');
    });

    for (final menu in [false, true]) {
      final kind = menu ? 'menu' : 'commandbar';
      testWidgets('$name $kind material', (tester) async {
        final controller = FlyoutController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          FluentApp(
            theme: theme,
            home: RepaintBoundary(
              key: _acrylicKey,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.black, Color(0xFF0078D4)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: SizedBox(
                      width: 320,
                      child: menu
                          ? FlyoutTarget(
                              controller: controller,
                              child: const Text('Menu target'),
                            )
                          : CommandBar(
                              primaryItems: const [],
                              secondaryItems: [
                                CommandBarButton(
                                  label: const Text('Copy'),
                                  onPressed: () {},
                                ),
                                const CommandBarButton(
                                  label: Text('Paste'),
                                  onPressed: null,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        if (menu) {
          controller.showFlyout<void>(
            builder: (context) => MenuFlyout(
              items: [
                MenuFlyoutItem(text: const Text('Copy'), onPressed: () {}),
                MenuFlyoutItem(text: const Text('Paste'), onPressed: null),
              ],
            ),
          );
        } else {
          await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.more));
        }
        await tester.pumpAndSettle();
        // The overflow lives in the app Overlay, outside the home's boundary.
        await _expectGolden(
          tester,
          find.byType(FluentApp),
          '${kind}_$name.png',
        );
      });
    }
  }
  testWidgets('light default Acrylic', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.light());
    await _expectGolden(tester, find.byKey(_acrylicKey), 'light_default.png');
  });

  testWidgets('dark default Acrylic', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.dark());
    await _expectGolden(tester, find.byKey(_acrylicKey), 'dark_default.png');
  });

  testWidgets('colored backdrop through Acrylic', (tester) async {
    await _pumpAcrylic(
      tester,
      theme: FluentThemeData.light(),
      tint: Colors.blue,
      tintAlpha: 0.8,
    );
    await _expectGolden(
      tester,
      find.byKey(_acrylicKey),
      'colored_backdrop.png',
    );
  });

  testWidgets('high contrast content through Acrylic', (tester) async {
    await _pumpAcrylic(
      tester,
      theme: FluentThemeData.dark(),
      backdrop: const Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.white),
          Align(
            child: Text(
              'black and white',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
        ],
      ),
    );
    await _expectGolden(tester, find.byKey(_acrylicKey), 'high_contrast.png');
  });

  testWidgets('disabled Acrylic fallback', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.dark(), disabled: true);
    await _expectGolden(
      tester,
      find.byKey(_acrylicKey),
      'disabled_fallback.png',
    );
  });
}

Future<void> _expectGolden(
  WidgetTester tester,
  Finder finder,
  String filename,
) async {
  try {
    // Asset decoding is real async work: pumpAndSettle alone can finish before
    // the noise texture loads, making captures depend on test order and timing.
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/AcrylicNoise.png', package: 'fluent_ui'),
        tester.element(finder),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(finder, matchesGoldenFile('goldens/acrylic/$filename'));
  } finally {
    debugDisableShadows = true;
  }
}

class _FlyoutSample extends StatelessWidget {
  const _FlyoutSample({required this.child, this.backdrop});

  final Widget child;
  final Color? backdrop;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    height: 180,
    child: Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: backdrop,
            gradient: backdrop == null
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFF0078D4),
                      Color(0xFFFFFF00),
                    ],
                  )
                : null,
          ),
        ),
        Padding(padding: const EdgeInsets.all(20), child: child),
      ],
    ),
  );
}

const _acrylicKey = ValueKey('acrylic-golden');

Future<void> _pumpAcrylic(
  WidgetTester tester, {
  required FluentThemeData theme,
  Color? tint,
  double? tintAlpha,
  Widget? backdrop,
  bool disabled = false,
}) async {
  final material = Acrylic(
    tint: tint,
    tintAlpha: tintAlpha,
    child: const SizedBox.expand(),
  );

  await tester.pumpWidget(
    FluentApp(
      theme: theme,
      home: Center(
        child: RepaintBoundary(
          key: _acrylicKey,
          child: SizedBox(
            width: 240,
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                backdrop ??
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.blue, Colors.yellow],
                        ),
                      ),
                    ),
                Positioned.fill(
                  child: disabled ? DisableAcrylic(child: material) : material,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
