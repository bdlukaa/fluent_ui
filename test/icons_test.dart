import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Icons specify FluentIcons font', (tester) async {
    await tester.pumpWidget(
      FluentApp(home: NavigationView(pane: NavigationPane())),
    );

    expect(FluentIcons.clear.fontFamily, 'FluentIcons');
    expect(FluentIcons.search.fontFamily, 'FluentIcons');
  });
}
