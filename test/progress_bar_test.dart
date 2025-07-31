import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('ProgressBar exposes correct semantics', (tester) async {
    await tester.pumpWidget(
      wrapApp(child: const ProgressBar(value: 66, semanticLabel: 'Loading')),
    );

    final semantics = tester
        .getSemantics(find.bySemanticsLabel('Loading'))
        .getSemanticsData();
    expect(semantics.label, 'Loading');
    expect(semantics.value, '66.00');
  });
}
