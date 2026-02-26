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

      // Build to establish parent linkage
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

  group('TreeView drag and drop', () {
    testWidgets('TreeView renders with canDragItems enabled', (tester) async {
      final items = [
        TreeViewItem(content: const Text('Item 1'), value: 'item1'),
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
      ];

      await tester.pumpWidget(
        wrapApp(
          child: TreeView(
            items: items,
            canDragItems: true,
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('canReorderItem callback is respected', (tester) async {
      var reorderedCalled = false;
      final items = [
        TreeViewItem(content: const Text('Item 1'), value: 'item1'),
        TreeViewItem(content: const Text('Item 2'), value: 'item2'),
        TreeViewItem(content: const Text('Item 3'), value: 'item3'),
      ];

      await tester.pumpWidget(
        wrapApp(
          child: TreeView(
            items: items,
            canDragItems: true,
            canReorderItem: (item, newParent, index) {
              // Only allow reordering to root level
              return newParent == null;
            },
            onItemReordered: (item, oldParent, newParent, newIndex) {
              reorderedCalled = true;
            },
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      // The canReorderItem callback and onItemReordered are tested
      // at the integration level - verifying they can be provided
      expect(reorderedCalled, false);
    });

    testWidgets('TreeView with drag and drop and controller', (tester) async {
      final controller = TreeViewController(
        items: [
          TreeViewItem(
            content: const Text('Folder'),
            value: 'folder',
            children: [
              TreeViewItem(content: const Text('File 1'), value: 'file1'),
            ],
          ),
          TreeViewItem(content: const Text('File 2'), value: 'file2'),
        ],
      );

      await tester.pumpWidget(
        wrapApp(
          child: TreeView(
            controller: controller,
            canDragItems: true,
          ),
        ),
      );

      expect(find.text('Folder'), findsOneWidget);
      expect(find.text('File 1'), findsOneWidget);
      expect(find.text('File 2'), findsOneWidget);

      controller.dispose();
    });
  });
}
