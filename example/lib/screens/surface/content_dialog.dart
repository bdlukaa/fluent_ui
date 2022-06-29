import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ContentDialogPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('ContentDialog'));
  }

  String? result = '';

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use a ContentDialog to show relavant information or to provide a modal dialog experience that can show any content.',
      ),
      subtitle(content: const Text('A basic content dialog with content')),
      CardHighlight(
        child: Row(children: [
          Button(
            child: const Text('Show dialog'),
            onPressed: () => showContentDialog(context),
          ),
          const SizedBox(width: 10.0),
          Text(result ?? ''),
          const Spacer(),
        ]),
        codeSnippet: '''Button(
  child: const Text('Show dialog'),
  onPressed: () => showContentDialog(context),
),

void showContentDialog(BuildContext context) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('Delete file permanently?'),
      content: const Text(
        'If you delete this file, you won't be able to recover it. Do you want to delete it?',
      ),
      actions: [
        Button(
          child: const Text('Delete'),
          onPressed: () {
            Navigator.pop(context, 'User deleted file');
            // Delete file here
          },
        ),
        FilledButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, 'User canceled dialog'),
        ),
      ],
    ),
  );
  setState(() {});
}
''',
      ),
    ];
  }

  void showContentDialog(BuildContext context) async {
    result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete file permanently?'),
        content: const Text(
          'If you delete this file, you won\'t be able to recover it. Do you want to delete it?',
        ),
        actions: [
          Button(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
    setState(() {});
  }
}
