import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_markdown/flutter_markdown.dart'
    deferred as flutter_markdown;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'deferred_widget.dart';

List<String>? changelog;

class Changelog extends StatefulWidget {
  const Changelog({super.key});

  @override
  State<Changelog> createState() => _ChangelogState();
}

class _ChangelogState extends State<Changelog> {
  @override
  void initState() {
    super.initState();
    fetchChangelog();
  }

  void fetchChangelog() async {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/bdlukaa/fluent_ui/master/CHANGELOG.md',
      ),
    );

    if (response.statusCode == 200) {
      final changelogResult = response.body.split('\n')..removeRange(0, 2);
      setState(() => changelog = changelogResult);
    } else {
      debugPrint(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return DeferredWidget(
      flutter_markdown.loadLibrary,
      () => ContentDialog(
        style: const ContentDialogThemeData(padding: EdgeInsets.zero),
        constraints: const BoxConstraints(maxWidth: 600),
        content: () {
          if (changelog == null) return const ProgressRing();
          return SingleChildScrollView(
            child: flutter_markdown.Markdown(
              shrinkWrap: true,
              data: changelog!.map<String>((line) {
                if (line.startsWith('## [')) {
                  final version = line.split(']').first.replaceAll('## [', '');
                  // if (line.split('-').length == 2) {
                  //   print('GO- ${line.split('-')[0]} - ${line.split('-')[1]}');
                  // }
                  String date = line
                      .split('-')
                      .last
                      .replaceAll('[', '')
                      .replaceAll(']', '');

                  if (!date.startsWith('##')) {
                    final splitDate = date.split('/');
                    final dateTime = DateTime(
                      int.parse(splitDate[2]),
                      int.parse(splitDate[1]),
                      int.parse(splitDate[0]),
                    );
                    final formatter = DateFormat.MMMMEEEEd();
                    date = '${formatter.format(dateTime)}\n';
                  } else {
                    date = '';
                  }
                  return '## $version\n$date';
                }
                return line;
              }).join('\n'),
              onTapLink: (text, href, title) {
                launchUrl(Uri.parse(href!));
              },
              styleSheet: flutter_markdown.MarkdownStyleSheet.fromTheme(
                m.Theme.of(context),
              ).copyWith(
                a: TextStyle(
                  color: theme.accentColor.defaultBrushFor(
                    theme.brightness,
                    // level: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
            ),
          );
        }(),
      ),
    );
  }
}

//

// class CodeElementBuilder extends flutter_markdown.MarkdownElementBuilder {
//   @override
//   Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
//     var language = 'dart';

//     if (element.attributes['class'] != null) {
//       String lg = element.attributes['class'] as String;
//       language = lg.substring(9);
//     }
//     return SizedBox(
//       width:
//           MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
//       child: HighlightView(
//         // The original code to be highlighted
//         element.textContent,

//         // Specify language
//         // It is recommended to give it a value for performance
//         language: language,

//         // Specify highlight theme
//         // All available themes are listed in `themes` folder
//         // theme: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
//         //             .platformBrightness ==
//         //         Brightness.light
//         //     ? atomOneLightTheme
//         //     : atomOneDarkTheme,

//         // Specify padding
//         padding: const EdgeInsets.all(8),

//         // Specify text style
//         // textStyle: GoogleFonts.robotoMono(),
//       ),
//     );
//   }
// }
