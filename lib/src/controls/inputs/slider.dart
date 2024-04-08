import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/rendering.dart';

/// A slider is a control that lets the user select from a range of values by
/// moving a thumb control along a track.
///
/// A slider is a good choice when you know that users think of the value as a
/// relative quantity, not a numeric value. For example, users think about
/// setting their audio volume to low or medium — not about setting the value to
/// 2 or 5.
///
/// ![Slider Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls/slider.png)
///
/// See also:
///
///   * [RatingBar], that allows users to view and set ratings
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/slider>
class Slider extends StatefulWidget {
  /// Creates a fluent-styled slider.
  const Slider({
    super.key,
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
    this.mouseCursor = MouseCursor.defer,
  })  : assert(value >= min && value <= max),
        assert(divisions == null || divisions > 0);

  /// The currently selected value for this slider.
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  ///
  /// The slider passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// value.
  ///
  /// If null, the slider will be displayed as disabled.
  ///
  /// The callback provided to onChanged should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when the user starts
  ///    changing the value.
  ///  * [onChangeEnd] for a callback that is called when the user stops
  ///    changing the value.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts selecting a new value for the slider.
  ///
  /// This callback shouldn't be used to update the slider [value] (use
  /// [onChanged] for that), but rather to be notified when the user has started
  /// selecting a new value by starting a drag or with a tap.
  ///
  /// The value passed will be the last [value] that the slider had before the
  /// change began.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeStart: (double startValue) {
  ///     print('Started change at $startValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeEnd] for a callback that is called when the value change is
  ///    complete.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider.
  ///
  /// This callback shouldn't be used to update the slider [value] (use
  /// [onChanged] for that), but rather to know when the user has completed
  /// selecting a new [value] by ending a drag or a click.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  ///   onChangeEnd: (double newValue) {
  ///     print('Ended change on $newValue');
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when a value change
  ///    begins.
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

  /// The style used in this slider.
  ///
  /// If provided, it's merged with [FluentThemeData.sliderTheme]. If not,
  /// the theme slider theme is used.
  ///
  /// See also:
  ///
  ///   * [SliderTheme] and [SliderThemeData], which define the style for a
  ///     slider.
  final SliderThemeData? style;

  /// A label to show close to the slider.
  ///
  /// It is displayed above the slider if [vertical] is false, and at the left
  /// of the slider if [vertical] is true.
  ///
  /// It is only shown if the slider is active.
  final String? label;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Whether the slider is vertical or not.
  ///
  /// Use a vertical slider if the slider represents a real-world value that is
  /// normally shown vertically (such as temperature).
  final bool vertical;

  /// {@macro fluent_ui.controls.inputs.HoverButton.mouseCursor}
  final MouseCursor mouseCursor;

  @override
  State<Slider> createState() => _SliderState();

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

class _SliderState extends State<Slider> {
  final materialSliderKey = GlobalKey<State<m.Slider>>();

  late FocusNode _focusNode;
  bool _sliding = false;
  bool _showFocusHighlight = false;

  static const showLabelDuration = Duration(milliseconds: 400);
  Timer? _overlayTimer;

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
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _showLabelOverlay() {
    final sliderState = materialSliderKey.currentState as dynamic;
    sliderState.showValueIndicator();
    (sliderState.overlayController as AnimationController).forward();
    (sliderState.valueIndicatorController as AnimationController).forward();
  }

