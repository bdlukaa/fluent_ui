import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' as m;

/// A slider is a control that lets the user select from a
/// range of values by moving a thumb control along a track.
///
/// A slider is a good choice when you know that users think
/// of the value as a relative quantity, not a numeric value.
/// For example, users think about setting their audio volume
/// to low or medium—not about setting the value to 2 or 5.
///
/// ![Slider Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/slider.png)
///
/// See also:
///   - [RatingBar]
class Slider extends StatefulWidget {
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
    this.vertical = false,
    this.autofocus = false,
  })  : assert(value >= min && value <= max),
        assert(divisions == null || divisions > 0),
        super(key: key);

  /// The currently selected value for this slider.
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double min;

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double max;

  /// The number of discrete divisions.
  ///
  /// Typically used with [label] to show the current discrete value.
  ///
  /// If null, the slider is continuous.
  final int? divisions;

  /// The style used in this slider. It's mescled with [ThemeData.sliderThemeData]
  final SliderThemeData? style;

  /// A label to show above the slider, or at the left
  /// of the slider if [vertical] is `true` when the slider is active.
  final String? label;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Whether the slider is vertical or not
  ///
  /// Use a vertical slider if the slider represents a
  /// real-world value that is normally shown vertically
  /// (such as temperature).
  final bool vertical;

  @override
  _SliderState createState() => _SliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value))
      ..add(DoubleProperty('min', min))
      ..add(DoubleProperty('max', max))
      ..add(IntProperty('divisions', divisions))
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode))
      ..add(DiagnosticsProperty<SliderThemeData>('style', style))
      ..add(FlagProperty('vertical', value: vertical, ifFalse: 'horizontal'));
  }
}

class _SliderState extends m.State<Slider> {
  bool _showFocusHighlight = false;

  late FocusNode _focusNode;
  bool _sliding = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    // Only dispose the focus node manually created
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = SliderTheme.of(context).merge(widget.style);
    Widget child = HoverButton(
      onPressed: () {},
      margin: style.margin ?? EdgeInsets.zero,
      builder: (context, states) => m.Material(
        type: m.MaterialType.transparency,
        child: TweenAnimationBuilder<double>(
          duration: FluentTheme.of(context).fastAnimationDuration,
          tween: Tween<double>(
            begin: 1.0,
            end: states.isPressing || _sliding
                ? 0.45
                : states.isHovering
                    ? 0.66
                    : 0.5,
          ),
          builder: (context, innerFactor, child) => m.SliderTheme(
            data: m.SliderThemeData(
              showValueIndicator: m.ShowValueIndicator.always,
              thumbColor: style.thumbColor ?? style.activeColor,
              overlayShape: const m.RoundSliderOverlayShape(overlayRadius: 0),
              thumbShape: SliderThumbShape(
                elevation: 0,
                pressedElevation: 0,
                useBall: style.useThumbBall ?? true,
                innerFactor: innerFactor,
                brightness: FluentTheme.of(context).brightness,
              ),
              valueIndicatorShape: _RectangularSliderValueIndicatorShape(
                backgroundColor: style.labelBackgroundColor,
                vertical: widget.vertical,
              ),
              trackHeight: 1.75,
              trackShape: _CustomTrackShape(),
              disabledThumbColor: style.disabledThumbColor,
              disabledInactiveTrackColor: style.disabledInactiveColor,
              disabledActiveTrackColor: style.disabledActiveColor,
            ),
            child: child!,
          ),
          child: m.Slider(
            value: widget.value,
            max: widget.max,
            min: widget.min,
            onChanged: widget.onChanged,
            onChangeEnd: (v) {
              widget.onChangeEnd?.call(v);
              setState(() => _sliding = false);
            },
            onChangeStart: (v) {
              widget.onChangeStart?.call(v);
              setState(() => _sliding = true);
            },
            activeColor: style.activeColor,
            inactiveColor: style.inactiveColor,
            divisions: widget.divisions,
            label: widget.label,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            mouseCursor: MouseCursor.defer,
          ),
        ),
      ),
    );
    child = FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _showFocusHighlight = v),
      child: FocusBorder(
        focused: _showFocusHighlight && (_focusNode.hasPrimaryFocus),
        useStackApproach: true,
        child: child,
      ),
    );
    if (widget.vertical) {
      return RotatedBox(
        quarterTurns: 3,
        child: child,
      );
    }
    return child;
  }
}

/// This is used to remove the padding the Material Slider adds automatically
class _CustomTrackShape extends m.RoundedRectSliderTrackShape {
  @override
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

/// The default shape of a [Slider]'s thumb.
///
/// There is a shadow for the resting, pressed, hovered, and focused state.
class SliderThumbShape extends m.SliderComponentShape {
  /// Create a fluent-styled slider thumb;
  const SliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
    this.useBall = true,
    this.innerFactor = 1.0,
    this.brightness = Brightness.light,
  });

  final double innerFactor;

  final Brightness brightness;

  /// Whether to draw a ball instead of a line
  final bool useBall;

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
  final double? disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  /// The resting elevation adds shadow to the unpressed thumb.
  ///
  /// The default is 1.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  ///
  final double elevation;

  /// The pressed elevation adds shadow to the pressed thumb.
  ///
  /// The default is 6.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
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
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double radius = radiusTween.evaluate(enableAnimation);

    if (!useBall) {
      canvas.drawLine(
        center - const Offset(0, 6),
        center + const Offset(0, 6),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 8.0,
      );
    } else {
      final Tween<double> elevationTween = Tween<double>(
        begin: elevation,
        end: pressedElevation,
      );
      final double evaluatedElevation =
          elevationTween.evaluate(activationAnimation);
      final Path path = Path()
        ..addArc(
            Rect.fromCenter(
                center: center, width: 2 * radius, height: 2 * radius),
            0,
            math.pi * 2);
      canvas.drawShadow(path, Colors.black, evaluatedElevation, true);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF454545),
      );
      canvas.drawCircle(
        center,
        radius * innerFactor,
        Paint()..color = color,
      );
    }
  }
}

