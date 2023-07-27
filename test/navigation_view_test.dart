import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'NavigationAppBar takes viewPadding into consideration',
    (WidgetTester tester) async {
      final navigationViewKey = GlobalKey();
      await tester.pumpWidget(FluentApp(
        builder: (context, child) {
          return MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(top: 27.0)),
            child: child!,
          );
        },
        home: NavigationView(
          key: navigationViewKey,
          pane: NavigationPane(),
        ),
      ));

      const appBar = NavigationAppBar();
      expect(
        appBar.finalHeight(navigationViewKey.currentContext!),
        // _kDefaultAppBarHeight
        50 + 27,
      );
    },
  );
}
