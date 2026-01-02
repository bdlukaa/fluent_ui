import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ContentDialogPage extends StatefulWidget {
  const ContentDialogPage({super.key});

  @override
  State<ContentDialogPage> createState() => _ContentDialogPageState();
}

class _ContentDialogPageState extends State<ContentDialogPage> with PageMixin {
  String? result = '';

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('ContentDialog')),
      children: [
        const Text(
          'Dialog controls are modal UI overlays that provide contextual app '
          'information. They block interactions with the app window until being '
          'explicitly dismissed. They often request some kind of action from the '
          'user.',
        ),
        subtitle(content: const Text('A basic content dialog with content')),
        CodeSnippetCard(
          codeSnippet: r'''
Button(
  child: const Text('Show dialog'),
  onPressed: () => showContentDialog(context),
),

void showContentDialog(BuildContext context) async {
  final result = await showDialog<String>(
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
}''',
          child: Row(
            children: [
              Button(
                child: const Text('Show dialog'),
                onPressed: () => showContentDialog(context),
              ),
              const SizedBox(width: 10),
              Text(result ?? ''),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> showContentDialog(final BuildContext context) async {
    result = await showDialog<String>(
      context: context,
      builder: (final context) => ContentDialog(
        title: const Text('Delete file permanently?'),
        content: const Text(
          "If you delete this file, you won't be able to recover it. Do you want to delete it?",
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
