import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class NumberBoxPage extends StatefulWidget {
  const NumberBoxPage({super.key});

  @override
  State<NumberBoxPage> createState() => _NumberBoxPageState();
}

class _NumberBoxPageState extends State<NumberBoxPage> with PageMixin {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20.0;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboBoxState>(debugLabel: 'Combobox Key');

  int? numberBoxValue = 0;
  int? numberBoxValueMinMax = 0;
  double? numberBoxValueDouble = 0;

  void _valueChanged(int? newValue) {
    setState(() {
      numberBoxValue = newValue;
    });
  }

  void _valueChangedMinMax(int? newValue) {
    setState(() {
      numberBoxValueMinMax = newValue;
    });
  }

  void _valueChangedDouble(double? newValue) {
    setState(() {
      numberBoxValueDouble = newValue;
    });
  }

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
        const Text('Use a number box to select a number. '
            'The selection can be applied in compact or in inline mode.'),
        subtitle(
          content: const Text(
            'A NumberBox in inline mode',
          ),
        ),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValue,
  onChanged: _valueChanged,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValue,
              onChanged: disabled ? null : _valueChanged,
              mode: SpinButtonPlacementMode.inline,
            ),
          ]),
        ),
        subtitle(
          content: const Text(
            'A NumberBox in compact mode',
          ),
        ),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
  mode: SpinButtonPlacementMode.compact,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValue,
              onChanged: disabled ? null : _valueChanged,
              mode: SpinButtonPlacementMode.compact,
            ),
          ]),
        ),
        subtitle(
          content: const Text(
            'A NumberBox in none mode',
          ),
        ),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
  mode: SpinButtonPlacementMode.none,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValue,
              onChanged: disabled ? null : _valueChanged,
              mode: SpinButtonPlacementMode.none,
            ),
          ]),
        ),
        subtitle(
          content: const Text(
            'A NumberBox with a min (0) and a max (20) value',
          ),
        ),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValueMinMax,
  min: 0,
  max: 20,
  onChanged: disabled ? null : _valueChangedMinMax,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValueMinMax,
              onChanged: disabled ? null : _valueChangedMinMax,
              min: 0,
              max: 20,
              mode: SpinButtonPlacementMode.inline,
            ),
          ]),
        ),
        subtitle(
          content: const Text(
            'A NumberBox mathematical expressions',
          ),
        ),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValueMinMax,
  onChanged: disabled ? null : _valueChangedMinMax,
  allowExpressions: true,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValueMinMax,
              onChanged: disabled ? null : _valueChangedMinMax,
              allowExpressions: true,
              mode: SpinButtonPlacementMode.inline,
            ),
          ]),
        ),
        subtitle(content: const Text('A NumberBox with double value')),
        CardHighlight(
          codeSnippet: '''NumberBox(
  value: numberBoxValueDouble,
  onChanged: disabled ? null : _valueChangedDouble,
  smallChange: 0.1,
  mode: SpinButtonPlacementMode.none,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberBox(
              value: numberBoxValueDouble,
              onChanged: disabled ? null : _valueChangedDouble,
              smallChange: 0.1,
              mode: SpinButtonPlacementMode.none,
            ),
          ]),
        ),
        subtitle(content: const Text('A NumberFormBox')),
        CardHighlight(
          codeSnippet: '''NumberFormBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
),
''',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NumberFormBox(
              value: numberBoxValue,
              onChanged: disabled ? null : _valueChanged,
              autovalidateMode: AutovalidateMode.always,
              validator: (v) {
                if (v == null || int.tryParse(v) == null) {
                  return 'Provide a valid number';
                }

                if (int.parse(v) > 10) {
                  return 'Provide a number smaller than 10';
                }

                return null;
              },
            ),
          ]),
        ),
      ],
    );
  }
}
