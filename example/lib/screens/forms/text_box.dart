import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TextBoxPage extends StatelessWidget with PageMixin {
  TextBoxPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TextBox')),
      children: [
        const Text(
          "The TextBox control lets a user type text into an app. It's typically "
          'used to capture a single line of text, but can be configured to capture '
          'multiple lines of text. The text displays on the screen in a simple, '
          'uniform, plaintext format.\n\n'
          'TextBox has a number of features that can simplify text entry. It comes '
          'with a familiar, built-in context menu with support for copying and '
          'pasting text. It also has spell checking capabilities built in and '
          'enabled by default.',
        ),
        subtitle(content: const Text('A simple TextBox')),
        const CodeSnippetCard(
          codeSnippet: '''TextBox()''',
          child: Row(
            children: [
              Expanded(child: TextBox()),
              SizedBox(width: 10),
              Expanded(
                child: TextBox(enabled: false, placeholder: 'Disabled TextBox'),
              ),
            ],
          ),
        ),

        subtitle(
          content: const Text('A TextBox with a header and placeholder text'),
        ),
        CodeSnippetCard(
          codeSnippet: '''
InfoLabel(
  label: 'Enter your name:',
  child: const TextBox(
    placeholder: 'Name',
    expands: false,
  ),
)''',
          child: InfoLabel(
            label: 'Enter your name:',
            child: const TextBox(placeholder: 'Name'),
          ),
        ),
        subtitle(
          content: const Text(
            'A read-only TextBox with various properties set',
          ),
        ),
        const CodeSnippetCard(
          codeSnippet: '''
TextBox(
  readOnly: true,
  placeholder: 'I am super excited to be here',
  style: TextStyle(
    fontFamily: 'Arial',
    fontSize: 24.0,
    letterSpacing: 8.0,
    color: Color(0xFF5178BE),
    fontStyle: FontStyle.italic,
  ),
),''',
          child: TextBox(
            readOnly: true,
            placeholder: 'I am super excited to be here!',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 24,
              letterSpacing: 8,
              color: Color(0xFF5178BE),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        subtitle(content: const Text('A multi-line TextBox')),
        const CodeSnippetCard(
          codeSnippet: '''
TextBox(
  maxLines: null,
),''',
          child: TextBox(maxLines: null),
        ),
        subtitle(content: const Text('A big TextBox')),
        const CodeSnippetCard(
          codeSnippet: '''
SizedBox(
  height: 200.0,
  child: TextBox(
    maxLines: null,
  ),
)''',
          child: SizedBox(height: 200, child: TextBox(maxLines: null)),
        ),
        subtitle(
          content: const Text('A TextBox with custom selection buttons'),
        ),
        const CodeSnippetCard(
          codeSnippet: r'''TextBox(
  controller: TextEditingController(
    text: 'Select some text and open the menu.',
  ),
  maxLines: null,
  contextMenuBuilder: (context, editableTextState) {
    return WindowsTextSelectionToolbar(
      buttonItems: [
        ...editableTextState.contextMenuButtonItems,
        ContextMenuButtonItem(
          type: ContextMenuButtonType.searchWeb,
          label: 'Search Web',
          onPressed: () {
            launchUrl(
              Uri.parse('https://www.google.com/search?q=${editableTextState.textEditingValue.text}'),
            );
          },
        ),
        ContextMenuButtonItem(
          type: ContextMenuButtonType.share,
          label: 'Share',
          onPressed: () {
            SharePlus.instance.share(ShareParams(text: controller.text));
          },
        ),
      ],
      anchors: editableTextState.contextMenuAnchors,
    );
  },
)''',
          child: SizedBox(height: 150, child: _CustomSelectionButtonsTextBox()),
        ),
      ],
    );
  }
}

class _CustomSelectionButtonsTextBox extends StatefulWidget {
  const _CustomSelectionButtonsTextBox();

  @override
  State<_CustomSelectionButtonsTextBox> createState() =>
      _CustomSelectionButtonsTextBoxState();
}

class _CustomSelectionButtonsTextBoxState
    extends State<_CustomSelectionButtonsTextBox> {
  late final TextEditingController controller = TextEditingController(
    text:
        'Select some text and open the menu to try Lookup, Search Web, '
        'and Share.',
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final undoController = editableTextState.widget.undoController;

    return WindowsTextSelectionToolbar(
      buttonItems: [
        ...editableTextState.contextMenuButtonItems,
        if (undoController != null)
          UndoContextMenuButtonItem(onPressed: undoController.undo),
        ContextMenuButtonItem(
          type: ContextMenuButtonType.searchWeb,
          label: 'Search Web',
          onPressed: () {
            launchUrl(
              Uri.parse('https://www.google.com/search?q=${controller.text}'),
            );
          },
        ),
        ContextMenuButtonItem(
          type: ContextMenuButtonType.share,
          label: 'Share',
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text: controller.text,
                sharePositionOrigin:
                    editableTextState.contextMenuAnchors.primaryAnchor &
                    Size.zero,
              ),
            );
          },
        ),
      ],
      anchors: editableTextState.contextMenuAnchors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextBox(
      controller: controller,
      maxLines: null,
      contextMenuBuilder: _buildContextMenu,
    );
  }
}
