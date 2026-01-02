import 'package:example/widgets/code_snippet_card.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/page.dart';

class CommandBarsPage extends StatefulWidget {
  const CommandBarsPage({super.key});

  @override
  State<CommandBarsPage> createState() => _CommandBarsPageState();
}

class _CommandBarsPageState extends State<CommandBarsPage> with PageMixin {
  final key = GlobalKey<CommandBarState>();

  final simpleCommandBarItems = <CommandBarItem>[
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.add),
      label: const Text('New'),
      tooltip: 'Create something new!',
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.delete),
      label: const Text('Delete'),
      tooltip: 'Delete what is currently selected!',
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.file_explorer),
      label: const Text('Archive'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.move),
      label: const Text('Move'),
      onPressed: () {},
    ),
    const CommandBarButton(
      icon: WindowsIcon(WindowsIcons.cancel),
      label: Text('Disabled'),
      onPressed: null,
    ),
  ];

  final moreCommandBarItems = <CommandBarItem>[
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.mail_reply),
      label: const Text('Reply'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.mail_reply_all),
      label: const Text('Reply All'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.forward),
      label: const Text('Forward'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.search),
      label: const Text('Search'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.pin),
      label: const Text('Pin'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.unpin),
      label: const Text('Unpin'),
      onPressed: () {},
    ),
  ];

  final evenMoreCommandBarItems = <CommandBarItem>[
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.accept),
      label: const Text('Accept'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.calculator_multiply),
      label: const Text('Reject'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.share),
      label: const Text('Share'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.favorite_star),
      label: const Text('Add Favorite'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.back),
      label: const Text('Backward'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.forward),
      label: const Text('Forward'),
      onPressed: () {},
    ),
  ];

  double? compactBreakpointWidth;
  bool _vertical = false;
  bool _compact = false;
  CommandBarOverflowBehavior overflowBehavior =
      CommandBarOverflowBehavior.dynamicOverflow;

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('CommandBar')),
      children: [
        const Text(
          "Command bars provide users with easy access to your app's most "
          'common tasks. Command bars can provide access to app-level or '
          'page-specific commands and can be used with any navigation pattern.',
        ),
        const SizedBox(height: 8),
        Card(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: InfoLabel(
                  label: 'Compact breakpoint width',
                  child: NumberBox<double>(
                    value: compactBreakpointWidth,
                    onChanged: (final value) {
                      setState(() {
                        compactBreakpointWidth = value;
                      });
                    },
                  ),
                ),
              ),
              InfoLabel(
                label: 'Overflow behavior',
                child: ComboBox<CommandBarOverflowBehavior>(
                  value: overflowBehavior,
                  items: CommandBarOverflowBehavior.values.map((
                    final behavior,
                  ) {
                    return ComboBoxItem<CommandBarOverflowBehavior>(
                      value: behavior,
                      child: Text(
                        behavior.name
                            .replaceAllMapped(
                              RegExp('([a-z])([A-Z])'),
                              (final match) =>
                                  '${match.group(1)} ${match.group(2)}',
                            )
                            .uppercaseFirst(),
                      ),
                    );
                  }).toList(),
                  onChanged: (final value) {
                    setState(() {
                      overflowBehavior = value!;
                    });
                  },
                ),
              ),
              Checkbox(
                checked: _vertical,
                onChanged: (final value) {
                  setState(() {
                    _vertical = value!;
                  });
                },
                content: const Text('Vertical'),
              ),
              Checkbox(
                checked: _compact,
                onChanged: (final value) {
                  setState(() {
                    _compact = value!;
                  });
                },
                content: const Text('Compact'),
              ),
              Button(
                onPressed: () {
                  key.currentState?.toggleSecondaryMenu();
                },
                child: const Text('Toggle secondary menu'),
              ),
            ],
          ),
        ),
        subtitle(
          content: const Text('Command bar with many items (dynamic overflow)'),
        ),
        CodeSnippetCard(
          codeSnippet:
              '''final commandBarKey = GlobalKey<CommandBarState>();

CommandBar(
  key: commandBarKey, ${compactBreakpointWidth != null ? '\n  compactBreakpointWidth: compactBreakpointWidth,' : ''}${_vertical ? '\n  direction: Axis.vertical,' : ''}${_compact ? '\n  isCompact: true,' : ''}
  overflowBehavior: $overflowBehavior,
  primaryItems: [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.add),
      label: const Text('New'),
      tooltip: 'Create something new!',
      onPressed: () {
        // Create something new!
      },
    ),
    const CommandBarSeparator(),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.delete),
      label: const Text('Delete'),
      tooltip: 'Delete what is currently selected!',
      onPressed: () {
        // Delete what is currently selected!
      },
    ),
  ],
);

// To toggle the secondary menu
commandBarKey.currentState?.toggleSecondaryMenu();
''',
          child: SizedBox(
            height: _vertical ? 400.0 : null,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: CommandBar(
                key: key,
                compactBreakpointWidth: compactBreakpointWidth,
                direction: _vertical ? Axis.vertical : Axis.horizontal,
                isCompact: _compact,
                overflowBehavior: overflowBehavior,
                primaryItems: [
                  ...simpleCommandBarItems,
                  const CommandBarSeparator(),
                  ...moreCommandBarItems,
                  const CommandBarSeparator(),
                  ...evenMoreCommandBarItems,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
