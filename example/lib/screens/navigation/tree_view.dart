import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TreeViewPage extends ScrollablePage {
  TreeViewPage({super.key});

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TreeView'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The tree view control enables a hierarchical list with expanding and '
        'collapsing nodes that contain nested items. It can be used to '
        'illustrate a folder structure or nested relationships in your UI.\n\n'
        'The tree view uses a combination of indentation and icons to represent '
        'the nested relationship between parent nodes and child nodes. Collapsed '
        'nodes use a chevron pointing to the right, and expanded nodes use a '
        'chevron pointing down.',
      ),
      subtitle(content: const Text('A TreeView with Multi-selection enabled')),
      CardHighlight(
        child: TreeView(
          selectionMode: TreeViewSelectionMode.multiple,
          shrinkWrap: true,
          items: items,
          onItemInvoked: (item) async => debugPrint('onItemInvoked: $item'),
          onSelectionChanged: (selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
          onSecondaryTap: (item, details) async {
            debugPrint('onSecondaryTap $item at ${details.globalPosition}');
          },
        ),
        codeSnippet: r'''final items = [
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
      ),
      subtitle(content: const Text('A TreeView with lazy-loading items')),
      CardHighlight(
        child: TreeView(
          shrinkWrap: true,
          items: lazyItems,
          onItemInvoked: (item) async => debugPrint('onItemInvoked: $item'),
          onSelectionChanged: (selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
          onSecondaryTap: (item, details) async {
            debugPrint('onSecondaryTap $item at ${details.globalPosition}');
          },
        ),
        codeSnippet: r'''final lazyItems = [
  TreeViewItem(
    content: const Text('Work Documents'),
    value: 'work_docs',
    // this means the item children will futurely be inserted
    lazy: true,
    // ensure the list is modifiable
    children: [],
    onInvoked: (item) async {
      // if it's already populated, return
      // we don't want to populate it twice
      if (item.children.isNotEmpty) return;
      // mark as loading
      setState(() => item.loading = true);
      // do your fetching...
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        item
          // set loading to false
          ..loading = false
          // add the fetched nodes
          ..children.addAll([
            TreeViewItem(
              content: const Text('XYZ Functional Spec'),
              value: 'xyz_functional_spec',
            ),
            TreeViewItem(
              content: const Text('Feature Schedule'),
              value: 'feature_schedule',
            ),
            TreeViewItem(
              content: const Text('Overall Project Plan'),
              value: 'overall_project_plan',
            ),
            TreeViewItem(
              content: const Text(
                'Feature Resources Allocation (this text should not overflow)',
                overflow: TextOverflow.ellipsis,
              ),
              value: 'feature_resources_alloc',
            ),
          ]);
      });
    },
  ),
];

TreeView(
  selectionMode: TreeViewSelectionMode.multiple,
  shrinkWrap: true,
  items: lazyItems,
  onItemInvoked: (item) async => debugPrint('onItemInvoked: \$item'),
  onSelectionChanged: (selectedItems) async => debugPrint(
              'onSelectionChanged: \${selectedItems.map((i) => i.value)}'),
  onSecondaryTap: (item, details) async {
    debugPrint('onSecondaryTap $item at ${details.globalPosition}');
  },
)
''',
      ),
    ];
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

  late final lazyItems = [
    TreeViewItem(
      content: const Text('Work Documents'),
      value: 'work_docs',
      // this means the item will be expandable
      lazy: true,
      // ensure the list is modifiable
      children: [],
      onInvoked: (item) async {
        // if it's already populated, return
        if (item.children.isNotEmpty) return;
        // mark as loading
        setState(() => item.loading = true);
        // do your fetching...
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          item
            // set loading to false
            ..loading = false
            // add the fetched nodes
            ..children.addAll([
              TreeViewItem(
                content: const Text('XYZ Functional Spec'),
                value: 'xyz_functional_spec',
              ),
              TreeViewItem(
                content: const Text('Feature Schedule'),
                value: 'feature_schedule',
              ),
              TreeViewItem(
                content: const Text('Overall Project Plan'),
                value: 'overall_project_plan',
              ),
              TreeViewItem(
                content: const Text(
                  'Feature Resources Allocation (this text should not overflow)',
                  overflow: TextOverflow.ellipsis,
                ),
                value: 'feature_resources_alloc',
              ),
            ]);
        });
        setState(() {
          item.expanded = true;
          item.updateSelected();
        });
      },
    ),
  ];
}
