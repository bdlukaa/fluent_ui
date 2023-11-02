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
    super.key,
    required this.child,
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
      ..add(
        FlagProperty('focused', value: focused, ifFalse: 'unfocused'),
      )
      ..add(DiagnosticsProperty<FocusThemeData>('style', style))
      ..add(FlagProperty(
        'renderOutside',
        value: renderOutside,
        ifFalse: 'render inside',
      ))
      ..add(FlagProperty(
        'useStackApproach',
        value: useStackApproach,
        defaultValue: true,
        ifFalse: 'use border approach',
      ));
  }

  static Widget _buildBorder(
    FocusThemeData style,
    bool focused, [
    Widget? child,
  ]) {
    return Builder(builder: (context) {
      return IgnorePointer(
        child: DecoratedBox(
          decoration: style.buildPrimaryDecoration(focused),
          child: DecoratedBox(
            decoration: style.buildSecondaryDecoration(focused),
            child: child,
          ),
        ),
      );
    });
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

class FocusTheme extends InheritedWidget {
  const FocusTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final FocusThemeData data;

  static FocusThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = context.dependOnInheritedWidgetOfExactType<FocusTheme>();
    return FocusThemeData.fromTheme(FluentTheme.of(context))
        .merge(FluentTheme.of(context).focusTheme.merge(theme?.data));
  }

  @override
  bool updateShouldNotify(FocusTheme oldWidget) => oldWidget.data != data;
}

class FocusThemeData with Diagnosticable {
  final BorderRadius? borderRadius;
  final BorderSide? primaryBorder;
  final BorderSide? secondaryBorder;
  final Color? glowColor;
  final double? glowFactor;
  final bool? renderOutside;

  const FocusThemeData({
    this.borderRadius,
    this.primaryBorder,
    this.secondaryBorder,
    this.glowColor,
    this.glowFactor,
    this.renderOutside,
  }) : assert(glowFactor == null || glowFactor >= 0);

  static FocusThemeData of(BuildContext context) {
    return FluentTheme.of(context).focusTheme;
  }

  factory FocusThemeData.fromTheme(FluentThemeData theme) {
    return FocusThemeData(
      borderRadius: BorderRadius.circular(6.0),
      primaryBorder: BorderSide(
        width: 2,
        color: theme.resources.focusStrokeColorOuter,
      ),
      secondaryBorder: BorderSide(
        color: theme.resources.focusStrokeColorInner,
      ),
      glowColor: theme.accentColor.withOpacity(0.15),
      glowFactor: 0.0,
      renderOutside: true,
    );
  }

  static FocusThemeData lerp(FocusThemeData? a, FocusThemeData? b, double t) {
    return FocusThemeData(
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      primaryBorder: BorderSide.lerp(a?.primaryBorder ?? BorderSide.none,
          b?.primaryBorder ?? BorderSide.none, t),
      secondaryBorder: BorderSide.lerp(a?.secondaryBorder ?? BorderSide.none,
          b?.secondaryBorder ?? BorderSide.none, t),
      glowColor: Color.lerp(a?.glowColor, b?.glowColor, t),
      glowFactor: lerpDouble(a?.glowFactor, b?.glowFactor, t),
      renderOutside: t < 0.5 ? a?.renderOutside : b?.renderOutside,
    );
  }

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
      ..add(DiagnosticsProperty<BorderSide>(
        'primaryBorder',
        primaryBorder,
        ifNull: 'No primary border',
      ))
      ..add(DiagnosticsProperty<BorderSide>(
        'secondaryBorder',
        secondaryBorder,
        ifNull: 'No secondary border',
      ))
      ..add(DiagnosticsProperty<BorderRadius>(
        'borderRadius',
        borderRadius,
        defaultValue: BorderRadius.zero,
      ))
      ..add(DoubleProperty('glowFactor', glowFactor, defaultValue: 0.0))
      ..add(ColorProperty(
        'glowColor',
        glowColor,
        defaultValue: Colors.transparent,
      ))
      ..add(FlagProperty(
        'renderOutside',
        value: renderOutside,
        defaultValue: true,
        ifFalse: 'renderInside',
      ));
  }
}
