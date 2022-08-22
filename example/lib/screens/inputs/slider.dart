import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SliderPage extends ScrollablePage {
  bool disabled = false;
  double firstValue = 23.0;
  double verticalValue = 50.0;

  @override
  Widget buildHeader(BuildContext context) {
    return PageHeader(
      title: const Text('Slider'),
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
          'Use a Slider when you want your users to be able to set defined, contiguous values (such as volume or brightness) or a range of discrete values (such as screen resolution settings).'),
      subtitle(content: const Text('A simple Slider')),
      CardHighlight(
        child: Row(children: [
          Slider(
            label: '${firstValue.toInt()}',
            value: firstValue,
            onChanged: disabled
                ? null
                : (v) {
                    setState(() => firstValue = v);
                  },
          ),
          const Spacer(),
          Text('Output:\n${firstValue.toInt()}'),
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
            label: '${verticalValue.toInt()}',
            value: verticalValue,
            onChanged:
                disabled ? null : (v) => setState(() => verticalValue = v),
          ),
          const Spacer(),
          Text('Output:\n${verticalValue.toInt()}'),
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
