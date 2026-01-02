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
          content: const Text('A TreeView with Multi-selection enabled'),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
final items = [
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
            content: const Text('Flooring weedgrain type'),
            value: 'flooring_weedgrain_type',
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
          TreeViewItem(content: const Text('2017'), value: "tax_2017"),
          TreeViewItem(
            content: const Text('Middle Years'),
            value: 'tax_middle_years',
            children: [
              TreeViewItem(content: const Text('2018'), value: "tax_2018"),
              TreeViewItem(content: const Text('2019'), value: "tax_2019"),
              TreeViewItem(content: const Text('2020'), value: "tax_2020"),
            ],
          ),
          TreeViewItem(content: const Text('2021'), value: "tax_2021"),
          TreeViewItem(content: const Text('Current Year'), value: "tax_cur"),
        ],
      ),
    ],
  ),
];

TreeView(
  selectionMode: TreeViewSelectionMode.multiple,
  shrinkWrap: true,
  items: items,
  onItemInvoked: (item) async => debugPrint('onItemInvoked: \$item'),
  onSelectionChanged: (selectedItems) async => debugPrint(
              'onSelectionChanged: \${selectedItems.map((i) => i.value)}'),
  onSecondaryTap: (item, details) async {
    debugPrint('onSecondaryTap $item at ${details.globalPosition}');
  },
)
''',
          child: TreeView(
            key: treeViewKey,
            selectionMode: TreeViewSelectionMode.multiple,
            items: items,
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
        CodeSnippetCard(
          codeSnippet: r'''
final lazyItems = [
  TreeViewItem(
    content: const Text('Item with lazy loading'),
    value: 'lazy_load',
    // This means the item will be expandable, although there are no
    // children yet.
    lazy: true,
    // Ensure the list is modifiable.
    children: [],
    onExpandToggle: (item, getsExpanded) async {
      // If it's already populated, return.
      if (item.children.isNotEmpty) return;

      // Do your fetching...
      await Future<void>.delayed(const Duration(seconds: 2));
      
      // ...and add the fetched nodes.
      item.children.addAll([
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
      ]);
    },
  ),
];

TreeView(
  shrinkWrap: true,
  items: lazyItems,
  onItemInvoked: (item) async => debugPrint('onItemInvoked: $item'),
  onSelectionChanged: (selectedItems) async => debugPrint(
    'onSelectionChanged: ${selectedItems.map((i) => i.value)}',
  ),
  onSecondaryTap: (item, details) async {
    debugPrint('onSecondaryTap $item at ${details.globalPosition}');
  },
)''',
          child: TreeView(
            items: lazyItems,
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
TreeView(
  ...,
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
),''',
          child: TreeView(
            items: items,
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

  late final items = [
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
              content: const Text('Flooring weedgrain type'),
              value: 'flooring_weedgrain_type',
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
                TreeViewItem(content: const Text('2018'), value: 'tax_2018'),
                TreeViewItem(
                  content: const Text('2019'),
                  value: 'tax_2019',
                  selected: true,
                ),
                TreeViewItem(content: const Text('2020'), value: 'tax_2020'),
              ],
            ),
            TreeViewItem(content: const Text('2021'), value: 'tax_2021'),
            TreeViewItem(content: const Text('Current Year'), value: 'tax_cur'),
          ],
        ),
      ],
    ),
  ];

  late final lazyItems = [
    TreeViewItem(
      content: const Text('Item with lazy loading'),
      value: 'lazy_load',
      // This means the item will be expandable, although there are no
      // children yet.
      lazy: true,
      // Ensure the list is modifiable.
      children: [],
      onExpandToggle: (final item, final getsExpanded) async {
        // If it's already populated, return.
        if (item.children.isNotEmpty) return;

        // Do your fetching...
        await Future<void>.delayed(const Duration(seconds: 2));

        // ...and add the fetched nodes.
        item.children.addAll([
          TreeViewItem(content: const Text('Lazy item 1'), value: 'lazy_1'),
          TreeViewItem(content: const Text('Lazy item 2'), value: 'lazy_2'),
          TreeViewItem(content: const Text('Lazy item 3'), value: 'lazy_3'),
          TreeViewItem(
            content: const Text(
              'Lazy item 4 (this text should not overflow)',
              overflow: TextOverflow.ellipsis,
            ),
            value: 'lazy_4',
          ),
        ]);
      },
    ),
  ];
}
