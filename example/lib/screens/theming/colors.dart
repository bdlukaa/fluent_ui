import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'icons.dart';

const _primaryNames = [
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Divider divider = Divider(
      style: DividerThemeData(
        verticalMargin: EdgeInsets.all(10),
        horizontalMargin: EdgeInsets.all(10),
      ),
    );
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Colors Showcase')),
      bottomBar: const SizedBox(
        width: double.infinity,
        child: InfoBar(
          title: Text('Tip:'),
          content:
              Text('You can click on any color to copy it to the clipboard!'),
        ),
      ),
      children: [
        const SizedBox(height: 14.0),
        InfoLabel(
          label: 'Primary Colors',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(Colors.accentColors.length, (index) {
              final name = _primaryNames[index];
              final color = Colors.accentColors[index];
              return ColorBlock(
                name: name,
                color: color,
                clipboard: 'Colors.${name.toLowerCase()}',
              );
            }),
          ),
        ),
        divider,
        InfoLabel(
          label: 'Info Colors',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              const ColorBlock(
                name: 'Warning 1',
                color: Colors.warningPrimaryColor,
                clipboard: 'Colors.warningPrimaryColor',
              ),
              ColorBlock(
                name: 'Warning 2',
                color: Colors.warningSecondaryColor,
                clipboard: 'Colors.warningSecondaryColor',
              ),
              const ColorBlock(
                name: 'Error 1',
                color: Colors.errorPrimaryColor,
                clipboard: 'Colors.errorPrimaryColor',
              ),
              ColorBlock(
                name: 'Error 2',
                color: Colors.errorSecondaryColor,
                clipboard: 'Colors.errorSecondaryColor',
              ),
              const ColorBlock(
                name: 'Success 1',
                color: Colors.successPrimaryColor,
                clipboard: 'Colors.successPrimaryColor',
              ),
              ColorBlock(
                name: 'Success 2',
                color: Colors.successSecondaryColor,
                clipboard: 'Colors.successSecondaryColor',
              ),
            ],
          ),
        ),
        divider,
        InfoLabel(
          label: 'All Shades',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              ColorBlock(
                name: 'Black',
                color: Colors.black,
                clipboard: 'Colors.black',
              ),
              ColorBlock(
                name: 'White',
                color: Colors.white,
                clipboard: 'Colors.white',
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              children: List.generate(22, (index) {
                final factor = (index + 1) * 10;
                return ColorBlock(
                  name: 'Grey#$factor',
                  color: Colors.grey[factor],
                  clipboard: 'Colors.grey[$factor]',
                );
              }),
            ),
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 10,
              spacing: 10,
              children: accent,
            ),
          ]),
        ),
      ],
    );
  }

  List<Widget> get accent {
    List<Widget> children = [];
    for (var i = 0; i < Colors.accentColors.length; i++) {
      final accent = Colors.accentColors[i];
      final name = _primaryNames[i];
      children.add(
        Column(
          // mainAxisSize: MainAxisSize.min,
          children: List.generate(accent.swatch.length, (index) {
            final variant = accent.swatch.keys.toList()[index];
            final color = accent.swatch[variant]!;
            return ColorBlock(
              name: name,
              color: color,
              variant: variant,
              clipboard: 'Colors.${name.toLowerCase()}.$variant',
            );
          }),
        ),
      );
    }
    return children;
  }
}

class ColorBlock extends StatelessWidget {
  const ColorBlock({
    super.key,
    required this.name,
    required this.color,
    this.variant,
    required this.clipboard,
  });

  final String name;
  final Color color;
  final String? variant;
  final String clipboard;

  @override
  Widget build(BuildContext context) {
    final textColor = color.basedOnLuminance();
    return Tooltip(
      message: '\n$clipboard\n(tap to copy to clipboard)\n',
      child: HoverButton(
        onPressed: () async {
          await FlutterClipboard.copy(clipboard);
          // ignore: use_build_context_synchronously
          showCopiedSnackbar(context, clipboard);
        },
        cursor: SystemMouseCursors.copy,
        builder: (context, states) {
          return FocusBorder(
            focused: states.isFocused,
            useStackApproach: true,
            renderOutside: false,
            child: Container(
              height: 85,
              width: 85,
              padding: const EdgeInsets.all(6.0),
              color: color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (variant != null)
                    Text(
                      variant!,
                      style: TextStyle(color: textColor),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
