import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'auto_suggest_box.dart';

class ComboboxPage extends ScrollablePage {
  String? selectedColor = 'Green';
  String? selectedCat;
  bool disabled = false;

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Combobox'));
  }

  Map<String, Color> colors = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
  };

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
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Combobox<String>(
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  height: 30,
                  width: 100,
                  color: colors[selectedColor],
                ),
              ],
            ),
          ),
          ToggleSwitch(
            checked: disabled,
            onChanged: (v) {
              setState(() => disabled = v);
            },
            content: const Text('Disabled'),
          ),
        ]),
        codeSnippet: '''
// Green by default
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
)''',
      ),
      subtitle(
        content: const Text('A Combobox with a long list of items'),
      ),
      CardHighlight(
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: Combobox<String>(
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  height: 30,
                  width: 100,
                  child: Text(selectedCat ?? ''),
                ),
              ],
            ),
          ),
          ToggleSwitch(
            checked: disabled,
            onChanged: (v) {
              setState(() => disabled = v);
            },
            content: const Text('Disabled'),
          ),
        ]),
        codeSnippet: '''
List<String> cats=[...];

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
    ];
  }
}
