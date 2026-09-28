import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light default Acrylic', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.light());
    await expectLater(
      find.byKey(_acrylicKey),
      matchesGoldenFile('goldens/acrylic/light_default.png'),
    );
  });

  testWidgets('dark default Acrylic', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.dark());
    await expectLater(
      find.byKey(_acrylicKey),
      matchesGoldenFile('goldens/acrylic/dark_default.png'),
    );
  });

  testWidgets('colored backdrop through Acrylic', (tester) async {
    await _pumpAcrylic(
      tester,
      theme: FluentThemeData.light(),
      tint: Colors.blue,
      tintAlpha: 0.8,
    );
    await expectLater(
      find.byKey(_acrylicKey),
      matchesGoldenFile('goldens/acrylic/colored_backdrop.png'),
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
    await expectLater(
      find.byKey(_acrylicKey),
      matchesGoldenFile('goldens/acrylic/high_contrast.png'),
    );
  });

  testWidgets('disabled Acrylic fallback', (tester) async {
    await _pumpAcrylic(tester, theme: FluentThemeData.dark(), disabled: true);
    await expectLater(
      find.byKey(_acrylicKey),
      matchesGoldenFile('goldens/acrylic/disabled_fallback.png'),
    );
  });
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
    child: const Center(child: Text('Acrylic', style: TextStyle(fontSize: 20))),
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
