import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/page.dart';

class NavigationViewPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('NavigationView'));
  }

  static const double itemHeight = 300.0;

  int topIndex = 0;

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text(
        'The NavigationView control provides top-level navigation for your app. '
        'It adapts to a variety of screen sizes and supports both top and left '
        'navigation styles.',
      ),
      subtitle(content: const Text('Top display mode')),
      ...buildDisplayMode(
        PaneDisplayMode.top,
        'The pane is positioned above the content.',
      ),
      subtitle(content: const Text('Open display mode')),
      ...buildDisplayMode(
        PaneDisplayMode.open,
        'The pane is expanded and positioned to the left of the content.',
      ),
      subtitle(content: const Text('Compact display mode')),
      ...buildDisplayMode(
        PaneDisplayMode.compact,
        'The pane shows only icons until opened and is positioned to the left '
        'of the content. When opened, the pane overlays the content.',
      ),
      subtitle(content: const Text('Minimal display mode')),
      ...buildDisplayMode(
        PaneDisplayMode.minimal,
        'Only the menu button is shown until the pane is opened. When opened, '
        'the pane overlays the left side of the content.',
      ),
    ];
  }

  List<Widget> buildDisplayMode(
    PaneDisplayMode displayMode,
    String desc,
  ) {
    return [
      description(content: Text(desc)),
      CardHighlight(
        child: SizedBox(
          height: itemHeight,
          child: NavigationView(
            appBar: const NavigationAppBar(
              title: Text('NavigationView'),
            ),
            pane: NavigationPane(
              selected: topIndex,
              onChanged: (index) => setState(() => topIndex = index),
              displayMode: displayMode,
              items: [
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title: const Text('Home'),
                ),
                PaneItem(
                  icon: const Icon(FluentIcons.issue_tracking),
                  title: const Text('Track orders'),
                  infoBadge: const InfoBadge(source: Text('8')),
                ),
                PaneItemExpander(
                  icon: const Icon(FluentIcons.account_management),
                  title: const Text('Account'),
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.mail),
                      title: const Text('Mail'),
                    ),
                    PaneItem(
                      icon: const Icon(FluentIcons.calendar),
                      title: const Text('Calendar'),
                    ),
                  ],
                ),
              ],
              footerItems: [
                PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('Settings'),
                ),
              ],
            ),
            content: NavigationBody(
              index: topIndex,
              children: const [
                _NavigationBodyItem(),
                _NavigationBodyItem(
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
                _NavigationBodyItem(
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
                _NavigationBodyItem(),
                _NavigationBodyItem(),
                _NavigationBodyItem(),
              ],
            ),
          ),
        ),
        codeSnippet: '''NavigationView(
  appBar: const NavigationAppBar(
    title: Text('NavigationView'),
  ),
  pane: NavigationPane(
    selected: topIndex,
    onChanged: (index) => setState(() => topIndex = index),
    displayMode: displayMode,
    items: [
      PaneItem(
        icon: const Icon(FluentIcons.home),
        title: const Text('Home'),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.issue_tracking),
        title: const Text('Track an order'),
        infoBadge: const InfoBadge(source: Text('8')),
      ),
      PaneItemExpander(
        icon: const Icon(FluentIcons.account_management),
        title: const Text('Account'),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.mail),
            title: const Text('Mail'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.calendar),
            title: const Text('Calendar'),
          ),
        ],
      ),
    ],
  ),
  body: NavigationBody(
    index: topIndex,
    children: const [
      BodyItem(),
      BodyItem(),
      BodyItem(),
      BodyItem(),
    ],
  )
)''',
      ),
    ];
  }
}

class _NavigationBodyItem extends StatelessWidget {
  const _NavigationBodyItem({
    Key? key,
    this.header,
    this.content,
  }) : super(key: key);

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
