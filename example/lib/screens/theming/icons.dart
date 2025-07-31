import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:example/screens/settings.dart';
import 'package:example/screens/theming/typography.dart';
import 'package:example/widgets/card_highlight.dart';
import 'package:fluent_ui/fluent_ui.dart';

Future<void> showCopiedSnackbar(BuildContext context, String copiedText) {
  return displayInfoBar(
    context,
    builder: (context, close) => InfoBar(
      title: RichText(
        text: TextSpan(
          text: 'Copied ',
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: copiedText,
              style: TextStyle(
                color: FluentTheme.of(context).accentColor.defaultBrushFor(
                  FluentTheme.of(context).brightness,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class IconsPage extends StatefulWidget {
  final Map<String, IconData> set;

  const IconsPage({super.key, required this.set});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  String filterText = '';
  Color? color;
  double? size;

  late final IconData icon = widget.set.values.elementAt(
    Random().nextInt(widget.set.length),
  );

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final theme = FluentTheme.of(context);

    color ??= IconTheme.of(context).color;
    size ??= IconTheme.of(context).size;

    final entries = widget.set.entries.where(
      (icon) =>
          filterText.isEmpty ||
          // Remove '_'
          icon.key
              .replaceAll('_', '')
              // toLowerCase
              .toLowerCase()
              .contains(
                filterText.toLowerCase()
                // Remove spaces
                .replaceAll(' ', ''),
              ),
    );

    final prefix = switch (icon.fontFamily) {
      'SegoeIcons' => 'WindowsIcons',
      'FluentIcons' => 'FluentIcons',
      _ => 'Icons',
    };
    final iconName = widget.set.entries.firstWhere((e) => e.value == icon).key;

    return ScaffoldPage(
      header: PageHeader(
        title: RichText(
          text: TextSpan(
            style: theme.typography.title,
            children: [
              const TextSpan(text: 'Windows Icons Gallery showcase '),
              TextSpan(
                text: '(${widget.set.length})',
                style: theme.typography.caption,
              ),
            ],
          ),
        ),
        commandBar: SizedBox(
          width: 240.0,
          child: Tooltip(
            message: 'Filter by name',
            child: TextBox(
              suffix: const Padding(
                padding: EdgeInsetsDirectional.only(end: 8.0),
                child: WindowsIcon(WindowsIcons.search, size: 16),
              ),
              placeholder: 'Type to filter icons by name (e.g "logo")',
              onChanged: (value) => setState(() {
                filterText = value;
              }),
            ),
          ),
        ),
      ),
      bottomBar: const SizedBox(
        width: double.infinity,
        child: InfoBar(
          title: Text('Tip:'),
          content: Text(
            'You can click on any icon to copy its name to the clipboard!',
          ),
        ),
      ),
      content: Padding(
        padding: EdgeInsetsDirectional.only(
          start: PageHeader.horizontalPadding(context),
          end: PageHeader.horizontalPadding(context),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                child: CardHighlight(
                  initiallyOpen: true,
                  codeSnippet:
                      '''const WindowsIcon(
  $prefix.$iconName,
  size: ${size!.toInt()},
  color: Color(0x${color!.toARGB32().toRadixString(16).padLeft(8, '0')}),
),''',
                  child: Row(
                    spacing: 8.0,
                    children: [
                      WindowsIcon(icon, size: size, color: color),
                      const Spacer(),
                      IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InfoLabel(
                              label: 'Icon Color',
                              child: ComboBox<Color>(
                                placeholder: const Text('Icon Color'),
                                onChanged: (c) => setState(() => color = c),
                                value: color,
                                isExpanded: true,
                                items: [
                                  ComboBoxItem(
                                    value: Colors.white,
                                    child: Row(
                                      children: [
                                        buildColorBox(Colors.white),
                                        const SizedBox(width: 10.0),
                                        const Text('White'),
                                      ],
                                    ),
                                  ),
                                  ComboBoxItem(
                                    value: const Color(0xE4000000),
                                    child: Row(
                                      children: [
                                        buildColorBox(const Color(0xE4000000)),
                                        const SizedBox(width: 10.0),
                                        const Text('Black'),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(Colors.accentColors.length, (
                                    index,
                                  ) {
                                    final color = Colors.accentColors[index];
                                    return ComboBoxItem(
                                      value: color,
                                      child: Row(
                                        children: [
                                          buildColorBox(color),
                                          const SizedBox(width: 10.0),
                                          Text(accentColorNames[index + 1]),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            InfoLabel(
                              label: 'Icon Size',
                              child: Slider(
                                value: size!,
                                onChanged: (v) => setState(() {
                                  size = v;
                                }),
                                min: 8.0,
                                max: 56.0,
                                label: '${size!.toInt()}',
                                style: SliderThemeData(
                                  margin: EdgeInsetsDirectional.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries.elementAt(index);
                return HoverButton(
                  onPressed: () async {
                    final copyText = '$prefix.${e.key}';
                    await FlutterClipboard.copy(copyText);
                    if (context.mounted) showCopiedSnackbar(context, copyText);
                  },
                  cursor: SystemMouseCursors.copy,
                  builder: (context, states) {
                    return FocusBorder(
                      focused: states.isFocused,
                      renderOutside: false,
                      child: Tooltip(
                        useMousePosition: false,
                        message:
                            '\nWindowsIcons.${e.key}\n(tap to copy to clipboard)\n',
                        child: RepaintBoundary(
                          child: AnimatedContainer(
                            duration: theme.fasterAnimationDuration,
                            decoration: BoxDecoration(
                              color: ButtonThemeData.uncheckedInputColor(
                                theme,
                                states,
                                transparentWhenNone: true,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(e.value, size: 40),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 8.0,
                                  ),
                                  child: Text(
                                    snakeCasetoSentenceCase(e.key),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String snakeCasetoSentenceCase(String original) {
    return '${original[0].toUpperCase()}${original.substring(1)}'.replaceAll(
      RegExp(r'(_|-)+'),
      ' ',
    );
  }
}
