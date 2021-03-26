import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';

class Slider extends StatelessWidget {
  const Slider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.style,
    this.label,
    this.focusNode,
  })  : assert(value >= min && value <= max),
        assert(divisions == null || divisions > 0),
        super(key: key);

  final double value;

  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  final int? divisions;
  final SliderStyle? style;

  final String? label;

  final FocusNode? focusNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value));
    properties.add(ObjectFlagProperty<ValueChanged<double>>(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
    properties.add(ObjectFlagProperty<ValueChanged<double>>.has(
      'onChangeStart',
      onChangeStart,
    ));
    properties.add(ObjectFlagProperty<ValueChanged<double>>.has(
      'onChangeEnd',
      onChangeEnd,
    ));
    properties.add(DoubleProperty('min', min));
    properties.add(DoubleProperty('max', max));
    properties.add(IntProperty('divisions', divisions));
    properties.add(StringProperty('label', label));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(ObjectFlagProperty<SliderStyle>('style', style));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.sliderStyle?.copyWith(this.style);
    return Padding(
      padding: style?.margin ?? EdgeInsets.zero,
      child: m.Material(
        type: m.MaterialType.transparency,
        child: m.SliderTheme(
          data: m.SliderThemeData(
            showValueIndicator: m.ShowValueIndicator.always,
            thumbColor: style?.thumbColor ?? style?.activeColor,
            overlayShape: m.RoundSliderOverlayShape(overlayRadius: 0),
            thumbShape: m.RoundSliderThumbShape(
              elevation: 0,
              pressedElevation: 0,
            ),
            valueIndicatorShape: _RectangularSliderValueIndicatorShape(
              style?.labelBackgroundColor,
            ),
            trackHeight: 0.25,
            trackShape: _CustomTrackShape(),
            disabledThumbColor: style?.disabledThumbColor,
            disabledInactiveTrackColor: style?.disabledInactiveColor,
            disabledActiveTrackColor: style?.disabledActiveColor,
          ),
          child: m.Slider(
            value: value,
            max: max,
            min: min,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            onChangeStart: onChangeStart,
            activeColor: style?.activeColor,
            inactiveColor: style?.inactiveColor,
            divisions: divisions,
            mouseCursor: style?.cursor,
            label: label,
            focusNode: focusNode,
          ),
        ),
      ),
    );
  }
}

class _CustomTrackShape extends m.RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required m.SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

@immutable
class SliderStyle with Diagnosticable {
  final Color? thumbColor;
  final Color? disabledThumbColor;
  final Color? labelBackgroundColor;

  final MouseCursor? cursor;

  final Color? activeColor;
  final Color? inactiveColor;

  final Color? disabledActiveColor;
  final Color? disabledInactiveColor;

  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const SliderStyle({
    this.cursor,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.thumbColor,
    this.disabledThumbColor,
    this.activeColor,
    this.disabledActiveColor,
    this.inactiveColor,
    this.disabledInactiveColor,
    this.labelBackgroundColor,
  });

  static SliderStyle defaultTheme(Style? style) {
    final def = SliderStyle(
      thumbColor: style?.accentColor,
      activeColor: style?.accentColor,
      inactiveColor: style?.disabledColor?.withOpacity(1),
      margin: EdgeInsets.zero,
      animationDuration: style?.mediumAnimationDuration,
      animationCurve: style?.animationCurve,
      disabledActiveColor: style?.disabledColor?.withOpacity(1),
      disabledThumbColor: style?.disabledColor?.withOpacity(1),
      disabledInactiveColor: style?.disabledColor,
    );

    return def;
  }

  SliderStyle copyWith(SliderStyle? style) {
    return SliderStyle(
      margin: style?.margin ?? margin,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      thumbColor: style?.thumbColor ?? thumbColor,
      activeColor: style?.activeColor ?? activeColor,
      inactiveColor: style?.inactiveColor ?? inactiveColor,
      disabledActiveColor: style?.disabledActiveColor ?? disabledActiveColor,
      disabledInactiveColor:
          style?.disabledInactiveColor ?? disabledInactiveColor,
      disabledThumbColor: style?.disabledThumbColor ?? disabledThumbColor,
      labelBackgroundColor: style?.labelBackgroundColor ?? labelBackgroundColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties.add(DiagnosticsProperty<MouseCursor>('cursor', cursor));
    properties
        .add(DiagnosticsProperty<Curve?>('animationCurve', animationCurve));
    properties.add(
        DiagnosticsProperty<Duration?>('animationDuration', animationDuration));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(ColorProperty('disabledActiveColor', disabledActiveColor));
    properties
        .add(ColorProperty('disabledInactiveColor', disabledInactiveColor));
    properties.add(ColorProperty('disabledThumbColor', disabledThumbColor));
    properties.add(ColorProperty('labelBackgroundColor', labelBackgroundColor));
  }
}

class _RectangularSliderValueIndicatorShape extends m.SliderComponentShape {
  final Color? backgroundColor;

  /// Create a slider value indicator that resembles a rectangular tooltip.
  const _RectangularSliderValueIndicatorShape([this.backgroundColor]);

