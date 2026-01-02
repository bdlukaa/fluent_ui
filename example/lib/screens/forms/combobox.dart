import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'auto_suggest_box.dart';

class ComboBoxPage extends StatefulWidget {
  const ComboBoxPage({super.key});

  @override
  State<ComboBoxPage> createState() => _ComboBoxPageState();
}

class _ComboBoxPageState extends State<ComboBoxPage> with PageMixin {
  String? selectedColor = 'Green';
  String? selectedCat;
  double fontSize = 20;
  bool disabled = false;
  final comboboxKey = GlobalKey<ComboBoxState>(debugLabel: 'Combobox Key');

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('ComboBox'),
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
          'Use a combo box (also known as a drop-down list) to present a list of '
          'items that a user can select from. A combo box starts in a compact '
          'state and expands to show a list of selectable items.\n\n'
          'When the combo box is closed, it either displays the current selection '
          'or is empty if there is no selected item. When the user expands the '
          'combo box, it displays the list of selectable items.\n\n'
          'Use a ComboBox when you need to conserve on-screen space and when '
          'users select only one option at a time. A ComboBox shows only the '
          'currently selected item.',
        ),
        subtitle(
          content: const Text(
            'A ComboBox with items defined inline and its width set',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
// Green by default
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ComboBox<String>(
                popupColor: colors[selectedColor],
                value: selectedColor,
                items: colors.entries.map((final e) {
                  return ComboBoxItem(value: e.key, child: Text(e.key));
                }).toList(),
                onChanged: disabled
                    ? null
                    : (final color) {
                        setState(() => selectedColor = color);
                      },
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(top: 8),
                height: 30,
                width: 100,
                color: colors[selectedColor],
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A ComboBox with a long list of items')),
        CodeSnippetCard(
          codeSnippet: '''
List<String> cats= [...];

ComboBox<String>(
  value: selectedCat,
  items: cats.map<ComboBoxItem<String>>((e) {
    return ComboBoxItem<String>(
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
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ComboBox<String>(
                value: selectedCat,
                items: cats.map<ComboBoxItem<String>>((final e) {
                  return ComboBoxItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: disabled
                    ? null
                    : (final color) {
                        setState(() => selectedCat = color);
                      },
                placeholder: const Text('Select a cat breed'),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(top: 8),
                height: 30,
                child: Text(selectedCat ?? ''),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('An editable ComboBox')),
        description(
          content: const Text(
            'By default, a combo box lets the user select from a pre-defined '
            'list of options. However, there are cases where the list contains '
            'only a subset of valid values, and the user should be able to enter '
            "other values that aren't listed. To support this, you can make the"
            ' combo box editable.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: r'''
static const fontSizes = <double>[
  8,
  9,
  ...,
];

double fontSize = 20.0;

EditableComboBox<int>(
  value: fontSize.toInt(),
  items: cats.map<ComboBoxItem<int>>((e) {
    return ComboBoxItem<int>(
      child: Text('$e'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: EditableComboBox<int>(
                  value: fontSize.toInt(),
                  items: fontSizes.map<ComboBoxItem<int>>((final fontSize) {
                    return ComboBoxItem<int>(
                      value: fontSize.toInt(),
                      child: Text('${fontSize.toInt()}'),
                    );
                  }).toList(),
                  onChanged: disabled
                      ? null
                      : (final size) {
                          setState(
                            () => fontSize = (size ?? fontSize).toDouble(),
                          );
                        },
                  placeholder: const Text('Font size'),
                  onFieldSubmitted: (final text) {
                    try {
                      final newSize = double.parse(text);

                      if (newSize < 8 || newSize > 100) {
                        throw UnsupportedError(
                          'The font size must be a number between 8 and 100.',
                        );
                      }

                      setState(() => fontSize = newSize);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (final context) {
                          return ContentDialog(
                            content: const Text(
                              'The font size must be a number between 8 and 100.',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Close'),
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
                margin: const EdgeInsetsDirectional.only(top: 8),
                constraints: const BoxConstraints(minHeight: 50),
                child: Text(
                  'You can set the font size for this text',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A ComboBox Form Field')),
        CodeSnippetCard(
          codeSnippet: r'''
Map<String, Color> colors = { ... };
Color selectedColor = 'Green';

Form(
  autovalidateMode: AutovalidateMode.always,
  child: ComboboxFormField<String>(
    value: selectedColor,
    items: colors.entries.map((e) {
      return ComboBoxItem(
        child: Text(e.key),
        value: e.key,
      );
    }).toList(),
    onChanged: disabled ? null : (color) => setState(() => selectedColor = color),
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
),''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: ComboboxFormField<String>(
                  popupColor: colors[selectedColor],
                  value: selectedColor,
                  items: colors.entries.map((final e) {
                    return ComboBoxItem(value: e.key, child: Text(e.key));
                  }).toList(),
                  onChanged: disabled
                      ? null
                      : (final color) => setState(() => selectedColor = color),
                  validator: (final text) {
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
                margin: const EdgeInsetsDirectional.only(top: 8),
                height: 30,
                width: 100,
                color: colors[selectedColor],
              ),
            ],
          ),
        ),
        subtitle(content: const Text('Open popup programatically')),
        CodeSnippetCard(
          codeSnippet: '''
// A GlobalKey<ComboboxState> is used to access the current
// state of the combo box. With it, it's possible to call .openPopup() and .closePopup()
// which will open and close the popup, respectively
//
// It is possible to use the key with ComboBox and EditableComboBox
final comboboxKey = GlobalKey<ComboboxState>(debugLabel: 'Combobox Key');

ComboBox<String>(
  key: comboboxKey,
  // define the other properties here
  ...
),

Button(
  child: const Text('Open popup'),
  onPressed: () => comboboxKey.currentState?.openPopup(),
),''',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ComboBox<String>(
                key: comboboxKey,
                popupColor: colors[selectedColor],
                value: selectedColor,
                items: colors.entries.map((final e) {
                  return ComboBoxItem(value: e.key, child: Text(e.key));
                }).toList(),
                onChanged: disabled
                    ? null
                    : (final color) => setState(() => selectedColor = color),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: disabled
                    ? null
                    : () => comboboxKey.currentState?.openPopup(),
                child: const Text('Open popup'),
              ),
            ],
          ),
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
