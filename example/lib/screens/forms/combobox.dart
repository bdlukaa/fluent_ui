import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'auto_suggest_box.dart';

class ComboboxPage extends ScrollablePage {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20.0;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboboxState>();

  @override
  Widget buildHeader(BuildContext context) {
    return PageHeader(
      title: const Text('Combobox'),
      commandBar: ToggleSwitch(
        checked: disabled,
        onChanged: (v) {
          setState(() => disabled = v);
        },
        content: const Text('Disabled'),
      ),
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

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'Use a ComboBox when you need to conserve on-screen space and when users select only one option at a time. A ComboBox shows only the currently selected item.',
      ),
      subtitle(
        content: const Text(
          'A Combobox with items defined inline and its width set',
        ),
      ),
      CardHighlight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Combobox<String>(
            isExpanded: false,
            comboboxColor: colors[selectedColor],
            value: selectedColor,
            items: colors.entries.map((e) {
              return ComboboxItem(
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
            margin: const EdgeInsets.only(top: 8.0),
            height: 30,
            width: 100,
            color: colors[selectedColor],
          ),
        ]),
        codeSnippet: '''// Green by default
Color selectedColor = 'Green';

Combobox<String>(
  value: selectedColor,
  items: colors.entries.map((e) {
    return ComboboxItem(
      child: Text(e.key),
      value: e.key,
    );
  }).toList(),
  onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
),''',
      ),
      subtitle(
        content: const Text('A Combobox with a long list of items'),
      ),
      CardHighlight(
        child: Wrap(spacing: 10.0, runSpacing: 10.0, children: [
          Combobox<String>(
            isExpanded: false,
            value: selectedCat,
            items: cats.map<ComboboxItem<String>>((e) {
              return ComboboxItem<String>(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: disabled
                ? null
                : (color) {
                    setState(() => selectedCat = color);
                  },
            placeholder: const Text('Select a cat breed'),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            height: 30,
            child: Text(selectedCat ?? ''),
          ),
        ]),
        codeSnippet: '''List<String> cats= [...];

Combobox<String>(
  value: selectedCat,
  items: cats.map<ComboboxItem<String>>((e) {
    return ComboboxItem<String>(
      child: Text(e),
      value: e,
    );
  }).toList(),
  onChanged: disabled
      ? null
      : (color) {
          setState(() => selectedCat = color);
        },
  placeholder: const Text('Select a cat breed'),
),''',
      ),
      subtitle(
        content: const Text('An editable Combobox'),
      ),
      CardHighlight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 150,
            child: EditableCombobox<int>(
              isExpanded: false,
              value: fontSize.toInt(),
              items: fontSizes.map<ComboboxItem<int>>((fontSize) {
                return ComboboxItem<int>(
                  child: Text('${fontSize.toInt()}'),
                  value: fontSize.toInt(),
                );
              }).toList(),
              onChanged: disabled
                  ? null
                  : (size) {
                      setState(() => fontSize = (size ?? fontSize).toDouble());
                    },
              placeholder: const Text('Font size'),
              onFieldSubmitted: (text) {
                try {
                  final newSize = int.parse(text);

                  if (newSize < 8 || newSize > 100) {
                    throw UnsupportedError(
                      'The font size must be a number between 8 and 100.',
                    );
                  }

                  setState(() => fontSize = newSize.toDouble());
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        content: const Text(
                          'The font size must be a number between 8 and 100.',
                        ),
                        actions: [
                          FilledButton(
                            child: const Text('Close'),
                            onPressed: Navigator.of(context).pop,
                          ),
                        ],
                      );
                    },
                  );
                }
                return '${fontSize.toInt()}';
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            constraints: const BoxConstraints(minHeight: 50.0),
            child: Text(
              'You can set the font size for this text',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ]),
        codeSnippet: '''static const fontSizes = <double>[
  8,
  9,
  ...,
];

double fontSize = 20.0;

EditableCombobox<int>(
  value: fontSize.toInt(),
  items: cats.map<ComboboxItem<int>>((e) {
    return ComboboxItem<int>(
      child: Text('\$e'),
      value: e.toInt(),
    );
  }).toList(),
  onChanged: disabled
      ? null
      : (size) {
          setState(() => fontSize = size?.toDouble() ?? fontSize);
        },
  placeholder: const Text('Select a font size'),
  onFieldSubmitted: (String text) {
    // When the value in the text field is changed, this callback is called
    // It's up to the developer to handle the text change

    try {
      final newSize = int.parse(text);

      if (newSize < 8 || newSize > 100) {
        throw UnsupportedError(
          'The font size must be a number between 8 and 100.',
        );
      }

      setState(() => fontSize = newSize.toDouble());
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            content: const Text(
              'The font size must be a number between 8 and 100.',
            ),
            actions: [
              FilledButton(
                child: const Text('Close'),
                onPressed: Navigator.of(context).pop,
              ),
            ],
          );
        },
      );
    }
    return fontSize.toInt().toString();
  },
),''',
      ),
      subtitle(content: const Text('A Combobox Form Field')),
      CardHighlight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Form(
            autovalidateMode: AutovalidateMode.always,
            child: ComboboxFormField<String>(
              comboboxColor: colors[selectedColor],
              value: selectedColor,
              items: colors.entries.map((e) {
                return ComboboxItem(
                  child: Text(e.key),
                  value: e.key,
                );
              }).toList(),
              onChanged: disabled
                  ? null
                  : (color) => setState(() => selectedColor = color),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Please provide a value';
                }

                final acceptedValues = colors.keys.skip(4);

                if (!acceptedValues.contains(text)) {
                  return '$text is not a valid value today';
                }

                return null;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            height: 30,
            width: 100,
            color: colors[selectedColor],
          ),
        ]),
        codeSnippet: '''// Green by default
Color selectedColor = 'Green';

Combobox<String>(
  value: selectedColor,
  items: colors.entries.map((e) {
    return ComboboxItem(
      child: Text(e.key),
      value: e.key,
    );
  }).toList(),
  onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
),''',
      ),
      subtitle(content: const Text('Open popup programatically')),
      CardHighlight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Combobox<String>(
            key: comboboxKey,
            isExpanded: false,
            comboboxColor: colors[selectedColor],
            value: selectedColor,
            items: colors.entries.map((e) {
              return ComboboxItem(
                child: Text(e.key),
                value: e.key,
              );
            }).toList(),
            onChanged: disabled
                ? null
                : (color) => setState(() => selectedColor = color),
          ),
          const SizedBox(width: 8.0),
          Button(
            child: const Text('Open popup'),
            onPressed: () => comboboxKey.currentState?.openPopup(),
          )
        ]),
        codeSnippet:
            '''// A GlobalKey<ComboboxState> is used to access the current
// state of the combobox. With it, it's possible to call .openPopup() and .closePopup()
// which will open and close the popup, respectively
//
// It is possible to use the key with Combobox and EditableCombobox
final comboboxKey = GlobalKey<ComboboxState>();

Combobox<String>(
  key: comboboxKey,
  // define the other properties here
  ...
),

Button(
  child: const Text('Open popup'),
  onPressed: () => comboboxKey.currentState?.openPopup(),
),''',
      ),
    ];
  }
}
