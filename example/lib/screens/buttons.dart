import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({Key key}) : super(key: key);

  @override
  _InputsPageState createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  bool value = false;

  TextStyle get cardTitleTextStyle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buttons', style: cardTitleTextStyle),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Button.compound(
                    text: Text('Next page'),
                    subtext: Text('Select ingredients'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            title: Text('Missing Subject'),
                            body: Text(
                              'Do you want to send this message without a subject?',
                            ),
                            footer: [
                              Button.primary(
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
                    },
                  ),
                  Button.action(
                    icon: Icon(FluentIcons.person_24_filled),
                    text: Text('Show snackbar'),
                    onPressed: () {
                      showSnackbar(
                        context: context,
                        snackbar: Snackbar(
                          title: Text('My beautiful snackbar'),
                          button: Button.primary(
                            text: Text('Button'),
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
                  Button.icon(
                    icon: Icon(FluentIcons.add_24_regular),
                    onPressed: () {},
                  ),
                  DropDownButton(
                    content: Text('Hover me :)'),
                    dropdown: Dropdown.sections(
                      sectionTitles: [Text('title'), Text('ajaa')],
                      sectionBodies: [Text('body'), Text('haha')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Toggles', style: cardTitleTextStyle),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ToggleSwitch(
                    checked: value,
                    onChanged: (v) => setState(() => value = v),
                  ),
                  Checkbox(
                    checked: value,
                    onChanged: (v) => setState(() => value = v),
                  ),
                  RadioButton(
                    selected: value,
                    onChanged: (v) => setState(() => value = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
