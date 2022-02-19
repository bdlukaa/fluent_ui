import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets('DropdownButton leading is shown correctly', (tester) async {
    await tester.pumpWidget(wrapApp(
      child: DropDownButton(
        items: [
          DropDownButtonItem(title: const Text('one'), onTap: () {}),
          DropDownButtonItem(title: const Text('two'), onTap: () {}),
        ],
        leading: const Icon(FluentIcons.number),
        title: const Text('Numbers'),
      ),
    ));

    expect(find.byIcon(FluentIcons.number), findsOneWidget);
  });
}
