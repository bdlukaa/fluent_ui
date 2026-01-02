import 'package:example/main.dart';
import 'package:example/widgets/code_snippet_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/page.dart';

class NavigationViewPage extends StatefulWidget {
  const NavigationViewPage({super.key});

  @override
  State<NavigationViewPage> createState() => _NavigationViewPageState();
}

class _NavigationViewPageState extends State<NavigationViewPage>
    with PageMixin {
  static const double itemHeight = 600;

  int topIndex = 0;

  PaneDisplayMode displayMode = PaneDisplayMode.expanded;
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
  bool hasTopBar = true;

  List<NavigationPaneItem> items = [];

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('NavigationView')),
      children: [
        const Text(
          'The NavigationView control provides top-level navigation for your app. '
          'It adapts to a variety of screen sizes and supports both top and left '
          'navigation styles.',
        ),
        const SizedBox(height: 10),
        ...buildDisplayMode(
          PaneDisplayMode.top,
          'Top display mode',
          'The pane is positioned above the content.',
        ),
        ...buildDisplayMode(
          PaneDisplayMode.expanded,
          'Open display mode',
          'The pane is expanded and positioned to the left of the content.',
        ),
        ...buildDisplayMode(
          PaneDisplayMode.compact,
          'Compact display mode',
          'The pane shows only icons until expanded and is positioned to the left '
              'of the content. When expanded, the pane overlays the content.',
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
    final PaneDisplayMode displayMode,
    final String title,
    final String desc,
  ) {
    if (displayMode != this.displayMode) return [];
    return [
      Wrap(
        runSpacing: 10,
        spacing: 10,
        children: [
          InfoLabel(
            label: 'Display mode',
            child: ComboBox<PaneDisplayMode>(
              value: displayMode,
              items: ([...PaneDisplayMode.values]..remove(PaneDisplayMode.auto))
                  .map((final mode) {
                    return ComboBoxItem(
                      value: mode,
                      child: Text(mode.name.uppercaseFirst()),
                    );
                  })
                  .toList(),
              onChanged: (final mode) =>
                  setState(() => this.displayMode = mode ?? displayMode),
            ),
          ),
          InfoLabel(
            label: 'Page Transition',
            child: ComboBox<String>(
              items: pageTransitions
                  .map((final e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              value: pageTransition,
              onChanged: (final transition) =>
                  setState(() => pageTransition = transition ?? pageTransition),
            ),
          ),
          InfoLabel(
            label: 'Indicator',
            child: ComboBox<String>(
              items: indicators.keys
                  .map((final e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              value: indicator,
              onChanged: (final i) =>
                  setState(() => indicator = i ?? indicator),
            ),
          ),
          InfoLabel(
            label: '',
            child: Button(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  FluentPageRoute(
                    builder: (final context) {
                      return const NavigationViewShellRoute();
                    },
                  ),
                );
              },
              child: const Text('Open in a new screen'),
            ),
          ),
          InfoLabel(
            label: '',
            child: Checkbox(
              checked: hasTopBar,
              onChanged: (final value) {
                setState(() => hasTopBar = value ?? false);
              },
              content: const Text('Has top bar'),
            ),
          ),
        ],
      ),
      subtitle(content: Text(title)),
      description(content: Text(desc)),
      CodeSnippetCard(
        codeSnippet: '''NavigationView(
  titleBar: TitleBar(
    icon: const FlutterLogo(),
    title: const Text('Windows UI for Flutter'),
    subtitle: const Text('Preview'),
    content: Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
      constraints: const BoxConstraints(maxWidth: 380),
      child: Builder(builder: (context) {
        return AutoSuggestBox(items: []);
      }),
    ),
    endHeader: const FlutterLogo(),
    captionControls: const WindowButtons(),
  ),
  pane: NavigationPane(
    selected: topIndex,
    onChanged: (index) => setState(() => topIndex = index),
    displayMode: displayMode,
    indicator: indicators[indicator],
    header: const Text('Pane Header'),
    items: [
      PaneItem(
        icon: const WindowsIcon(WindowsIcons.home),
        title: const Text('Home'),
        body: const _NavigationBodyItem(),
      ),
      PaneItemSeparator(),
      PaneItem(
        icon: const WindowsIcon(WindowsIcons.issue_tracking),
        title: const Text('Track orders'),
        infoBadge: const InfoBadge(source: Text('8')),
        body: const _NavigationBodyItem(header: 'Badging', content: Text('...')),
      ),
      PaneItem(
        icon: const WindowsIcon(WindowsIcons.disable_updates),
        title: const Text('Disabled Item'),
        body: const _NavigationBodyItem(),
        enabled: false,
      ),
      PaneItemHeader(header: const Text('Apps')),
      PaneItemExpander(
        icon: const WindowsIcon(WindowsIcons.account_management),
        title: const Text('Account'),
        initiallyExpanded: true,
        items: [
          PaneItem(
            icon: const WindowsIcon(WindowsIcons.mail),
            title: const Text('Mail'),
            body: const _NavigationBodyItem(),
          ),
          PaneItem(
            icon: const WindowsIcon(WindowsIcons.calendar),
            title: const Text('Calendar'),
            body: const _NavigationBodyItem(),
          ),
          PaneItemHeader(header: const Text('Subscriptions')),
          PaneItemExpander(
            icon: const WindowsIcon(WindowsIcons.payment_card),
            title: const Text('Cards'),
            body: const _NavigationBodyItem(),
            items: [
              PaneItem(
                icon: const WindowsIcon(WindowsIcons.payment_card),
                title: const Text('Credit Card'),
                body: const _NavigationBodyItem(),
              ),
              PaneItem(
                icon: const WindowsIcon(WindowsIcons.payment_card),
                title: const Text('Debit Card'),
                body: const _NavigationBodyItem(),
              ),
            ],
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
              Flexible(child: Text('This is a custom widget')),
            ]),
          );
        }),
      ),
      // Items added dynamically
      ...items,
    ],
    footerItems: [
      PaneItemSeparator(),
      PaneItem(
        icon: const WindowsIcon(WindowsIcons.settings),
        title: const Text('Settings'),
        body: const _NavigationBodyItem(),
      ),
      PaneItemAction(
        icon: const WindowsIcon(WindowsIcons.add),
        title: const Text('Add New Item'),
        onTap: () {
          // Logic to add new items
        },
      ),
    ],
  ),
)''',
        child: SizedBox(
          height: itemHeight,
          child: NavigationView(
            titleBar: hasTopBar
                ? TitleBar(
                    icon: const FlutterLogo(),
                    title: const Text('Windows UI for Flutter'),
                    subtitle: const Text('Preview'),
                    content: Container(
                      margin: const EdgeInsetsDirectional.symmetric(
                        vertical: 6,
                      ),
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Builder(
                        builder: (context) {
                          final allItems = NavigationView.dataOf(context)
                              .pane!
                              .allItems
                              .where(
                                (i) =>
                                    i is PaneItem &&
                                    i is! PaneItemExpander &&
                                    i.body != null &&
                                    i.enabled,
                              )
                              .cast<PaneItem>();
                          return AutoSuggestBox(
                            items: [
                              for (final item in allItems)
                                AutoSuggestBoxItem<String>(
                                  value: (item.title! as Text).data,
                                  label: (item.title! as Text).data!,
                                  onSelected: () {
                                    NavigationView.dataOf(
                                      context,
                                    ).pane?.changeTo(item);
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    endHeader: const FlutterLogo(),
                    captionControls: const WindowButtons(),
                  )
                : null,
            onDisplayModeChanged: (final mode) {
              debugPrint('Changed to $mode');
            },
            pane: NavigationPane(
              selected: topIndex,
              onChanged: (final index) {
                debugPrint('Changed to $index');
                setState(() => topIndex = index);
              },
              displayMode: displayMode,
              indicator: indicators[indicator],
              header: const Text('Pane Header'),
              items: [
                PaneItem(
                  icon: const WindowsIcon(WindowsIcons.home),
                  title: const Text('Home'),
                  body: const _NavigationBodyItem(),
                  onTap: () => debugPrint('Tapped home'),
                ),
                PaneItemSeparator(),
                PaneItem(
                  icon: const WindowsIcon(WindowsIcons.mail),
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
                  icon: const WindowsIcon(WindowsIcons.disable_updates),
                  title: const Text('Disabled Item'),
                  body: const _NavigationBodyItem(),
                  enabled: false,
                  onTap: () => debugPrint('Tapped disabled'),
                ),
                PaneItemHeader(header: const Text('Apps')),
                PaneItemExpander(
                  icon: const WindowsIcon(WindowsIcons.switch_user),
                  title: const Text('Account'),
                  initiallyExpanded: true,
                  // ignore: avoid_redundant_argument_values
                  body: null,
                  onTap: () =>
                      debugPrint('Tapped account (expander without body)'),
                  items: [
                    PaneItem(
                      icon: const WindowsIcon(WindowsIcons.mail),
                      title: const Text('Mail'),
                      body: const _NavigationBodyItem(),
                      onTap: () => debugPrint('Tapped mail'),
                    ),
                    PaneItemHeader(header: const Text('Subscriptions')),
                    PaneItemExpander(
                      icon: const WindowsIcon(WindowsIcons.payment_card),
                      title: const Text('Cards'),
                      body: const _NavigationBodyItem(),
                      onTap: () => debugPrint('Tapped cards'),
                      items: [
                        PaneItem(
                          icon: const WindowsIcon(WindowsIcons.payment_card),
                          title: const Text('Credit Card'),
                          body: const _NavigationBodyItem(),
                          onTap: () => debugPrint('Tapped credit card'),
                        ),
                        PaneItem(
                          icon: const WindowsIcon(WindowsIcons.payment_card),
                          title: const Text('Debit Card'),
                          body: const _NavigationBodyItem(),
                          onTap: () => debugPrint('Tapped debit card'),
                        ),
                      ],
                    ),
                    PaneItem(
                      icon: const WindowsIcon(WindowsIcons.calendar),
                      title: const Text('Calendar'),
                      body: const _NavigationBodyItem(),
                      onTap: () => debugPrint('Tapped calendar'),
                    ),
                  ],
                ),
                PaneItemWidgetAdapter(
                  child: Builder(
                    builder: (final context) {
                      if (NavigationView.dataOf(context).displayMode ==
                          PaneDisplayMode.compact) {
                        return const FlutterLogo();
                      }
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FlutterLogo(),
                            SizedBox(width: 6),
                            Flexible(child: Text('This is a custom widget')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ...items,
              ],
              footerItems: [
                PaneItemSeparator(),
                PaneItem(
                  icon: const WindowsIcon(WindowsIcons.settings),
                  title: const Text('Settings'),
                  body: const _NavigationBodyItem(),
                ),
                PaneItemAction(
                  icon: const WindowsIcon(WindowsIcons.add),
                  title: const Text('Add New Item'),
                  onTap: () {
                    items.add(
                      PaneItem(
                        icon: const WindowsIcon(WindowsIcons.new_folder),
                        title: const Text('New Item'),
                        body: const Center(
                          child: Text('This is a newly added Item'),
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
                : (final child, final animation) {
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
  const NavigationViewShellRoute({super.key});

  @override
  Widget build(final BuildContext context) {
    return NavigationView(
      titleBar: TitleBar(
        title: const Text('NavigationView'),
        onBackRequested: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        onDragStarted: !kIsWeb ? windowManager.startDragging : null,
      ),
      content: const ScaffoldPage(
        header: PageHeader(title: Text('New Page')),
        content: Center(child: Text('This is a new page')),
      ),
    );
  }
}

class _NavigationBodyItem extends StatelessWidget {
  const _NavigationBodyItem({this.header, this.content});

  final String? header;
  final Widget? content;

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(title: Text(header ?? 'This is a header text')),
      content:
          content ??
          LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              final crossAxisCount = isLargeScreen ? 3 : 2;
              final itemCount = isLargeScreen ? 9 : 6;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final colors = [
                    Colors.blue.normal,
                    Colors.green.normal,
                    Colors.orange.normal,
                    Colors.purple.normal,
                    Colors.red.normal,
                    Colors.teal.normal,
                    Colors.magenta.normal,
                    Colors.yellow.normal,
                    Colors.blue.dark,
                  ];
                  final color = colors[index % colors.length];

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            WindowsIcons.circle_fill,
                            size: isLargeScreen ? 48 : 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Item ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLargeScreen)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Large Screen',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
