import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// A focus border creates an animated border around a widget whenever it has
/// the application primary focus.
///
/// ![FocusBorder Preview](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/header-reveal-focus.svg)
class FocusBorder extends StatelessWidget {
  /// Creates a focus border.
  const FocusBorder({
    required this.child,
    super.key,
    this.focused = true,
    this.style,
    this.renderOutside,
    this.useStackApproach = true,
  });

  /// The child that will receive the border
  final Widget child;

  /// Whether to show the border. Defaults to true
  final bool focused;

  /// The style of this focus border.
  ///
  /// If non-null, this is mescled with [FluentThemeData.focusTheme]
  final FocusThemeData? style;

  /// Whether the border should be rendered outside of the box or not.
  ///
  /// If null, [FocusThemeData.renderOutside] is used.
  final bool? renderOutside;

  /// Whether wrapping the widget in a stack is the approach that is going to be
  /// used to render the box. If false, a transparent border is created around
  /// the [child] as a placeholder, and the real border is only displayed when
  /// [focused] is true.
  ///
  /// Using the stack approach is recommended for widgets that have a defined
  /// size. You should not use it with widgets that require dragging.
  final bool useStackApproach;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('focused', value: focused, ifFalse: 'unfocused'))
      ..add(DiagnosticsProperty<FocusThemeData>('style', style))
      ..add(
        FlagProperty(
          'renderOutside',
          value: renderOutside,
          ifFalse: 'render inside',
        ),
      )
      ..add(
        FlagProperty(
          'useStackApproach',
          value: useStackApproach,
          defaultValue: true,
          ifFalse: 'use border approach',
        ),
      );
  }

  static Widget _buildBorder(
    FocusThemeData style,
    bool focused, [
    Widget? child,
  ]) {
    return Builder(
      builder: (context) {
        return IgnorePointer(
          child: DecoratedBox(
            decoration: style.buildPrimaryDecoration(focused),
            child: DecoratedBox(
              decoration: style.buildSecondaryDecoration(focused),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = FocusTheme.of(context).merge(this.style);
    final borderWidth =
        (style.primaryBorder?.width ?? 0) + (style.secondaryBorder?.width ?? 0);
    if (useStackApproach) {
      final renderOutside = this.renderOutside ?? style.renderOutside ?? true;
      final clipBehavior = renderOutside ? Clip.none : Clip.hardEdge;
      return Stack(
        fit: StackFit.passthrough,
        clipBehavior: clipBehavior,
        children: [
          child,
          PositionedDirectional(
            start: renderOutside ? -borderWidth : 0,
            end: renderOutside ? -borderWidth : 0,
            top: renderOutside ? -borderWidth : 0,
            bottom: renderOutside ? -borderWidth : 0,
            child: _buildBorder(style, focused),
          ),
        ],
      );
    } else {
      return _buildBorder(style, focused, child);
    }
  }
}

/// An inherited widget that defines the configuration for
/// [FocusBorder]s in this widget's subtree.
///
/// Values specified here are used for [FocusBorder] properties that are not
/// given an explicit non-null value.
class FocusTheme extends InheritedTheme {
  /// Creates a theme that controls how descendant [FocusBorder]s should
  /// look like.
  const FocusTheme({required this.data, required super.child, super.key});

  /// The theme data for the focus border.
  final FocusThemeData data;

  /// Creates a theme that merges the nearest [FocusTheme] with [data].
  static Widget merge({
    required FocusThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return FocusTheme(
          key: key,
          data: FocusTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [FocusThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Defaults from [FocusThemeData.standard]
  /// 2. Global theme from [FluentThemeData.focusTheme]
  /// 3. Local [FocusTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// FocusThemeData theme = FocusTheme.of(context);
  /// ```
  static FocusThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<FocusTheme>();
    return FocusThemeData.standard(
      theme,
    ).merge(theme.focusTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return FocusTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(FocusTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for [FocusBorder] widgets.
class FocusThemeData with Diagnosticable {
  /// The border radius of the focus border.
  final BorderRadius? borderRadius;

  /// The primary border of the focus border.
  final BorderSide? primaryBorder;

  /// The secondary border of the focus border.
  final BorderSide? secondaryBorder;

  /// The glow color of the focus border.
  final Color? glowColor;

  /// The glow factor of the focus border.
  final double? glowFactor;

  /// Whether the focus border should be rendered outside of the box or not.
  final bool? renderOutside;

  /// Creates a theme data for [FocusBorder] widgets.
  const FocusThemeData({
    this.borderRadius,
    this.primaryBorder,
    this.secondaryBorder,
    this.glowColor,
    this.glowFactor,
    this.renderOutside,
  }) : assert(glowFactor == null || glowFactor >= 0);

  /// Creates the standard [FocusThemeData] based on the given [theme].
  factory FocusThemeData.standard(FluentThemeData theme) {
    return FocusThemeData(
      borderRadius: BorderRadius.circular(6),
      primaryBorder: BorderSide(
        width: 2,
        color: theme.resources.focusStrokeColorOuter,
      ),
      secondaryBorder: BorderSide(color: theme.resources.focusStrokeColorInner),
      glowColor: theme.accentColor.withValues(alpha: 0.15),
      glowFactor: 0,
      renderOutside: true,
    );
  }

  /// Lerps between two [FocusThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
  static FocusThemeData lerp(FocusThemeData? a, FocusThemeData? b, double t) {
    return FocusThemeData(
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      primaryBorder: BorderSide.lerp(
        a?.primaryBorder ?? BorderSide.none,
        b?.primaryBorder ?? BorderSide.none,
        t,
      ),
      secondaryBorder: BorderSide.lerp(
        a?.secondaryBorder ?? BorderSide.none,
        b?.secondaryBorder ?? BorderSide.none,
        t,
      ),
      glowColor: Color.lerp(a?.glowColor, b?.glowColor, t),
      glowFactor: lerpDouble(a?.glowFactor, b?.glowFactor, t),
      renderOutside: t < 0.5 ? a?.renderOutside : b?.renderOutside,
    );
  }

  /// Merges this [FocusThemeData] with another, with the other taking
  /// precedence.
  FocusThemeData merge(FocusThemeData? other) {
    if (other == null) return this;
    return FocusThemeData(
      primaryBorder: other.primaryBorder ?? primaryBorder,
      secondaryBorder: other.secondaryBorder ?? secondaryBorder,
      borderRadius: other.borderRadius ?? borderRadius,
      glowFactor: other.glowFactor ?? glowFactor,
      glowColor: other.glowColor ?? glowColor,
      renderOutside: other.renderOutside ?? renderOutside,
    );
  }

  /// Builds the primary decoration for the focus border.
  Decoration buildPrimaryDecoration(bool focused) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
        side: !focused ? BorderSide.none : primaryBorder ?? BorderSide.none,
      ),
      shadows: focused && glowFactor != 0 && glowColor != null
          ? [
              BoxShadow(
                offset: const Offset(1, 1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: const Offset(-1, -1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: const Offset(-1, 1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: const Offset(1, -1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
            ]
          : null,
    );
  }

  /// Builds the secondary decoration for the focus border.
  Decoration buildSecondaryDecoration(bool focused) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
        side: !focused ? BorderSide.none : secondaryBorder ?? BorderSide.none,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<BorderSide>(
          'primaryBorder',
          primaryBorder,
          ifNull: 'No primary border',
        ),
      )
      ..add(
        DiagnosticsProperty<BorderSide>(
          'secondaryBorder',
          secondaryBorder,
          ifNull: 'No secondary border',
        ),
      )
      ..add(
        DiagnosticsProperty<BorderRadius>(
          'borderRadius',
          borderRadius,
          defaultValue: BorderRadius.zero,
        ),
      )
      ..add(DoubleProperty('glowFactor', glowFactor, defaultValue: 0.0))
      ..add(
        ColorProperty('glowColor', glowColor, defaultValue: Colors.transparent),
      )
      ..add(
        FlagProperty(
          'renderOutside',
          value: renderOutside,
          defaultValue: true,
          ifFalse: 'renderInside',
        ),
      );
  }
}
