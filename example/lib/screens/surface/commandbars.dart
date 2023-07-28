import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/page.dart';

class CommandBarsPage extends StatefulWidget {
  const CommandBarsPage({super.key});

  @override
  State<CommandBarsPage> createState() => _CommandBarsPageState();
}

class _CommandBarsPageState extends State<CommandBarsPage> with PageMixin {
  final simpleCommandBarItems = <CommandBarItem>[
    CommandBarBuilderItem(
      builder: (context, mode, w) => Tooltip(
        message: "Create something new!",
        child: w,
      ),
      wrappedItem: CommandBarButton(
        icon: const Icon(FluentIcons.add),
        label: const Text('New'),
        onPressed: () {},
      ),
    ),
    CommandBarBuilderItem(
      builder: (context, mode, w) => Tooltip(
        message: "Delete what is currently selected!",
        child: w,
      ),
      wrappedItem: CommandBarButton(
        icon: const Icon(FluentIcons.delete),
        label: const Text('Delete'),
        onPressed: () {},
      ),
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.archive),
      label: const Text('Archive'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.move),
      label: const Text('Move'),
      onPressed: () {},
    ),
    const CommandBarButton(
      icon: Icon(FluentIcons.cancel),
      label: Text('Disabled'),
      onPressed: null,
    ),
  ];

  final moreCommandBarItems = <CommandBarItem>[
    CommandBarButton(
      icon: const Icon(FluentIcons.reply),
      label: const Text('Reply'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.reply_all),
      label: const Text('Reply All'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.forward),
      label: const Text('Forward'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.search),
      label: const Text('Search'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.pin),
      label: const Text('Pin'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.unpin),
      label: const Text('Unpin'),
      onPressed: () {},
    ),
  ];

  final evenMoreCommandBarItems = <CommandBarItem>[
    CommandBarButton(
      icon: const Icon(FluentIcons.accept),
      label: const Text('Accept'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.calculator_multiply),
      label: const Text('Reject'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.share),
      label: const Text('Share'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.add_favorite),
      label: const Text('Add Favorite'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.back),
      label: const Text('Backward'),
      onPressed: () {},
    ),
    CommandBarButton(
      icon: const Icon(FluentIcons.forward),
      label: const Text('Forward'),
      onPressed: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('CommandBar'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            ...simpleCommandBarItems,
          ],
        ),
      ),
      children: [
        const Text(
          'Command bars provide users with easy access to your app\'s most '
          'common tasks. Command bars can provide access to app-level or '
          'page-specific commands and can be used with any navigation pattern.',
        ),
        subtitle(content: const Text('Simple command bar (no wrapping)')),
        CardHighlight(
          codeSnippet: '''
/// Define list of CommandBarItem
final simpleCommandBarItems = <CommandBarItem>[
  CommandBarBuilderItem(
    builder: (context, mode, w) => Tooltip(
      message: "Create something new!",
      child: w,
    ),
    wrappedItem: CommandBarButton(
      icon: const Icon(FluentIcons.add),
      label: const Text('New'),
      onPressed: () {},
    ),
  ),
  CommandBarBuilderItem(
    builder: (context, mode, w) => Tooltip(
      message: "Delete what is currently selected!",
      child: w,
    ),
    wrappedItem: CommandBarButton(
      icon: const Icon(FluentIcons.delete),
      label: const Text('Delete'),
      onPressed: () {},
    ),
  ),
  CommandBarButton(
    icon: const Icon(FluentIcons.archive),
    label: const Text('Archive'),
    onPressed: () {},
  ),
  CommandBarButton(
    icon: const Icon(FluentIcons.move),
    label: const Text('Move'),
    onPressed: () {},
  ),
  const CommandBarButton(
    icon: Icon(FluentIcons.cancel),
    label: Text('Disabled'),
    onPressed: null,
  ),
];

/// Generate CommandBar with different properties like overflowBehavior
CommandBar(
  overflowBehavior: CommandBarOverflowBehavior.noWrap,
  primaryItems: [
    ...simpleCommandBarItems,
  ],
);
''',
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              ...simpleCommandBarItems,
            ],
          ),
        ),
        subtitle(
            content: const Text('Simple command bar (no wrapping) (vertical)')),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

