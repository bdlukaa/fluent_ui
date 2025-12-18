import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BreadcrumbBarPage extends StatefulWidget {
  const BreadcrumbBarPage({super.key});

  @override
  State<BreadcrumbBarPage> createState() => _BreadcrumbBarPageState();
}

class _BreadcrumbBarPageState extends State<BreadcrumbBarPage> with PageMixin {
  static const items = <BreadcrumbItem<int>>[
    BreadcrumbItem(label: Text('Home'), value: 0),
    BreadcrumbItem(label: Text('Documents'), value: 1),
    BreadcrumbItem(label: Text('Design'), value: 2),
    BreadcrumbItem(label: Text('Northwind'), value: 3),
    BreadcrumbItem(label: Text('Images'), value: 4),
    BreadcrumbItem(label: Text('Folder1'), value: 5),
    BreadcrumbItem(label: Text('Folder2'), value: 6),
    BreadcrumbItem(label: Text('Folder3'), value: 7),
    BreadcrumbItem(label: Text('Folder4'), value: 8),
    BreadcrumbItem(label: Text('Folder5'), value: 9),
    BreadcrumbItem(label: Text('Folder6'), value: 10),
  ];

  var _items = items.toList();

  void resetItems() {
    setState(() => _items = items.toList());
  }

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('BreadcrumbBar')),
      children: [
        description(
          content: const Text(
            'The BreadcrumbBar control provides a commmon horizontal layout to '
            'display the trail of navigation taken to the current location. '
            'Resize to see the nodes crumble, starting at the root.',
          ),
        ),
        subtitle(content: const Text('A BreadcrumbBar control')),
        CodeSnippetCard(
          header: Row(
            children: [
              const Expanded(child: Text('Source code')),
              Button(onPressed: resetItems, child: const Text('Reset sample')),
            ],
          ),
          codeSnippet: '''
final _items = <BreadcrumbItem<int>>[
  BreadcrumbItem(label: Text('Home'), value: 0),
  BreadcrumbItem(label: Text('Documents'), value: 1),
  BreadcrumbItem(label: Text('Design'), value: 2),
  BreadcrumbItem(label: Text('Northwind'), value: 3),
  BreadcrumbItem(label: Text('Images'), value: 4),
  BreadcrumbItem(label: Text('Folder1'), value: 5),
  BreadcrumbItem(label: Text('Folder2'), value: 6),
  BreadcrumbItem(label: Text('Folder3'), value: 7),
  BreadcrumbItem(label: Text('Folder4'), value: 8),
  BreadcrumbItem(label: Text('Folder5'), value: 9),
  BreadcrumbItem(label: Text('Folder6'), value: 10),
];

BreadcrumbBar<int>(
  items: _items,
  onItemPressed: (item) {
    setState(() {
      final index = _items.indexOf(item);
      _items.removeRange(index + 1, _items.length);
    });
  },
),''',
          child: BreadcrumbBar<int>(
            onItemPressed: (final item) {
              setState(() {
                final index = _items.indexOf(item);
                _items.removeRange(index + 1, _items.length);
              });
            },
            items: _items,
          ),
        ),
      ],
    );
  }
}
