import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class CheckBoxPage extends StatefulWidget {
  const CheckBoxPage({super.key});

  @override
  State<CheckBoxPage> createState() => _CheckBoxPageState();
}

class _CheckBoxPageState extends State<CheckBoxPage> with PageMixin {
  bool firstChecked = false;
  bool firstDisabled = false;
  bool? secondChecked = false;
  bool secondDisabled = false;
  bool iconDisabled = false;
  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Checkbox')),
      children: [
        const Text(
          "CheckBox controls let the user select a combination of binary options. In contrast, RadioButton controls allow the user to select from mutually exclusive options. The indeterminate state is used to indicate that an option is set for some, but not all, child options. Don't allow users to set an indeterminate state directly to indicate a third option.",
        ),
        subtitle(content: const Text('A 2-state Checkbox')),
        CodeSnippetCard(
          codeSnippet: '''
bool checked = false;

Checkbox(
  checked: checked,
  onPressed: disabled ? null : (v) => setState(() => checked = v),
)''',
          child: Row(
            children: [
              Checkbox(
                checked: firstChecked,
                onChanged: firstDisabled
                    ? null
                    : (final v) => setState(() => firstChecked = v!),
                content: const Text('Two-state Checkbox'),
              ),
              const Spacer(),
              ToggleSwitch(
                checked: firstDisabled,
                onChanged: (final v) {
                  setState(() {
                    firstDisabled = v;
                  });
                },
                content: const Text('Disabled'),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('A 3-state Checkbox')),
        CodeSnippetCard(
          codeSnippet: '''
bool checked = false;

Checkbox(
  checked: checked,
  onPressed: disabled ? null : (v) {
    setState(() {
      // if v (the new value) is true, then true
      // if v is false, then null (third state)
      // if v is null (was third state before), then false
      // otherwise (just to be safe), it's true
      checked = (v == true
        ? true
          : v == false
            ? null
              : v == null
                ? false
                  : true);
    });
  },
)''',
          child: Row(
            children: [
              Checkbox(
                checked: secondChecked,
                // checked: null,
                onChanged: secondDisabled
                    ? null
                    : (final v) {
                        setState(() {
                          secondChecked = v ?? false
                              ? true
                              : v == false
                              ? null
                              : !(v == null);
                        });
                      },
                content: const Text('Three-state Checkbox'),
              ),
              const Spacer(),
              ToggleSwitch(
                checked: secondDisabled,
                onChanged: (final v) {
                  setState(() {
                    secondDisabled = v;
                  });
                },
                content: const Text('Disabled'),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('Using a 3-state Checkbox (TreeView)')),
        Card(
          child: TreeView(
            items: [
              TreeViewItem(
                content: const Text('Select all'),
                children: treeViewItems,
              ),
            ],
            selectionMode: TreeViewSelectionMode.multiple,
          ),
        ),
      ],
    );
  }

  final treeViewItems = [
    TreeViewItem(content: const Text('Option 1')),
    TreeViewItem(content: const Text('Option 2')),
    TreeViewItem(content: const Text('Option 3')),
  ];
}
