import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ButtonPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'simple_disabled': false,
    'filled_disabled': false,
    'icon_disabled': false,
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
    ];
  }
}
