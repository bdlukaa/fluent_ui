import 'package:fluent_ui/fluent_ui.dart';

import '../settings.dart';

class TypographyPage extends StatefulWidget {
  const TypographyPage({super.key});

  @override
  State<TypographyPage> createState() => _TypographyPageState();
}

class _TypographyPageState extends State<TypographyPage> {
  Color? color;
  double scale = 1.0;

  Widget buildColorBox(Color color) {
    const double boxSize = 25.0;
    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Typography typography = FluentTheme.of(context).typography;
    color ??= typography.display!.color;
    typography = typography.apply(displayColor: color!);
    const Widget spacer = SizedBox(height: 4.0);
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Typography showcase'),
        commandBar: SizedBox(
          width: 180.0,
          child: Tooltip(
            message: 'Pick a text color',
            child: ComboBox<Color>(
              placeholder: const Text('Text Color'),
              onChanged: (c) => setState(() => color = c),
              value: color,
              items: [
                ComboBoxItem(
                  value: Colors.white,
                  child: Row(children: [
                    buildColorBox(Colors.white),
                    const SizedBox(width: 10.0),
                    const Text('White'),
                  ]),
                ),
                ComboBoxItem(
                  value: const Color(0xE4000000),
                  child: Row(children: [
                    buildColorBox(const Color(0xE4000000)),
                    const SizedBox(width: 10.0),
                    const Text('Black'),
                  ]),
                ),
                ...List.generate(Colors.accentColors.length, (index) {
                  final color = Colors.accentColors[index];
                  return ComboBoxItem(
                    value: color,
                    child: Row(children: [
                      buildColorBox(color),
                      const SizedBox(width: 10.0),
                      Text(accentColorNames[index + 1]),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      content: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'The Windows type ramp establishes crucial relationships '
                'between the type styles on a page, helping users read content '
                'easily.',
              ),
              Expanded(
                child: ListView(children: [
                  Text('Display',
                      style: typography.display?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Title Large',
                      style:
                          typography.titleLarge?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Title',
                      style: typography.title?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Subtitle',
                      style: typography.subtitle?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Body Large',
                      style:
                          typography.bodyLarge?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Body Strong',
                      style:
                          typography.bodyStrong?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Body',
                      style: typography.body?.apply(fontSizeFactor: scale)),
                  spacer,
                  Text('Caption',
                      style: typography.caption?.apply(fontSizeFactor: scale)),
                  spacer,
                ]),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Scale',
          child: Slider(
            vertical: true,
            value: scale,
            onChanged: (v) => setState(() => scale = v),
            label: scale.toStringAsFixed(2),
            max: 2,
            min: 0.5,
            // style: SliderThemeData(useThumbBall: false),
          ),
        ),
      ]),
    );
  }
}
