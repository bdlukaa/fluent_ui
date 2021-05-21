import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Divider extends StatelessWidget {
  /// Creates a divider.
  const Divider({
    Key? key,
    this.direction = Axis.horizontal,
    this.style,
    this.size,
  }) : super(key: key);

  /// The current direction of the slider. Uses [Axis.horizontal] by default
  final Axis direction;

  /// The `style` of the divider. It's mescled with [ThemeData.dividerThemeData]
  final DividerThemeData? style;

  /// The size of the divider. The opposite of the [DividerThemeData.thickness]
  final double? size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty(
      'size',
      size,
      ifNull: 'indeterminate',
      defaultValue: 1.0,
    ));
    properties.add(DiagnosticsProperty('style', style));
    properties.add(EnumProperty(
      'direction',
      direction,
      defaultValue: Axis.horizontal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = DividerThemeData.standard(FluentTheme.of(context)).copyWith(
      FluentTheme.of(context).dividerTheme.copyWith(this.style),
    );
    return AnimatedContainer(
      duration: FluentTheme.of(context).fastAnimationDuration,
      curve: FluentTheme.of(context).animationCurve,
      height: direction == Axis.horizontal ? style.thickness : size,
      width: direction == Axis.vertical ? style.thickness : size,
      margin: direction == Axis.horizontal
          ? style.horizontalMargin
          : style.verticalMargin,
      decoration: style.decoration,
    );
  }
}

@immutable
class DividerThemeData with Diagnosticable {
  /// The thickness of the style.
  ///
  /// If it's horizontal, it corresponds to the divider
  /// `height`, otherwise it corresponds to its `width`
  final double? thickness;

  /// The decoration of the style. If null, defaults to a
  /// [BoxDecoration] with a `Color(0xFFB7B7B7)` for light
  /// mode and `Color(0xFF484848)` for dark mode
  final Decoration? decoration;

  /// The vertical margin of the style.
  final EdgeInsetsGeometry? verticalMargin;

  /// The horizontal margin of the style.
  final EdgeInsetsGeometry? horizontalMargin;

  const DividerThemeData({
    this.thickness,
    this.decoration,
    this.verticalMargin,
    this.horizontalMargin,
  });

  factory DividerThemeData.standard(ThemeData style) {
    return DividerThemeData(
      thickness: 1,
      horizontalMargin: const EdgeInsets.symmetric(horizontal: 10),
      verticalMargin: const EdgeInsets.symmetric(vertical: 10),
      decoration: () {
        if (style.brightness == Brightness.light) {
          return BoxDecoration(color: Color(0xFFB7B7B7));
        } else {
          return BoxDecoration(color: Color(0xFF484848));
        }
      }(),
    );
  }

  static DividerThemeData lerp(
      DividerThemeData? a, DividerThemeData? b, double t) {
    return DividerThemeData(
      decoration: Decoration.lerp(a?.decoration, b?.decoration, t),
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      horizontalMargin:
          EdgeInsetsGeometry.lerp(a?.horizontalMargin, b?.horizontalMargin, t),
      verticalMargin:
          EdgeInsetsGeometry.lerp(a?.verticalMargin, b?.verticalMargin, t),
    );
  }

  DividerThemeData copyWith(DividerThemeData? style) {
    if (style == null) return this;
    return DividerThemeData(
      decoration: style.decoration ?? decoration,
      thickness: style.thickness ?? thickness,
      horizontalMargin: style.horizontalMargin ?? horizontalMargin,
      verticalMargin: style.verticalMargin ?? verticalMargin,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(DiagnosticsProperty('horizontalMargin', horizontalMargin));
    properties.add(DiagnosticsProperty('verticalMargin', verticalMargin));
    properties.add(DoubleProperty('thickness', thickness, defaultValue: 1.0));
  }
}
