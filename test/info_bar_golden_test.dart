@Tags(<String>['golden'])
library;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light InfoBars', (tester) async {
    await _pumpInfoBars(tester, FluentThemeData.light());

    await expectLater(
      find.byKey(_infoBarsKey),
      matchesGoldenFile('goldens/info_bar/light.png'),
    );
  });

  testWidgets('dark InfoBars', (tester) async {
    await _pumpInfoBars(tester, FluentThemeData.dark());

    await expectLater(
      find.byKey(_infoBarsKey),
      matchesGoldenFile('goldens/info_bar/dark.png'),
    );
  });
}

const _infoBarsKey = ValueKey('info-bars-golden');

Future<void> _pumpInfoBars(WidgetTester tester, FluentThemeData theme) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.noScaling),
      child: FluentApp(
        theme: theme,
        home: const Center(
          child: RepaintBoundary(
            key: _infoBarsKey,
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  InfoBar.info(
                    title: Text('Information'),
                    content: Text('An informational message.'),
                  ),
                  InfoBar.warning(
                    title: Text('Warning'),
                    content: Text('A warning message.'),
                  ),
                  InfoBar.success(
                    title: Text('Success'),
                    content: Text('A success message.'),
                  ),
                  InfoBar.error(
                    title: Text('Error'),
                    content: Text('An error message.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
