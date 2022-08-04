import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/card_highlight.dart';

class ExpanderPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Expander'));
  }

  final expanderKey = GlobalKey<ExpanderState>();

  @override
  List<Widget> buildScrollable(BuildContext context) {
    final open = expanderKey.currentState?.open ?? false;
    return [
      const Text(
        'The Expander has a header and can expand to show a body with more content. Use an Expander when some content is only relevant some of the time (for example to read more information or access additional options for an item).',
      ),
      subtitle(content: const Text('Simple expander')),
      const CardHighlight(
        child: Expander(
          header: Text('This text is in header'),
          content: Text('This text is in content'),
        ),
        codeSnippet: '''Expander(
  header: Text('This text is in header'),
  content: Text('This text is in content'),
)''',
      ),
      subtitle(content: const Text('Expander opened programatically')),
      CardHighlight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Expander(
                key: expanderKey,
                header: const Text('This text is in header'),
                content: const Text('This text is in content'),
                onStateChanged: (open) => setState(() {}),
              ),
            ),
            const SizedBox(width: 20),
            ToggleSwitch(
              checked: open,
              onChanged: (v) {
                setState(() {
                  expanderKey.currentState?.open = v;
                });
              },
              content: Text(open ? 'Close' : 'Open'),
            ),
          ]),
          codeSnippet: '''final expanderKey = GlobalKey<ExpanderState>();

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
}'''),
    ];
  }
}
