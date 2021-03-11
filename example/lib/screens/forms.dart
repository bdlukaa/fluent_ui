import 'package:fluent_ui/fluent_ui.dart';

class Forms extends StatefulWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  final _clearController = TextEditingController();
  bool _showPassword = false;

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
        TextBox(
          readOnly: true,
          placeholder: 'Read only text box',
        ),
        SizedBox(height: 20),
        TextBox(
          enabled: false,
          placeholder: 'Disabled text box',
        ),
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
        TextBox(
          header: 'Password',
          placeholder: 'Type your placeholder here',
          obscureText: !_showPassword,
          maxLines: 1,
          suffixMode: OverlayVisibilityMode.editing,
          suffix: IconButton(
            icon: Icon(!_showPassword
                ? Icons.eye_show_regular
                : Icons.eye_hide_regular),
            onPressed: () => setState(() => _showPassword = !_showPassword),
            style: IconButtonStyle(margin: EdgeInsets.zero),
          ),
          outsideSuffix: Button(
            style: ButtonStyle(margin: EdgeInsets.symmetric(horizontal: 4)),
            text: Text('Done'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
