import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class RadioButtonPage extends ScrollablePage {
  PageState state = <String, dynamic>{
    'first_checked': false,
    'first_disabled': false,
    'second_state': false,
    'second_disabled': false,
    'icon_disabled': false,
  };

  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('RadioButton'));
  }

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'A control that allows a user to select a single option from a group of options.',
      ),
      subtitle(content: const Text('A 2-state Checkbox')),
      Card(
        child: Row(children: [
          Checkbox(
            checked: state['first_checked'],
            onChanged: state['first_disabled']
                ? null
                : (v) {
                    setState(() {
                      state['first_checked'] = v;
                    });
                  },
            content: const Text('Two-state Checkbox'),
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['first_disabled'],
            onChanged: (v) {
              setState(() {
                state['first_disabled'] = v;
              });
            },
            content: const Text('Disabled'),
          ),
        ]),
      ),
      subtitle(content: const Text('A 3-state Checkbox')),
      Card(
        child: Row(children: [
          Checkbox(
            checked: state['second_state'],
            // checked: null,
            onChanged: state['second_disabled']
                ? null
                : (v) {
                    setState(() {
                      print(v);
                      state['second_state'] = v == true
                          ? true
                          : v == false
                              ? null
                              : v == null
                                  ? false
                                  : true;
                    });
                  },
            content: const Text('Three-state Checkbox'),
          ),
          const Spacer(),
          ToggleSwitch(
            checked: state['second_disabled'],
            onChanged: (v) {
              setState(() {
                state['second_disabled'] = v;
              });
            },
            content: const Text('Disabled'),
          ),
        ]),
      ),
      subtitle(
        content: const Text('Using a 3-state Checkbox (TreeView)'),
      ),
      Card(
        child: TreeView(
          items: [
            TreeViewItem(
              content: const Text('Select all'),
              children: [
                TreeViewItem(content: const Text('Option 1')),
                TreeViewItem(content: const Text('Option 2')),
                TreeViewItem(content: const Text('Option 3')),
              ],
            ),
          ],
          selectionMode: TreeViewSelectionMode.multiple,
        ),
      ),
    ];
  }
}
