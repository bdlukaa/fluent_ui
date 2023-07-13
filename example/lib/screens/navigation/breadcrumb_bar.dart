import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BreadcrumbBarPage extends StatelessWidget with PageMixin {
  const BreadcrumbBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('BreadcrumbBar')),
      children: [
        BreadcrumbBar(
          overflowButton: IconButton(
            icon: const Icon(FluentIcons.more),
            onPressed: () {
              debugPrint('statement');
            },
          ),
          items: const [
            BreadcrumbItem(label: Text('Home'), value: 0),
            BreadcrumbItem(label: Text('Documents'), value: 0),
            BreadcrumbItem(label: Text('Design'), value: 0),
            BreadcrumbItem(label: Text('Northwind'), value: 0),
            BreadcrumbItem(label: Text('Images'), value: 0),
            BreadcrumbItem(label: Text('Folder1'), value: 0),
            BreadcrumbItem(label: Text('Folder2'), value: 0),
            BreadcrumbItem(label: Text('Folder3'), value: 0),
            BreadcrumbItem(label: Text('Folder4'), value: 0),
            BreadcrumbItem(label: Text('Folder5'), value: 0),
            BreadcrumbItem(label: Text('Folder6'), value: 0),
          ],
        ),
      ],
    );
  }
}
