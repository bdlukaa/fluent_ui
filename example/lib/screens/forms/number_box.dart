import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class NumberBoxPage extends StatefulWidget {
  const NumberBoxPage({super.key});

  @override
  State<NumberBoxPage> createState() => _NumberBoxPageState();
}

class _NumberBoxPageState extends State<NumberBoxPage> with PageMixin {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboBoxState>(debugLabel: 'Combobox Key');

  int? numberBoxValue = 0;
  int? numberBoxValueMinMax = 0;
  double? numberBoxValueDouble = 0;
  double? numberBoxValueCurrency = 1234.56;

  final currencyFormat = NumberFormat.currency(symbol: r'$');

  void _valueChanged(final int? newValue) {
    setState(() {
      numberBoxValue = newValue;
    });
  }

  void _valueChangedMinMax(final int? newValue) {
    setState(() {
      numberBoxValueMinMax = newValue;
    });
  }

  void _valueChangedDouble(final double? newValue) {
    setState(() {
      numberBoxValueDouble = newValue;
    });
  }

  void _valueChangedCurrency(final double? newValue) {
    setState(() {
      numberBoxValueCurrency = newValue;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('NumberBox'),
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
          'Use a number box to select a number. '
          'The selection can be applied in compact or in inline mode.',
        ),
        subtitle(content: const Text('A NumberBox in inline mode')),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValue,
  onChanged: _valueChanged,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValue,
                onChanged: disabled ? null : _valueChanged,
                mode: SpinButtonPlacementMode.inline,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A NumberBox in compact mode')),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
  mode: SpinButtonPlacementMode.compact,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValue,
                onChanged: disabled ? null : _valueChanged,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A NumberBox in none mode')),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
  mode: SpinButtonPlacementMode.none,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValue,
                onChanged: disabled ? null : _valueChanged,
                mode: SpinButtonPlacementMode.none,
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'A NumberBox with a min (0) and a max (20) value',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValueMinMax,
  min: 0,
  max: 20,
  onChanged: disabled ? null : _valueChangedMinMax,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValueMinMax,
                onChanged: disabled ? null : _valueChangedMinMax,
                min: 0,
                max: 20,
                mode: SpinButtonPlacementMode.inline,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A NumberBox mathematical expressions')),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValueMinMax,
  onChanged: disabled ? null : _valueChangedMinMax,
  allowExpressions: true,
  mode: SpinButtonPlacementMode.inline,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValueMinMax,
                onChanged: disabled ? null : _valueChangedMinMax,
                allowExpressions: true,
                mode: SpinButtonPlacementMode.inline,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A NumberBox with double value')),
        CodeSnippetCard(
          codeSnippet: '''
NumberBox(
  value: numberBoxValueDouble,
  onChanged: disabled ? null : _valueChangedDouble,
  smallChange: 0.1,
  mode: SpinButtonPlacementMode.none,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox(
                value: numberBoxValueDouble,
                onChanged: disabled ? null : _valueChangedDouble,
                smallChange: 0.1,
                mode: SpinButtonPlacementMode.none,
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text('A NumberBox with custom format and parse'),
        ),
        description(
          content: const Text(
            'Use the format and parse parameters to display and input '
            'values with custom formatting, such as currency.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(symbol: r'$');

NumberBox<double>(
  value: numberBoxValueCurrency,
  onChanged: _valueChangedCurrency,
  format: (number) => number == null ? null : currencyFormat.format(number),
  parse: (text) {
    try {
      return currencyFormat.parse(text).toDouble();
    } catch (_) {
      return null;
    }
  },
  mode: SpinButtonPlacementMode.inline,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBox<double>(
                value: numberBoxValueCurrency,
                onChanged: disabled ? null : _valueChangedCurrency,
                format: (final number) =>
                    number == null ? null : currencyFormat.format(number),
                parse: (final text) {
                  try {
                    return currencyFormat.parse(text).toDouble();
                  } catch (_) {
                    return null;
                  }
                },
                mode: SpinButtonPlacementMode.inline,
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A NumberFormBox')),
        CodeSnippetCard(
          codeSnippet: '''
NumberFormBox(
  value: numberBoxValue,
  onChanged: disabled ? null : _valueChanged,
),
''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberFormBox(
                value: numberBoxValue,
                onChanged: disabled ? null : _valueChanged,
                autovalidateMode: AutovalidateMode.always,
                validator: (final v) {
                  if (v == null || int.tryParse(v) == null) {
                    return 'Provide a valid number';
                  }

                  if (int.parse(v) > 10) {
                    return 'Provide a number smaller than 10';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
