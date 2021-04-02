import 'package:fluent_ui/fluent_ui.dart';

class Forms extends StatefulWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  final autoSuggestBox = TextEditingController();

  final _clearController = TextEditingController();
  bool _showPassword = false;

  final values = ['Blue', 'Green', 'Yellow', 'Red'];
  String? comboBoxValue;

  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBox(
          header: 'Email',
          placeholder: 'Type your email here :)',
        ),
        SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: TextBox(
              readOnly: true,
              placeholder: 'Read only text box',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextBox(
              enabled: false,
              placeholder: 'Disabled text box',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: AutoSuggestBox<String>(
              controller: autoSuggestBox,
              items: [
                'Blue',
                'Green',
                'Red',
                'Yellow',
                'Grey',
              ],
              onSelected: (text) {
                print(text);
              },
              textBoxBuilder: (context, controller, focusNode, key) {
                const BorderSide _kDefaultRoundedBorderSide = BorderSide(
                  style: BorderStyle.solid,
                  width: 0.8,
                );
                return TextBox(
                  key: key,
                  controller: controller,
                  focusNode: focusNode,
                  suffixMode: OverlayVisibilityMode.editing,
                  suffix: IconButton(
                    icon: Icon(Icons.pane_close),
                    onPressed: () {
                      controller.clear();
                      focusNode.unfocus();
                    },
                  ),
                  placeholder: 'Type a color',
                  decoration: BoxDecoration(
                    border: Border(
                      top: _kDefaultRoundedBorderSide,
                      bottom: _kDefaultRoundedBorderSide,
                      left: _kDefaultRoundedBorderSide,
                      right: _kDefaultRoundedBorderSide,
                    ),
                    borderRadius: focusNode.hasFocus
                        ? BorderRadius.vertical(top: Radius.circular(3.0))
                        : BorderRadius.all(Radius.circular(3.0)),
                  ),
                );
              },
            ),
          ),
        ]),
        SizedBox(height: 20),
        TextBox(
          maxLines: null,
          controller: _clearController,
          suffixMode: OverlayVisibilityMode.always,
          minHeight: 100,
          suffix: IconButton(
            icon: Icon(Icons.share_close_tray_filled),
            style: IconButtonStyle(
              // padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
            onPressed: () {
              _clearController.clear();
            },
          ),
          placeholder: 'Text box with clear button',
        ),
        SizedBox(height: 20),
        TextBox(
          header: 'Password',
          placeholder: 'Type your placeholder here',
          obscureText: !_showPassword,
          maxLines: 1,
          suffixMode: OverlayVisibilityMode.editing,
          suffix: IconButton(
            icon: Icon(!_showPassword ? Icons.eye_show : Icons.eye_hide),
            onPressed: () => setState(() => _showPassword = !_showPassword),
            style: IconButtonStyle(margin: EdgeInsets.zero),
          ),
          outsideSuffix: Button(
            style: ButtonStyle(margin: EdgeInsets.symmetric(horizontal: 4)),
            text: Text('Done'),
            onPressed: () {},
          ),
        ),
        SizedBox(height: 20),
        Wrap(children: [
          SizedBox(
            width: 200,
            child: ComboBox<String>(
              header: 'Colors',
              placeholder: 'Selected list item',
              isExpanded: true,
              items: values
                  .map((e) => ComboboxMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              value: comboBoxValue,
              onChanged: (value) {
                print(value);
                if (value != null) setState(() => comboBoxValue = value);
              },
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 295,
            child: DatePicker(
              // popupHeight: kOneLineTileHeight * 6,
              header: 'Date of birth',
              selected: date,
              onChanged: (v) => setState(() => date = v),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 240,
            child: TimePicker(
              // popupHeight: kOneLineTileHeight * 5,
              header: 'Arrival time',
              selected: date,
              onChanged: (v) => setState(() => date = v),
            ),
          ),
        ]),
        SizedBox(height: 20),
      ],
    );
  }
}
