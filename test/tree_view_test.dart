import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
      'TreeView calculates the selected property for parent as soon as it is built',
      (WidgetTester tester) async {
    final itemOne = TreeViewItem(
      content: const Text('Item 1'),
      selected: true,
    );
    final items = [
      TreeViewItem(
        content: const Text('Parent item'),
        children: [
          itemOne,
          TreeViewItem(
            content: const Text('Item 1'),
          ),
          TreeViewItem(
            content: const Text('Item 1'),
          ),
        ],
      ),
    ];

    await tester.pumpWidget(wrapApp(child: TreeView(items: items)));

    expect(itemOne.parent, isNotNull);
    expect(itemOne.parent?.selected, null);
  });
}
