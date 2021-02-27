import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({Key key}) : super(key: key);

  @override
  _InputsPageState createState() => _InputsPageState();
}

TextStyle get cardTitleTextStyle => TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

class _InputsPageState extends State<InputsPage> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(children: [
        _buildButtons(),
        _buildCheckboxes(),
        _buildToggleSwitches(),
        _buildRadioButtons(),
      ]),
    );
  }

  Widget _buildButtons() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buttons', style: cardTitleTextStyle),
          ...[
            Button(
              text: Text('Enabled button'),
              onPressed: () {},
            ),
            Button(
              text: Text('Disabled button'),
              onPressed: null,
            ),
            ToggleButton(
              child: Text('Toggle Button'),
              checked: value,
              onChanged: (value) => setState(() => this.value = value),
            ),
            Button.icon(
              icon: Icon(FluentSystemIcons.ic_fluent_add_regular),
              onPressed: () {},
            ),
            // DropDownButton(
            //   content: Text('Hover me :)'),
            //   dropdown: Dropdown.sections(
            //     sectionTitles: [Text('title'), Text('ajaa')],
            //     sectionBodies: [Text('body'), Text('haha')],
            //   ),
            // ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkboxes', style: cardTitleTextStyle),
          ...buildStateColumn([
            Checkbox(checked: false, onChanged: (v) {}),
            Checkbox(checked: true, onChanged: (v) {}),
            Checkbox(checked: null, onChanged: (v) {}),
            Checkbox(checked: true, onChanged: null),
          ], [
            'Checked',
            'Unchecked',
            'Third state',
            'Disabled',
          ]),
        ],
      ),
    );
  }

  Widget _buildToggleSwitches() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Toggles', style: cardTitleTextStyle),
          ...buildStateColumn([
            ToggleSwitch(checked: false, onChanged: (v) {}),
            ToggleSwitch(checked: true, onChanged: (v) {}),
            ToggleSwitch(checked: false, onChanged: null),
            ToggleSwitch(checked: true, onChanged: null),
          ], [
            'Off',
            'On',
            'Disabled Off',
            'Disabled On',
          ]),
        ],
      ),
    );
  }

  Widget _buildRadioButtons() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Radio Buttons', style: cardTitleTextStyle),
          ...buildStateColumn(
            [
              RadioButton(selected: false, onChanged: (v) {}),
              RadioButton(selected: true, onChanged: (v) {}),
              RadioButton(selected: false, onChanged: null),
              RadioButton(selected: true, onChanged: null),
            ]
                .map((e) => Padding(
                      padding: EdgeInsets.all(5),
                      child: e,
                    ))
                .toList(),
            [
              'Off',
              'On',
              'Disabled Off',
              'Disabled On',
            ],
          ),
        ],
      ),
    );
  }
}

void a(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        title: Text('Missing Subject'),
        body: Text(
          'Do you want to send this message without a subject?',
        ),
        footer: [
          Button(
            text: Text('Save'),
            onPressed: () {},
          ),
          Button(
            text: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

List<Widget> buildStateColumn(List<Widget> boxes, List<String> texts) {
  return List.generate(4, (index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxes[index],
        Text(texts[index]),
      ],
    );
  });
}
