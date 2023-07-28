import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../widgets/page.dart';

class InfoBarsPage extends StatefulWidget {
  const InfoBarsPage({super.key});

  @override
  State<InfoBarsPage> createState() => _InfoBarsPageState();
}

class _InfoBarsPageState extends State<InfoBarsPage> with PageMixin {
  // First info bar
  bool _firstOpen = true;
  InfoBarSeverity severity = InfoBarSeverity.info;

  // Second info bar
  bool _secondOpen = true;
  bool _isLong = false;
  bool _hasActionButton = true;
  bool _isIconVisible = true;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('InfoBar')),
      children: [
        const Text(
          'Use an InfoBar control when a user should be informed of, acknowledge,'
          ' or take action on a changed application state. By default the notification'
          ' will remain in the content area until closed by the user but will '
          'not necessarily break user flow.',
        ),
        subtitle(
          content: const Text(
            'A InfoBar as a popup',
          ),
        ),
        CardHighlight(
          backgroundColor: FluentTheme.of(context).micaBackgroundColor,
          codeSnippet: '''displayInfoBar(context, builder: (context, close) {
  return InfoBar(
    title: const Text('You can not do that :/'),
    content: const Text(
        'A proper warning message of why the user can not do that :/'),
    action: IconButton(
      icon: const Icon(FluentIcons.clear),
      onPressed: close,
    ),
    severity: InfoBarSeverity.warning,
  );
}''',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Button(
              onPressed: () {
                displayInfoBar(context, builder: (context, close) {
                  return InfoBar(
                    title: const Text('You can not do that :/'),
                    content: const Text(
                        'A proper warning message of why the user can not do that :/'),
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                    severity: InfoBarSeverity.warning,
                  );
                });
              },
              child: const Text('Show InfoBar'),
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'A closable InfoBar with options to change its severity',
          ),
        ),
        CardHighlight(
          backgroundColor: FluentTheme.of(context).micaBackgroundColor,
          codeSnippet: '''InfoBar(
  title: const Text('Title'),
  content: const Text(
    'Essential app message for your users to be informed of, '
    'acknowledge, or take action on.',
  ),
  severity: $severity,
  isLong: true,
)''',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_firstOpen)
                  InfoBar(
                    title: const Text('Title'),
                    content: const Text(
                      'Essential app message for your users to be informed of, '
                      'acknowledge, or take action on.',
                    ),
                    severity: severity,
                    isLong: true,
                    onClose: () => setState(() => _firstOpen = false),
                  ),
                const SizedBox(height: 10.0),
                const Divider(),
                const SizedBox(height: 10.0),
                Checkbox(
                  checked: _firstOpen,
                  onChanged: (v) => setState(() => _firstOpen = v!),
                  content: const Text('Is open'),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 10.0),
                  width: 150.0,
                  child: ComboBox<InfoBarSeverity>(
                    isExpanded: true,
                    items: InfoBarSeverity.values
                        .map(
                          (severity) => ComboBoxItem(
                            value: severity,
                            child: Text(severity.name),
                          ),
                        )
                        .toList(),
                    value: severity,
                    onChanged: (v) => setState(() => severity = v ?? severity),
                    popupColor: () {
                      switch (severity) {
                        case InfoBarSeverity.info:
                          break;
                        case InfoBarSeverity.warning:
                          return Colors.warningPrimaryColor;
                        case InfoBarSeverity.error:
                          return Colors.errorPrimaryColor;
                        case InfoBarSeverity.success:
                          return Colors.successPrimaryColor;
                      }
                    }(),
                  ),
                ),
              ],
            ),
          ),
        ),
        subtitle(
          content: const Text(
            'A closable InfoBar with a long and short message and action button',
          ),
        ),
        CardHighlight(
          backgroundColor: FluentTheme.of(context).micaBackgroundColor,
          codeSnippet: '''InfoBar(
  title: const Text('Title'),
  content: Text(
    ${_isLong ? '"Essential app message for your users to be informed '
                  'of, acknowledge, or take action on. Lorem Ipsum is '
                  'simply dummy text of the printing and typesetting '
                  'industry. Lorem Ipsum has been the industry\'s '
                  'standard dummy text ever since the 1500s, when an '
                  'unknown printer took a galley of type and scrambled '
                  'it to make a type specimen book."' : '"A short essential message"'}
  ),
  severity: $severity,
  isLong: true,
  ${_hasActionButton ? '''action: Button(
    child: const Text('Action'),
    onPressed: () {},
  )''' : null}
)''',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_secondOpen)
                  InfoBar(
                    title: const Text('Title'),
                    content: Text(
                      _isLong
                          ? 'Essential app message for your users to be informed '
                              'of, acknowledge, or take action on. Lorem Ipsum is '
                              'simply dummy text of the printing and typesetting '
                              'industry. Lorem Ipsum has been the industry\'s '
                              'standard dummy text ever since the 1500s, when an '
                              'unknown printer took a galley of type and scrambled '
                              'it to make a type specimen book.'
                          : 'A short essential message',
                    ),
                    severity: severity,
                    isLong: _isLong,
                    onClose: () => setState(() => _secondOpen = false),
                    action: _hasActionButton
                        ? Button(
                            child: const Text('Action'),
                            onPressed: () {},
                          )
                        : null,
                    isIconVisible: _isIconVisible,
                  ),
                const SizedBox(height: 10.0),
                const Divider(),
                const SizedBox(height: 10.0),
                Checkbox(
                  checked: _secondOpen,
                  onChanged: (v) => setState(() => _secondOpen = v!),
                  content: const Text('Is open'),
                ),
                Checkbox(
                  checked: _isLong,
                  onChanged: (v) => setState(() => _isLong = v!),
                  content: const Text('Is long'),
                ),
                Checkbox(
                  checked: _hasActionButton,
                  onChanged: (v) => setState(() => _hasActionButton = v!),
                  content: const Text('Has action button'),
                ),
                Checkbox(
                  checked: _isIconVisible,
                  onChanged: (v) => setState(() => _isIconVisible = v!),
                  content: const Text('Is icon visible'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