/// Generate CommandBar with different properties like overflowBehavior
CommandBar(
  direction: Axis.vertical,
  overflowBehavior: CommandBarOverflowBehavior.noWrap,
  primaryItems: [
    ...simpleCommandBarItems,
  ],
);
''',
          child: CommandBar(
            direction: Axis.vertical,
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              ...simpleCommandBarItems,
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'Command bar with many items (wrapping, auto-compact < 600px)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

CommandBar(
  overflowBehavior: CommandBarOverflowBehavior.wrap,
  compactBreakpointWidth: 600,
  primaryItems: [
    ...simpleCommandBarItems,
    const CommandBarSeparator(),
    ...moreCommandBarItems,
  ],
);
''',
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.wrap,
            compactBreakpointWidth: 600,
            primaryItems: [
              ...simpleCommandBarItems,
              const CommandBarSeparator(),
              ...moreCommandBarItems,
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'Command bar with many items (wrapping, auto-compact < 600px) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBar(
    direction: Axis.vertical,
    overflowBehavior: CommandBarOverflowBehavior.wrap,
    compactBreakpointWidth: 600,
    primaryItems: [
      ...simpleCommandBarItems,
      const CommandBarSeparator(direction: Axis.horizontal),
      ...moreCommandBarItems,
    ],
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBar(
              direction: Axis.vertical,
              overflowBehavior: CommandBarOverflowBehavior.wrap,
              compactBreakpointWidth: 600,
              primaryItems: [
                ...simpleCommandBarItems,
                const CommandBarSeparator(direction: Axis.horizontal),
                ...moreCommandBarItems,
              ],
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded compact command bar with many items (clipped)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 230),
  child: CommandBarCard(
    child: CommandBar(
      overflowBehavior: CommandBarOverflowBehavior.clip,
      isCompact: true,
      primaryItems: [
        ...simpleCommandBarItems,
        const CommandBarSeparator(),
        ...moreCommandBarItems,
      ],
    ),
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: CommandBarCard(
              child: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.clip,
                isCompact: true,
                primaryItems: [
                  ...simpleCommandBarItems,
                  const CommandBarSeparator(),
                  ...moreCommandBarItems,
                ],
              ),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded compact command bar with many items (clipped) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBarCard(
    child: CommandBar(
      direction: Axis.vertical,
      overflowBehavior: CommandBarOverflowBehavior.clip,
      isCompact: true,
      primaryItems: [
        ...simpleCommandBarItems,
        const CommandBarSeparator(),
        ...moreCommandBarItems,
      ],
    ),
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBarCard(
              child: CommandBar(
                direction: Axis.vertical,
                overflowBehavior: CommandBarOverflowBehavior.clip,
                isCompact: true,
                primaryItems: [
                  ...simpleCommandBarItems,
                  const CommandBarSeparator(),
                  ...moreCommandBarItems,
                ],
              ),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded compact command bar with many items (dynamic overflow)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Create different lists of CommandBarItem
/// named simpleCommandBarItems, moreCommandBarItems, evenMoreCommandBarItems
/// These lists can be used as primaryItems as shown
CommandBarCard(
  child: CommandBar(
    overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
    primaryItems: [
      ...simpleCommandBarItems,
      const CommandBarSeparator(),
      ...moreCommandBarItems,
      const CommandBarSeparator(),
      ...evenMoreCommandBarItems,
    ],
  ),
);
''',
          child: CommandBarCard(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
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
        subtitle(
          content: const Text(
            'Carded compact command bar with many items (dynamic overflow) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Create different lists of CommandBarItem
/// named simpleCommandBarItems, moreCommandBarItems, evenMoreCommandBarItems
/// These lists can be used as primaryItems as shown
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBarCard(
    child: CommandBar(
      direction: Axis.vertical,
      overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
      primaryItems: [
        ...simpleCommandBarItems,
        const CommandBarSeparator(),
        ...moreCommandBarItems,
        const CommandBarSeparator(),
        ...evenMoreCommandBarItems,
      ],
    ),
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBarCard(
              child: CommandBar(
                direction: Axis.vertical,
                overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
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
        subtitle(
          content: const Text(
            'End-aligned command bar with many items (dynamic overflow, auto-compact < 900px)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Create different lists of CommandBarItem
/// named simpleCommandBarItems, moreCommandBarItems, evenMoreCommandBarItems
/// These lists can be used as primaryItems as shown

CommandBar(
  mainAxisAlignment: MainAxisAlignment.end,
  overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
  compactBreakpointWidth: 900,
  primaryItems: [
    ...simpleCommandBarItems,
    const CommandBarSeparator(),
    ...moreCommandBarItems,
    const CommandBarSeparator(),
    ...evenMoreCommandBarItems,
  ],
);
''',
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
            compactBreakpointWidth: 900,
            primaryItems: [
              ...simpleCommandBarItems,
              const CommandBarSeparator(),
              ...moreCommandBarItems,
              const CommandBarSeparator(),
              ...evenMoreCommandBarItems,
            ],
          ),
        ),
        subtitle(
          content: const Text(
            'End-aligned command bar with many items (dynamic overflow, auto-compact < 900px) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Create different lists of CommandBarItem
/// named simpleCommandBarItems, moreCommandBarItems, evenMoreCommandBarItems
/// These lists can be used as primaryItems as shown

ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBar(
    direction: Axis.vertical,
    mainAxisAlignment: MainAxisAlignment.end,
    overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
    compactBreakpointWidth: 900,
    primaryItems: [
      ...simpleCommandBarItems,
      const CommandBarSeparator(),
      ...moreCommandBarItems,
      const CommandBarSeparator(),
      ...evenMoreCommandBarItems,
    ],
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBar(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.end,
              overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
              compactBreakpointWidth: 900,
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
        subtitle(
          content: const Text(
            'End-aligned command bar with permanent secondary items (dynamic overflow)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

CommandBar(
  mainAxisAlignment: MainAxisAlignment.end,
  overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
  primaryItems: [
    ...simpleCommandBarItems,
    const CommandBarSeparator(),
    ...moreCommandBarItems,
  ],
  secondaryItems: evenMoreCommandBarItems,
);
''',
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
            primaryItems: [
              ...simpleCommandBarItems,
              const CommandBarSeparator(),
              ...moreCommandBarItems,
            ],
            secondaryItems: evenMoreCommandBarItems,
          ),
        ),
        subtitle(
          content: const Text(
            'End-aligned command bar with permanent secondary items (dynamic overflow) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBar(
    direction: Axis.vertical,
    mainAxisAlignment: MainAxisAlignment.end,
    overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
    primaryItems: [
      ...simpleCommandBarItems,
      const CommandBarSeparator(),
      ...moreCommandBarItems,
    ],
    secondaryItems: evenMoreCommandBarItems,
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBar(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.end,
              overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
              primaryItems: [
                ...simpleCommandBarItems,
                const CommandBarSeparator(),
                ...moreCommandBarItems,
              ],
              secondaryItems: evenMoreCommandBarItems,
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Command bar with secondary items (wrapping)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

CommandBar(
  overflowBehavior: CommandBarOverflowBehavior.wrap,
  primaryItems: simpleCommandBarItems,
  secondaryItems: moreCommandBarItems,
);
''',
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.wrap,
            primaryItems: simpleCommandBarItems,
            secondaryItems: moreCommandBarItems,
          ),
        ),
        subtitle(
          content: const Text(
            'Command bar with secondary items (wrapping) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
/// Lists of CommandBarItem named as simpleCommandBarItems and moreCommandBarItems
/// Used as following

ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230),
  child: CommandBar(
    direction: Axis.vertical,
    overflowBehavior: CommandBarOverflowBehavior.wrap,
    primaryItems: simpleCommandBarItems,
    secondaryItems: moreCommandBarItems,
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230),
            child: CommandBar(
              direction: Axis.vertical,
              overflowBehavior: CommandBarOverflowBehavior.wrap,
              primaryItems: simpleCommandBarItems,
              secondaryItems: moreCommandBarItems,
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded complex command bar with many items (horizontal scrolling)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
CommandBarCard(
    child: Row(children: [
      Expanded(
        child: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.scrolling,
          primaryItems: [
            ...simpleCommandBarItems,
            const CommandBarSeparator(),
            ...moreCommandBarItems,
          ],
        ),
      ),
      // End-aligned button(s)
      CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.noWrap,
        primaryItems: [
          CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            onPressed: () {},
          ),
        ],
      ),
    ],
  ),
);
''',
          child: CommandBarCard(
            child: Row(
              children: [
                Expanded(
                  child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.scrolling,
                    primaryItems: [
                      ...simpleCommandBarItems,
                      const CommandBarSeparator(),
                      ...moreCommandBarItems,
                    ],
                  ),
                ),
                // End-aligned button(s)
                CommandBar(
                  overflowBehavior: CommandBarOverflowBehavior.noWrap,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.refresh),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded complex command bar with many items (vertical scrolling) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 230, maxWidth: 48),
  child: CommandBarCard(
    child: Column(
      children: [
        Expanded(
          child: CommandBar(
            direction: Axis.vertical,
            overflowBehavior: CommandBarOverflowBehavior.scrolling,
            primaryItems: [
              ...simpleCommandBarItems,
              const CommandBarSeparator(direction: Axis.horizontal),
              ...moreCommandBarItems,
            ],
          ),
        ),
        // End-aligned button(s)
        CommandBar(
          direction: Axis.vertical,
          overflowBehavior: CommandBarOverflowBehavior.noWrap,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 230, maxWidth: 48),
            child: CommandBarCard(
              child: Column(
                children: [
                  Expanded(
                    child: CommandBar(
                      direction: Axis.vertical,
                      overflowBehavior: CommandBarOverflowBehavior.scrolling,
                      primaryItems: [
                        ...simpleCommandBarItems,
                        const CommandBarSeparator(direction: Axis.horizontal),
                        ...moreCommandBarItems,
                      ],
                    ),
                  ),
                  // End-aligned button(s)
                  CommandBar(
                    direction: Axis.vertical,
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.refresh),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded complex command bar with many items (dynamic overflow)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
CommandBarCard(
  child: Row(
    children: [
      Expanded(
        child: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
          overflowItemAlignment: MainAxisAlignment.end,
          primaryItems: [
            ...simpleCommandBarItems,
            const CommandBarSeparator(),
            ...moreCommandBarItems,
          ],
          secondaryItems: evenMoreCommandBarItems,
        ),
      ),
      // End-aligned button(s)
      CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.noWrap,
        primaryItems: [
          CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            onPressed: () {},
          ),
        ],
      ),
    ],
  ),
);
''',
          child: CommandBarCard(
            child: Row(
              children: [
                Expanded(
                  child: CommandBar(
                    overflowBehavior:
                        CommandBarOverflowBehavior.dynamicOverflow,
                    overflowItemAlignment: MainAxisAlignment.end,
                    primaryItems: [
                      ...simpleCommandBarItems,
                      const CommandBarSeparator(),
                      ...moreCommandBarItems,
                    ],
                    secondaryItems: evenMoreCommandBarItems,
                  ),
                ),
                // End-aligned button(s)
                CommandBar(
                  overflowBehavior: CommandBarOverflowBehavior.noWrap,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.refresh),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'Carded complex command bar with many items (dynamic overflow) (vertical)',
          ),
        ),
        CardHighlight(
          codeSnippet: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 330),
  child: CommandBarCard(
    child: Column(
      children: [
        Expanded(
          child: CommandBar(
            direction: Axis.vertical,
            overflowBehavior:
                CommandBarOverflowBehavior.dynamicOverflow,
            overflowItemAlignment: MainAxisAlignment.end,
            primaryItems: [
              ...simpleCommandBarItems,
              const CommandBarSeparator(direction: Axis.horizontal),
              ...moreCommandBarItems,
            ],
            secondaryItems: evenMoreCommandBarItems,
          ),
        ),
        // End-aligned button(s)
        CommandBar(
          direction: Axis.vertical,
          overflowBehavior: CommandBarOverflowBehavior.noWrap,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  ),
);
''',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 330),
            child: CommandBarCard(
              child: Column(
                children: [
                  Expanded(
                    child: CommandBar(
                      direction: Axis.vertical,
                      overflowBehavior:
                          CommandBarOverflowBehavior.dynamicOverflow,
                      overflowItemAlignment: MainAxisAlignment.end,
                      primaryItems: [
                        ...simpleCommandBarItems,
                        const CommandBarSeparator(direction: Axis.horizontal),
                        ...moreCommandBarItems,
                      ],
                      secondaryItems: evenMoreCommandBarItems,
                    ),
                  ),
                  // End-aligned button(s)
                  CommandBar(
                    direction: Axis.vertical,
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.refresh),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
