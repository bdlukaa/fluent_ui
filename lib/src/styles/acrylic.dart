import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Acrylic extends StatelessWidget {
  const Acrylic({
    Key? key,
    this.color,
    this.decoration,
    this.filter,
    this.child,
    this.opacity = 0.8,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.shadowColor,
    this.elevation,
  }) : super(key: key);

  final Color? color;
  final Decoration? decoration;

  final double opacity;
  final ImageFilter? filter;

  final Widget? child;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Color? shadowColor;
  final double? elevation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(DoubleProperty('opacity', opacity));
    properties.add(DiagnosticsProperty<ImageFilter>('filter', filter));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
    properties.add(ColorProperty('shadowColor', shadowColor));
    properties.add(DoubleProperty('elevation', elevation));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    final color = this.color ?? style.navigationPanelBackgroundColor;
    Widget result = AnimatedContainer(
      duration: style.fastAnimationDuration ?? Duration.zero,
      curve: style.animationCurve ?? standartCurve,
      padding: margin ?? EdgeInsets.zero,
      width: width,
      height: height,
      child: ClipRect(
        child: BackdropFilter(
          filter: filter ?? ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: AnimatedContainer(
            padding: padding,
            duration: style.fastAnimationDuration ?? Duration.zero,
            curve: style.animationCurve ?? standartCurve,
            decoration:
                decoration ?? BoxDecoration(color: color?.withOpacity(opacity)),
            child: child,
          ),
        ),
      ),
    );
    if (elevation != null && elevation != 0) {
      result = PhysicalModel(
        color: shadowColor ?? Colors.black,
        elevation: elevation!,
        child: result,
      );
    }
    return result;
  }
}
