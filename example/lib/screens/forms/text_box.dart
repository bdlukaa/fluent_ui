import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TextBoxPage extends ScrollablePage {
  TextBoxPage({super.key});

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('TextBox'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The TextBox control lets a user type text into an app. It\'s typically '
        'used to capture a single line of text, but can be configured to capture '
        'multiple lines of text. The text displays on the screen in a simple, '
        'uniform, plaintext format.\n\n'
        'TextBox has a number of features that can simplify text entry. It comes '
        'with a familiar, built-in context menu with support for copying and '
        'pasting text. The "clear all" button lets a user quickly delete all '
        'text that has been entered. It also has spell checking capabilities '
        'built in and enabled by default.',
      ),
      subtitle(content: const Text('A simple TextBox')),
      CardHighlight(
        child: Row(children: const [
          Expanded(child: TextBox()),
          SizedBox(width: 10.0),
          Expanded(child: TextBox(enabled: false, placeholder: 'Disabled'))
        ]),
        codeSnippet: '''TextBox()''',
      ),
      subtitle(
        content: const Text('A TextBox with a header and placeholder text'),
      ),
      const CardHighlight(
        child: TextBox(
          header: 'Enter your name:',
          placeholder: 'Name',
          expands: false,
        ),
        codeSnippet: '''TextBox(
  header: 'Enter your name:',
  placeholder: 'Name',
  expands: false,
),''',
      ),
      subtitle(
        content: const Text('A read-only TextBox with various properties set'),
      ),
      const CardHighlight(
        child: TextBox(
          readOnly: true,
          placeholder: 'I am super excited to be here!',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 24.0,
            letterSpacing: 8,
            color: Color(0xFF5178BE),
            fontStyle: FontStyle.italic,
          ),
        ),
        codeSnippet: '''TextBox(
  readOnly: true,
  placeholder: 'I am super excited to be here',
  style: TextStyle(
    fontFamily: 'Arial,
    fontSize: 24.0,
    letterSpacing: 8,
    color: Color(0xFF5178BE),
    fontStyle: FontStyle.italic,
  ),
),''',
      ),
      subtitle(content: const Text('A multi-line TextBox')),
      const CardHighlight(
        child: TextBox(
          maxLines: null,
        ),
        codeSnippet: '''TextBox(
  maxLines: null,
),''',
      ),
    ];
  }
}
