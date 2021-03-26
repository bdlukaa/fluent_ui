import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Divider extends StatelessWidget {
  const Divider({
    Key? key,
    this.direction = Axis.horizontal,
    this.style,
    this.size,
  }) : super(key: key);

  final Axis direction;
  final DividerStyle? style;

  final double? size;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.dividerStyle?.copyWith(this.style);
    return AnimatedContainer(
      duration: context.theme.fastAnimationDuration ?? Duration.zero,
      curve: context.theme.animationCurve ?? Curves.linear,
      height: direction == Axis.horizontal ? style?.thickness : size,
      width: direction == Axis.vertical ? style?.thickness : size,
      margin: style?.margin?.call(direction),
      decoration: style?.decoration,
    );
  }
}

@immutable
class DividerStyle with Diagnosticable {
  final double? thickness;
  final Decoration? decoration;
  final EdgeInsetsGeometry Function(Axis direction)? margin;

  const DividerStyle({this.thickness, this.decoration, this.margin});

  static DividerStyle defaultTheme(Style style) {
    return DividerStyle(
      thickness: 1,
      margin: (direction) {
        if (direction == Axis.horizontal)
          return EdgeInsets.symmetric(horizontal: 10);
        else
          return EdgeInsets.symmetric(vertical: 10);
      },
      decoration: () {
        if (style.brightness == Brightness.light) {
          return BoxDecoration(color: Color(0XFFB7B7B7));
        } else {
          return BoxDecoration(color: Color(0xFF484848));
        }
      }(),
    );
  }

  DividerStyle copyWith(DividerStyle? style) {
    if (style == null) return this;
    return DividerStyle(
      decoration: style.decoration ?? decoration,
      margin: style.margin ?? margin,
      thickness: style.thickness ?? thickness,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(ObjectFlagProperty.has('margin', margin));
    properties.add(DoubleProperty('thickness', thickness));
  }
}
