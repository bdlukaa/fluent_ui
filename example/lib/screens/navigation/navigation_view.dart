import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/page.dart';

class NavigationViewPage extends StatefulWidget {
  const NavigationViewPage({super.key});

  @override
  State<NavigationViewPage> createState() => _NavigationViewPageState();
}

class _NavigationViewPageState extends State<NavigationViewPage>
    with PageMixin {
  static const double itemHeight = 300.0;

  int topIndex = 0;

  PaneDisplayMode displayMode = PaneDisplayMode.open;
  String pageTransition = 'Default';
  static const List<String> pageTransitions = [
    'Default',
    'Entrance',
    'Drill in',
    'Horizontal',
  ];

  String indicator = 'Sticky';
  static final Map<String, Widget> indicators = {
    'Sticky': const StickyNavigationIndicator(),
    'End': const EndNavigationIndicator(),
  };

  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const _NavigationBodyItem(),
      onTap: () => debugPrint('Tapped home'),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.issue_tracking),
      title: const Text('Track orders'),
      infoBadge: const InfoBadge(source: Text('8')),
      body: const _NavigationBodyItem(
        header: 'Badging',
        content: Text(
          'Badging is a non-intrusive and intuitive way to display '
          'notifications or bring focus to an area within an app - '
          'whether that be for notifications, indicating new content, '
          'or showing an alert. An InfoBadge is a small piece of UI '
          'that can be added into an app and customized to display a '
          'number, icon, or a simple dot.',
        ),
      ),
      onTap: () => debugPrint('Tapped track orders'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.disable_updates),
      title: const Text('Disabled Item'),
      body: const _NavigationBodyItem(),
      enabled: false,
      onTap: () => debugPrint('Tapped disabled'),
    ),
    PaneItemExpander(
      icon: const Icon(FluentIcons.account_management),
      title: const Text('Account'),
      initiallyExpanded: true,
      body: const _NavigationBodyItem(
        header: 'PaneItemExpander',
        content: Text(
          'Some apps may have a more complex hierarchical structure '
          'that requires more than just a flat list of navigation '
          'items. You may want to use top-level navigation items to '
          'display categories of pages, with children items displaying '
          'specific pages. It is also useful if you have hub-style '
          'pages that only link to other pages. For these kinds of '
          'cases, you should create a hierarchical NavigationView.',
        ),
      ),
      onTap: () => debugPrint('Tapped account'),
      items: [
        PaneItemHeader(header: const Text('Apps')),
        PaneItem(
          icon: const Icon(FluentIcons.mail),
          title: const Text('Mail'),
          body: const _NavigationBodyItem(),
          onTap: () => debugPrint('Tapped mail'),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.calendar),
          title: const Text('Calendar'),
          body: const _NavigationBodyItem(),
          onTap: () => debugPrint('Tapped calendar'),
        ),
      ],
    ),
    PaneItemWidgetAdapter(
      child: Builder(builder: (context) {
        if (NavigationView.of(context).displayMode == PaneDisplayMode.compact) {
          return const FlutterLogo();
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200.0),
          child: const Row(children: [
            FlutterLogo(),
            SizedBox(width: 6.0),
            Text('This is a custom widget'),
          ]),
        );
      }),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('NavigationView')),
      children: [
        const Text(
          'The NavigationView control provides top-level navigation for your app. '
          'It adapts to a variety of screen sizes and supports both top and left '
          'navigation styles.',
        ),
        const SizedBox(height: 10.0),
        ...buildDisplayMode(
          PaneDisplayMode.top,
          'Top display mode',
          'The pane is positioned above the content.',
        ),
        ...buildDisplayMode(
          PaneDisplayMode.open,
          'Open display mode',
          'The pane is expanded and positioned to the left of the content.',
        ),
        ...buildDisplayMode(
          PaneDisplayMode.compact,
          'Compact display mode',
          'The pane shows only icons until opened and is positioned to the left '
              'of the content. When opened, the pane overlays the content.',
        ),
        ...buildDisplayMode(
          PaneDisplayMode.minimal,
          'Minimal display mode',
          'Only the menu button is shown until the pane is opened. When opened, '
              'the pane overlays the left side of the content.',
        ),
      ],
    );
  }

  List<Widget> buildDisplayMode(
    PaneDisplayMode displayMode,
    String title,
    String desc,
  ) {
    if (displayMode != this.displayMode) return [];
    return [
      Wrap(runSpacing: 10.0, spacing: 10.0, children: [
        InfoLabel(
          label: 'Display mode',
          child: ComboBox<PaneDisplayMode>(
            value: displayMode,
            items: ([...PaneDisplayMode.values]..remove(PaneDisplayMode.auto))
                .map((mode) {
              return ComboBoxItem(
                value: mode,
                child: Text(
                  mode.name.uppercaseFirst(),
                ),
              );
            }).toList(),
            onChanged: (mode) => setState(
              () => this.displayMode = mode ?? displayMode,
            ),
          ),
        ),
        InfoLabel(
          label: 'Page Transition',
          child: ComboBox<String>(
            items: pageTransitions
                .map((e) => ComboBoxItem(value: e, child: Text(e)))
                .toList(),
            value: pageTransition,
            onChanged: (transition) => setState(
              () => pageTransition = transition ?? pageTransition,
            ),
          ),
        ),
        InfoLabel(
          label: 'Indicator',
          child: ComboBox<String>(
            items: indicators.keys
                .map((e) => ComboBoxItem(value: e, child: Text(e)))
                .toList(),
            value: indicator,
            onChanged: (i) => setState(
              () => indicator = i ?? indicator,
            ),
          ),
        ),
        InfoLabel(
          label: '',
          child: Button(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push(FluentPageRoute(builder: (context) {
                return const NavigationViewShellRoute();
              }));
            },
            child: const Text('Open in a new screen'),
          ),
        ),
        InfoLabel(
          label: '',
          child: Button(
            onPressed: () {
              context.push('/navigation_view');
            },
            child: const Text('Open in a new shell route'),
          ),
        ),
      ]),
      subtitle(content: Text(title)),
      description(content: Text(desc)),
      CardHighlight(
        codeSnippet: '''
// Do not define the `items` inside the `Widget Build` function
// otherwise on running `setstate`, new item can not be added.

List<NavigationPaneItem> items = [
  PaneItem(
    icon: const Icon(FluentIcons.home),
    title: const Text('Home'),
    body: const _NavigationBodyItem(),
  ),
  PaneItemSeparator(),
  PaneItem(
    icon: const Icon(FluentIcons.issue_tracking),
    title: const Text('Track orders'),
    infoBadge: const InfoBadge(source: Text('8')),
    body: const _NavigationBodyItem(
      header: 'Badging',
      content: Text(
        'Badging is a non-intrusive and intuitive way to display '
        'notifications or bring focus to an area within an app - '
        'whether that be for notifications, indicating new content, '
        'or showing an alert. An InfoBadge is a small piece of UI '
        'that can be added into an app and customized to display a '
        'number, icon, or a simple dot.',
      ),
    ),
  ),
  PaneItem(
    icon: const Icon(FluentIcons.disable_updates),
    title: const Text('Disabled Item'),
    body: const _NavigationBodyItem(),
    enabled: false,
  ),
  PaneItemExpander(
    icon: const Icon(FluentIcons.account_management),
    title: const Text('Account'),
    body: const _NavigationBodyItem(
      header: 'PaneItemExpander',
      content: Text(
        'Some apps may have a more complex hierarchical structure '
        'that requires more than just a flat list of navigation '
        'items. You may want to use top-level navigation items to '
        'display categories of pages, with children items displaying '
        'specific pages. It is also useful if you have hub-style '
        'pages that only link to other pages. For these kinds of '
        'cases, you should create a hierarchical NavigationView.',
      ),
    ),
    items: [
      PaneItemHeader(header: const Text('Apps')),
      PaneItem(
        icon: const Icon(FluentIcons.mail),
        title: const Text('Mail'),
        body: const _NavigationBodyItem(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.calendar),
        title: const Text('Calendar'),
        body: const _NavigationBodyItem(),
      ),
    ],
  ),
  PaneItemWidgetAdapter(
    child: Builder(builder: (context) {
      // Build the widget depending on the current display mode.
      //
      // This already returns the resolved auto display mode.
      if (NavigationView.of(context).displayMode == PaneDisplayMode.compact) {
        return const FlutterLogo();
      }
      return ConstrainedBox(
        // Constraints are required for top display mode, otherwise the Row will
        // expand to the available space.
        constraints: const BoxConstraints(maxWidth: 200.0),
        child: const Row(children: [
          FlutterLogo(),
          SizedBox(width: 6.0),
          Text('This is a custom widget'),
        ]),
      );
    }),
  ),
];

// Return the NavigationView from `Widegt Build` function

NavigationView(
  appBar: const NavigationAppBar(
    title: Text('NavigationView'),
  ),
  pane: NavigationPane(
    selected: topIndex,
    onItemPressed: (index) {
      // Do anything you want to do, such as:
      if (index == topIndex) {
        if (displayMode == PaneDisplayMode.open) {
          setState(() => this.displayMode = PaneDisplayMode.compact);
        } else if (displayMode == PaneDisplayMode.compact) {
          setState(() => this.displayMode = PaneDisplayMode.open);
        }
      }
    },
    onChanged: (index) => setState(() => topIndex = index),
    displayMode: displayMode,
    items: items,
    footerItems: [
      PaneItem(
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const _NavigationBodyItem(),
      ),
      PaneItemAction(
        icon: const Icon(FluentIcons.add),
        title: const Text('Add New Item'),
        onTap: () {
          // Your Logic to Add New `NavigationPaneItem`
          items.add(
            PaneItem(
              icon: const Icon(FluentIcons.new_folder),
              title: const Text('New Item'),
              body: const Center(
                child: Text(
                  'This is a newly added Item',
                ),
              ),
            ),
          );
          setState(() {});
        },
      ),
    ],
  ),
)''',
        child: SizedBox(
          height: itemHeight,
          child: NavigationView(
            appBar: const NavigationAppBar(
              title: Text('NavigationView'),
            ),
            onDisplayModeChanged: (mode) {
              debugPrint('Changed to $mode');
            },
            pane: NavigationPane(
              selected: topIndex,
              onItemPressed: (index) {
                // Do anything you want to do, such as:
                if (index == topIndex) {
                  if (displayMode == PaneDisplayMode.open) {
                    setState(() => this.displayMode = PaneDisplayMode.compact);
                  } else if (displayMode == PaneDisplayMode.compact) {
                    setState(() => this.displayMode = PaneDisplayMode.open);
                  }
                }
              },
              onChanged: (index) => setState(() => topIndex = index),
              displayMode: displayMode,
              indicator: indicators[indicator],
              header: const Text('Pane Header'),
              items: items,
              footerItems: [
                PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('Settings'),
                  body: const _NavigationBodyItem(),
                ),
                PaneItemAction(
                  icon: const Icon(FluentIcons.add),
                  title: const Text('Add New Item'),
                  onTap: () {
                    items.add(
                      PaneItem(
                        icon: const Icon(FluentIcons.new_folder),
                        title: const Text('New Item'),
                        body: const Center(
                          child: Text(
                            'This is a newly added Item',
                          ),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
            transitionBuilder: pageTransition == 'Default'
                ? null
                : (child, animation) {
                    switch (pageTransition) {
                      case 'Entrance':
                        return EntrancePageTransition(
                          animation: animation,
                          child: child,
                        );
                      case 'Drill in':
                        return DrillInPageTransition(
                          animation: animation,
                          child: child,
                        );
                      case 'Horizontal':
                        return HorizontalSlidePageTransition(
                          animation: animation,
                          child: child,
                        );
                      default:
                        throw UnsupportedError(
                          '$pageTransition is not a supported transition',
                        );
                    }
                  },
          ),
        ),
      ),
    ];
  }
}

class NavigationViewShellRoute extends StatelessWidget {
  const NavigationViewShellRoute({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: () {
          const title = Text('NavigationView');

          if (kIsWeb) return title;

          return const DragToMoveArea(child: title);
        }(),
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      content: const ScaffoldPage(
        header: PageHeader(
          title: Text('New Page'),
        ),
        content: Center(
          child: Text('This is a new page'),
        ),
      ),
    );
  }
}

class _NavigationBodyItem extends StatelessWidget {
  const _NavigationBodyItem({
    this.header,
    this.content,
  });

  final String? header;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(title: Text(header ?? 'This is a header text')),
      content: content ?? const SizedBox.shrink(),
    );
  }
}
