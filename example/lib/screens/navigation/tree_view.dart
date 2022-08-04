import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TreeViewPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TreeView'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The TreeView control is a hierarchical list pattern with expanding and collapsing nodes that contain nested items.',
      ),
      subtitle(content: const Text('A TreeView with Multi-selection enabled')),
      Card(
        child: TreeView(
          selectionMode: TreeViewSelectionMode.multiple,
          shrinkWrap: true,
          items: items,
          onItemInvoked: (item) async => debugPrint('onItemInvoked: $item'),
          onSelectionChanged: (selectedItems) async => debugPrint(
              'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
        ),
      ),
    ];
  }

  final items = [
    TreeViewItem(
      content: const Text('Work Documents'),
      value: 'work_docs',
      lazy: true,
      children: [
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
      ],
    ),
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
}