  static const _RectangularSliderValueIndicatorPathPainter _pathPainter =
      _RectangularSliderValueIndicatorPathPainter();

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    TextPainter? labelPainter,
    double? textScaleFactor,
  }) {
    assert(labelPainter != null);
    assert(textScaleFactor != null && textScaleFactor >= 0);
    return _pathPainter.getPreferredSize(labelPainter!, textScaleFactor!);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required m.SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final double scale = activationAnimation.value;
    _pathPainter.paint(
      parentBox: parentBox,
      canvas: canvas,
      center: center,
      scale: scale,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      backgroundPaintColor: backgroundColor ?? sliderTheme.valueIndicatorColor!,
    );
  }
}

class _RectangularSliderValueIndicatorPathPainter {
  const _RectangularSliderValueIndicatorPathPainter();

  static const double _triangleHeight = 8.0;
  static const double _labelPadding = 8.0;
  static const double _preferredHeight = 32.0;
  static const double _minLabelWidth = 16.0;
  static const double _bottomTipYOffset = 14.0;
  static const double _preferredHalfHeight = _preferredHeight / 2;
  static const double _upperRectRadius = 4;

  Size getPreferredSize(TextPainter labelPainter, double textScaleFactor) {
    return Size(
      _upperRectangleWidth(labelPainter, 1, textScaleFactor),
      labelPainter.height + _labelPadding,
    );
  }

  double getHorizontalShift({
    required RenderBox parentBox,
    required Offset center,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required double scale,
  }) {
    assert(!sizeWithOverflow.isEmpty);

    const double edgePadding = 8.0;
    final double rectangleWidth =
        _upperRectangleWidth(labelPainter, scale, textScaleFactor);

    /// Value indicator draws on the Overlay and by using the global Offset
    /// we are making sure we use the bounds of the Overlay instead of the Slider.
    final Offset globalCenter = parentBox.localToGlobal(center);

    // The rectangle must be shifted towards the center so that it minimizes the
    // chance of it rendering outside the bounds of the render box. If the shift
    // is negative, then the lobe is shifted from right to left, and if it is
    // positive, then the lobe is shifted from left to right.
    final double overflowLeft =
        math.max(0, rectangleWidth / 2 - globalCenter.dx + edgePadding);
    final double overflowRight = math.max(
        0,
        rectangleWidth / 2 -
            (sizeWithOverflow.width - globalCenter.dx - edgePadding));

    if (rectangleWidth < sizeWithOverflow.width) {
      return overflowLeft - overflowRight;
    } else if (overflowLeft - overflowRight > 0) {
      return overflowLeft - (edgePadding * textScaleFactor);
    } else {
      return -overflowRight + (edgePadding * textScaleFactor);
    }
  }

  double _upperRectangleWidth(
    TextPainter labelPainter,
    double scale,
    double textScaleFactor,
  ) {
    final double unscaledWidth =
        math.max(_minLabelWidth * textScaleFactor, labelPainter.width) +
            _labelPadding;
    return unscaledWidth * scale;
  }

  void paint({
    required RenderBox parentBox,
    required Canvas canvas,
    required Offset center,
    required double scale,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required Color backgroundPaintColor,
    Color? strokePaintColor,
  }) {
    if (scale == 0.0) {
      // Zero scale essentially means "do not draw anything", so it's safe to just return.
      return;
    }
    assert(!sizeWithOverflow.isEmpty);

    final double rectangleWidth = _upperRectangleWidth(
      labelPainter,
      scale,
      textScaleFactor,
    );
    final double horizontalShift = getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      scale: scale,
    );

    final double rectHeight = labelPainter.height + _labelPadding;
    final Rect upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_triangleHeight - rectHeight,
      rectangleWidth,
      rectHeight,
    );

    final Path trianglePath = Path()..close();
    final Paint fillPaint = Paint()..color = backgroundPaintColor;
    final RRect upperRRect = RRect.fromRectAndRadius(
      upperRect,
      const Radius.circular(_upperRectRadius),
    );
    trianglePath.addRRect(upperRRect);

    canvas.save();
    // Prepare the canvas for the base of the tooltip, which is relative to the
    // center of the thumb.
    canvas.translate(center.dx, center.dy - _bottomTipYOffset);
    canvas.scale(scale, scale);
    if (strokePaintColor != null) {
      final Paint strokePaint = Paint()
        ..color = strokePaintColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(trianglePath, strokePaint);
    }
    canvas.drawPath(trianglePath, fillPaint);

    // The label text is centered within the value indicator.
    final double bottomTipToUpperRectTranslateY =
        -_preferredHalfHeight / 2 - upperRect.height;
    canvas.translate(0, bottomTipToUpperRectTranslateY);
    final Offset boxCenter = Offset(horizontalShift, upperRect.height / 2);
    final Offset halfLabelPainterOffset =
        Offset(labelPainter.width / 2, labelPainter.height / 2);
    final Offset labelOffset = boxCenter - halfLabelPainterOffset;
    labelPainter.paint(canvas, labelOffset);
    canvas.restore();
  }
}
