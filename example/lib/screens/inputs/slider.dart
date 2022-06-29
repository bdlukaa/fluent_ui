import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SliderPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'disabled': false,
    'first_value': 23.0,
    'vertical_value': 50.0,
  };

  @override
  Widget buildHeader(BuildContext context) {
    return PageHeader(
      title: const Text('Slider'),
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
          'Use a Slider when you want your users to be able to set defined, contiguous values (such as volume or brightness) or a range of discrete values (such as screen resolution settings).'),
      subtitle(content: const Text('A simple Slider')),
      CardHighlight(
        child: Row(children: [
          Slider(
            label: '${state['first_value'].toInt()}',
            value: state['first_value'],
            onChanged: isDisabled
                ? null
                : (v) {
                    setState(() => state['first_value'] = v);
                  },
          ),
          const Spacer(),
          Text('Output:\n${state['first_value'].toInt()}'),
        ]),
        codeSnippet: '''double value = 0;

Slider(
  label: '\${value.toInt()}',
  value: value,
  onChanged: disabled ? null : (v) => setState(() => value = v),
),
''',
      ),
      subtitle(content: const Text('A vertical slider')),
      CardHighlight(
        child: Row(children: [
          Slider(
            vertical: true,
            label: '${state['vertical_value'].toInt()}',
            value: state['vertical_value'],
            onChanged: isDisabled
                ? null
                : (v) {
                    setState(() => state['vertical_value'] = v);
                  },
          ),
          const Spacer(),
          Text('Output:\n${state['vertical_value'].toInt()}'),
        ]),
        codeSnippet: '''double value = 0;

Slider(
  vertical: true,
  label: '\${value.toInt()}',
  value: value,
  onChanged: disabled ? null : (v) => setState(() => value = v),
),
''',
      ),
    ];
  }
}
