import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('FlyoutListTile can be used outside of a Flyout', (tester) async {
    await tester.pumpWidget(
      wrapApp(
        child: const FlyoutListTile(text: Text('Copy')),
      ),
    );
  });
}
