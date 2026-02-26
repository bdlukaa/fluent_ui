import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> with PageMixin {
  final treeViewKey = GlobalKey<TreeViewState>(debugLabel: 'TreeView key');

  late final TreeViewController _controller;
  late final TreeViewController _lazyController;
  late final TreeViewController _gesturesController;

  @override
  void initState() {
    super.initState();
    _controller = TreeViewController(
      items: [
        TreeViewItem(
          content: const Text('Personal Documents'),
          value: 'personal_docs',
          children: [
            TreeViewItem(
              content: const Text('Home Remodel'),
              value: 'home_remodel',
              children: [
                TreeViewItem(
                  content: const Text('Contractor Contact Info'),
                  value: 'contr_cont_inf',
                ),
                TreeViewItem(
                  content: const Text('Paint Color Scheme'),
                  value: 'paint_color_scheme',
                ),
                TreeViewItem(
                  content: const Text('Flooring woodgrain type'),
                  value: 'flooring_woodgrain_type',
                ),
                TreeViewItem(
                  content: const Text('Kitchen cabinet style'),
                  value: 'kitch_cabinet_style',
                ),
              ],
            ),
            TreeViewItem(
              content: const Text('Tax Documents'),
              value: 'tax_docs',
              children: [
                TreeViewItem(content: const Text('2017'), value: 'tax_2017'),
                TreeViewItem(
                  content: const Text('Middle Years'),
                  value: 'tax_middle_years',
                  children: [
                    TreeViewItem(
                      content: const Text('2018'),
                      value: 'tax_2018',
                    ),
                    TreeViewItem(
                      content: const Text('2019'),
                      value: 'tax_2019',
                      selected: true,
                    ),
                    TreeViewItem(
                      content: const Text('2020'),
                      value: 'tax_2020',
                    ),
                  ],
                ),
                TreeViewItem(content: const Text('2021'), value: 'tax_2021'),
                TreeViewItem(
                  content: const Text('Current Year'),
                  value: 'tax_cur',
                ),
              ],
            ),
          ],
        ),
      ],
    );

    _lazyController = TreeViewController(
      items: [
        TreeViewItem(
          content: const Text('Item with lazy loading'),
          value: 'lazy_load',
          lazy: true,
          children: [],
        ),
      ],
    );

    _gesturesController = TreeViewController(
      items: [
        TreeViewItem(
          content: const Text('Personal Documents'),
          value: 'personal_docs',
          children: [
            TreeViewItem(
              content: const Text('Home Remodel'),
              value: 'home_remodel',
              children: [
                TreeViewItem(
                  content: const Text('Contractor Contact Info'),
                  value: 'contr_cont_inf',
                ),
                TreeViewItem(
                  content: const Text('Paint Color Scheme'),
                  value: 'paint_color_scheme',
                ),
                TreeViewItem(
                  content: const Text('Flooring woodgrain type'),
                  value: 'flooring_woodgrain_type',
                ),
                TreeViewItem(
                  content: const Text('Kitchen cabinet style'),
                  value: 'kitch_cabinet_style',
                ),
              ],
            ),
            TreeViewItem(
              content: const Text('Tax Documents'),
              value: 'tax_docs',
              children: [
                TreeViewItem(content: const Text('2017'), value: 'tax_2017'),
                TreeViewItem(
                  content: const Text('Middle Years'),
                  value: 'tax_middle_years',
                  children: [
                    TreeViewItem(
                      content: const Text('2018'),
                      value: 'tax_2018',
                    ),
                    TreeViewItem(
                      content: const Text('2019'),
                      value: 'tax_2019',
                      selected: true,
                    ),
                    TreeViewItem(
                      content: const Text('2020'),
                      value: 'tax_2020',
                    ),
                  ],
                ),
                TreeViewItem(content: const Text('2021'), value: 'tax_2021'),
                TreeViewItem(
                  content: const Text('Current Year'),
                  value: 'tax_cur',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _lazyController.dispose();
    _gesturesController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TreeView')),
      children: [
        const Text(
          'The tree view control enables a hierarchical list with expanding and '
          'collapsing nodes that contain nested items. It can be used to '
          'illustrate a folder structure or nested relationships in your UI.\n\n'
          'The tree view uses a combination of indentation and icons to represent '
          'the nested relationship between parent nodes and child nodes. Collapsed '
          'nodes use a chevron pointing to the right, and expanded nodes use a '
          'chevron pointing down.',
        ),
        subtitle(
          content: const Text(
            'A TreeView with Multi-selection and TreeViewController',
          ),
        ),
        description(
          content: const Text(
            'TreeViewController provides programmatic control over the tree. '
            'Use the buttons below to expand all, collapse all, or add items.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => _controller.expandAll(),
                child: const Text('Expand All'),
              ),
              FilledButton(
                onPressed: () => _controller.collapseAll(),
                child: const Text('Collapse All'),
              ),
              Button(
                onPressed: () {
                  _controller.addItem(
                    TreeViewItem(
                      content: Text('New Item ${DateTime.now().second}'),
                      value: 'new_${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  );
                },
                child: const Text('Add Root Item'),
              ),
              Button(
                onPressed: () => _controller.selectAll(),
                child: const Text('Select All'),
              ),
              Button(
                onPressed: () => _controller.deselectAll(),
                child: const Text('Deselect All'),
              ),
              Button(
                onPressed: () {
                  // Move the first root item's first child to root level
                  final items = _controller.items;
                  if (items.isNotEmpty && items.first.children.isNotEmpty) {
                    final child = items.first.children.first;
                    _controller.moveItem(child);
                  }
                },
                child: const Text('Move First Child to Root'),
              ),
            ],
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
final controller = TreeViewController(
  items: [
    TreeViewItem(
      content: const Text('Personal Documents'),
      value: 'personal_docs',
      children: [...],
    ),
  ],
);

TreeView(
  controller: controller,
  selectionMode: TreeViewSelectionMode.multiple,
  onItemInvoked: (item, reason) async =>
      debugPrint('onItemInvoked(reason=$reason): $item'),
  onSelectionChanged: (selectedItems) async => debugPrint(
      'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
)

// Programmatic control:
controller.expandAll();
controller.collapseAll();
controller.addItem(TreeViewItem(content: Text('New'), value: 'new'));
controller.moveItem(someItem, newParent: targetItem, index: 0);
controller.selectAll();
controller.deselectAll();
''',
          child: TreeView(
            key: treeViewKey,
            controller: _controller,
            selectionMode: TreeViewSelectionMode.multiple,
            onItemInvoked: (final item, final reason) async =>
                debugPrint('onItemInvoked(reason=$reason): $item'),
            onSelectionChanged: (final selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((final i) => i.value)}',
            ),
            onSecondaryTap: (final item, final details) async {
              debugPrint('onSecondaryTap $item at ${details.globalPosition}');
            },
          ),
        ),
        subtitle(content: const Text('A TreeView with lazy-loading items')),
        description(
          content: const Text(
            'Use the controller to add children when expanding a lazy-loaded '
            'item. The controller\'s addItems method efficiently adds multiple '
            'children in a single rebuild.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
final lazyController = TreeViewController(
  items: [
    TreeViewItem(
      content: const Text('Item with lazy loading'),
      value: 'lazy_load',
      lazy: true,
      children: [],
    ),
  ],
);

TreeView(
  controller: lazyController,
  onItemExpandToggle: (item, getsExpanded) async {
    if (item.children.isNotEmpty) return;

    // Do your fetching...
    await Future<void>.delayed(const Duration(seconds: 2));

    // ...and add the fetched nodes via the controller.
    lazyController.addItems([
      TreeViewItem(content: const Text('Lazy item 1'), value: 'lazy_1'),
      TreeViewItem(content: const Text('Lazy item 2'), value: 'lazy_2'),
    ], parent: item);
  },
)''',
          child: TreeView(
            controller: _lazyController,
            onItemExpandToggle: (final item, final getsExpanded) async {
              // If it's already populated, return.
              if (item.children.isNotEmpty) return;

              // Do your fetching...
              await Future<void>.delayed(const Duration(seconds: 2));

              // ...and add the fetched nodes via the controller.
              _lazyController.addItems(
                [
                  TreeViewItem(
                    content: const Text('Lazy item 1'),
                    value: 'lazy_1',
                  ),
                  TreeViewItem(
                    content: const Text('Lazy item 2'),
                    value: 'lazy_2',
                  ),
                  TreeViewItem(
                    content: const Text('Lazy item 3'),
                    value: 'lazy_3',
                  ),
                  TreeViewItem(
                    content: const Text(
                      'Lazy item 4 (this text should not overflow)',
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: 'lazy_4',
                  ),
                ],
                parent: item,
              );
            },
            onItemInvoked: (final item, final reason) async =>
                debugPrint('onItemInvoked(reason=$reason): $item'),
            onSelectionChanged: (final selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((final i) => i.value)}',
            ),
            onSecondaryTap: (final item, final details) async {
              debugPrint('onSecondaryTap $item at ${details.globalPosition}');
            },
          ),
        ),
        subtitle(content: const Text('A TreeView with custom gestures')),
        description(
          content: const Text(
            'In the example below, a double tap gesture recognizer is added to '
            'every item in the tree view.\n'
            'This can be done by passing a GestureRecognizer to the gesturesBuilder'
            'callback, whether it is built-in or custom.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
final controller = TreeViewController(items: [...]);

TreeView(
  controller: controller,
  gesturesBuilder: (item) {
    return <Type, GestureRecognizerFactory>{
      DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(),
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap =
            () => debugPrint('onDoubleTap $item');
        },
      ),
    };
  },
)''',
          child: TreeView(
            controller: _gesturesController,
            onItemInvoked: (final item, final reason) async =>
                debugPrint('onItemInvoked(reason=$reason): $item'),
            onSelectionChanged: (final selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((final i) => i.value)}',
            ),
            onSecondaryTap: (final item, final details) async {
              debugPrint('onSecondaryTap $item at ${details.globalPosition}');
            },
            gesturesBuilder: (final item) {
              return <Type, GestureRecognizerFactory>{
                DoubleTapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      DoubleTapGestureRecognizer
                    >(DoubleTapGestureRecognizer.new, (final instance) {
                      instance.onDoubleTap = () =>
                          debugPrint('onDoubleTap $item');
                    }),
              };
            },
          ),
        ),
      ],
    );
  }
}
