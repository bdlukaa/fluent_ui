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
    expect(itemOne.parent, items[0]);
    expect(itemOne.parent?.selected, null);
  });

  testWidgets('TreeViewItem deep copy rebuilds parent linkage',
      (WidgetTester tester) async {
    final items = [
      TreeViewItem(
        content: const Text('Parent item'),
        children: [
          TreeViewItem(
            content: const Text('Item 1'),
            children: [
              TreeViewItem(
                content: const Text('Subitem 1'),
              ),
              TreeViewItem(
                content: const Text('Subitem 2'),
              ),
            ],
          ),
          TreeViewItem(
            content: const Text('Item 2'),
          ),
          TreeViewItem(
            content: const Text('Item 3'),
          ),
        ],
      ),
    ];

    await tester.pumpWidget(wrapApp(child: TreeView(items: items)));
    expect(items[0].parent, isNull);
    expect(items[0].children[0].parent, items[0]);
    expect(items[0].children[1].parent, items[0]);
    expect(items[0].children[2].parent, items[0]);
    expect(items[0].children[0].children[0].parent, items[0].children[0]);
    expect(items[0].children[0].children[1].parent, items[0].children[0]);

    final itemsCopy = items.map(TreeViewItem.from).toList();
    expect(itemsCopy[0].parent, isNull);
    expect(itemsCopy[0].children[0].parent, itemsCopy[0]);
    expect(itemsCopy[0].children[1].parent, itemsCopy[0]);
    expect(itemsCopy[0].children[2].parent, itemsCopy[0]);
    expect(
        itemsCopy[0].children[0].children[0].parent, itemsCopy[0].children[0]);
    expect(
        itemsCopy[0].children[0].children[1].parent, itemsCopy[0].children[0]);
  });
}
