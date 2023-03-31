import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PasswordBoxPage extends StatefulWidget {
  const PasswordBoxPage({super.key});

  @override
  State<PasswordBoxPage> createState() => _PasswordBoxPageState();
}

class _PasswordBoxPageState extends State<PasswordBoxPage> with PageMixin {
  bool disabled = false;
  PasswordRevealMode revealMode = PasswordRevealMode.peek;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('NumberBox'),
        commandBar: ToggleSwitch(
          checked: disabled,
          onChanged: (v) {
            setState(() => disabled = v);
          },
          content: const Text('Disabled'),
        ),
      ),
      children: [
        const Text(
          'The PasswordBox is almost identical to the TextBox. But the character'
          ' is obfuscated by default and a button in the suffix allow the user to '
          'show briefly the password in plain text.',
        ),
        subtitle(
            content: const Text('A simple PasswordBox in peek mode (default)')),
        CardHighlight(
          child: Row(children: [
            Expanded(
                child: PasswordBox(
              enabled: !disabled,
            )),
          ]),
          codeSnippet: '''PasswordBox()''',
        ),
        subtitle(
            content: const Text('A simple PasswordBox in peekAlways mode')),
        CardHighlight(
          child: Row(children: [
            Expanded(
                child: PasswordBox(
              enabled: !disabled,
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
          child: Row(children: [
            Expanded(
                child: PasswordBox(
              enabled: !disabled,
              revealMode: PasswordRevealMode.visible,
              placeholder: 'Visible Password',
            )),
            const SizedBox(width: 10.0),
            Expanded(
              child: PasswordBox(
                enabled: !disabled,
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
        subtitle(content: const Text('Update programmatically the visibility')),
        CardHighlight(
          child: Row(children: [
            Expanded(
              child: PasswordBox(
                enabled: !disabled,
                revealMode: revealMode,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              // width: 50,
              child: ComboBox<PasswordRevealMode>(
                onChanged: (e) {
                  setState(() {
                    revealMode = e ?? PasswordRevealMode.peek;
                  });
                },
                value: revealMode,
                items: PasswordRevealMode.values.map((e) {
                  return ComboBoxItem(child: Text(e.name), value: e);
                }).toList(),
              ),
            ),
          ]),
          codeSnippet: '''PasswordBox(
  revealMode: revealMode,
)''',
        ),
      ],
    );
  }
}