  void _hideLabelOverlay() {
    final sliderState = materialSliderKey.currentState as dynamic;
    (sliderState.overlayController as AnimationController).reverse();
    (sliderState.valueIndicatorController as AnimationController).reverse();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    final style = SliderTheme.of(context).merge(widget.style);
    final direction = Directionality.of(context);

    final disabledState = {ButtonStates.disabled};
    Widget child = HoverButton(
      onPressed: widget.onChanged == null ? null : () {},
      margin: style.margin ?? EdgeInsets.zero,
      cursor: widget.mouseCursor,
      builder: (context, states) => m.Material(
        type: m.MaterialType.transparency,
        child: TweenAnimationBuilder<double>(
          duration: theme.fastAnimationDuration,
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
              thumbColor: style.thumbColor?.resolve(states),
              overlayShape: const m.RoundSliderOverlayShape(overlayRadius: 0),
              valueIndicatorTextStyle: TextStyle(
                color: style.labelForegroundColor,
              ),
              thumbShape: SliderThumbShape(
                pressedElevation: 1.0,
                useBall: style.useThumbBall ?? true,
                innerFactor: innerFactor,
                borderColor: theme.resources.controlSolidFillColorDefault,
                enabledThumbRadius: style.thumbRadius?.resolve(states) ?? 10.0,
                disabledThumbRadius: style.thumbRadius?.resolve(states),
              ),
              valueIndicatorShape: _RectangularSliderValueIndicatorShape(
                strokeColor: style.labelBackgroundColor,
                backgroundColor: style.labelBackgroundColor,
                vertical: widget.vertical,
                ltr: direction == TextDirection.ltr,
              ),
              trackHeight: style.trackHeight?.resolve(states),
              trackShape: _CustomTrackShape(),
              disabledThumbColor: style.thumbColor?.resolve(disabledState),
              disabledInactiveTrackColor:
                  style.inactiveColor?.resolve(disabledState),
              disabledActiveTrackColor:
                  style.activeColor?.resolve(disabledState),
            ),
            child: child!,
          ),
          child: m.Slider(
            key: materialSliderKey,
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
            activeColor: style.activeColor?.resolve(states),
            inactiveColor: style.inactiveColor?.resolve(states),
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
        child: child,
      ),
    );
    child = MouseRegion(
      onEnter: (event) {
        _overlayTimer = Timer(showLabelDuration, _showLabelOverlay);
      },
      onExit: (event) {
        _overlayTimer?.cancel();
        _overlayTimer = null;
        _hideLabelOverlay();
      },
      child: child,
    );
    if (widget.vertical) {
      return RotatedBox(
        quarterTurns: direction == TextDirection.ltr ? 3 : 5,
        child: child,
      );
    }
    return child;
  }
}

/// This is used to remove the padding the Material Slider adds automatically
class _CustomTrackShape extends m.RoundedRectSliderTrackShape {
  static const double _trackSidePadding = 10.0;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required m.SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight!;
    final trackLeft = offset.dx + _trackSidePadding;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - (2 * _trackSidePadding);
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required m.SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    return super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );
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
    this.borderColor = Colors.transparent,
  });

  final double innerFactor;

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

  final Color borderColor;

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

    final canvas = context.canvas;
    final radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final color = colorTween.evaluate(enableAnimation)!;
    final radius = radiusTween.evaluate(enableAnimation);

    if (!useBall) {
      canvas.drawLine(
        center - const Offset(0, 6),
        center + const Offset(0, 6),
        Paint()
          ..color = color.withOpacity(activationAnimation.value)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 8.0,
      );
    } else {
      final elevationTween = Tween<double>(
        begin: elevation,
        end: pressedElevation,
      );
      final evaluatedElevation = elevationTween.evaluate(activationAnimation);
      final path = Path()
        ..addArc(
            Rect.fromCenter(
                center: center, width: 2 * radius, height: 2 * radius),
            0,
            math.pi * 2);
      canvas
        ..drawShadow(path, Colors.black, evaluatedElevation, true)
        ..drawCircle(
          center,
          radius,
          Paint()..color = borderColor,
        )
        ..drawCircle(
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
    super.key,
    required this.data,
    required super.child,
  });

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
  /// no ancestor, it returns [FluentThemeData.sliderTheme]. Applications can assume
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
  final ButtonState<Color?>? thumbColor;
  final ButtonState<double?>? thumbRadius;
  final ButtonState<double?>? trackHeight;

  /// The color of the label background
  final Color? labelBackgroundColor;

  /// The color of the label text
  final Color? labelForegroundColor;

  final bool? useThumbBall;

  final ButtonState<Color?>? activeColor;
  final ButtonState<Color?>? inactiveColor;

  final EdgeInsetsGeometry? margin;

  const SliderThemeData({
    this.margin,
    this.thumbColor,
    this.thumbRadius,
    this.trackHeight,
    this.activeColor,
    this.inactiveColor,
    this.labelBackgroundColor,
    this.labelForegroundColor,
    this.useThumbBall,
  });

  factory SliderThemeData.standard(FluentThemeData theme) {
    final def = SliderThemeData(
      thumbColor: ButtonState.resolveWith(
        (states) => ButtonThemeData.checkedInputColor(theme, states),
      ),
      activeColor: ButtonState.resolveWith(
        (states) => ButtonThemeData.checkedInputColor(theme, states),
      ),
      inactiveColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlStrongFillColorDisabled;
        } else {
          return theme.resources.controlStrongFillColorDefault;
        }
      }),
      margin: EdgeInsets.zero,
      useThumbBall: true,
      labelBackgroundColor: theme.resources.controlSolidFillColorDefault,
      labelForegroundColor: theme.resources.textFillColorPrimary,
      trackHeight: ButtonState.all(3.75),
    );

    return def;
  }

  static SliderThemeData lerp(SliderThemeData a, SliderThemeData b, double t) {
    return SliderThemeData(
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
      thumbColor: ButtonState.lerp(a.thumbColor, b.thumbColor, t, Color.lerp),
      thumbRadius:
          ButtonState.lerp(a.thumbRadius, b.thumbRadius, t, lerpDouble),
      trackHeight:
          ButtonState.lerp(a.trackHeight, b.trackHeight, t, lerpDouble),
      activeColor:
          ButtonState.lerp(a.activeColor, b.activeColor, t, Color.lerp),
      inactiveColor:
          ButtonState.lerp(a.inactiveColor, b.inactiveColor, t, Color.lerp),
      labelBackgroundColor:
          Color.lerp(a.labelBackgroundColor, b.labelBackgroundColor, t),
      labelForegroundColor:
          Color.lerp(a.labelForegroundColor, b.labelForegroundColor, t),
      useThumbBall: t < 0.5 ? a.useThumbBall : b.useThumbBall,
    );
  }

  SliderThemeData merge(SliderThemeData? style) {
    return SliderThemeData(
      margin: style?.margin ?? margin,
      thumbColor: style?.thumbColor ?? thumbColor,
      thumbRadius: style?.thumbRadius ?? thumbRadius,
      activeColor: style?.activeColor ?? activeColor,
      inactiveColor: style?.inactiveColor ?? inactiveColor,
      labelBackgroundColor: style?.labelBackgroundColor ?? labelBackgroundColor,
      labelForegroundColor: style?.labelForegroundColor ?? labelForegroundColor,
      useThumbBall: style?.useThumbBall ?? useThumbBall,
      trackHeight: style?.trackHeight ?? trackHeight,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin))
      ..add(DiagnosticsProperty('thumbColor', thumbColor))
      ..add(DiagnosticsProperty('activeColor', activeColor))
      ..add(DiagnosticsProperty('inactiveColor', inactiveColor))
      ..add(ColorProperty('labelBackgroundColor', labelBackgroundColor))
      ..add(ColorProperty('labelForegroundColor', labelForegroundColor));
  }
}

