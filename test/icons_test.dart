import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('Icons specify FluentIcons font', (tester) async {
    await tester.pumpWidget(wrapApp(child: const Icon(FluentIcons.clear)));

    expect(FluentIcons.clear.fontFamily, 'FluentIcons');
    expect(FluentIcons.search.fontFamily, 'FluentIcons');
  });
}
