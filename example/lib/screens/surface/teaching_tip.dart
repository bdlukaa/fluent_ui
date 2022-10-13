import 'package:example/theme.dart';
import 'package:example/widgets/card_highlight.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class TeachingTipPage extends StatefulWidget {
  const TeachingTipPage({Key? key}) : super(key: key);

  @override
  State<TeachingTipPage> createState() => _TeachingTipPageState();
}

class _TeachingTipPageState extends State<TeachingTipPage> with PageMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final appTheme = context.watch<AppTheme>();

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Teaching Tip')),
      children: [
        description(
          content: const Text(
            'A teaching tip is a semi-persistent and content-rich flyout '
            'that provides contextual information. It is often used for '
            'informing, reminding, and teaching users about important and new '
            'features that may enhance their experience.',
          ),
        ),
        subtitle(
          content: const Text('Show a non-targeted TeachingTip with buttons'),
        ),
        CardHighlight(
          child: Button(
            child: const Text('Show TeachingTip'),
            onPressed: () {
              showTeachingTip(
                context: context,
                teachingTip: TeachingTip(
                  alignment: Alignment.bottomCenter,
                  placementMargin: const EdgeInsets.all(20.0),
                  title: const Text('Change themes without hassle'),
                  subtitle: const Text(
                    'It\'s easier to see control samples in both light and dark theme',
                  ),
                  buttons: [
                    Button(
                      child: const Text('Toggle theme now'),
                      onPressed: () {
                        if (theme.brightness.isDark) {
                          appTheme.mode = ThemeMode.light;
                        } else {
                          appTheme.mode = ThemeMode.dark;
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    Button(
                      child: const Text('Got it'),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
              );
            },
          ),
          codeSnippet: '''final teachingTip = TeachingTip(
  title: Text('Change themes without hassle'),
  subtitle: Text(
    'It's easier to see control samples in both light and dark theme',
  ),
  buttons: <Widget>[
    Button(
      child: const Text('Toggle theme now'),
      onPressed: () {
        // toggle theme here

        // then close the popup
        Navigator.of(context).pop();
      },
    ),
    Button(
      child: const Text('Got it'),
      onPressed: Navigator.of(context).pop,
    ),
  ],
),

showTeachingTip(
  context: context,
  teachingTip: teachingTip,
);''',
        ),
      ],
    );
  }
}
