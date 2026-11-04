import 'dart:math';

import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:window_manager/window_manager.dart';

class TabViewPage extends StatefulWidget {
  const TabViewPage({super.key});

  @override
  State<TabViewPage> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> with PageMixin {
  int currentIndex = 0;
  List<Tab>? tabs;
  late final TabViewController _controller;
  var _nextControllerTab = 3;

  TabWidthBehavior tabWidthBehavior = TabWidthBehavior.equal;
  CloseButtonVisibilityMode closeButtonVisibilityMode =
      CloseButtonVisibilityMode.always;
  bool showScrollButtons = true;
  bool wheelScroll = false;

  Tab generateTab(final int index) {
    final allIcons = WindowsIcons.allIcons.values;
    late Tab tab;
    tab = Tab(
      text: Text('Document $index'),
      semanticLabel: 'Document #$index',
      icon: Icon(allIcons.elementAt(Random().nextInt(allIcons.length))),
      body: Container(
        color:
            Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
      ),
      onClosed: () {
        setState(() {
          tabs!.remove(tab);

          if (currentIndex > 0) currentIndex--;
        });
      },
    );
    return tab;
  }

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

  int _secondaryIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabViewController(
      tabs: List.generate(3, _createControllerTab),
      initialIndex: 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    tabs ??= List.generate(3, generateTab);
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
        subtitle(content: const Text('Controller-managed tabs')),
        const Text(
          'TabViewController owns the tabs and selection state. Use it when '
          'tabs are added, closed, selected, or reordered outside the build '
          'method. Give each tab a stable key so its body stays associated with '
          'that tab when the list changes.',
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
        subtitle(
          content: const Text(
            'Legacy callback API: adding, closing and rearranging tabs',
          ),
        ),
        Card(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: InfoLabel(
                  label: 'Tab width behavior',
                  child: ComboBox<TabWidthBehavior>(
                    isExpanded: true,
                    value: tabWidthBehavior,
                    items: TabWidthBehavior.values.map((final behavior) {
                      return ComboBoxItem(
                        value: behavior,
                        child: Text(behavior.name),
                      );
                    }).toList(),
                    onChanged: (final behavior) {
                      if (behavior != null) {
                        setState(() => tabWidthBehavior = behavior);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: InfoLabel(
                  label: 'Close button visbility',
                  child: ComboBox<CloseButtonVisibilityMode>(
                    isExpanded: true,
                    value: closeButtonVisibilityMode,
                    items: CloseButtonVisibilityMode.values.map((final mode) {
                      return ComboBoxItem(value: mode, child: Text(mode.name));
                    }).toList(),
                    onChanged: (final mode) {
                      if (mode != null) {
                        setState(() => closeButtonVisibilityMode = mode);
                      }
                    },
                  ),
                ),
              ),
              Checkbox(
                checked: showScrollButtons,
                onChanged: (final v) => setState(() => showScrollButtons = v!),
                content: const Text('Show scroll buttons'),
              ),
              Checkbox(
                checked: wheelScroll,
                onChanged: (final v) => setState(() => wheelScroll = v!),
                content: const Text('Wheel scroll'),
              ),
            ],
          ),
        ),
        CodeSnippetCard(
          codeSnippet:
              '''int currentIndex = 0;
List<Tab> tabs = [];

/// Creates a tab for the given index
Tab generateTab(int index) {
  late Tab tab;
  tab = Tab(
    text: Text('Document \$index'),
    semanticLabel: 'Document #\$index',
    icon: const FlutterLogo(),
    body: Container(
      color: Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
    ),
    onClosed: () {
      setState(() {
        tabs!.remove(tab);

        if (currentIndex > 0) currentIndex--;
      });
    },
  );
  return tab;
}

TabView(
  tabs: tabs!,
  currentIndex: currentIndex,
  onChanged: (index) => setState(() => currentIndex = index),
  tabWidthBehavior: $tabWidthBehavior,
  closeButtonVisibility: $closeButtonVisibilityMode,
  showScrollButtons: $showScrollButtons,
  wheelScroll: $wheelScroll,
  onNewPressed: () {
    setState(() {
      final index = tabs!.length + 1;
      final tab = generateTab(index);
      tabs!.add(tab);
    });
  },
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final item = tabs!.removeAt(oldIndex);
      tabs!.insert(newIndex, item);

      if (currentIndex == newIndex) {
        currentIndex = oldIndex;
      } else if (currentIndex == oldIndex) {
        currentIndex = newIndex;
      }
    });
  },
)''',
          child: SizedBox(
            height: 400,
            child: TabView(
              tabs: tabs!,
              reservedStripWidth: 100,
              currentIndex: currentIndex,
              onChanged: (final index) => setState(() => currentIndex = index),
              tabWidthBehavior: tabWidthBehavior,
              closeButtonVisibility: closeButtonVisibilityMode,
              showScrollButtons: showScrollButtons,
              onNewPressed: () {
                setState(() {
                  final index = tabs!.length + 1;
                  final tab = generateTab(index);
                  tabs!.add(tab);
                });
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = tabs!.removeAt(oldIndex);
                  tabs!.insert(newIndex, item);

                  if (currentIndex == newIndex) {
                    currentIndex = oldIndex;
                  } else if (currentIndex == oldIndex) {
                    currentIndex = newIndex;
                  }
                });
              },
              stripBuilder: kIsWeb
                  ? null
                  : (final context, final strip) {
                      return DragToMoveArea(child: strip);
                    },
            ),
          ),
        ),
        subtitle(content: const Text('Custom tabs and secondary tap gestures')),
        CodeSnippetCard(
          codeSnippet: '''
class MyCustomTab extends Tab {
  MyCustomTab({
    super.key,
    required super.body,
    required super.text,
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
      onSecondaryTapUp: (d) {
        // This calculates the position of the flyout according to the parent navigator.
        // See https://bdlukaa.github.io/fluent_ui/#/popups/flyout
        final targetContext = _targetKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
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

TabView(
  currentIndex: index,
  onChanged: (index) => setState(() => this.index = index),
  tabWidthBehavior: TabWidthBehavior.sizeToContent,
  closeButtonVisibility: CloseButtonVisibilityMode.never,
  tabs: <Tab>[
    Tab(
      text: const Text('Tab that recognizes secondary tap'),
      body: Container(color: Colors.red),
      gestures: {
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer instance) {
            instance.onSecondaryTap = () {
              debugPrint('Secondary tap recognized');
              displayInfoBar(context, builder: (context, close) {
                return const InfoBar(
                  title: Text('Secondary tap recognized'),
                  severity: InfoBarSeverity.success,
                );
              });
            };
          },
        ),
      },
    ),
    MyCustomTab(
      text: const Text('Custom tab that opens menu on secondary tap'),
      body: Container(color: Colors.blue),
    ),
  ],
)
''',
          child: SizedBox(
            height: 200,
            child: TabView(
              currentIndex: _secondaryIndex,
              onChanged: (final index) =>
                  setState(() => _secondaryIndex = index),
              tabWidthBehavior: TabWidthBehavior.sizeToContent,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
              tabs: <Tab>[
                Tab(
                  text: const Text('Tab that recognizes secondary tap'),
                  body: Container(color: Colors.red),
                  gestures: {
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TapGestureRecognizer
                        >(TapGestureRecognizer.new, (final instance) {
                          instance.onSecondaryTap = () {
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
                        }),
                  },
                ),
                MyCustomTab(
                  text: const Text(
                    'Custom tab that opens menu on secondary tap',
                  ),
                  body: Container(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
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
      onSecondaryTapUp: (final d) {
        // This calculates the position of the flyout according to the parent navigator.
        // See https://bdlukaa.github.io/fluent_ui/#/popups/flyout
        final targetContext = _targetKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject()! as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
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
