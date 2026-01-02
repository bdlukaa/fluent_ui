import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A border that paints a gradient.
///
/// This is a common design among modern Windows applications.
///
/// See also:
///
///  * [FilledButton], a button that uses this border.
class RoundedRectangleGradientBorder extends ShapeBorder {
  /// the gradient used to paint the border.
  final Gradient gradient;

  /// The style of this side of the border. Default to [BorderStyle.solid]
  ///
  /// To omit a side, set [style] to [BorderStyle.none]. This skips
  /// painting the border, but the border still has a [width].
  final BorderStyle style;

  /// The radii for each corner.
  final BorderRadiusGeometry borderRadius;

  /// The width of this side of the border, in logical pixels.
  final double width;

  /// The relative position of the stroke on a [BorderSide] in an
  /// [OutlinedBorder] or [Border].
  ///
  /// Values typically range from -1.0 ([strokeAlignInside], inside border,
  /// default) to 1.0 ([strokeAlignOutside], outside border), without any
  /// bound constraints (e.g., a value of -2.0 is not typical, but allowed).
  /// A value of 0 ([strokeAlignCenter]) will center the border on the edge
  /// of the widget.
  ///
  /// When set to [strokeAlignInside], the stroke is drawn completely inside
  /// the widget. For [strokeAlignCenter] and [strokeAlignOutside], a property
  /// such as [Container.clipBehavior] can be used in an outside widget to clip
  /// it. If [Container.decoration] has a border, the container may incorporate
  /// [width] as additional padding:
  /// - [strokeAlignInside] provides padding with full [width].
  /// - [strokeAlignCenter] provides padding with half [width].
  /// - [strokeAlignOutside] provides zero padding, as stroke is drawn entirely outside.
  final double strokeAlign;

  /// The border is drawn fully inside of the border path.
  ///
  /// This is a constant for use with [strokeAlign].
  ///
  /// This is the default value for [strokeAlign].
  static const double strokeAlignInside = -1;

  /// The border is drawn on the center of the border path, with half of the
  /// [BorderSide.width] on the inside, and the other half on the outside of
  /// the path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignCenter = 0;

  /// The border is drawn on the outside of the border path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignOutside = 1;

  /// Creates a rounded rectangle border.
  const RoundedRectangleGradientBorder({
    this.gradient = const LinearGradient(colors: []),
    this.borderRadius = BorderRadius.zero,
    this.width = 1.0,
    this.strokeAlign = strokeAlignInside,
    this.style = BorderStyle.solid,
  });

  /// Get the amount of the stroke width that lies inside of the [BorderSide].
  ///
  /// For example, this will return the [width] for a [strokeAlign] of -1, half
  /// the [width] for a [strokeAlign] of 0, and 0 for a [strokeAlign] of 1.
  double get strokeInset => width * (1 - (1 + strokeAlign) / 2);

  /// Get the amount of the stroke width that lies outside of the [BorderSide].
  ///
  /// For example, this will return 0 for a [strokeAlign] of -1, half the
  /// [width] for a [strokeAlign] of 0, and the [width] for a [strokeAlign]
  /// of 1.
  double get strokeOutset => width * (1 + strokeAlign) / 2;

  /// The offset of the stroke, taking into account the stroke alignment.
  ///
  /// For example, this will return the negative [width] of the stroke
  /// for a [strokeAlign] of -1, 0 for a [strokeAlign] of 0, and the
  /// [width] for a [strokeAlign] of -1.
  double get strokeOffset => width * strokeAlign;

  @override
  ShapeBorder scale(double t) {
    return RoundedRectangleGradientBorder(
      gradient: gradient.scale(t),
      width: math.max(0, width * t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsetsDirectional.all(math.max(strokeInset, 0));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final borderRect = borderRadius.resolve(textDirection).toRRect(rect);
    final adjustedRect = borderRect.deflate(strokeInset);
    return Path()..addRRect(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(
        borderRadius.resolve(textDirection).toRRect(rect),
        paint,
      );
    }
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final paint = Paint()
          ..shader = gradient.createShader(rect, textDirection: textDirection);
        final borderRect = borderRadius.resolve(textDirection).toRRect(rect);
        final inner = borderRect.deflate(strokeInset);
        final outer = borderRect.inflate(strokeOutset);
        canvas.drawDRRect(outer, inner, paint);
    }
  }

  /// Returns a copy of this RoundedRectangleBorder with the given fields
  /// replaced with the new values.
  RoundedRectangleGradientBorder copyWith({
    required Gradient gradient,
    required BorderRadiusGeometry borderRadius,
    required double width,
    required double strokeAlign,
  }) {
    return RoundedRectangleGradientBorder(
      gradient: gradient,
      width: width,
      borderRadius: borderRadius,
      strokeAlign: strokeAlign,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RoundedRectangleGradientBorder &&
        other.gradient == gradient &&
        other.width == width &&
        other.borderRadius == borderRadius &&
        other.style == style &&
        other.strokeAlign == strokeAlign;
  }

  @override
  int get hashCode =>
      Object.hash(gradient, width, borderRadius, strokeAlign, style);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'RoundedRectangleGradientBorder')}($gradient, $width, $borderRadius, $strokeAlign, $style)';
  }
}
