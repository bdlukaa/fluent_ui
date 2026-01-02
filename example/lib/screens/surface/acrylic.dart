import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../settings.dart';

const questionMark = Padding(
  padding: EdgeInsetsDirectional.only(start: 4),
  child: WindowsIcon(WindowsIcons.status_circle_question_mark, size: 14),
);

InlineSpan _buildLabel(final String label, final String description) {
  return TextSpan(
    text: label,
    children: [
      WidgetSpan(
        child: Tooltip(
          useMousePosition: false,
          message: description,
          child: questionMark,
        ),
      ),
    ],
  );
}

class AcrylicPage extends StatefulWidget {
  const AcrylicPage({super.key});

  @override
  State<AcrylicPage> createState() => _AcrylicPageState();
}

class _AcrylicPageState extends State<AcrylicPage> with PageMixin {
  double tintOpacity = 0.8;
  double luminosityOpacity = 0.8;
  double blurAmout = 30;
  double elevation = 0;
  Color? color;

  @override
  Widget build(final BuildContext context) {
    final menuColor = FluentTheme.of(
      context,
    ).menuColor.withValues(alpha: kMenuColorOpacity);

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Acrylic')),
      children: [
        const Text(
          'A translucent material recommended for panel backgrounds. Acrylic is a '
          'type of Brush that creates a translucent texture. You can apply acrylic '
          'to app surfaces to add depth and help establish a visual hierarchy.',
        ),
        subtitle(content: const Text('Default background acrylic brush.')),
        const Card(
          child: SizedBox(
            height: 300,
            width: 500,
            child: Stack(
              children: [
                _AcrylicChildren(),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(12),
                    child: Acrylic(),
                  ),
                ),
              ],
            ),
          ),
        ),
        subtitle(content: const Text('Custom acrylic brush.')),
        Card(
          child: SizedBox(
            height: 300,
            width: 500,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      const _AcrylicChildren(),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(12),
                          child: Acrylic(
                            tintAlpha: tintOpacity,
                            luminosityAlpha: luminosityOpacity,
                            blurAmount: blurAmout,
                            elevation: elevation,
                            tint: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoLabel.rich(
                      label: _buildLabel(
                        'Tint color',
                        'the color/tint overlay layer.',
                      ),
                      child: ComboBox<Color>(
                        placeholder: const Text('Tint color               '),
                        onChanged: (final c) => setState(() => color = c),
                        value: color,
                        items: [
                          ComboBoxItem(
                            value: menuColor,
                            child: Row(
                              children: [
                                buildColorBox(menuColor),
                                const SizedBox(width: 10),
                                const Text('Acrylic background'),
                              ],
                            ),
                          ),
                          ComboBoxItem(
                            value: Colors.white,
                            child: Row(
                              children: [
                                buildColorBox(Colors.white),
                                const SizedBox(width: 10),
                                const Text('White'),
                              ],
                            ),
                          ),
                          ComboBoxItem(
                            value: const Color(0xE4000000),
                            child: Row(
                              children: [
                                buildColorBox(const Color(0xE4000000)),
                                const SizedBox(width: 10),
                                const Text('Black'),
                              ],
                            ),
                          ),
                          ...List.generate(Colors.accentColors.length, (
                            final index,
                          ) {
                            final color = Colors.accentColors[index];
                            return ComboBoxItem(
                              value: color,
                              child: Row(
                                children: [
                                  buildColorBox(color),
                                  const SizedBox(width: 10),
                                  Text(accentColorNames[index + 1]),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    InfoLabel.rich(
                      label: _buildLabel(
                        'Tint opacity',
                        'the opacity of the tint layer.',
                      ),
                      child: Slider(
                        value: tintOpacity,
                        max: 1,
                        onChanged: (final v) => setState(() => tintOpacity = v),
                      ),
                    ),
                    InfoLabel.rich(
                      label: _buildLabel(
                        'Tint luminosity opacity',
                        'controls the amount of saturation that is allowed through '
                            'the acrylic surface from the background.',
                      ),
                      child: Slider(
                        value: luminosityOpacity,
                        max: 1,
                        onChanged: (final v) =>
                            setState(() => luminosityOpacity = v),
                      ),
                    ),
                    InfoLabel(
                      label: 'Blur amount',
                      child: Slider(
                        value: blurAmout,
                        onChanged: (final v) => setState(() => blurAmout = v),
                      ),
                    ),
                    InfoLabel(
                      label: 'Elevation',
                      child: Slider(
                        value: elevation,
                        max: 20,
                        onChanged: (final v) => setState(() => elevation = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildColorBox(final Color color) {
    const boxSize = 16.0;
    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _AcrylicChildren extends StatelessWidget {
  const _AcrylicChildren();

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        Container(height: 200, width: 100, color: Colors.blue.lightest),
        Align(
          alignment: AlignmentDirectional.center,
          child: Container(height: 152, width: 152, color: Colors.magenta),
        ),
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: Container(height: 100, width: 80, color: Colors.yellow),
        ),
      ],
    );
  }
}
