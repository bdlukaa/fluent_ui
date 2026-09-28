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

  List<CommandBarItem> get simpleCommandBarItems => [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.add),
      label: const Text('New'),
      tooltip: 'Ctrl+N',
      onPressed: () => _runAction('New playlist'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.delete),
      label: const Text('Delete'),
      tooltip: 'Delete',
      onPressed: () => _runAction('Removed selected track'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.file_explorer),
      label: const Text('Add to playlist'),
      tooltip: 'Ctrl+L',
      onPressed: () => _runAction('Added to playlist'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.move),
      label: const Text('Move'),
      tooltip: 'Ctrl+Shift+M',
      onPressed: () => _runAction('Move requested'),
    ),
    const CommandBarButton(
      icon: WindowsIcon(WindowsIcons.cancel),
      label: Text('Unavailable'),
      tooltip: 'Unavailable',
      onPressed: null,
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.mail_reply),
      label: const Text('Play next'),
      tooltip: 'Alt+N',
      onPressed: () => _runAction('Queued next'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.mail_reply_all),
      label: const Text('Add to queue'),
      tooltip: 'Q',
      onPressed: () => _runAction('Added to queue'),
    ),
  ];

  List<CommandBarItem> get moreCommandBarItems => [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.forward),
      label: const Text('Share'),
      tooltip: 'Ctrl+S',
      onPressed: () => _runAction('Share requested'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.search),
      label: const Text('Search library'),
      tooltip: 'Ctrl+F',
      onPressed: () => _runAction('Search requested'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.pin),
      label: const Text('Pin playlist'),
      tooltip: 'Ctrl+P',
      onPressed: () => _runAction('Playlist pinned'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.unpin),
      label: const Text('Remove pin'),
      tooltip: 'Ctrl+Shift+P',
      onPressed: () => _runAction('Playlist unpinned'),
    ),
  ];

  List<CommandBarItem> get evenMoreCommandBarItems => [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.accept),
      label: const Text('Mark played'),
      tooltip: 'M',
      onPressed: () => _runAction('Marked as played'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.calculator_multiply),
      label: const Text('Remove from queue'),
      tooltip: 'Delete',
      onPressed: () => _runAction('Removed from queue'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.back),
      label: const Text('Previous'),
      tooltip: 'Left Arrow',
      onPressed: () => _runAction('Previous track'),
    ),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.forward),
      label: const Text('Next'),
      tooltip: 'Right Arrow',
      onPressed: () => _runAction('Next track'),
    ),
  ];

  double? compactBreakpointWidth;
  bool _vertical = false;
  bool _compact = false;
  CommandBarOverflowBehavior overflowBehavior =
      CommandBarOverflowBehavior.dynamicOverflow;
  String _lastAction = 'Ready to play';

  void _runAction(String action) {
    setState(() => _lastAction = action);
  }

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('CommandBar')),
      children: [
        const Text(
          'This sample mirrors the WinUI Gallery media command bar. '
          'Primary commands stay visible when possible; secondary commands '
          'and dynamically overflowed commands appear in the More menu.',
        ),
        const SizedBox(height: 8),
        Card(
          child: Row(
            children: [
              const Icon(FluentIcons.music_note, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Now playing', style: TextStyle(fontSize: 16)),
                    Text('The track selected in the WinUI Gallery sample'),
                  ],
                ),
              ),
              Text(_lastAction),
            ],
          ),
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
        subtitle(content: const Text('Media player command bar')),
        CodeSnippetCard(
          codeSnippet:
              '''final commandBarKey = GlobalKey<CommandBarState>();

CommandBar(
  key: commandBarKey, ${compactBreakpointWidth != null ? '\n  compactBreakpointWidth: compactBreakpointWidth,' : ''}${_vertical ? '\n  direction: Axis.vertical,' : ''}${_compact ? '\n  isCompact: true,' : ''}
  overflowBehavior: $overflowBehavior,
  primaryItems: [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.add),
      label: const Text('New playlist'),
      tooltip: 'Ctrl+N',
      onPressed: () {},
    ),
    const CommandBarSeparator(),
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.delete),
      label: const Text('Remove'),
      tooltip: 'Delete',
      onPressed: () {},
    ),
  ],
  secondaryItems: [
    CommandBarButton(
      icon: const WindowsIcon(WindowsIcons.share),
      label: const Text('Share'),
      tooltip: 'Ctrl+S',
      onPressed: () {},
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
                  ...evenMoreCommandBarItems,
                ],
                secondaryItems: moreCommandBarItems,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
