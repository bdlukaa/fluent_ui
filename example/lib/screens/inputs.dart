import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart' as m;

class InputsPage extends StatefulWidget {
  const InputsPage({Key? key}) : super(key: key);

  @override
  _InputsPageState createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  TextStyle? get titleTextStyle => context.theme!.typography?.base;
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
      ], runSpacing: 10, spacing: 10),
    );
  }

  Widget _buildButtons() {
    final splitButtonHeight = 50.0;
    return Acrylic(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buttons', style: titleTextStyle),
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
            Button(text: Text('Disabled button'), onPressed: null),
            ToggleButton(
              child: Text('Toggle Button'),
              checked: value,
              onChanged: (value) => setState(() => this.value = value),
            ),
            Button.icon(
              icon: Icon(Icons.add),
              onPressed: () => print('pressed icon button'),
            ),
            SplitButtonBar(buttons: [
              SizedBox(
                height: splitButtonHeight,
                child: Button(
                  text: Container(
                    color: context.theme!.accentColor,
                    height: 24,
                    width: 24,
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                height: splitButtonHeight,
                child: Button(
                  text: Icon(Icons.chevron_down),
                  onPressed: () {},
                  style: ButtonStyle(padding: EdgeInsets.all(6)),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Acrylic(
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Checkboxes', style: titleTextStyle),
        ...buildStateColumn(context, [
          Checkbox(checked: false, onChanged: (v) {}),
          Checkbox(checked: true, onChanged: (v) {}),
          Checkbox(checked: null, onChanged: (v) {}),
          Checkbox(checked: true, onChanged: null),
        ], [
          'Unchecked',
          'Checked',
          'Third state',
          'Disabled',
        ]),
      ]),
    );
  }

  Widget _buildToggleSwitches() {
    return Acrylic(
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Toggles', style: titleTextStyle),
        ...buildStateColumn(context, [
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
      ]),
    );
  }

  Widget _buildRadioButtons() {
    return Acrylic(
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Radio Buttons', style: titleTextStyle),
        ...buildStateColumn(
          context,
          [
            RadioButton(checked: false, onChanged: (v) {}),
            RadioButton(checked: true, onChanged: (v) {}),
            RadioButton(checked: false, onChanged: null),
            RadioButton(checked: true, onChanged: null),
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
      ]),
    );
  }

  Widget _buildSliders() {
    return Acrylic(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sliders', style: titleTextStyle),
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

List<Widget> buildStateColumn(
  BuildContext context,
  List<Widget> boxes,
  List<String> texts,
) {
  debugCheckHasFluentTheme(context);
  return List.generate(4, (index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        boxes[index],
        Text(texts[index], style: context.theme!.typography?.body),
      ],
    );
  });
}
