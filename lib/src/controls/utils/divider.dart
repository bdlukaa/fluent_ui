import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Divider extends StatelessWidget {
  /// Creates a divider.
  const Divider({
    super.key,
    this.direction = Axis.horizontal,
    this.style,
    this.size,
  });

  /// The current direction of the slider.
  ///
  /// Uses [Axis.horizontal] by default
  final Axis direction;

  /// The `style` of the divider. It's mescled with [FluentThemeData.dividerTheme]
  final DividerThemeData? style;

  /// The size of the divider. The opposite of the [DividerThemeData.thickness]
  final double? size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty(
        'size',
        size,
        ifNull: 'indeterminate',
        defaultValue: 1.0,
      ))
      ..add(DiagnosticsProperty('style', style))
      ..add(EnumProperty(
        'direction',
        direction,
        defaultValue: Axis.horizontal,
      ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = DividerTheme.of(context).merge(this.style);
    return Container(
      height: direction == Axis.horizontal ? style.thickness : size,
      width: direction == Axis.vertical ? style.thickness : size,
      margin: direction == Axis.horizontal
          ? style.horizontalMargin
          : style.verticalMargin,
      decoration: style.decoration,
    );
  }
}

/// An inherited widget that defines the configuration for
/// [Divider]s in this widget's subtree.
///
/// Values specified here are used for [Divider] properties that are not
/// given an explicit non-null value.
class DividerTheme extends InheritedTheme {
  /// Creates a divider theme that controls the configurations for
  /// [Divider].
  const DividerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The properties for descendant [Divider] widgets.
  final DividerThemeData data;

  /// Creates a button theme that controls how descendant [Divider]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required DividerThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return DividerTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static DividerThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<DividerTheme>();
    return theme?.data ?? FluentTheme.of(context).dividerTheme;
  }

  /// Returns the [data] from the closest [DividerTheme] ancestor. If there is
  /// no ancestor, it returns [FluentThemeData.dividerTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DividerThemeData theme = DividerTheme.of(context);
  /// ```
  static DividerThemeData of(BuildContext context) {
    return DividerThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DividerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(DividerTheme oldWidget) => data != oldWidget.data;
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

  factory DividerThemeData.standard(FluentThemeData theme) {
    return DividerThemeData(
      thickness: 1,
      horizontalMargin: const EdgeInsets.symmetric(horizontal: 10),
      verticalMargin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.resources.dividerStrokeColorDefault,
      ),
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

  DividerThemeData merge(DividerThemeData? style) {
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
    properties
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration))
      ..add(DiagnosticsProperty('horizontalMargin', horizontalMargin))
      ..add(DiagnosticsProperty('verticalMargin', verticalMargin))
      ..add(DoubleProperty('thickness', thickness, defaultValue: 1.0));
  }
}
