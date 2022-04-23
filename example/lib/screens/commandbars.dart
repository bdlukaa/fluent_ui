import 'package:fluent_ui/fluent_ui.dart';

class CommandBars extends StatefulWidget {
  const CommandBars({Key? key}) : super(key: key);

  @override
  _CommandBarsState createState() => _CommandBarsState();
}

class _CommandBarsState extends State<CommandBars> {
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
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Command bars')),
      children: [
        const SizedBox(height: 20.0),
        InfoLabel(
          label: 'Simple command bar (no wrapping)',
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              ...simpleCommandBarItems,
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        InfoLabel(
          label: 'Command bar with many items (wrapping, auto-compact < 600px)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label: 'Carded compact command bar with many items (clipped)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label: 'Carded command bar with many items (dynamic overflow)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label:
              'End-aligned command bar with many items (dynamic overflow, auto-compact < 900px)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label:
              'End-aligned command bar with permanent secondary items (dynamic overflow)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label: 'Command bar with secondary items (wrapping)',
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.wrap,
            primaryItems: simpleCommandBarItems,
            secondaryItems: moreCommandBarItems,
          ),
        ),
        const SizedBox(height: 20.0),
        InfoLabel(
          label:
              'Carded complex command bar with many items (horizontal scrolling)',
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
        const SizedBox(height: 20.0),
        InfoLabel(
          label:
              'Carded complex command bar with many items (dynamic overflow)',
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
      ],
    );
  }
}
