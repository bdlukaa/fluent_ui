import 'package:fluent_ui/fluent_ui.dart';

class ColorsPage extends StatelessWidget {
  const ColorsPage({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  Widget buildColorBlock(String name, Color color) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 65,
        minWidth: 65,
      ),
      padding: EdgeInsets.all(2.0),
      color: color,
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(name, style: TextStyle(color: color.basedOnLuminance())),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: Text('Colors Showcase')),
      content: ListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        controller: controller,
        children: [
          InfoLabel(
            label: 'Primary Colors',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: Colors.accentColors.map<Widget>((color) {
                return buildColorBlock('', color);
              }).toList(),
            ),
          ),
          Divider(
              style: DividerThemeData(margin: (axis) => EdgeInsets.all(10))),
          InfoLabel(
            label: 'Info Colors',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                buildColorBlock('Warning 1', Colors.warningPrimaryColor),
                buildColorBlock('Warning 2', Colors.warningSecondaryColor),
                buildColorBlock('Error 1', Colors.errorPrimaryColor),
                buildColorBlock('Error 2', Colors.errorSecondaryColor),
                buildColorBlock('Success 1', Colors.successPrimaryColor),
                buildColorBlock(
                    'Success 2', Colors.successSecondaryColor.toAccentColor()),
              ],
            ),
          ),
          Divider(
              style: DividerThemeData(margin: (axis) => EdgeInsets.all(10))),
          InfoLabel(
            label: 'All Shades',
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                buildColorBlock('Black', Colors.black),
                buildColorBlock('White', Colors.white),
              ]),
              SizedBox(height: 10),
              Wrap(
                children: List.generate(22, (index) {
                  return buildColorBlock(
                    'Grey#${(index + 1) * 10}',
                    Colors.grey[(index + 1) * 10]!,
                  );
                }),
              ),
              SizedBox(height: 10),
              Wrap(
                children: accent,
                runSpacing: 10,
                spacing: 10,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> get accent {
    List<Widget> children = [];
    Colors.accentColors.forEach((AccentColor accent) {
      children.add(
        Wrap(
          // mainAxisSize: MainAxisSize.min,
          children: List.generate(accent.swatch.length, (index) {
            final name = accent.swatch.keys.toList()[index];
            final color = accent.swatch[name];
            return buildColorBlock(name, color!);
          }),
        ),
      );
    });
    return children;
  }
}
