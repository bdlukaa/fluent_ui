import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:example/widgets/card_highlight.dart';

class ToggleSwitchPage extends ScrollablePage {
  bool disabled = false;
  bool firstValue = false;
  bool secondValue = true;

  @override
  Widget buildHeader(BuildContext context) {
    return PageHeader(
      title: const Text('ToggleSwitch'),
      commandBar: ToggleSwitch(
        checked: disabled,
        onChanged: (v) => setState(() => disabled = v),
        content: const Text('Disabled'),
      ),
    );
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use ToggleSwitch controls to present users with exactly two mutually exclusive options (like on/off), where choosing an option results in an immediate commit. A toggle switch should have a single label',
      ),
      subtitle(content: const Text('A simple ToggleSwitch')),
      CardHighlight(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ToggleSwitch(
            checked: firstValue,
            onChanged: disabled
                ? null
                : (v) {
                    setState(() => firstValue = v);
                  },
            content: Text(firstValue ? 'On' : 'Off'),
          ),
        ),
        codeSnippet: '''bool checked = false;

ToggleSwitch(
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
)''',
      ),
      subtitle(
        content: const Text('A ToggleSwitch with custom header and content'),
      ),
      CardHighlight(
        child: Row(children: [
          InfoLabel(
            label: 'Header',
            child: ToggleSwitch(
              checked: secondValue,
              onChanged: disabled
                  ? null
                  : (v) {
                      setState(() => secondValue = v);
                    },
              content: Text(secondValue ? 'Working' : 'Do work'),
            ),
          ),
          if (secondValue)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ProgressRing(),
            )
        ]),
        codeSnippet: '''bool checked = false;

ToggleSwitch(
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
  content: Text(checked ? 'Working' : 'Do work'),
)''',
      ),
    ];
  }
}
