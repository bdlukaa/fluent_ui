import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('FluentTextSelectionToolbar renders non-standard button types', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        child: WindowsTextSelectionToolbar(
          buttonItems: [
            ContextMenuButtonItem(
              type: ContextMenuButtonType.lookUp,
              label: 'Lookup',
              onPressed: () {},
            ),
            ContextMenuButtonItem(
              type: ContextMenuButtonType.share,
              label: 'Share',
              onPressed: () {},
            ),
          ],
          anchors: const TextSelectionToolbarAnchors(
            primaryAnchor: Offset(100, 100),
            secondaryAnchor: Offset(100, 100),
          ),
        ),
      ),
    );

    expect(find.text('Lookup'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}
