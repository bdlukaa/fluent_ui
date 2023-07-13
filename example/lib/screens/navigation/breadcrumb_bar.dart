import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BreadcrumbBarPage extends StatefulWidget {
  const BreadcrumbBarPage({super.key});

  @override
  State<BreadcrumbBarPage> createState() => _BreadcrumbBarPageState();
}

class _BreadcrumbBarPageState extends State<BreadcrumbBarPage> with PageMixin {
  static const items = [
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
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('BreadcrumbBar')),
      children: [
        BreadcrumbBar(
          onChanged: (item) {
            debugPrint('${item.value} pressed');
            setState(() {
              _items.removeLast();
            });
            // setState(() {
            //   final index = _items.indexOf(item);
            //   for (int i = items.length - 1; i >= index + 1; i--) {
            //     _items.removeAt(i);
            //   }
            // });
          },
          items: _items,
        ),
      ],
    );
  }
}
