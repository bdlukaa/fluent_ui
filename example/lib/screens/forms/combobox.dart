import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ComboboxPage extends ScrollablePage {
  PageState state = {
    'selected_color': 'Green',
    'disabled': false,
  };

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
      Card(
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 200,
                child: Combobox<String>(
                  value: state['selected_color'],
                  items: colors.entries.map((e) {
                    return ComboboxItem(
                      child: Text(e.key),
                      value: e.key,
                      onTap: () => setState(
                        () => state['selected_color'] = e.key,
                      ),
                    );
                  }).toList(),
                  onChanged: state['disabled']
                      ? null
                      : (color) {
                          setState(() => state['selected_color'] = color);
                        },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                height: 30,
                width: 100,
                color: colors[state['selected_color']],
              ),
            ]),
          ),
          ToggleSwitch(
            checked: state['disabled'],
            onChanged: (v) {
              setState(() => state['disabled'] = v);
            },
            content: const Text('Disabled'),
          ),
        ]),
      ),
    ];
  }
}
