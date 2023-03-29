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
      subtitle(
          content: const Text('A simple PasswordBox in peek mode (default)')),
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
      subtitle(content: const Text('A simple PasswordBox in peekAlways mode')),
      CardHighlight(
        child: Row(children: const [
          Expanded(
              child: PasswordBox(
            revealMode: PasswordRevealMode.peekAlways,
          )),
        ]),
        codeSnippet: '''PasswordBox(
  revealMode: PasswordRevealMode.peekAlways,
)''',
      ),
      subtitle(
          content: const Text(
              'A simple PasswordBox in visible (left) and hidden (right) mode')),
      CardHighlight(
        child: Row(children: const [
          Expanded(
              child: PasswordBox(
            revealMode: PasswordRevealMode.visible,
            placeholder: 'Visible Password',
          )),
          SizedBox(width: 10.0),
          Expanded(
            child: PasswordBox(
              revealMode: PasswordRevealMode.hidden,
              placeholder: 'Hidden Password',
            ),
          )
        ]),
        codeSnippet: '''PasswordBox(
  revealMode: PasswordRevealMode.visible,
);

PasswordBox(
  revealMode: PasswordRevealMode.hidden,
);''',
      ),
    ];
  }
}
