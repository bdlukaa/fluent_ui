import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('DropdownButton leading is shown correctly', (tester) async {
    await tester.pumpWidget(wrapApp(
      child: DropDownButton(
        items: [
          MenuFlyoutItem(text: const Text('one'), onPressed: () {}),
          MenuFlyoutItem(text: const Text('two'), onPressed: () {}),
        ],
        leading: const Icon(FluentIcons.number),
        title: const Text('Numbers'),
      ),
    ));

    expect(find.byIcon(FluentIcons.number), findsOneWidget);
  });

  testWidgets(
    'DropdownButton flyout should be displayed above if not enough space',
    (tester) async {
      const screenSize = Size(600, 600);
      await tester.pumpWidget(SizedBox.fromSize(
        size: screenSize,
        child: wrapApp(
          child: Column(children: [
            const Spacer(),
            DropDownButton(
              items: [
                MenuFlyoutItem(text: const Text('one'), onPressed: () {}),
                MenuFlyoutItem(text: const Text('two'), onPressed: () {}),
              ],
              leading: const Icon(FluentIcons.number),
              title: const Text('Numbers'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Numbers'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MenuFlyout), findsOneWidget);
      expect(
        tester.getBottomRight(find.byType(MenuFlyout)).dy >
            screenSize.height / 2,
        true,
      );
    },
  );
}
