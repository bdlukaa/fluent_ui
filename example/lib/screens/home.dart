import 'package:example/widgets/code_snippet_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';

import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;

  @override
  Widget build(final BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Windows UI for Flutter Showcase App'),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Link(
              uri: Uri.parse('https://github.com/bdlukaa/fluent_ui'),
              builder: (final context, final open) => Semantics(
                link: true,
                child: Tooltip(
                  message: 'Source code',
                  child: IconButton(
                    icon: const WindowsIcon(WindowsIcons.code, size: 24),
                    onPressed: open,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        CodeSnippetCard(
          initiallyOpen: true,
          codeSnippet: '''
import 'package:fluent_ui/fluent_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Windows UI for Flutter',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
''',
          child: Card(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                InfoLabel(
                  label: 'Inputs',
                  child: ToggleSwitch(
                    checked: selected,
                    onChanged: (final v) => setState(() => selected = v),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: InfoLabel(
                    label: 'Forms',
                    child: ComboBox<String>(
                      value: comboboxValue,
                      items: ['Item 1', 'Item 2']
                          .map(
                            (final e) => ComboBoxItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      isExpanded: true,
                      onChanged: (final v) => setState(() => comboboxValue = v),
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: InfoLabel(
                      label: 'Progress',
                      child: const SizedBox(
                        height: 30,
                        width: 30,
                        child: ProgressRing(),
                      ),
                    ),
                  ),
                ),
                InfoLabel(
                  label: 'Surfaces & Materials',
                  child: SizedBox(
                    height: 40,
                    width: 120,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 50,
                          color: theme.accentColor.lightest,
                        ),
                        const Positioned.fill(
                          child: Acrylic(luminosityAlpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                InfoLabel(
                  label: 'Icons',
                  child: const WindowsIcon(WindowsIcons.flag, size: 30),
                ),
                InfoLabel(
                  label: 'Colors',
                  child: SizedBox(
                    width: 40,
                    height: 30,
                    child: Wrap(
                      children:
                          <Color>[
                            ...Colors.accentColors,
                            Colors.successPrimaryColor,
                            Colors.warningPrimaryColor,
                            Colors.errorPrimaryColor,
                            Colors.grey,
                          ].map((final color) {
                            return Container(
                              height: 10,
                              width: 10,
                              color: color,
                            );
                          }).toList(),
                    ),
                  ),
                ),
                InfoLabel(
                  label: 'Typography',
                  child: ShaderMask(
                    shaderCallback: (final rect) {
                      return LinearGradient(
                        colors: [Colors.white, ...Colors.accentColors],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcATop,
                    child: const Text(
                      'ABCDEFGH',
                      style: TextStyle(
                        fontSize: 24,
                        shadows: [Shadow(offset: Offset(1, 1))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        subtitle(
          content: const Text(
            'Equivalents with the material and cupertino libraries',
          ),
        ),
        const UIEquivalents(),
      ],
    );
  }
}

class SponsorButton extends StatelessWidget {
  const SponsorButton({
    required this.imageUrl,
    required this.username,
    super.key,
  });

  final String imageUrl;
  final String username;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(imageUrl)),
            shape: BoxShape.circle,
          ),
        ),
        Text(username),
      ],
    );
  }
}
