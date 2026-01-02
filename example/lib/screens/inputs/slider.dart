import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> with PageMixin {
  bool disabled = false;
  double firstValue = 23;
  double verticalValue = 50;

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Slider'),
        commandBar: ToggleSwitch(
          checked: disabled,
          onChanged: (final v) => setState(() => disabled = v),
          content: const Text('Disabled'),
        ),
      ),
      children: [
        const Text(
          'Use a Slider when you want your users to be able to set defined, '
          'contiguous values (such as volume or brightness) or a range of discrete '
          'values (such as screen resolution settings).\n\n'
          'A slider is a good choice when you know that users think of the value '
          'as a relative quantity, not a numeric value. For example, users think '
          'about setting their audio volume to low or medium—not about setting '
          'the value to 2 or 5.',
        ),
        subtitle(content: const Text('A simple Slider')),
        CodeSnippetCard(
          codeSnippet: r'''
double value = 0;

Slider(
  label: '${value.toInt()}',
  value: value,
  onChanged: disabled ? null : (v) => setState(() => value = v),
),
''',
          child: Row(
            children: [
              Slider(
                label: '${firstValue.toInt()}',
                value: firstValue,
                onChanged: disabled
                    ? null
                    : (final v) {
                        setState(() => firstValue = v);
                      },
              ),
              const Spacer(),
              Text('Output:\n${firstValue.toInt()}'),
            ],
          ),
        ),
        subtitle(content: const Text('A vertical slider')),
        description(
          content: const Text(
            '''
You can orient your slider horizontally or vertically. Use these guidelines to determine which layout to use.

    *   Use a natural orientation. For example, if the slider represents a real-world value that is normally shown vertically (such as temperature), use a vertical orientation.
    *   If the control is used to seek within media, like in a video app, use a horizontal orientation.
    *   When using a slider in page that can be panned in one direction (horizontally or vertically), use a different orientation for the slider than the panning direction. Otherwise, users might swipe the slider and change its value accidentally when they try to pan the page.
    *   If you're still not sure which orientation to use, use the one that best fits your page layout.''',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
double value = 0;

Slider(
  vertical: true,
  label: '${value.toInt()}',
  value: value,
  onChanged: disabled ? null : (v) => setState(() => value = v),
),
''',
          child: Row(
            children: [
              Slider(
                vertical: true,
                label: '${verticalValue.toInt()}',
                value: verticalValue,
                onChanged: disabled
                    ? null
                    : (final v) => setState(() => verticalValue = v),
              ),
              const Spacer(),
              Text('Output:\n${verticalValue.toInt()}'),
            ],
          ),
        ),
      ],
    );
  }
}
