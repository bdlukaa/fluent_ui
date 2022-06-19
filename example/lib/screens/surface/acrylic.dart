import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../settings.dart';

class AcrylicPage extends ScrollablePage {
  @override
  Widget buildHeader(BuildContext context) {
    return const PageHeader(title: Text('Acrylic'));
  }

  double tintOpacity = 0.8;
  double luminosityOpacity = 0.8;
  double blurAmout = 30;
  double elevation = 0;
  Color? color;

  @override
  List<Widget> buildScrollable(BuildContext context) {
    return [
      const Text('A translucent material recommended for panel backgrounds.'),
      subtitle(content: const Text('Default background acrylic brush.')),
      Card(
        child: SizedBox(
          height: 300,
          width: 500,
          child: Stack(children: const [
            _AcrylicChildren(),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Acrylic(),
              ),
            ),
          ]),
        ),
      ),
      subtitle(content: const Text('Custom acrylic brush.')),
      Card(
        child: SizedBox(
          height: 300,
          width: 500,
          child: Row(children: [
            Expanded(
              child: Stack(children: [
                const _AcrylicChildren(),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Acrylic(
                      tintAlpha: tintOpacity,
                      luminosityAlpha: luminosityOpacity,
                      blurAmount: blurAmout,
                      elevation: elevation,
                      tint: color,
                    ),
                  ),
                ),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InfoLabel(
                label: 'Tint color',
                child: Combobox<Color>(
                  placeholder: const Text('Tint color               '),
                  onChanged: (c) => setState(() => color = c),
                  value: color,
                  items: [
                    ComboboxItem(
                      child: Row(children: [
                        buildColorBox(Colors.white),
                        const SizedBox(width: 10.0),
                        const Text('White'),
                      ]),
                      value: Colors.white,
                    ),
                    ComboboxItem(
                      child: Row(children: [
                        buildColorBox(const Color(0xE4000000)),
                        const SizedBox(width: 10.0),
                        const Text('Black'),
                      ]),
                      value: const Color(0xE4000000),
                    ),
                    ...List.generate(Colors.accentColors.length, (index) {
                      final color = Colors.accentColors[index];
                      return ComboboxItem(
                        child: Row(children: [
                          buildColorBox(color),
                          const SizedBox(width: 10.0),
                          Text(accentColorNames[index + 1]),
                        ]),
                        value: color,
                      );
                    }),
                  ],
                ),
              ),
              InfoLabel(
                label: 'Tint opacity',
                child: Slider(
                  value: tintOpacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) => setState(() => tintOpacity = v),
                ),
              ),
              InfoLabel(
                label: 'Luminosity opacity',
                child: Slider(
                  value: luminosityOpacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) => setState(() => luminosityOpacity = v),
                ),
              ),
              InfoLabel(
                label: 'Blur amount',
                child: Slider(
                  value: blurAmout,
                  min: 0.0,
                  max: 100,
                  onChanged: (v) => setState(() => blurAmout = v),
                ),
              ),
              InfoLabel(
                label: 'Elevation',
                child: Slider(
                  value: elevation,
                  min: 0,
                  max: 20,
                  onChanged: (v) => setState(() => elevation = v),
                ),
              ),
            ]),
          ]),
        ),
      ),
    ];
  }

  Widget buildColorBox(Color color) {
    const double boxSize = 16.0;
    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class _AcrylicChildren extends StatelessWidget {
  const _AcrylicChildren({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: 200,
        width: 100,
        color: Colors.blue.lightest,
      ),
      Align(
        alignment: Alignment.center,
        child: Container(
          height: 152,
          width: 152,
          color: Colors.magenta,
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Container(
          height: 100,
          width: 80,
          color: Colors.yellow,
        ),
      ),
    ]);
  }
}
