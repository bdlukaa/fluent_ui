import 'package:example/widgets/code_snippet_card.dart';
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
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('PasswordBox'),
        commandBar: ToggleSwitch(
          checked: disabled,
          onChanged: (final v) {
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
          content: const Text('A simple PasswordBox in peek mode (default)'),
        ),
        CodeSnippetCard(
          codeSnippet: '''PasswordBox()''',
          child: Row(
            children: [Expanded(child: PasswordBox(enabled: !disabled))],
          ),
        ),
        subtitle(
          content: const Text('A simple PasswordBox in peekAlways mode'),
        ),
        CodeSnippetCard(
          codeSnippet: '''
PasswordBox(
  revealMode: PasswordRevealMode.peekAlways,
)''',
          child: Row(
            children: [
              Expanded(
                child: PasswordBox(
                  enabled: !disabled,
                  revealMode: PasswordRevealMode.peekAlways,
                ),
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'A simple PasswordBox in visible (left) and hidden (right) mode',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
PasswordBox(
  revealMode: PasswordRevealMode.visible,
);

PasswordBox(
  revealMode: PasswordRevealMode.hidden,
);''',
          child: Row(
            children: [
              Expanded(
                child: PasswordBox(
                  enabled: !disabled,
                  revealMode: PasswordRevealMode.visible,
                  placeholder: 'Visible Password',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PasswordBox(
                  enabled: !disabled,
                  revealMode: PasswordRevealMode.hidden,
                  placeholder: 'Hidden Password',
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('Update programmatically the visibility')),
        CodeSnippetCard(
          codeSnippet: '''
PasswordBox(
  revealMode: revealMode,
)''',
          child: Row(
            children: [
              Expanded(
                child: PasswordBox(enabled: !disabled, revealMode: revealMode),
              ),
              const SizedBox(width: 10),
              SizedBox(
                // width: 50,
                child: ComboBox<PasswordRevealMode>(
                  onChanged: (final e) {
                    setState(() {
                      revealMode = e ?? PasswordRevealMode.peek;
                    });
                  },
                  value: revealMode,
                  items: PasswordRevealMode.values.map((final e) {
                    return ComboBoxItem(value: e, child: Text(e.name));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('PasswordFormBox')),
        CodeSnippetCard(
          codeSnippet: '''
PasswordBox(
  autovalidateMode: AutovalidateMode.always,
  validator: (text) {
    if (text == null) return null;
    if (text.length < 8) return 'At least 8 characters';

    return null;
  },
)''',
          child: PasswordFormBox(
            enabled: !disabled,
            autovalidateMode: AutovalidateMode.always,
            validator: (final text) {
              if (text == null) return null;
              if (text.length < 8) return 'At least 8 characters';

              return null;
            },
            revealMode: revealMode,
          ),
        ),
      ],
    );
  }
}
