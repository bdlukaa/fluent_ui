import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// A thin line used to separate content into groups.
///
/// Dividers help organize content and establish visual hierarchy by creating
/// clear boundaries between sections or items.
///
/// {@tool snippet}
/// This example shows a horizontal divider between text:
///
/// ```dart
/// Column(
///   children: [
///     Text('Section 1'),
///     Divider(),
///     Text('Section 2'),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a vertical divider in a row:
///
/// ```dart
/// Row(
///   children: [
///     Text('Left'),
///     Divider(direction: Axis.vertical, size: 20),
///     Text('Right'),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [DividerTheme], for customizing divider appearance
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/separator>
class Divider extends StatelessWidget {
  /// Creates a divider.
  const Divider({
    super.key,
    this.direction = Axis.horizontal,
    this.style,
    this.size,
  });

  /// The direction of the divider.
  ///
  /// Use [Axis.horizontal] for a line that spans horizontally (default).
  /// Use [Axis.vertical] for a line that spans vertically.
  final Axis direction;

  /// The `style` of the divider. It's mescled with [FluentThemeData.dividerTheme]
  final DividerThemeData? style;

  /// The size of the divider. The opposite of the [DividerThemeData.thickness]
  final double? size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DoubleProperty(
          'size',
          size,
          ifNull: 'indeterminate',
          defaultValue: 1.0,
        ),
      )
      ..add(DiagnosticsProperty('style', style))
      ..add(
        EnumProperty('direction', direction, defaultValue: Axis.horizontal),
      );
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
  /// Creates a theme that controls how descendant [Divider]s should look like.
  const DividerTheme({required this.data, required super.child, super.key});

  /// The properties for descendant [Divider] widgets.
  final DividerThemeData data;

  /// Creates a theme that merges the nearest [DividerTheme] with [data].
  static Widget merge({
    required DividerThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return DividerTheme(
          key: key,
          data: DividerTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [DividerThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Defaults from [DividerThemeData.standard]
  /// 2. Global theme from [FluentThemeData.dividerTheme]
  /// 3. Local [DividerTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DividerThemeData theme = DividerTheme.of(context);
  /// ```
  static DividerThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<DividerTheme>();
    return DividerThemeData.standard(
      theme,
    ).merge(theme.dividerTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DividerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(DividerTheme oldWidget) => data != oldWidget.data;
}

@immutable
/// Theme data for [Divider] widgets.
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

  /// Creates a divider theme data.
  const DividerThemeData({
    this.thickness,
    this.decoration,
    this.verticalMargin,
    this.horizontalMargin,
  });

  /// Creates the standard [DividerThemeData] based on the given [theme].
  factory DividerThemeData.standard(FluentThemeData theme) {
    return DividerThemeData(
      thickness: 1,
      horizontalMargin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      verticalMargin: const EdgeInsetsDirectional.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.resources.dividerStrokeColorDefault,
      ),
    );
  }

  /// Linearly interpolates between two [DividerThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
  static DividerThemeData lerp(
    DividerThemeData? a,
    DividerThemeData? b,
    double t,
  ) {
    return DividerThemeData(
      decoration: Decoration.lerp(a?.decoration, b?.decoration, t),
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      horizontalMargin: EdgeInsetsGeometry.lerp(
        a?.horizontalMargin,
        b?.horizontalMargin,
        t,
      ),
      verticalMargin: EdgeInsetsGeometry.lerp(
        a?.verticalMargin,
        b?.verticalMargin,
        t,
      ),
    );
  }

  /// Merges this [DividerThemeData] with another, with the other taking
  /// precedence.
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
