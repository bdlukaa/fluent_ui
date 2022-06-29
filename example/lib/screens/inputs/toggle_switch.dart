import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:example/widgets/card_highlight.dart';

class ToggleSwitchPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'disabled': false,
    'first_value': false,
    'second_value': true,
  };

  @override
  Widget buildHeader(BuildContext context) {
    return PageHeader(
      title: const Text('ToggleSwitch'),
      commandBar: ToggleSwitch(
        checked: isDisabled,
        onChanged: (v) => setState(() => state['disabled'] = v),
        content: const Text('Disabled'),
      ),
    );
  }

  bool get isDisabled => state['disabled'];

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
            checked: state['first_value'],
            onChanged: isDisabled
                ? null
                : (v) {
                    setState(() => state['first_value'] = v);
                  },
            content: Text(state['first_value'] ? 'On' : 'Off'),
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
              checked: state['second_value'],
              onChanged: isDisabled
                  ? null
                  : (v) {
                      setState(() => state['second_value'] = v);
                    },
              content: Text(state['second_value'] ? 'Working' : 'Do work'),
            ),
          ),
          if (state['second_value'])
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
