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

  int _secondaryIndex = 0;

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
        subtitle(
          content: const Text(
            'A TabView with support for adding, closing and rearraging tabs',
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
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
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
              onReorder: (final oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
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
