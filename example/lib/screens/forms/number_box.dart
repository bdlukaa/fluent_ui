import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'auto_suggest_box.dart';

class NumberBoxPage extends StatefulWidget {
  const NumberBoxPage({Key? key}) : super(key: key);

  @override
  State<NumberBoxPage> createState() => _NumberBoxPageState();
}

class _NumberBoxPageState extends State<NumberBoxPage> with PageMixin {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20.0;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboBoxState>(debugLabel: 'Combobox Key');

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
          'Use a number box to select a number. '
          'The selection can be applied in compact or in inline mode.'
        ),
        subtitle(
          content: const Text(
            'A NumberBox',
          ),
        ),
        CardHighlight(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                NumberBox(value: 0, onChanged: null),
            /*ComboBox<String>(
              isExpanded: false,
              popupColor: colors[selectedColor],
              value: selectedColor,
              items: colors.entries.map((e) {
                return ComboBoxItem(
                  child: Text(e.key),
                  value: e.key,
                );
              }).toList(),
              onChanged: disabled
                  ? null
                  : (color) {
                      setState(() => selectedColor = color);
                    },
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(top: 8.0),
              height: 30,
              width: 100,
              color: colors[selectedColor],
            ),*/
          ]),
          codeSnippet: '''// Green by default
Color selectedColor = 'Green';

ComboBox<String>(
  value: selectedColor,
  items: colors.entries.map((e) {
    return ComboBoxItem(
      child: Text(e.key),
      value: e.key,
    );
  }).toList(),
  onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
),''',
        ),
      ],
    );
  }

  Map<String, Color> colors = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
    'Grey': Colors.grey,
    'Magenta': Colors.magenta,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
  };

  static const fontSizes = <double>[
    8,
    9,
    10,
    11,
    12,
    14,
    16,
    18,
    20,
    24,
    28,
    36,
    48,
    72,
  ];
}
