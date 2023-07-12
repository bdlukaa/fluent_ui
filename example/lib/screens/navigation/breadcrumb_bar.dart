import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class BreadcrumbBarPage extends StatelessWidget with PageMixin {
  const BreadcrumbBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('BreadcrumbBar')),
      children: const [
        BreadcrumbBar(
          items: [
            BreadcrumbItem(label: Text('Home'), value: 0),
            BreadcrumbItem(label: Text('Pictures'), value: 0),
            BreadcrumbItem(label: Text('2020'), value: 0),
            BreadcrumbItem(label: Text('Summer'), value: 0),
            BreadcrumbItem(label: Text('Lake'), value: 0),
          ],
        ),
      ],
    );
  }
}
