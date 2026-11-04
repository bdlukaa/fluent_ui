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
  late final TabViewController _keepAliveController;
  late final TabViewController _secondaryController;
  var _nextControllerTab = 3;

  Tab _createControllerTab(final int index) {
    late final Tab tab;
    tab = Tab(
      key: ValueKey('controller-document-$index'),
      text: Text('Controller document $index'),
      body: Center(child: Text('Content for controller document $index')),
      onClosed: () => _controller.removeAt(_controller.tabs.indexOf(tab)),
    );
    return tab;
  }

  void _addControllerTab() {
    _controller.add(_createControllerTab(_nextControllerTab++));
  }

  @override
  void initState() {
    super.initState();
    _controller = TabViewController(
      tabs: List.generate(3, _createControllerTab),
      initialIndex: 1,
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
          text: const Text('Tab that recognizes secondary tap'),
          body: Container(color: Colors.red),
          gestures: {
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (final instance) {
                    instance.onSecondaryTap = () {
                      if (!mounted) return;
                      debugPrint('Secondary tap recognized');
                      displayInfoBar(
                        context,
                        builder: (final context, final close) {
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
          text: const Text('Custom tab that opens menu on secondary tap'),
          body: Container(color: Colors.blue),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _keepAliveController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('TabView')),
      children: [
        const Text(
          'The TabView control is a way to display a set of tabs and their '
          'respective content. TabViews are useful for displaying several pages '
          '(or documents) of content while giving a user the capability to '
          'rearrange, open, or close new tabs.',
        ),
        subtitle(content: const Text('Keyboarding support')),
        RichText(
          text: () {
            const lineBreakSpan = TextSpan(text: '\n');
            const topicSpan = TextSpan(
              text: '  •  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
            TextSpan shortcutSpan(final String text) {
              return TextSpan(
                text: text,
                style: TextStyle(
                  color: theme.accentColor.defaultBrushFor(theme.brightness),
                  fontWeight: FontWeight.w600,
                ),
              );
            }

            return TextSpan(
              children: [
                TextSpan(
                  children: [
                    topicSpan,
                    shortcutSpan('Ctrl + T'),
                    const TextSpan(text: ' opens a new tab'),
                    lineBreakSpan,
                  ],
                ),
                TextSpan(
                  children: [
                    topicSpan,
                    shortcutSpan('Ctrl + W'),
                    const TextSpan(text: ' or '),
                    shortcutSpan('Ctrl + F4'),
                    const TextSpan(text: ' closes the selected tab'),
                    lineBreakSpan,
                  ],
                ),
                TextSpan(
                  children: [
                    topicSpan,
                    shortcutSpan('Ctrl + 1'),
                    const TextSpan(text: ' + '),
                    shortcutSpan('Ctrl + 8'),
                    const TextSpan(text: ' selects that number tab'),
                    lineBreakSpan,
                  ],
                ),
                TextSpan(
                  children: [
                    topicSpan,
                    shortcutSpan('Ctrl + 9'),
                    const TextSpan(text: ' selects the last tab'),
                  ],
                ),
              ],
              style: theme.typography.body,
            );
          }(),
        ),
        subtitle(content: const Text('Managing tabs')),
        const Text(
          'TabViewController owns the tabs and selection state. Give each tab '
          'a stable key so its body stays associated with that tab when the '
          'list changes.',
        ),
        CodeSnippetCard(
          codeSnippet: r'''late final TabViewController controller;
int nextTab = 3;

@override
void initState() {
  super.initState();
  controller = TabViewController(
    tabs: List.generate(3, createTab),
    initialIndex: 1,
  );
}

Tab createTab(int index) {
  late final Tab tab;
  tab = Tab(
    key: ValueKey('document-$index'),
    text: Text('Document $index'),
    body: Center(child: Text('Content $index')),
    onClosed: () => controller.removeAt(controller.tabs.indexOf(tab)),
  );
  return tab;
}

void addTab() {
  controller.add(createTab(nextTab++));
}

TabView(
  controller: controller,
  onNewPressed: addTab,
)

// Select a tab programmatically.
controller.select(1);

// Move a tab programmatically. Users can also drag tabs to reorder them.
controller.move(0, controller.tabs.length - 1);''',
          child: SizedBox(
            height: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Button(
                      onPressed: _addControllerTab,
                      child: const Text('Add tab'),
                    ),
                    Button(
                      onPressed: () {
                        if (_controller.tabs.length > 1) {
                          _controller.select(1);
                        }
                      },
                      child: const Text('Select second tab'),
                    ),
                    Button(
                      onPressed: () {
                        if (_controller.tabs.length > 1) {
                          _controller.move(0, _controller.tabs.length - 1);
                        }
                      },
                      child: const Text('Move first tab to end'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Close a tab with its close button or drag tabs to reorder them.',
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabView(
                    controller: _controller,
                    onNewPressed: _addControllerTab,
                  ),
                ),
              ],
            ),
          ),
        ),
        subtitle(content: const Text('Controlling body lifetime')),
        const Text(
          'Tab bodies are kept alive by default. Set automaticallyKeepAlive to false '
          'when each body should decide whether it remains alive.',
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
      key: const ValueKey('secondary-tap'),
      text: const Text('Tab that recognizes secondary tap'),
      body: Container(color: Colors.red),
    ),
    MyCustomTab(
      key: const ValueKey('custom-secondary-tap'),
      text: const Text('Custom tab that opens menu on secondary tap'),
      body: Container(color: Colors.blue),
    ),
  ],
);

TabView(
  controller: controller,
  tabWidthBehavior: TabWidthBehavior.sizeToContent,
  closeButtonVisibility: CloseButtonVisibilityMode.never,
)''',
          child: SizedBox(
            height: 200,
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
  Widget build(final BuildContext context) {
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
  MyCustomTab({required super.body, required super.text, super.key});

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

  void _showMenu(final Offset position) {
    _flyoutController.showFlyout<void>(
      position: position,
      builder: (final context) {
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
  Widget build(final BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (final details) {
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
