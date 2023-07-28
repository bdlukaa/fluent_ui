import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:example/widgets/card_highlight.dart';

class ToggleSwitchPage extends StatefulWidget {
  const ToggleSwitchPage({super.key});

  @override
  State<ToggleSwitchPage> createState() => _ToggleSwitchPageState();
}

class _ToggleSwitchPageState extends State<ToggleSwitchPage> with PageMixin {
  bool disabled = false;
  bool firstValue = false;
  bool secondValue = true;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('ToggleSwitch'),
        commandBar: ToggleSwitch(
          checked: disabled,
          onChanged: (v) => setState(() => disabled = v),
          content: const Text('Disabled'),
        ),
      ),
      children: [
        const Text(
          'The toggle switch represents a physical switch that allows users to '
          'turn things on or off, like a light switch. Use toggle switch controls '
          'to present users with two mutually exclusive options (such as on/off), '
          'where choosing an option provides immediate results.',
        ),
        subtitle(content: const Text('A simple ToggleSwitch')),
        CardHighlight(
          codeSnippet: '''bool checked = false;

ToggleSwitch(
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
)''',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ToggleSwitch(
              checked: firstValue,
              onChanged:
                  disabled ? null : (v) => setState(() => firstValue = v),
              content: Text(firstValue ? 'On' : 'Off'),
            ),
          ),
        ),
        subtitle(
          content: const Text('A ToggleSwitch with custom header and content'),
        ),
        CardHighlight(
          codeSnippet: '''bool checked = false;

ToggleSwitch(
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
  content: Text(checked ? 'Working' : 'Do work'),
)''',
          child: Row(children: [
            InfoLabel(
              label: 'Header',
              child: ToggleSwitch(
                checked: secondValue,
                onChanged:
                    disabled ? null : (v) => setState(() => secondValue = v),
                content: Text(secondValue ? 'Working' : 'Do work'),
              ),
            ),
            if (secondValue)
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 24.0),
                child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: ProgressRing(),
                ),
              )
          ]),
        ),
      ],
    );
  }
}
