import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/gestures.dart';

class TabViewPage extends StatefulWidget {
  const TabViewPage({super.key});

  @override
  State<TabViewPage> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> with PageMixin {
  late final TabViewController _controller;
  late final TabViewController _compactController;
  late final TabViewController _keepAliveController;
  late final TabViewController _secondaryController;
  var _nextDocument = 4;

  Tab _createDocumentTab(int index, {String? title}) {
    late final Tab tab;
    final documentTitle = title ?? 'Document $index';
    tab = Tab(
      key: ValueKey('document-$index'),
      icon: const WindowsIcon(
        WindowsIcons.document,
        fallbackIcon: FluentIcons.document,
      ),
      text: Text(documentTitle),
      body: _DocumentTabBody(title: documentTitle),
      onClosed: () => _controller.removeAt(_controller.tabs.indexOf(tab)),
    );
    return tab;
  }

  void _addDocument() {
    _controller.add(_createDocumentTab(_nextDocument++));
  }

  @override
  void initState() {
    super.initState();
    _controller = TabViewController(
      tabs: [
        _createDocumentTab(1, title: 'Project brief'),
        _createDocumentTab(2, title: 'Meeting notes'),
        _createDocumentTab(3, title: 'Release checklist'),
      ],
      initialIndex: 1,
    );
    _compactController = TabViewController(
      tabs: [
        Tab(
          icon: const WindowsIcon(
            WindowsIcons.document,
            fallbackIcon: FluentIcons.document,
          ),
          text: const Text('Notes'),
          body: const _CompactTabBody(title: 'Notes'),
        ),
        Tab(
          icon: const WindowsIcon(
            WindowsIcons.folder_open,
            fallbackIcon: FluentIcons.folder_open,
          ),
          text: const Text('Files'),
          body: const _CompactTabBody(title: 'Files'),
        ),
        Tab(
          icon: const WindowsIcon(
            WindowsIcons.settings,
            fallbackIcon: FluentIcons.settings,
          ),
          text: const Text('Settings'),
          body: const _CompactTabBody(title: 'Settings'),
        ),
      ],
    );
    _keepAliveController = TabViewController(
      tabs: [
        Tab(
          text: const Text('Kept alive'),
          body: const _CounterTabBody(keepAlive: true),
        ),
        Tab(
          text: const Text('Discarded'),
          body: const _CounterTabBody(keepAlive: false),
        ),
        Tab(text: const Text('Other 1'), body: const SizedBox()),
        Tab(text: const Text('Other 2'), body: const SizedBox()),
      ],
    );
    _secondaryController = TabViewController(
      tabs: [
        Tab(
          key: const ValueKey('secondary-tap'),
          icon: const WindowsIcon(
            WindowsIcons.document,
            fallbackIcon: FluentIcons.document,
          ),
          text: const Text('Recognizes secondary tap'),
          body: const _SecondaryTapBody(
            title: 'Use the secondary mouse button on this tab.',
          ),
          gestures: {
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (instance) {
                    instance.onSecondaryTap = () {
                      if (!mounted) return;
                      debugPrint('Secondary tap recognized');
                      displayInfoBar(
                        context,
                        builder: (context, close) {
                          return const InfoBar(
                            title: Text('Secondary tap recognized'),
                            severity: InfoBarSeverity.success,
                          );
                        },
                      );
                    };
                  },
                ),
          },
        ),
        MyCustomTab(
          key: const ValueKey('custom-secondary-tap'),
          icon: const WindowsIcon(
            WindowsIcons.settings,
            fallbackIcon: FluentIcons.settings,
          ),
          text: const Text('Custom context menu'),
          body: const _SecondaryTapBody(
            title: 'Use the secondary mouse button to open a menu.',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _compactController.dispose();
    _keepAliveController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TabView')),
      children: [
        description(
          content: const Text(
            'Use document tabs to keep related work in one window. Tabs support '
            'icons, closing, reordering, keyboard shortcuts, and custom content.',
          ),
        ),
        subtitle(content: const Text('Document tabs')),
        const Text(
          'This sample mirrors a desktop document workspace. Add a document, close '
          'a tab, or drag a tab to change its order.',
        ),
        CodeSnippetCard(
          header: const Text('Document workspace'),
          initiallyOpen: true,
          codeSnippet: r'''late final TabViewController controller;
int nextDocument = 4;

@override
void initState() {
  super.initState();
  controller = TabViewController(
    tabs: [
      createDocumentTab(1),
      createDocumentTab(2),
      createDocumentTab(3),
    ],
  );
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}

Tab createDocumentTab(int index) {
  late final Tab tab;
  tab = Tab(
    key: ValueKey('document-$index'),
    icon: const WindowsIcon(
      WindowsIcons.document,
      fallbackIcon: FluentIcons.document,
    ),
    text: Text('Document $index'),
    body: const Center(child: Text('Document content')),
    onClosed: () => controller.removeAt(controller.tabs.indexOf(tab)),
  );
  return tab;
}

TabView(
  controller: controller,
  onNewPressed: () => controller.add(createDocumentTab(nextDocument++)),
)''',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxWidth < 520 ? 360.0 : 300.0;
              return SizedBox(
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, child) {
                        final canManageTabs = _controller.tabs.length > 1;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              onPressed: _addDocument,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  WindowsIcon(
                                    WindowsIcons.add,
                                    fallbackIcon: FluentIcons.add,
                                  ),
                                  SizedBox(width: 8),
                                  Text('New document'),
                                ],
                              ),
                            ),
                            Button(
                              onPressed: canManageTabs
                                  ? () => _controller.select(1)
                                  : null,
                              child: const Text('Select second tab'),
                            ),
                            Button(
                              onPressed: canManageTabs
                                  ? () => _controller.move(
                                      0,
                                      _controller.tabs.length - 1,
                                    )
                                  : null,
                              child: const Text('Move first to end'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabView(
                        controller: _controller,
                        onNewPressed: _addDocument,
                        onReorder: (oldIndex, newIndex) {
                          debugPrint('Moved tab $oldIndex to $newIndex');
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        subtitle(content: const Text('Keyboard shortcuts')),
        RichText(
          text: () {
            TextSpan shortcut(String text) {
              return TextSpan(
                text: '•  $text',
                style: TextStyle(
                  color: theme.accentColor.defaultBrushFor(theme.brightness),
                  fontWeight: FontWeight.w600,
                ),
              );
            }

            return TextSpan(
              style: theme.typography.body,
              children: [
                shortcut('Ctrl + T'),
                const TextSpan(text: ' opens a new tab\n'),
                shortcut('Ctrl + W or Ctrl + F4'),
                const TextSpan(text: ' closes the selected tab\n'),
                shortcut('Ctrl + 1 through Ctrl + 8'),
                const TextSpan(text: ' selects a numbered tab\n'),
                shortcut('Ctrl + 9'),
                const TextSpan(text: ' selects the last tab'),
              ],
            );
          }(),
        ),
        subtitle(content: const Text('Compact tab sizing')),
        const Text(
          'Use compact tabs when the document name is secondary to its icon and '
          'the tab strip needs to stay dense.',
        ),
        CodeSnippetCard(
          codeSnippet: '''TabView(
  controller: controller,
  tabWidthBehavior: TabWidthBehavior.compact,
  closeButtonVisibility: CloseButtonVisibilityMode.never,
)''',
          child: SizedBox(
            height: 170,
            child: TabView(
              controller: _compactController,
              tabWidthBehavior: TabWidthBehavior.compact,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
            ),
          ),
        ),
        subtitle(content: const Text('Controlling body lifetime')),
        const Text(
          'Tab bodies are kept alive by default. Set automaticallyKeepAlive to '
          'false when each body should decide whether it remains alive.',
        ),
        CodeSnippetCard(
          codeSnippet: '''class KeptAliveTabBody extends StatefulWidget {
  const KeptAliveTabBody({super.key});

  @override
  State<KeptAliveTabBody> createState() => _KeptAliveTabBodyState();
}

class _KeptAliveTabBodyState extends State<KeptAliveTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Text('This tab body stays alive.');
  }
}

TabView(
  controller: controller,
  automaticallyKeepAlive: false,
)''',
          child: SizedBox(
            height: 180,
            child: TabView(
              controller: _keepAliveController,
              automaticallyKeepAlive: false,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
            ),
          ),
        ),
        subtitle(content: const Text('Custom tabs and secondary tap gestures')),
        const Text(
          'Tabs can recognize secondary clicks directly or supply their own tab '
          'implementation for a context menu.',
        ),
        CodeSnippetCard(
          codeSnippet: '''class MyCustomTab extends Tab {
  MyCustomTab({
    super.key,
    required super.body,
    required super.text,
  });

  @override
  State<Tab> createState() => MyCustomTabState();
}

final controller = TabViewController(
  tabs: <Tab>[
    Tab(
      text: const Text('Recognizes secondary tap'),
      body: const Center(child: Text('Secondary tap body')),
      gestures: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (instance) {
                instance.onSecondaryTap = () {
                  debugPrint('Secondary tap recognized');
                };
              },
            ),
      },
    ),
    MyCustomTab(
      text: const Text('Custom context menu'),
      body: const Center(child: Text('Custom tab body')),
    ),
  ],
);''',
          child: SizedBox(
            height: 190,
            child: TabView(
              controller: _secondaryController,
              tabWidthBehavior: TabWidthBehavior.sizeToContent,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentTabBody extends StatelessWidget {
  const _DocumentTabBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                FluentIcons.document,
                color: theme.accentColor.defaultBrushFor(theme.brightness),
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(title, style: theme.typography.subtitle),
              const SizedBox(height: 4),
              const Text(
                'Select another tab to continue working, or use the plus button '
                'to create a new document.',
              ),
              const SizedBox(height: 16),
              Button(onPressed: () {}, child: const Text('Open document')),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactTabBody extends StatelessWidget {
  const _CompactTabBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title content'));
  }
}

class _SecondaryTapBody extends StatelessWidget {
  const _SecondaryTapBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}

class _CounterTabBody extends StatefulWidget {
  const _CounterTabBody({required this.keepAlive});

  final bool keepAlive;

  @override
  State<_CounterTabBody> createState() => _CounterTabBodyState();
}

class _CounterTabBodyState extends State<_CounterTabBody>
    with AutomaticKeepAliveClientMixin<_CounterTabBody> {
  var _count = 0;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Count: $_count'),
          const SizedBox(height: 8),
          Button(
            onPressed: () => setState(() => _count++),
            child: const Text('Increment'),
          ),
          const SizedBox(height: 8),
          Text(
            widget.keepAlive
                ? 'This tab keeps its counter when inactive.'
                : 'This tab does not request preservation when inactive.',
          ),
        ],
      ),
    );
  }
}

class MyCustomTab extends Tab {
  MyCustomTab({
    required super.body,
    required super.text,
    super.icon,
    super.key,
  });

  @override
  State<Tab> createState() => MyCustomTabState();
}

class MyCustomTabState extends TabState {
  late FlyoutController _flyoutController;
  final _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _flyoutController = FlyoutController();
  }

  void _showMenu(Offset position) {
    _flyoutController.showFlyout<void>(
      position: position,
      builder: (context) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              onPressed: () {
                debugPrint('Item 1 pressed');
                Navigator.of(context).maybePop();
              },
              leading: const WindowsIcon(WindowsIcons.add),
              text: const Text('New tab'),
            ),
            MenuFlyoutItem(
              onPressed: () {
                debugPrint('Item 2 pressed');
                Navigator.of(context).maybePop();
              },
              leading: const WindowsIcon(WindowsIcons.refresh),
              text: const Text('Refresh'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        final targetContext = _targetKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject()! as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        _showMenu(position);
      },
      child: FlyoutTarget(
        key: _targetKey,
        controller: _flyoutController,
        child: super.build(context),
      ),
    );
  }
}
