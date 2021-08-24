import 'package:fluent_ui/fluent_ui.dart';

import 'settings.dart';

class TypographyPage extends StatefulWidget {
  const TypographyPage({Key? key}) : super(key: key);

  @override
  _TypographyPageState createState() => _TypographyPageState();
}

class _TypographyPageState extends State<TypographyPage> {
  Color? color;
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Typography typography = FluentTheme.of(context).typography;
    if (color == null) color = typography.header!.color;
    typography = typography.apply(displayColor: color!);
    const Widget spacer = const SizedBox(height: 4.0);
    const double boxSize = 25.0;
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Typography showcase'),
        commandBar: SizedBox(
          width: 180.0,
          child: Tooltip(
            message: 'Pick a text color',
            child: Combobox<Color>(
              placeholder: Text('Text Color'),
              onChanged: (c) => setState(() => color = c),
              value: color,
              items: [
                ComboboxItem(
                  child: Row(children: [
                    Container(
                        height: boxSize, width: boxSize, color: Colors.white),
                    SizedBox(width: 10.0),
                    Text('White'),
                  ]),
                  value: Colors.white,
                ),
                ComboboxItem(
                  child: Row(children: [
                    Container(
                        height: boxSize, width: boxSize, color: Colors.black),
                    SizedBox(width: 10.0),
                    Text('Black'),
                  ]),
                  value: Colors.black,
                ),
                ...List.generate(Colors.accentColors.length, (index) {
                  final color = Colors.accentColors[index];
                  return ComboboxItem(
                    child: Row(children: [
                      Container(height: boxSize, width: boxSize, color: color),
                      SizedBox(width: 10.0),
                      Text(accentColorNames[index + 1]),
                    ]),
                    value: color,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PageHeader.horizontalPadding(context),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
                ),
                Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Header', style: typography.header),
                      spacer,
                      Text('Subheader', style: typography.subheader),
                      spacer,
                      Text('Title', style: typography.title),
                      spacer,
                      Text('Subtitle', style: typography.subtitle),
                      spacer,
                      Text('Base', style: typography.base),
                      spacer,
                      Text('Body', style: typography.body),
                      spacer,
                      Text('Caption', style: typography.caption),
                      spacer,
                    ],
                  ),
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
      ),
    );
  }
}