/// An inherited widget that defines the configuration for
/// [Slider]s in this widget's subtree.
///
/// Values specified here are used for [Slider] properties that are not
/// given an explicit non-null value.
class SliderTheme extends InheritedTheme {
  /// Creates a slider theme that controls the configurations for
  /// [Slider].
  const SliderTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Slider] widgets.
  final SliderThemeData data;

  /// Creates a button theme that controls how descendant [Slider]s should
  /// look like, and merges in the current slider theme, if any.
  static Widget merge({
    Key? key,
    required SliderThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return SliderTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static SliderThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<SliderTheme>();
    return theme?.data ?? FluentTheme.of(context).sliderTheme;
  }

  /// Returns the [data] from the closest [SliderTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.sliderTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SliderThemeData theme = SliderTheme.of(context);
  /// ```
  static SliderThemeData of(BuildContext context) {
    return SliderThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SliderTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SliderTheme oldWidget) => data != oldWidget.data;
}

@immutable
class SliderThemeData with Diagnosticable {
  final Color? thumbColor;
  final Color? disabledThumbColor;
  final Color? labelBackgroundColor;

  final bool? useThumbBall;

  final Color? activeColor;
  final Color? inactiveColor;

  final Color? disabledActiveColor;
  final Color? disabledInactiveColor;

  final EdgeInsetsGeometry? margin;

  const SliderThemeData({
    this.margin,
    this.thumbColor,
    this.disabledThumbColor,
    this.activeColor,
    this.disabledActiveColor,
    this.inactiveColor,
    this.disabledInactiveColor,
    this.labelBackgroundColor,
    this.useThumbBall,
  });

  factory SliderThemeData.standard(ThemeData? style) {
    final def = SliderThemeData(
      thumbColor: style?.accentColor,
      activeColor: style?.accentColor,
      inactiveColor: style?.disabledColor.withOpacity(1),
      margin: EdgeInsets.zero,
      disabledActiveColor: style?.disabledColor.withOpacity(1),
      disabledThumbColor: style?.disabledColor.withOpacity(1),
      disabledInactiveColor: style?.disabledColor,
      useThumbBall: true,
    );

    return def;
  }

  static SliderThemeData lerp(
      SliderThemeData? a, SliderThemeData? b, double t) {
    return SliderThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      thumbColor: Color.lerp(a?.thumbColor, b?.thumbColor, t),
      activeColor: Color.lerp(a?.activeColor, b?.activeColor, t),
      inactiveColor: Color.lerp(a?.inactiveColor, b?.inactiveColor, t),
      disabledActiveColor:
          Color.lerp(a?.disabledActiveColor, b?.disabledActiveColor, t),
      disabledInactiveColor:
          Color.lerp(a?.disabledInactiveColor, b?.disabledInactiveColor, t),
      disabledThumbColor:
          Color.lerp(a?.disabledThumbColor, b?.disabledThumbColor, t),
      labelBackgroundColor:
          Color.lerp(a?.labelBackgroundColor, b?.labelBackgroundColor, t),
      useThumbBall: t < 0.5 ? a?.useThumbBall : b?.useThumbBall,
    );
  }

  SliderThemeData merge(SliderThemeData? style) {
    return SliderThemeData(
      margin: style?.margin ?? margin,
      thumbColor: style?.thumbColor ?? thumbColor,
      activeColor: style?.activeColor ?? activeColor,
      inactiveColor: style?.inactiveColor ?? inactiveColor,
      disabledActiveColor: style?.disabledActiveColor ?? disabledActiveColor,
      disabledInactiveColor:
          style?.disabledInactiveColor ?? disabledInactiveColor,
      disabledThumbColor: style?.disabledThumbColor ?? disabledThumbColor,
      labelBackgroundColor: style?.labelBackgroundColor ?? labelBackgroundColor,
      useThumbBall: style?.useThumbBall ?? useThumbBall,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
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
  final bool vertical;

  /// Create a slider value indicator that resembles a rectangular tooltip.
  const _RectangularSliderValueIndicatorShape({
    this.backgroundColor,
    this.vertical = false,
  });

  get _pathPainter => _RectangularSliderValueIndicatorPathPainter(vertical);

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
  final bool vertical;

  const _RectangularSliderValueIndicatorPathPainter([this.vertical = false]);

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
    const verticalFactor = 20;
    canvas.translate(
      center.dx + (vertical ? -verticalFactor : 0),
      center.dy - _bottomTipYOffset + (vertical ? -verticalFactor : 0),
    );
    canvas.scale(scale, scale);
    // Rotate the label if it's vertical
    if (vertical) canvas.rotate(math.pi / 2);
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
