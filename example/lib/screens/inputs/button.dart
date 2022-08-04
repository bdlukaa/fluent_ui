// ignore_for_file: prefer_const_constructors

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/card_highlight.dart';

class ButtonPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'simple_disabled': false,
    'filled_disabled': false,
    'icon_disabled': false,
    'toggle_state': false,
    'toggle_disabled': false,
    'split_button_disabled': false,
    'radio_button_disabled': false,
    'radio_button_selected': -1,
  };

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Button'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The Button control provides a Click event to respond to user input from a touch, mouse, keyboard, stylus, or other input device. You can put different kinds of content in a button, such as text or an image, or you can restyle a button to give it a new look.',
      ),
      subtitle(content: const Text('A simple button with text content')),
      CardHighlight(
        child: Row(children: [
          Button(
            child: const Text('Standart Button'),
            onPressed: state['simple_disabled'] ? null : () {},
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['simple_disabled'],
            onChanged: (v) {
              setState(() {
                state['simple_disabled'] = v;
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
            onPressed: state['filled_disabled'] ? null : () {},
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['filled_disabled'],
            onChanged: (v) {
              setState(() {
                state['filled_disabled'] = v;
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
            onPressed: state['icon_disabled'] ? null : () {},
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['icon_disabled'],
            onChanged: (v) {
              setState(() {
                state['icon_disabled'] = v;
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
      subtitle(content: const Text('A simple ToggleButton with text content')),
      const Text(
        'A ToggleButton looks like a Button, but works like a CheckBox. It typically has two states, checked (on) or unchecked (off).',
      ),
      CardHighlight(
        child: Row(children: [
          ToggleButton(
            child: const Text('Toggle Button'),
            checked: state['toggle_state'],
            onChanged: state['toggle_disabled']
                ? null
                : (v) {
                    setState(() {
                      state['toggle_state'] = v;
                    });
                  },
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['toggle_disabled'],
            onChanged: (v) {
              setState(() {
                state['toggle_disabled'] = v;
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
      CardHighlight(
        child: Row(
          children: [
            SplitButtonBar(
              buttons: [
                Button(
                  child: Container(
                    decoration: BoxDecoration(
                      color: state['split_button_disabled']
                          ? FluentTheme.of(context).accentColor.darker
                          : FluentTheme.of(context).accentColor,
                      borderRadius: const BorderRadiusDirectional.horizontal(
                        start: Radius.circular(4.0),
                      ),
                    ),
                    height: 24,
                    width: 24,
                  ),
                  onPressed: state['split_button_disabled'] ? null : () {},
                ),
                IconButton(
                  icon: const SizedBox(
                    // height: splitButtonHeight,
                    child: Icon(FluentIcons.chevron_down, size: 10.0),
                  ),
                  onPressed: state['split_button_disabled'] ? null : () {},
                ),
              ],
            ),
            const Spacer(),
            ToggleSwitch(
              checked: state['split_button_disabled'],
              onChanged: (v) {
                setState(() {
                  state['split_button_disabled'] = v;
                });
              },
              content: const Text('Disabled'),
            ),
          ],
        ),
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
      const Text(
        'A control that allows a user to select a single option from a group of options',
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
                    checked: state['radio_button_selected'] == index,
                    onChanged: state['radio_button_disabled']
                        ? null
                        : (v) {
                            if (v) {
                              setState(() {
                                state['radio_button_selected'] = index;
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
            checked: state['radio_button_disabled'],
            onChanged: (v) {
              setState(() {
                state['radio_button_disabled'] = v;
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
    ];
  }
}
