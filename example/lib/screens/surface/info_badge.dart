import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class InfoBadgePage extends StatefulWidget {
  const InfoBadgePage({super.key});

  @override
  State<InfoBadgePage> createState() => _InfoBadgePageState();
}

class _InfoBadgePageState extends State<InfoBadgePage> with PageMixin {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('InfoBadge')),
      children: [
        const Text(
          'Badging is a non-intrusive and intuitive way to display notifications or '
          'bring focus to an area within an app - whether that be for notifications, '
          'indicating new content, or showing an alert. An InfoBadge is a small '
          'piece of UI that can be added into an app and customized to display a number, '
          'icon, or a simple dot.',
        ),
        subtitle(content: const Text('A simple InfoBadge')),
        description(
          content: const Text(
            'An InfoBadge can be displayed as a standalone widget, or inside other controls.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet:
              '''InfoBadge(
  source: Text('$_counter'),
),
''',
          child: Row(
            children: [
              InfoBadge(source: Text('$_counter')),
              const SizedBox(width: 10),
              Button(
                child: const Text('Increment'),
                onPressed: () => setState(() => _counter++),
              ),
              const SizedBox(width: 10),
              Button(
                child: const Text('Reset'),
                onPressed: () => setState(() => _counter = 0),
              ),
            ],
          ),
        ),
        subtitle(content: const Text('InfoBadge with Icon')),
        const CodeSnippetCard(
          codeSnippet: '''InfoBadge(source: Icon(WindowsIcons.message)),
''',
          child: InfoBadge(source: Icon(WindowsIcons.asterisk, size: 10)),
        ),
        subtitle(content: const Text('Dot InfoBadge')),
        const CodeSnippetCard(
          codeSnippet: '''InfoBadge(),
''',
          child: Row(children: [InfoBadge()]),
        ),
        subtitle(content: const Text('Customized InfoBadge')),
        const CodeSnippetCard(
          codeSnippet: '''InfoBadge.success(
  source: const Text('1'),
),
''',
          child: InfoBadge.success(source: Text('1')),
        ),
        subtitle(content: const Text('InfoBadge inside a NavigationView')),
        description(
          content: const Text(
            'InfoBadge is commonly used within NavigationView items to indicate new notifications.',
          ),
        ),
        CodeSnippetCard(
          codeSnippet: '''PaneItem(
  icon: const Icon(WindowsIcons.mail),
  title: const Text('Mail'),
  infoBadge: const InfoBadge(source: Text('9+')),
  body: const SizedBox.shrink(),
),
''',
          child: SizedBox(
            height: 200,
            child: NavigationView(
              pane: NavigationPane(
                selected: 0,
                displayMode: PaneDisplayMode.compact,
                items: [
                  PaneItem(
                    icon: const Icon(WindowsIcons.mail),
                    title: const Text('Mail'),
                    infoBadge: const InfoBadge(source: Text('9+')),
                    body: const SizedBox.shrink(),
                  ),
                  PaneItem(
                    icon: const Icon(WindowsIcons.calendar),
                    title: const Text('Calendar'),
                    infoBadge: const InfoBadge(source: Text('3')),
                    body: const SizedBox.shrink(),
                  ),
                  PaneItem(
                    icon: const Icon(WindowsIcons.alert_urgent),
                    title: const Text('Alerts'),
                    infoBadge: const InfoBadge(),
                    body: const SizedBox.shrink(),
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
