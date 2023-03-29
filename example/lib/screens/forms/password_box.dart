import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PasswordBoxPage extends ScrollablePage {
  PasswordBoxPage({super.key});

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('PasswordBox'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The PasswordBox is almost identical to the TextBox. But the character'
        ' is obfuscated by default and a button in the suffix allow the user to '
        'show briefly the password in plain text.',
      ),
      subtitle(content: const Text('A simple PasswordBox')),
      CardHighlight(
        child: Row(children: const [
          Expanded(child: PasswordBox()),
          SizedBox(width: 10.0),
          Expanded(
            child: PasswordBox(
              enabled: false,
              placeholder: 'Disabled PasswordBox',
            ),
          )
        ]),
        codeSnippet: '''PasswordBox()''',
      ),
    ];
  }
}
