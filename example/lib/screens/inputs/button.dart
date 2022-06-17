// ignore_for_file: prefer_const_constructors

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ButtonPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'simple_disabled': false,
    'filled_disabled': false,
    'icon_disabled': false,
    'toggle_state': false,
    'toggle_disabled': false,
    'split_button_disabled': false,
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
      Card(
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
      ),
      subtitle(content: const Text('Accent Style applied to Button')),
      Card(
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
      ),
      subtitle(
        content: const Text('A Button with graphical content (IconButton)'),
      ),
      Card(
        child: Row(children: [
          IconButton(
            icon: const Icon(
              FluentIcons.graph_symbol,
              size: 24.0,
            ),
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
      ),
      subtitle(content: const Text('A simple ToggleButton with text content')),
      const Text(
        'A ToggleButton looks like a Button, but works like a CheckBox. It typically has two states, checked (on) or unchecked (off).',
      ),
      Card(
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
      ),
      subtitle(content: const Text('DropDownButton')),
      const Text(
        'A control that drops down a flyout of choices from which one can be chosen',
      ),
      Card(
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
      ),
      subtitle(content: const Text('SplitButton')),
      Card(
        child: Row(
          children: [
            SplitButtonBar(
              buttons: [
                Button(
                  child: SizedBox(
                    // height: splitButtonHeight,
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
      ),
    ];
  }
}
