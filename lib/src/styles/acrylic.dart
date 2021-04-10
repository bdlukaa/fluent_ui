import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Acrylic is a type of Brush that creates a translucent texture.
/// You can apply acrylic to app surfaces to add depth and help establish a visual hierarchy.
class Acrylic extends StatelessWidget {

  /// The [color] and [decoration] arguments can not be both supplied.
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
  })  : assert(
          elevation == null || elevation >= 0,
          'The elevation can NOT be negative',
        ),
        assert(opacity >= 0, 'The opacity can NOT be negative'),
        super(key: key);

  /// The color to fill the background of the box
  final Color? color;

  /// The decoration to paint behind the [child].
  ///
  /// Use the [color] property to specify a simple solid color.
  ///
  /// The [child] is not clipped to the decoration. To clip a child to the shape
  /// of a particular [ShapeDecoration], consider using a [ClipPath] widget.
  final Decoration? decoration;

  /// The opacity applied to the [color] from 0.0 to 1.0.
  final double opacity;

  /// The image filter to apply to the existing painted content before painting the child.
  ///
  /// For example, consider using [ImageFilter.blur] to create a backdrop blur effect.
  final ImageFilter? filter;

  /// The child contained by this box
  final Widget? child;

  /// The width of the box
  final double? width;

  /// The height of the box
  final double? height;

  /// Empty space to inscribe inside the [decoration].
  /// The [child], if any, is placed inside this padding.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The color of the elevation
  final Color? shadowColor;

  /// The z-coordinate relative to the parent at which to place this physical object.
  ///
  /// The value is non-negative.
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
      margin: EdgeInsets.zero,
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
    if (elevation != null && elevation! > 0) {
      result = PhysicalModel(
        color: shadowColor ?? Colors.black,
        elevation: elevation!,
        child: result,
      );
    }
    return result;
  }
}
