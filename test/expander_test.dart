import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  final expanderKey = GlobalKey<ExpanderState>();

  testWidgets('Expander intiallyExpanded works properly', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: Expander(
          key: expanderKey,
          initiallyExpanded: true,
          header: const Text('Header'),
          content: const Text('Content'),
        ),
      ),
    );

    expect(expanderKey.currentState!.isExpanded, true);
  });
}
