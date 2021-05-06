import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// A focus border creates an animated border around a widget
/// whenever it has the application primary focus.
///
/// ![FocusBorder Preview](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/header-reveal-focus.svg)
class FocusBorder extends StatelessWidget {
  /// Creates a focus border.
  const FocusBorder({
    Key? key,
    required this.child,
    this.focused = true,
    this.style,
    this.renderOutside,
    this.useStackApproach = true,
  }) : super(key: key);

  /// The child that will receive the border
  final Widget child;

  /// Whether to show the border. Defaults to true
  final bool focused;

  /// The style of this focus border. If non-null, this
  /// is mescled with [ThemeData.focusThemeData]
  final FocusThemeData? style;

  /// Whether the border should be rendered outside of the
  /// box or not. If null, [FocusThemeData.renderOutside]
  /// is used.
  final bool? renderOutside;

  /// Whether wrapping the widget in a stack is the approach
  /// that is goind to be used to render the box. If false,
  /// a transparent border is created around the [child] as a
  /// placeholder, and the real border is only displayed when
  /// [focused] is true.
  ///
  /// Using the stack approach is recommended for widgets that
  /// have a defined size (height and width). You should not use
  /// it with widgets that require dragging.
  ///
  /// This property is disabled by default on the following widgets:
  ///   - [Slider]
  final bool useStackApproach;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('focused', value: focused, ifFalse: 'unfocused'),
    );
    properties.add(DiagnosticsProperty<FocusThemeData>('style', style));
    properties.add(FlagProperty(
      'renderOutside',
      value: renderOutside,
      ifFalse: 'render inside',
    ));
    properties.add(FlagProperty(
      'useStackApproach',
      value: useStackApproach,
      defaultValue: true,
      ifFalse: 'use border approach',
    ));
  }

  static Widget buildBorder(
    FocusThemeData style,
    bool focused, [
    Widget? child,
  ]) {
    return AnimatedContainer(
      duration: style.animationDuration ?? Duration.zero,
      curve: style.animationCurve ?? Curves.linear,
      decoration: style.buildPrimaryDecoration(focused),
      child: DecoratedBox(
        decoration: style.buildSecondaryDecoration(focused),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = context.theme.focusTheme.copyWith(this.style);
    final double borderWidth =
        (style.primaryBorder?.width ?? 0) + (style.secondaryBorder?.width ?? 0);
    if (useStackApproach) {
      final renderOutside = this.renderOutside ?? style.renderOutside ?? true;
      final clipBehavior = renderOutside ? Clip.none : Clip.hardEdge;
      return Stack(
        fit: StackFit.passthrough,
        clipBehavior: clipBehavior,
        children: [
          child,
          Positioned.fill(
            left: renderOutside ? -borderWidth : 0,
            right: renderOutside ? -borderWidth : 0,
            top: renderOutside ? -borderWidth : 0,
            bottom: renderOutside ? -borderWidth : 0,
            child: buildBorder(style, focused),
          ),
        ],
      );
    } else {
      return buildBorder(style, focused, child);
    }
  }
}

class FocusThemeData with Diagnosticable {
  final BorderRadius? borderRadius;
  final BorderSide? primaryBorder;
  final BorderSide? secondaryBorder;
  final Color? glowColor;
  final double? glowFactor;
  final bool? renderOutside;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const FocusThemeData({
    this.borderRadius,
    this.primaryBorder,
    this.secondaryBorder,
    this.glowColor,
    this.glowFactor,
    this.renderOutside,
    this.animationDuration,
    this.animationCurve,
  }) : assert(glowFactor == null || glowFactor >= 0);

  static FocusThemeData of(BuildContext context) {
    return FluentTheme.of(context).focusTheme;
  }

  factory FocusThemeData.standard({
    required Color primaryBorderColor,
    required Color secondaryBorderColor,
    required Color glowColor,
    required Duration animationDuration,
    required Curve animationCurve,
  }) {
    return FocusThemeData(
      borderRadius: BorderRadius.zero,
      primaryBorder: BorderSide(width: 2, color: primaryBorderColor),
      secondaryBorder: BorderSide(width: 1, color: secondaryBorderColor),
      glowColor: glowColor,
      glowFactor: 0.0,
      renderOutside: true,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }

  FocusThemeData copyWith(FocusThemeData? other) {
    if (other == null) return this;
    return FocusThemeData(
      primaryBorder: other.primaryBorder ?? primaryBorder,
      secondaryBorder: other.secondaryBorder ?? secondaryBorder,
      borderRadius: other.borderRadius ?? borderRadius,
      glowFactor: other.glowFactor ?? glowFactor,
      glowColor: other.glowColor ?? glowColor,
      renderOutside: other.renderOutside ?? renderOutside,
      animationCurve: other.animationCurve ?? animationCurve,
      animationDuration: other.animationDuration ?? animationDuration,
    );
  }

  BoxDecoration buildPrimaryDecoration(bool focused) {
    return BoxDecoration(
      borderRadius: borderRadius,
      border: Border.fromBorderSide(
        !focused ? BorderSide.none : primaryBorder ?? BorderSide.none,
      ),
      boxShadow: focused && glowFactor != 0 && glowColor != null
          ? [
              BoxShadow(
                offset: Offset(1, 1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: Offset(-1, -1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: Offset(-1, 1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
              BoxShadow(
                offset: Offset(1, -1),
                color: glowColor!,
                spreadRadius: glowFactor!,
                blurRadius: glowFactor! * 2.5,
              ),
            ]
          : null,
    );
  }

  BoxDecoration buildSecondaryDecoration(bool focused) {
    return BoxDecoration(
      borderRadius: borderRadius,
      border: Border.fromBorderSide(
        !focused ? BorderSide.none : secondaryBorder ?? BorderSide.none,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BorderSide>(
      'primaryBorder',
      primaryBorder,
      ifNull: 'No primary border',
    ));
    properties.add(DiagnosticsProperty<BorderSide>(
      'secondaryBorder',
      secondaryBorder,
      ifNull: 'No secondary border',
    ));
    properties.add(DiagnosticsProperty<BorderRadius>(
      'borderRadius',
      borderRadius,
      defaultValue: BorderRadius.zero,
    ));
    properties.add(DoubleProperty('glowFactor', glowFactor, defaultValue: 0.0));
    properties.add(ColorProperty(
      'glowColor',
      glowColor,
      defaultValue: Colors.transparent,
    ));
    properties.add(FlagProperty(
      'renderOutside',
      value: renderOutside,
      defaultValue: true,
      ifFalse: 'renderInside',
    ));
  }
}
