// ignore_for_file: prefer_const_constructors

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/card_highlight.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> with PageMixin {
  bool simpleDisabled = false;
  bool filledDisabled = false;
  bool iconDisabled = false;
  bool toggleDisabled = false;
  bool toggleState = false;
  bool splitButtonDisabled = false;
  bool radioButtonDisabled = false;
  int radioButtonSelected = -1;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Button')),
      children: [
        const Text(
          'The Button control provides a Click event to respond to user input from a touch, mouse, keyboard, stylus, or other input device. You can put different kinds of content in a button, such as text or an image, or you can restyle a button to give it a new look.',
        ),
        subtitle(content: const Text('A simple button with text content')),
        description(
          content: const Text('A button that initiates an immediate action.'),
        ),
        CardHighlight(
          child: Row(children: [
            Button(
              child: const Text('Standart Button'),
              onPressed: simpleDisabled ? null : () {},
            ),
            const Spacer(),
            ToggleSwitch(
              checked: simpleDisabled,
              onChanged: (v) {
                setState(() {
                  simpleDisabled = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ]),
          codeSnippet: '''Button(
  child: const Text('Standart Button'),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''',
        ),
        subtitle(content: const Text('Accent Style applied to Button')),
        CardHighlight(
          child: Row(children: [
            FilledButton(
              child: const Text('Filled Button'),
              onPressed: filledDisabled ? null : () {},
            ),
            const Spacer(),
            ToggleSwitch(
              checked: filledDisabled,
              onChanged: (v) {
                setState(() {
                  filledDisabled = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ]),
          codeSnippet: '''FilledButton(
  child: const Text('Filled Button'),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''',
        ),
        subtitle(
          content: const Text('A Button with graphical content (IconButton)'),
        ),
        CardHighlight(
          child: Row(children: [
            IconButton(
              icon: const Icon(FluentIcons.graph_symbol, size: 24.0),
              onPressed: iconDisabled ? null : () {},
            ),
            const Spacer(),
            ToggleSwitch(
              checked: iconDisabled,
              onChanged: (v) {
                setState(() {
                  iconDisabled = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ]),
          codeSnippet: '''IconButton(
  icon: const Icon(FluentIcons.graph_symbol, size: 24.0),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''',
        ),
        subtitle(
            content: const Text('A simple ToggleButton with text content')),
        description(
          content: const Text(
            'A ToggleButton looks like a Button, but works like a CheckBox. It '
            'typically has two states, checked (on) or unchecked (off).',
          ),
        ),
        CardHighlight(
          child: Row(children: [
            ToggleButton(
              child: const Text('Toggle Button'),
              checked: toggleState,
              onChanged: toggleDisabled
                  ? null
                  : (v) {
                      setState(() {
                        toggleState = v;
                      });
                    },
            ),
            const Spacer(),
            ToggleSwitch(
              checked: toggleDisabled,
              onChanged: (v) {
                setState(() {
                  toggleDisabled = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ]),
          codeSnippet: '''bool checked = false;

ToggleButton(
  child: const Text('Toggle Button'),
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
)''',
        ),
        subtitle(content: const Text('DropDownButton')),
        const Text(
          'A control that drops down a flyout of choices from which one can be chosen',
        ),
        CardHighlight(
          child: Row(children: [
            DropDownButton(
              title: Text('Email'),
              items: [
                MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
                MenuFlyoutItem(text: const Text('Reply'), onPressed: () {}),
                MenuFlyoutItem(text: const Text('Reply all'), onPressed: () {}),
              ],
            ),
            SizedBox(width: 10.0),
            DropDownButton(
              title: Icon(FluentIcons.edit_mail, size: 22.0),
              items: [
                MenuFlyoutItem(
                  leading: Icon(FluentIcons.send),
                  text: const Text('Send'),
                  onPressed: () {},
                ),
                MenuFlyoutItem(
                  leading: Icon(FluentIcons.reply),
                  text: const Text('Reply'),
                  onPressed: () {},
                ),
                MenuFlyoutItem(
                  leading: Icon(FluentIcons.reply_all),
                  text: const Text('Reply all'),
                  onPressed: () {},
                ),
              ],
            ),
          ]),
          codeSnippet: '''DropDownButton(
  title: Text('Email'),
  items: [
    MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
    MenuFlyoutItem(text: const Text('Reply'), onPressed: () {}),
    MenuFlyoutItem(text: const Text('Reply all'), onPressed: () {}),
  ],
)''',
        ),
        subtitle(content: const Text('SplitButton')),
        description(
          content: const Text(
            'Represents a button with two parts that can be invoked separately. '
            'One part behaves like a standard button and the other part invokes '
            'a flyout.',
          ),
        ),
        CardHighlight(
          child: Row(children: [
            SplitButtonBar(
              buttons: [
                Button(
                  child: Container(
                    decoration: BoxDecoration(
                      color: splitButtonDisabled
                          ? FluentTheme.of(context).accentColor.darker
                          : FluentTheme.of(context).accentColor,
                      borderRadius: const BorderRadiusDirectional.horizontal(
                        start: Radius.circular(4.0),
                      ),
                    ),
                    height: 24,
                    width: 24,
                  ),
                  onPressed: splitButtonDisabled ? null : () {},
                ),
                IconButton(
                  icon: const SizedBox(
                    // height: splitButtonHeight,
                    child: Icon(FluentIcons.chevron_down, size: 10.0),
                  ),
                  onPressed: splitButtonDisabled ? null : () {},
                ),
              ],
            ),
            const Spacer(),
            ToggleSwitch(
              checked: splitButtonDisabled,
              onChanged: (v) {
                setState(() {
                  splitButtonDisabled = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ]),
          codeSnippet: '''SplitButtonBar(
  buttons: [
    Button(
      child: Container(
        height: 24.0,
        width: 24.0,
        color: Colors.green,
      ),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(FluentIcons.chevron_down, size: 10.0),
      onPressed: () {},
    ),
  ],
)''',
        ),
        subtitle(content: const Text('RadioButton')),
        description(
          content: const Text(
            'Radio buttons, also called option buttons, let users select one option '
            'from a collection of two or more mutually exclusive, but related, '
            'options. Radio buttons are always used in groups, and each option is '
            'represented by one radio button in the group.',
          ),
        ),
        CardHighlight(
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == 2 ? 0.0 : 14.0),
                    child: RadioButton(
                      checked: radioButtonSelected == index,
                      onChanged: radioButtonDisabled
                          ? null
                          : (v) {
                              if (v) {
                                setState(() {
                                  radioButtonSelected = index;
                                });
                              }
                            },
                      content: Text('RadioButton ${index + 1}'),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            ToggleSwitch(
              checked: radioButtonDisabled,
              onChanged: (v) {
                setState(() {
                  radioButtonDisabled = v;
                });
              },
              content: const Text('Disabled'),
            )
          ]),
          codeSnippet: '''int? selected;

Column(
  children: List.generate(3, (index) {
    return RadioButton(
      checked: selected == index,
      onChanged: (checked) {
        if (checked) {
          setState(() => selected = index);
        }
      }
    );
  }),
)''',
        ),
      ],
    );
  }
}
