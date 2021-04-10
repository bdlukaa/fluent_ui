import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class FocusBorder extends StatelessWidget {
  const FocusBorder({
    Key? key,
    required this.child,
    this.focused = true,
    this.style,
  }) : super(key: key);

  final Widget child;

  /// Whether the border is focused
  final bool focused;

  /// The style of this focus border. This is mescled with [Style.focusStyle]
  final FocusStyle? style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.focusStyle!.copyWith(this.style);
    return AnimatedContainer(
      duration: context.theme.fastAnimationDuration ?? Duration.zero,
      curve: context.theme.animationCurve ?? Curves.linear,
      decoration: BoxDecoration(
        borderRadius: style.borderRadius,
        border: focused
            ? Border.fromBorderSide(style.primaryBorder ?? BorderSide.none)
            : null,
        boxShadow: focused && style.glowFactor != 0 && style.glowColor != null
            ? [
                BoxShadow(
                  offset: Offset(1, 1),
                  color: style.glowColor!,
                  spreadRadius: style.glowFactor!,
                  blurRadius: style.glowFactor! * 2.5,
                ),
                BoxShadow(
                  offset: Offset(-1, -1),
                  color: style.glowColor!,
                  spreadRadius: style.glowFactor!,
                  blurRadius: style.glowFactor! * 2.5,
                ),
                BoxShadow(
                  offset: Offset(-1, 1),
                  color: style.glowColor!,
                  spreadRadius: style.glowFactor!,
                  blurRadius: style.glowFactor! * 2.5,
                ),
                BoxShadow(
                  offset: Offset(1, -1),
                  color: style.glowColor!,
                  spreadRadius: style.glowFactor!,
                  blurRadius: style.glowFactor! * 2.5,
                ),
              ]
            : null,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: style.borderRadius,
          border: focused
              ? Border.fromBorderSide(style.secondaryBorder ?? BorderSide.none)
              : null,
        ),
        child: child,
      ),
    );
  }
}

class FocusStyle with Diagnosticable {
  final BorderRadius? borderRadius;
  final BorderSide? primaryBorder;
  final BorderSide? secondaryBorder;
  final Color? glowColor;
  final double? glowFactor;

  const FocusStyle({
    this.borderRadius,
    this.primaryBorder,
    this.secondaryBorder,
    this.glowColor,
    this.glowFactor,
  }) : assert(glowFactor == null || glowFactor >= 0);

  factory FocusStyle.standard(Style style) {
    return FocusStyle(
      borderRadius: BorderRadius.zero,
      primaryBorder: BorderSide(
        width: 2,
        color: style.inactiveColor ?? Colors.transparent,
      ),
      secondaryBorder: BorderSide(
        width: 1,
        color: style.scaffoldBackgroundColor ?? Colors.transparent,
      ),
      glowColor: style.accentColor?.withOpacity(0.25) ?? Colors.transparent,
      glowFactor: 0.0,
    );
  }

  FocusStyle copyWith(FocusStyle? other) {
    if (other == null) return this;
    return FocusStyle(
      primaryBorder: other.primaryBorder ?? primaryBorder,
      secondaryBorder: other.secondaryBorder ?? secondaryBorder,
      borderRadius: other.borderRadius ?? borderRadius,
      glowFactor: other.glowFactor ?? glowFactor,
      glowColor: other.glowColor ?? glowColor,
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
  }
}
