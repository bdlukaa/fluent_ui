import 'package:fluent_ui/fluent_ui.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({Key? key}) : super(key: key);

  @override
  _InputsPageState createState() => _InputsPageState();
}

TextStyle get cardTitleTextStyle => TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

class _InputsPageState extends State<InputsPage> {
  bool value = false;

  double sliderValue = 5;
  double get max => 9;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(children: [
        _buildButtons(),
        _buildCheckboxes(),
        _buildToggleSwitches(),
        _buildRadioButtons(),
        _buildSliders(),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ContentDialog(
                    title: Text('Delete file permanently?'),
                    content: Text(
                      'If you delete this file, you won\'t be able to recover it. Do you want to delete it?',
                    ),
                    actions: [
                      Button(
                        text: Text('Delete'),
                        onPressed: () {
                          // Delete file here
                        },
                      ),
                      Button(
                        text: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
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
              icon: Icon(Icons.add_regular),
              onPressed: () => print('pressed icon button'),
            ),
            SplitButtonBar(
              buttons: List.generate(2, (index) {
                return SplitButton(
                  child: Text('$index'),
                  onPressed: () => print(index),
                );
              }),
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

  Widget _buildSliders() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sliders', style: cardTitleTextStyle),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 200,
            child: Slider(
              max: max,
              label: '${sliderValue.toInt()}',
              value: sliderValue,
              onChanged: (v) => setState(() => sliderValue = v),
              divisions: 10,
            ),
          ),
          SizedBox(height: 12),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 200,
            child: Slider(
              max: max,
              value: sliderValue,
              onChanged: null,
            ),
          ),
          RatingBar(
            amount: max.toInt(),
            rating: sliderValue,
            onChanged: (v) => setState(() => sliderValue = v),
          ),
        ],
      ),
    );
  }
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
