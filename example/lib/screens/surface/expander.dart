import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/code_snippet_card.dart';

class ExpanderPage extends StatefulWidget {
  const ExpanderPage({super.key});

  @override
  State<ExpanderPage> createState() => _ExpanderPageState();
}

class _ExpanderPageState extends State<ExpanderPage> with PageMixin {
  final expanderKey = GlobalKey<ExpanderState>(debugLabel: 'Expander key');

  bool crostOpen = false;
  List<String> crosts = ['Classic', 'Whole wheat', 'Gluten free'];
  String crost = 'Whole wheat';
  List<String> sizes = ['Regular', 'Thin', 'Pan', 'Stuffed'];
  String size = 'Pan';
  bool checked = false;

  @override
  Widget build(final BuildContext context) {
    final open = expanderKey.currentState?.isExpanded ?? false;
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Expander')),
      children: [
        description(
          content: const Text(
            'The Expander control lets you show or hide less important content '
            "that's related to a piece of primary content that's always visible. "
            'Items contained in the Header are always visible. The user can expand '
            'and collapse the Content area, where secondary content is displayed, '
            'by interacting with the header. When the content area is expanded, it '
            'pushes other UI elements out of the way; it does not overlay other UI. '
            'The Expander can expand upwards or downwards.\n\n'
            'Both the Header and Content areas can contain any content, from simple '
            'text to complex UI layouts. For example, you can use the control to '
            'show additional options for an item.\n\n'
            'Use an Expander when some primary content should always be visible, '
            'but related secondary content may be hidden until needed. This UI is '
            'commonly used when display space is limited and when information or '
            'options can be grouped together. Hiding the secondary content until '
            "it's needed can also help to focus the user on the most important "
            'parts of your app.',
          ),
        ),
        subtitle(content: const Text('Simple expander')),
        description(
          content: const Text(
            'In this example, the trailing vanishes when the expander is open.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''
Expander(
  leading: RadioButton(
    checked: checked,
    onChanged: (v) => setState(() => checked = v),
  ),
  header: Text('This text is in header'),
  content: Text('This text is in content'),
)''',
          child: Expander(
            header: const Text('Choose your crost'),
            onStateChanged: (final open) => setState(() => crostOpen = open),
            trailing: crostOpen
                ? null
                : Text(
                    '$crost, $size',
                    style: FluentTheme.of(context).typography.caption,
                  ),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: crosts
                      .map(
                        (final e) => Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 8),
                          child: RadioButton(
                            checked: crost == e,
                            onChanged: (final selected) {
                              if (selected) setState(() => crost = e);
                            },
                            content: Text(e),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sizes
                      .map(
                        (final e) => Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 8),
                          child: RadioButton(
                            checked: size == e,
                            onChanged: (final selected) {
                              if (selected) setState(() => size = e);
                            },
                            content: Text(e),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        subtitle(content: const Text('Scrollable content')),
        CodeSnippetCard(
          codeSnippet: '''
Expander(
  header: Text('Open to see the scrollable text'),
  content: SizedBox(
    height: 300,
    child: SingleChildScrollView(
      child: Text('A LONG TEXT HERE'),
    ),
  ),
)''',
          child: Expander(
            header: const Text('Open to see the scrollable text'),
            content: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: SelectableText(
                  '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis porta lectus lacus, ut viverra ex aliquet at. Sed ac tempus magna. Ut velit diam, condimentum ac bibendum sit amet, aliquam at quam. Mauris bibendum, elit ut mollis molestie, neque risus lacinia libero, id fringilla lacus odio a nisl. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Aliquam viverra tincidunt diam, id porta justo iaculis ac. Aenean ornare bibendum rutrum. Aenean dignissim egestas augue id elementum. Suspendisse dapibus, felis nec varius porta, purus turpis sodales est, sit amet consectetur velit turpis in orci. Curabitur sed tortor purus. Donec ut ligula tortor. Quisque ac nulla dui. Praesent sed diam id dui pharetra facilisis. Maecenas lacinia augue eu metus luctus, vitae efficitur ex accumsan. Sed viverra tellus quis ex tempus, sit amet aliquam mauris hendrerit. Proin tempus nisl mauris, eget ultricies ligula aliquet id.

Fusce molestie quis augue vel eleifend. Praesent ligula velit, porta id diam sed, malesuada molestie odio. Proin egestas nisl vel leo accumsan, vel ullamcorper ipsum dapibus. Curabitur libero augue, porttitor dictum mauris ut, dignissim blandit lacus. Suspendisse lacinia augue elit, sit amet auctor eros pretium sit amet. Proin ullamcorper augue nulla, sit amet rhoncus nisl gravida ac. Aenean auctor ligula in nibh fermentum fermentum. Aliquam erat volutpat. Sed molestie vulputate diam, id rhoncus augue mattis vitae. Ut tempus tempus dui, in imperdiet elit tincidunt id. Integer congue urna eu nisl bibendum accumsan. Aliquam commodo tempor turpis sit amet suscipit.

Donec sit amet semper sem. Pellentesque commodo mi in est sagittis ultricies in ut elit. Donec vulputate commodo vestibulum. Pellentesque pulvinar tortor vel suscipit hendrerit. Vestibulum interdum, est et aliquam dapibus, tellus elit pharetra nisl, in volutpat sapien ipsum in velit. Donec gravida erat tellus, et molestie diam interdum sed. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Duis dolor nisl, viverra sed pellentesque molestie, tempor ut enim. Duis suscipit massa sed dolor suscipit mollis. In lobortis efficitur egestas. Integer blandit, dolor eu tristique mollis, lorem urna convallis arcu, non iaculis elit purus vel velit. Nam eget aliquet quam, vitae luctus urna. Nunc vehicula sagittis risus, vitae pretium lacus ornare semper. In ornare massa vitae odio consequat, eu lacinia mi imperdiet. Vivamus at augue diam. Fusce eu purus magna.

Fusce tempor, dolor in porttitor porttitor, turpis leo ullamcorper urna, vitae ultrices lorem augue eget nulla. Nulla sodales venenatis tellus quis feugiat. Phasellus sit amet condimentum nulla. Quisque felis lorem, tempus quis odio id, tincidunt volutpat ante. Fusce ultrices dui vel lorem tincidunt, in pellentesque ligula luctus. Morbi luctus est vitae eros blandit dictum. Quisque convallis diam sed arcu volutpat, eget placerat turpis cursus. Aliquam dapibus finibus luctus. Praesent vestibulum viverra risus, nec sollicitudin mi mattis eu. Nulla vestibulum, nibh eget sagittis placerat, elit eros egestas libero, eu luctus justo ante eget tellus. Etiam quis lacus gravida, consequat diam in, laoreet sapien.

Fusce nunc neque, imperdiet id justo non, porttitor finibus massa. Ut quis risus quis tellus ultricies accumsan et et lorem. Nam pulvinar luctus velit, ut vehicula neque sagittis nec. Integer commodo, metus auctor rutrum finibus, tellus justo feugiat leo, sit amet tempus est justo eu augue. Cras eget nibh ac enim bibendum lobortis. Sed ultricies nunc elit, imperdiet consectetur velit scelerisque eu. Aliquam suscipit libero vel nibh porttitor, vel sodales nisi viverra. Duis vitae rutrum metus, vitae accumsan massa. Sed congue, est interdum commodo facilisis, leo libero blandit tellus, a dapibus tortor odio eget ex. Nunc aliquet nulla vel augue pulvinar, vel luctus risus sagittis. Sed non sodales urna. Phasellus quis sapien placerat, ultricies risus ut, hendrerit mi. Donec pretium ligula non arcu posuere porttitor. Pellentesque eleifend mollis ex non eleifend. Nam sed elit mollis mauris laoreet aliquam eget vel elit.''',
                  selectionControls: fluentTextSelectionControls,
                ),
              ),
            ),
          ),
        ),
        subtitle(content: const Text('Expander opened programatically')),
        CodeSnippetCard(
          codeSnippet:
              '''final expanderKey = GlobalKey<ExpanderState>(debugLabel: 'Expander key');

Expander(
  key: expanderKey,
  header: Text('This text is in header'),
  content: Text('This text is in content'),
  onStateChanged: (open) {
    print('state changed to open=$open');
  },
)

/// Toggles the current expander state
/// 
/// if it's open, now it's closed, and vice versa
void toggle() {
  final open = expanderKey.currentState?.open ?? false;

  expanderKey.currentState?.open = !open;
}''',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Expander(
                  key: expanderKey,
                  header: const Text('This text is in header'),
                  content: const Text('This text is in content'),
                  onStateChanged: (final open) => setState(() {}),
                ),
              ),
              const SizedBox(width: 20),
              ToggleSwitch(
                checked: open,
                onChanged: (final v) {
                  setState(() {
                    expanderKey.currentState?.isExpanded = v;
                  });
                },
                content: Text(open ? 'Close' : 'Open'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