class _RectangularSliderValueIndicatorShape extends m.SliderComponentShape {
  final Color? backgroundColor;
  final Color? strokeColor;
  final bool vertical;
  final bool ltr;

  /// Create a slider value indicator that resembles a rectangular tooltip.
  const _RectangularSliderValueIndicatorShape({
    this.backgroundColor,
    this.strokeColor,
    this.vertical = false,
    this.ltr = false,
  });

  _RectangularSliderValueIndicatorPathPainter get _pathPainter =>
      _RectangularSliderValueIndicatorPathPainter(
        vertical,
        ltr,
      );

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
    final canvas = context.canvas;
    final scale = activationAnimation.value;
    _pathPainter.paint(
      parentBox: parentBox,
      canvas: canvas,
      center: center,
      scale: scale,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      backgroundPaintColor: backgroundColor ?? sliderTheme.valueIndicatorColor!,
      strokePaintColor: strokeColor,
    );
  }
}

class _RectangularSliderValueIndicatorPathPainter {
  final bool vertical;

  /// Whether the current [Directionality] is [TextDirection.ltr]
  final bool ltr;

  const _RectangularSliderValueIndicatorPathPainter([
    this.vertical = false,
    this.ltr = false,
  ]);

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

    const edgePadding = 8.0;
    final rectangleWidth =
        _upperRectangleWidth(labelPainter, scale, textScaleFactor);

    /// Value indicator draws on the Overlay and by using the global Offset
    /// we are making sure we use the bounds of the Overlay instead of the Slider.
    final globalCenter = parentBox.localToGlobal(center);

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
    final unscaledWidth =
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

    final opacity = scale;
    // the animation should not scale, only fade
    scale = 1.0;

    final rectangleWidth = _upperRectangleWidth(
      labelPainter,
      scale,
      textScaleFactor,
    );
    final horizontalShift = getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      scale: scale,
    );

    final rectHeight = labelPainter.height + _labelPadding;
    final upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_triangleHeight - rectHeight,
      rectangleWidth,
      rectHeight,
    );

    final trianglePath = Path()..close();
    final fillPaint = Paint()
      ..color = backgroundPaintColor.withOpacity(opacity);
    final upperRRect = RRect.fromRectAndRadius(
      upperRect,
      const Radius.circular(_upperRectRadius),
    );
    trianglePath.addRRect(upperRRect);
    canvas.save();
    // Prepare the canvas for the base of the tooltip, which is relative to the
    // center of the thumb.
    final verticalFactor = ltr ? 20.0 : 10.0;
    canvas
      ..translate(
        center.dx +
            (vertical
                ? ltr
                    ? -verticalFactor
                    : verticalFactor * 2
                : 0),
        center.dy -
            _bottomTipYOffset +
            (vertical
                ? ltr
                    ? -verticalFactor
                    : -verticalFactor * 2
                : 0),
      )
      ..scale(scale, scale);
    // Rotate the label if it's vertical
    if (vertical) canvas.rotate((ltr ? 1 : -1) * math.pi / 2);
    if (strokePaintColor != null) {
      final strokePaint = Paint()
        ..color = strokePaintColor.withOpacity(opacity)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(trianglePath, strokePaint);
    }
    canvas.drawPath(trianglePath, fillPaint);

    // The label text is centered within the value indicator.
    final bottomTipToUpperRectTranslateY =
        -_preferredHalfHeight / 2 - upperRect.height;
    canvas.translate(0, bottomTipToUpperRectTranslateY);
    final boxCenter = Offset(horizontalShift, upperRect.height / 2);
    final halfLabelPainterOffset =
        Offset(labelPainter.width / 2, labelPainter.height / 2);
    final labelOffset = boxCenter - halfLabelPainterOffset;

    final span = labelPainter.text as TextSpan;
    labelPainter
      ..text = TextSpan(
        text: span.text,
        style: span.style
            ?.copyWith(color: span.style?.color?.withOpacity(opacity)),
      )
      ..paint(canvas, labelOffset);

    canvas.restore();
  }
}
