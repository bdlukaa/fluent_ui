import 'package:fluent_ui/fluent_ui.dart';

class Divider extends StatelessWidget {
  const Divider({
    Key? key,
    this.direction = Axis.vertical,
    this.style,
  }) : super(key: key);

  final Axis direction;
  final DividerStyle? style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!.dividerStyle!.copyWith(this.style);
    return Container(
      height: direction == Axis.horizontal ? style.thickness : double.infinity,
      width: direction == Axis.vertical ? style.thickness : double.infinity,
      margin: style.margin,
      decoration: style.decoration,
    );
  }
}

class DividerStyle {
  final double? thickness;
  final Decoration? decoration;
  final EdgeInsetsGeometry? margin;

  DividerStyle({this.thickness, this.decoration, this.margin});

  static DividerStyle defaultTheme([Brightness? brightness]) {
    final def = DividerStyle(
      thickness: 5,
      margin: EdgeInsets.zero,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(DividerStyle(
        decoration: BoxDecoration(color: Colors.grey),
      ));
    else
      return def.copyWith(DividerStyle(
        decoration: BoxDecoration(color: Colors.grey[30]),
      ));
  }

  DividerStyle copyWith(DividerStyle? style) {
    return DividerStyle(
      decoration: style?.decoration ?? decoration,
      margin: style?.margin ?? margin,
      thickness: style?.thickness ?? thickness,
    );
  }
}
