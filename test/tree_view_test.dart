import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart';

void main() {
  testWidgets(
    'TreeView calculates the selected property for parent as soon as it is built',
    (tester) async {
      final itemOne = TreeViewItem(
        content: const Text('Item 1'),
        selected: true,
      );
      final items = [
        TreeViewItem(
          content: const Text('Parent item'),
          children: [
            itemOne,
            TreeViewItem(content: const Text('Item 1')),
            TreeViewItem(content: const Text('Item 1')),
          ],
        ),
      ];

      await tester.pumpWidget(wrapApp(child: TreeView(items: items)));

      expect(itemOne.parent, isNotNull);
      expect(itemOne.parent, items[0]);
      expect(itemOne.parent?.selected, null);
    },
  );

  testWidgets('TreeViewItem deep copy rebuilds parent linkage', (tester) async {
    final items = [
      TreeViewItem(
        content: const Text('Parent item'),
        children: [
          TreeViewItem(
            content: const Text('Item 1'),
            children: [
              TreeViewItem(content: const Text('Subitem 1')),
              TreeViewItem(content: const Text('Subitem 2')),
            ],
          ),
          TreeViewItem(content: const Text('Item 2')),
          TreeViewItem(content: const Text('Item 3')),
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
      itemsCopy[0].children[0].children[0].parent,
      itemsCopy[0].children[0],
    );
    expect(
      itemsCopy[0].children[0].children[1].parent,
      itemsCopy[0].children[0],
    );
  });

  group('TreeViewController', () {
    test('controller initializes with items', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(content: const Text('Item 1'), value: 'item1'),
          TreeViewItem(content: const Text('Item 2'), value: 'item2'),
        ],
      );

      expect(controller.items.length, 2);
      expect(controller.isAttached, false);

      controller.dispose();
    });

    test('controller initializes with empty items by default', () {
      final controller = TreeViewController();
      expect(controller.items.length, 0);
      controller.dispose();
    });

    test('getItemFromValue finds items', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(
            content: const Text('Parent'),
            value: 'parent',
            children: [
              TreeViewItem(content: const Text('Child'), value: 'child'),
            ],
          ),
        ],
      );

      expect(controller.getItemFromValue('parent'), isNotNull);
      expect(controller.getItemFromValue('child'), isNotNull);
      expect(controller.getItemFromValue('nonexistent'), isNull);

      controller.dispose();
    });

    test('addItem adds items at root and as children', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(content: const Text('Item 1'), value: 'item1'),
        ],
      );

      controller.addItem(
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
      );
      expect(controller.items.length, 2);

      final parent = controller.items.first;
      controller.addItem(
        TreeViewItem(content: const Text('Child'), value: 'child'),
        parent: parent,
      );
      expect(parent.children.length, 1);

      controller.dispose();
    });

    test('addItem inserts at index', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(content: const Text('Item 1'), value: 'item1'),
          TreeViewItem(content: const Text('Item 3'), value: 'item3'),
        ],
      );

      controller.addItem(
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
        index: 1,
      );
      expect(controller.items.length, 3);
      expect(controller.items[1].value, 'item2');

      controller.dispose();
    });

    test('removeItem removes items', () {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final parent = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [child],
      );
      final controller = TreeViewController(items: [parent]);

      // build() sets the parent reference on each item, which is needed
      // for removeItem to find and remove the item from its parent's children.
      controller.items.build();

      expect(controller.removeItem(child), true);
      expect(parent.children.length, 0);

      expect(controller.removeItem(parent), true);
      expect(controller.items.length, 0);

      controller.dispose();
    });

    test('expandAll and collapseAll work', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(
            content: const Text('Parent'),
            value: 'parent',
            expanded: false,
            children: [
              TreeViewItem(
                content: const Text('Child'),
                value: 'child',
                expanded: false,
                children: [
                  TreeViewItem(
                    content: const Text('Grandchild'),
                    value: 'grandchild',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      controller.expandAll();
      expect(controller.items[0].expanded, true);
      expect(controller.items[0].children[0].expanded, true);

      controller.collapseAll();
      expect(controller.items[0].expanded, false);
      expect(controller.items[0].children[0].expanded, false);

      controller.dispose();
    });

    test('expandItem and collapseItem work', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        expanded: false,
        children: [
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ],
      );
      final controller = TreeViewController(items: [item]);

      controller.expandItem(item);
      expect(item.expanded, true);

      controller.collapseItem(item);
      expect(item.expanded, false);

      controller.dispose();
    });

    test('selectItem and deselectItem work', () {
      final item = TreeViewItem(
        content: const Text('Item'),
        value: 'item',
        selected: false,
      );
      final controller = TreeViewController(items: [item]);

      controller.selectItem(item);
      expect(item.selected, true);

      controller.deselectItem(item);
      expect(item.selected, false);

      controller.dispose();
    });

    test('selectAll and deselectAll work', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(
            content: const Text('Item 1'),
            value: 'item1',
            selected: false,
          ),
          TreeViewItem(
            content: const Text('Item 2'),
            value: 'item2',
            selected: false,
            children: [
              TreeViewItem(
                content: const Text('Child'),
                value: 'child',
                selected: false,
              ),
            ],
          ),
        ],
      );

      controller.selectAll();
      expect(controller.items[0].selected, true);
      expect(controller.items[1].selected, true);
      expect(controller.items[1].children[0].selected, true);

      controller.deselectAll();
      expect(controller.items[0].selected, false);
      expect(controller.items[1].selected, false);
      expect(controller.items[1].children[0].selected, false);

      controller.dispose();
    });

    test('controller notifies listeners on changes', () {
      final controller = TreeViewController(
        items: [
          TreeViewItem(content: const Text('Item'), value: 'item'),
        ],
      );

      var notified = false;
      controller.addListener(() => notified = true);

      controller.expandAll();
      expect(notified, true);

      controller.dispose();
    });

    testWidgets('TreeView works with controller', (tester) async {
      final controller = TreeViewController(
        items: [
          TreeViewItem(
            content: const Text('Parent'),
            value: 'parent',
            children: [
              TreeViewItem(content: const Text('Child 1'), value: 'child1'),
              TreeViewItem(content: const Text('Child 2'), value: 'child2'),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        wrapApp(child: TreeView(controller: controller)),
      );

      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);

      controller.dispose();
    });

    testWidgets(
      'TreeView with controller rebuilds when items change',
      (tester) async {
        final controller = TreeViewController(
          items: [
            TreeViewItem(content: const Text('Item 1'), value: 'item1'),
          ],
        );

        await tester.pumpWidget(
          wrapApp(child: TreeView(controller: controller)),
        );

        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsNothing);

        controller.addItem(
          TreeViewItem(content: const Text('Item 2'), value: 'item2'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);

        controller.dispose();
      },
    );

    testWidgets(
      'TreeView with controller collapses items programmatically',
      (tester) async {
        final parent = TreeViewItem(
          content: const Text('Parent'),
          value: 'parent',
          expanded: true,
          children: [
            TreeViewItem(content: const Text('Child'), value: 'child'),
          ],
        );
        final controller = TreeViewController(items: [parent]);

        await tester.pumpWidget(
          wrapApp(child: TreeView(controller: controller)),
        );

        expect(find.text('Child'), findsOneWidget);

        controller.collapseItem(parent);
        await tester.pumpAndSettle();

        expect(find.text('Child'), findsNothing);

        controller.dispose();
      },
    );
  });

  group('TreeView drag and drop via controller', () {
    test('moveItem moves item to root level', () {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final parent = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [child],
      );
      final controller = TreeViewController(items: [parent]);

      // build() sets the parent reference on each item, which is needed
      // for moveItem to find and remove the item from its parent's children.
      controller.items.build();

      expect(controller.moveItem(child), true);
      expect(parent.children.length, 0);
      expect(controller.items.length, 2);
      expect(controller.items[1].value, 'child');

      controller.dispose();
    });

    test('moveItem moves item to a new parent', () {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final parentA = TreeViewItem(
        content: const Text('Parent A'),
        value: 'parent_a',
        children: [child],
      );
      final parentB = TreeViewItem(
        content: const Text('Parent B'),
        value: 'parent_b',
        children: [],
      );
      final controller = TreeViewController(items: [parentA, parentB]);

      // build() sets the parent reference on each item, which is needed
      // for moveItem to find and remove the item from its parent's children.
      controller.items.build();

      expect(controller.moveItem(child, newParent: parentB), true);
      expect(parentA.children.length, 0);
      expect(parentB.children.length, 1);
      expect(parentB.children.first.value, 'child');

      controller.dispose();
    });

    test('moveItem moves item to specific index', () {
      final item1 = TreeViewItem(
        content: const Text('Item 1'),
        value: 'item1',
      );
      final item2 = TreeViewItem(
        content: const Text('Item 2'),
        value: 'item2',
      );
      final item3 = TreeViewItem(
        content: const Text('Item 3'),
        value: 'item3',
      );
      final controller = TreeViewController(items: [item1, item2, item3]);

      // Move item3 to index 0
      expect(controller.moveItem(item3, index: 0), true);
      expect(controller.items[0].value, 'item3');
      expect(controller.items[1].value, 'item1');
      expect(controller.items[2].value, 'item2');

      controller.dispose();
    });

    testWidgets('TreeView with controller moveItem updates UI',
        (tester) async {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final parent = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        expanded: true,
        children: [child],
      );
      final controller = TreeViewController(items: [parent]);

      await tester.pumpWidget(
        wrapApp(child: TreeView(controller: controller)),
      );

      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);

      // Move child to root level
      controller.moveItem(child);
      await tester.pumpAndSettle();

      // Both should still be visible, but Child is now at root level
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
      expect(controller.items.length, 2);

      controller.dispose();
    });
  });

  group('TreeViewItem.children is unmodifiable', () {
    test('children list throws on add', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [],
      );

      expect(
        () => item.children.add(
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ),
        throwsUnsupportedError,
      );
    });

    test('children list throws on addAll', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [],
      );

      expect(
        () => item.children.addAll([
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ]),
        throwsUnsupportedError,
      );
    });

    test('children list throws on remove', () {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [child],
      );

      expect(() => item.children.remove(child), throwsUnsupportedError);
    });

    test('children list throws on clear', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ],
      );

      expect(() => item.children.clear(), throwsUnsupportedError);
    });

    test('children list throws on insert', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [],
      );

      expect(
        () => item.children.insert(
          0,
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ),
        throwsUnsupportedError,
      );
    });

    test('children list throws on removeAt', () {
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [
          TreeViewItem(content: const Text('Child'), value: 'child'),
        ],
      );

      expect(() => item.children.removeAt(0), throwsUnsupportedError);
    });

    test('children list is readable', () {
      final child = TreeViewItem(
        content: const Text('Child'),
        value: 'child',
      );
      final item = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [child],
      );

      expect(item.children.length, 1);
      expect(item.children.first.value, 'child');
      expect(item.children.isNotEmpty, true);
    });
  });

  group('TreeViewController.addItems', () {
    test('addItems adds multiple items at root', () {
      final controller = TreeViewController();

      controller.addItems([
        TreeViewItem(content: const Text('Item 1'), value: 'item1'),
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
        TreeViewItem(content: const Text('Item 3'), value: 'item3'),
      ]);

      expect(controller.items.length, 3);
      expect(controller.items[0].value, 'item1');
      expect(controller.items[1].value, 'item2');
      expect(controller.items[2].value, 'item3');

      controller.dispose();
    });

    test('addItems adds multiple items as children of parent', () {
      final parent = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        children: [],
      );
      final controller = TreeViewController(items: [parent]);

      controller.addItems(
        [
          TreeViewItem(content: const Text('Child 1'), value: 'child1'),
          TreeViewItem(content: const Text('Child 2'), value: 'child2'),
        ],
        parent: parent,
      );

      expect(parent.children.length, 2);
      expect(parent.children[0].value, 'child1');
      expect(parent.children[1].value, 'child2');

      controller.dispose();
    });

    test('addItems notifies listeners once', () {
      final controller = TreeViewController();

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.addItems([
        TreeViewItem(content: const Text('Item 1'), value: 'item1'),
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
      ]);

      // Only one notification for batch add
      expect(notifyCount, 1);

      controller.dispose();
    });

    testWidgets('TreeView with controller addItems updates UI',
        (tester) async {
      final parent = TreeViewItem(
        content: const Text('Parent'),
        value: 'parent',
        expanded: true,
        children: [],
        lazy: true,
      );
      final controller = TreeViewController(items: [parent]);

      await tester.pumpWidget(
        wrapApp(child: TreeView(controller: controller)),
      );

      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);

      controller.addItems(
        [
          TreeViewItem(content: const Text('Child 1'), value: 'child1'),
          TreeViewItem(content: const Text('Child 2'), value: 'child2'),
        ],
        parent: parent,
      );
      await tester.pumpAndSettle();

      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);

      controller.dispose();
    });
  });
}
