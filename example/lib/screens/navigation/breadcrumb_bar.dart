import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BreadcrumbBarPage extends StatelessWidget with PageMixin {
  const BreadcrumbBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 24.0);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('BreadcrumbBar')),
      children: [
        BreadcrumbBar(
          overflowButton: IconButton(
            icon: Icon(FluentIcons.more),
            onPressed: () {
              debugPrint('statement');
            },
          ),
          items: [
            BreadcrumbItem(label: Text('Home', style: style), value: 0),
            BreadcrumbItem(label: Text('Documents', style: style), value: 0),
            BreadcrumbItem(label: Text('Design', style: style), value: 0),
            BreadcrumbItem(label: Text('Northwind', style: style), value: 0),
            BreadcrumbItem(label: Text('Images', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder1', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder2', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder3', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder4', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder5', style: style), value: 0),
            BreadcrumbItem(label: Text('Folder6', style: style), value: 0),
          ],
        ),
      ],
    );
  }
}
