// ignore_for_file: prefer_const_constructors

import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

import '../../widgets/card_highlight.dart';

const _kSplitButtonHeight = 32.0;
const _kSplitButtonWidth = 36.0;

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> with PageMixin {
  bool simpleDisabled = false;
  bool filledDisabled = false;
  bool iconDisabled = false;
  bool iconSmall = false;
  bool toggleDisabled = false;
  bool toggleState = false;
  bool splitButtonDisabled = false;
  bool splitButtonState = false;
  bool radioButtonDisabled = false;
  int radioButtonSelected = -1;

  AccentColor splitButtonColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final splitButtonFlyout = FlyoutContent(
      constraints: BoxConstraints(maxWidth: 200.0),
      child: Wrap(
        runSpacing: 10.0,
        spacing: 8.0,
        children: Colors.accentColors.map((color) {
          return IconButton(
            autofocus: splitButtonColor == color,
            style: ButtonStyle(
              padding: ButtonState.all(
                EdgeInsets.all(4.0),
              ),
            ),
            onPressed: () {
              setState(() => splitButtonColor = color);
              Navigator.of(context).pop(color);
            },
            icon: Container(
              height: _kSplitButtonHeight,
              width: _kSplitButtonHeight,
              color: color,
            ),
          );
        }).toList(),
      ),
    );

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
          codeSnippet: '''Button(
  child: const Text('Standard Button'),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''',
          child: Row(children: [
            Button(
              onPressed: simpleDisabled ? null : () {},
              child: const Text('Standard Button'),
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
        ),
        subtitle(content: const Text('Accent Style applied to Button')),
        CardHighlight(
          codeSnippet: '''FilledButton(
  child: const Text('Filled Button'),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''',
          child: Row(children: [
            FilledButton(
              onPressed: filledDisabled ? null : () {},
              child: const Text('Filled Button'),
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
        ),
        subtitle(content: const Text('Hyperlink Button')),
        const Text(
          'Hyperlinks navigate the user to another part of the app, to another '
          'app, or launch a specific uniform resource identifier (URI) using a '
          'separate browser app.',
        ),
        CardHighlight(
          codeSnippet: '''Link( // from the url_launcher package
  uri: Uri.parse('https://github.com/bdlukaa/fluent_ui')
  builder: (Context, open) {
    return HyperlinkButton(
      child: Text('Fluent UI homepage'),
      onPressed: open,
    );
  },
)''',
          child: Link(
            uri: Uri.parse('https://github.com/bdlukaa/fluent_ui'),
            builder: (context, open) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: HyperlinkButton(
                  onPressed: open,
                  child: Semantics(
                    link: true,
                    child: Text('Fluent UI homepage'),
                  ),
                ),
              );
            },
          ),
        ),
        subtitle(
          content: const Text('A Button with graphical content (IconButton)'),
        ),
        CardHighlight(
          codeSnippet: () {
            if (iconSmall) {
              return '''SmallIconButton(
  child: IconButton(
    icon: const Icon(FluentIcons.graph_symbol, size: 20.0),
    onPressed: disabled ? null : () => debugPrint('pressed button'),
  ),
)''';
            }

            return '''IconButton(
  icon: const Icon(FluentIcons.graph_symbol, size: 24.0),
  onPressed: disabled ? null : () => debugPrint('pressed button'),
)''';
          }(),
          child: Row(children: [
            () {
              final button = IconButton(
                icon: Icon(
                  FluentIcons.graph_symbol,
                  size: iconSmall ? 20.0 : 24.0,
                ),
                onPressed: iconDisabled ? null : () {},
              );

              if (iconSmall) return SmallIconButton(child: button);

              return button;
            }(),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                checked: iconSmall,
                onChanged: (v) {
                  setState(() {
                    iconSmall = v ?? !iconSmall;
                  });
                },
                content: const Text('Small'),
              ),
              const SizedBox(height: 4.0),
              Checkbox(
                checked: iconDisabled,
                onChanged: (v) {
                  setState(() {
                    iconDisabled = v ?? !iconDisabled;
                  });
                },
                content: const Text('Disabled'),
              ),
            ]),
          ]),
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
          codeSnippet: '''bool checked = false;

ToggleButton(
  child: const Text('Toggle Button'),
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
)''',
          child: Row(children: [
            ToggleButton(
              checked: toggleState,
              onChanged: toggleDisabled
                  ? null
                  : (v) {
                      setState(() {
                        toggleState = v;
                      });
                    },
              child: const Text('Toggle Button'),
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
        ),
        subtitle(content: const Text('DropDownButton')),
        const Text(
          'A control that drops down a flyout of choices from which one can be chosen',
        ),
        CardHighlight(
          codeSnippet: '''DropDownButton(
  title: Text('Email'),
  items: [
    MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
    MenuFlyoutSeparator(),
    MenuFlyoutItem(text: const Text('Reply'), onPressed: () {}),
    MenuFlyoutItem(text: const Text('Reply all'), onPressed: () {}),
  ],
)''',
          child: Row(children: [
            DropDownButton(
              title: Text('Email'),
              items: [
                MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
                MenuFlyoutSeparator(),
                MenuFlyoutItem(text: const Text('Reply'), onPressed: () {}),
                MenuFlyoutItem(text: const Text('Reply all'), onPressed: () {}),
              ],
            ),
            SizedBox(width: 10.0),
            DropDownButton(
              title: Icon(FluentIcons.mail),
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
        description(
          content: const Text(
            'Represents a button with two parts that can be invoked separately. '
            'One part behaves like a standard button and the other part invokes '
            'a flyout.',
          ),
        ),
        CardHighlight(
          codeSnippet: '''final splitButtonKey = GlobalKey<SplitButtonState>();

// To create a toggle button, use the [SplitButton.toggle] constructor
SplitButton(
  key: splitButtonKey,
  enabled: !disabled,
  child: Container(
    decoration: BoxDecoration(
      color: disabled
          ? color.secondaryBrushFor(theme.brightness)
          : color,
      borderRadius: const BorderRadiusDirectional.horizontal(
        start: Radius.circular(4.0),
      ),
    ),
    height: $_kSplitButtonHeight,
    width: $_kSplitButtonWidth,
  ),
  flyout: FlyoutContent(
    constraints: BoxConstraints(maxWidth: 200.0),
    child: Wrap(
      runSpacing: 10.0,
      spacing: 8.0,
      children: Colors.accentColors.map((color) {
        return Button(
          autofocus: splitButtonColor == color,
          style: ButtonStyle(
            padding: ButtonState.all(
              EdgeInsets.all(4.0),
            ),
          ),
          onPressed: () {
            setState(() => splitButtonColor = color);
            Navigator.of(context).pop(color);
          },
          child: Container(
            height: $_kSplitButtonHeight,
            width: $_kSplitButtonHeight,
            color: color,
          ),
        );
      }).toList(),
    ),
  ),
)

// Show the flyout programmatically
splitButtonKey.currentState?.showFlyout();
''',
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'SplitButton with custom content',
                  style: theme.typography.caption,
                ),
              ),
              SplitButton(
                enabled: !splitButtonDisabled,
                flyout: splitButtonFlyout,
                child: Container(
                  decoration: BoxDecoration(
                    color: splitButtonDisabled
                        ? splitButtonColor.secondaryBrushFor(theme.brightness)
                        : splitButtonColor,
                    borderRadius: const BorderRadiusDirectional.horizontal(
                      start: Radius.circular(4.0),
                    ),
                  ),
                  height: _kSplitButtonHeight,
                  width: _kSplitButtonWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
                child: Text(
                  'A toggleable SplitButton with text content',
                  style: theme.typography.caption,
                ),
              ),
              SplitButton.toggle(
                enabled: !splitButtonDisabled,
                checked: splitButtonState,
                onInvoked: () {
                  debugPrint('Invoked split button primary action');
                  setState(() => splitButtonState = !splitButtonState);
                },
                flyout: splitButtonFlyout,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Choose color'),
                ),
              ),
            ]),
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
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (index) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                        bottom: index == 2 ? 0.0 : 14.0),
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
        ),
      ],
    );
  }
}
