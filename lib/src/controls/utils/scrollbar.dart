import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// {@macro flutter.widgets.Scrollbar}
class Scrollbar extends RawScrollbar {
  /// Creates a fluent-styled scrollbar that wraps the given [child].
  ///
  /// The [child], or a descendant of the [child], should be a
  /// source of [ScrollNotification] notifications, typically a
  /// [Scrollable] widget.
  ///
  /// The [child], [fadeDuration], and [timeToFade] arguments must not be null.
  const Scrollbar({
    Key? key,
    required Widget child,
    ScrollController? controller,
    bool thumbVisibility = true,
    this.style,
    Duration fadeDuration = const Duration(milliseconds: 300),
    Duration timeToFade = const Duration(milliseconds: 600),
  }) : super(
          key: key,
          child: child,
          thumbVisibility: thumbVisibility,
          controller: controller,
          timeToFade: timeToFade,
          fadeDuration: fadeDuration,
        );

  /// The style applied to the scroll bar. If non-null, it's mescled
  /// with [ThemeData.scrollbarThemeData]
  final ScrollbarThemeData? style;

  @override
  _ScrollbarState createState() => _ScrollbarState();
}

class _ScrollbarState extends RawScrollbarState<Scrollbar> {
  late AnimationController _hoverController;
  late ScrollbarThemeData _scrollbarTheme;
  bool _dragIsActive = false;
  bool _hoverIsActive = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _hoverController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void didChangeDependencies() {
    assert(debugCheckHasFluentTheme(context));
    _scrollbarTheme = ScrollbarTheme.of(context).merge(widget.style);
    _hoverController.duration = _scrollbarTheme.animationDuration ??
        FluentTheme.of(context).fasterAnimationDuration;
    super.didChangeDependencies();
  }

  ButtonStates get _currentState {
    if (_dragIsActive) {
      return ButtonStates.pressing;
    } else if (_hoverIsActive) {
      return ButtonStates.hovering;
    } else {
      return ButtonStates.none;
    }
  }

  Color _trackColor(ButtonStates state) {
    // if (state == ButtonStates.hovering || state == ButtonStates.pressing) {
    //   return _scrollbarTheme.backgroundColor ?? Colors.transparent;
    // }
    return Colors.transparent;
  }

  Color _thumbColor(ButtonStates state) {
    Color? color;
    if (state == ButtonStates.pressing) {
      color = _scrollbarTheme.scrollbarPressingColor;
    }
    color ??= _scrollbarTheme.scrollbarColor ?? Colors.transparent;
    return color;
  }

  @override
  void updateScrollbarPainter() {
    assert(debugCheckHasDirectionality(context));
    final animation = CurvedAnimation(
      parent: _hoverController,
      curve: _scrollbarTheme.animationCurve ?? Curves.linear,
    );
    scrollbarPainter
      ..color = _thumbColor(_currentState)
      ..trackColor = _trackColor(_currentState)
      ..trackBorderColor = Color.lerp(
            _scrollbarTheme.trackBorderColor,
            _scrollbarTheme.hoveringTrackBorderColor,
            animation.value,
          ) ??
          Colors.transparent
      ..textDirection = Directionality.of(context)
      ..thickness = Tween<double>(
        begin: _scrollbarTheme.thickness ?? 2.0,
        end: _scrollbarTheme.hoveringThickness ?? 16.0,
      ).evaluate(animation)
      ..radius = _hoverController.status != AnimationStatus.dismissed
          ? _scrollbarTheme.hoveringRadius
          : _scrollbarTheme.radius
      ..crossAxisMargin = Tween<double>(
        begin: _scrollbarTheme.crossAxisMargin ?? 2.0,
        end: _scrollbarTheme.hoveringCrossAxisMargin ?? 0.0,
      ).evaluate(animation)
      ..mainAxisMargin = Tween<double>(
        begin: _scrollbarTheme.mainAxisMargin ?? 6.0,
        end: _scrollbarTheme.hoveringMainAxisMargin ?? 0.0,
      ).evaluate(animation)
      ..minLength = _scrollbarTheme.minThumbLength ?? 48.0
      ..padding = MediaQuery.of(context).padding;
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    if (mounted) {
      setState(() {
        _dragIsActive = true;
      });
    }
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    if (mounted) {
      setState(() {
        _dragIsActive = false;
      });
    }
  }

  @override
  void handleHover(PointerHoverEvent event) async {
    super.handleHover(event);
    // Check if the position of the pointer falls over the painted scrollbar
    if (isPointerOverScrollbar(event.position, event.kind)) {
      // Pointer is hovering over the scrollbar
      if (mounted) {
        setState(() {
          _hoverIsActive = true;
        });
      }
      _hoverController.forward();
    } else if (_hoverIsActive) {
      await _hoverController.reverse();
      // Pointer was, but is no longer over painted scrollbar.
      if (mounted) {
        setState(() {
          _hoverIsActive = false;
        });
      }
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    if (mounted) {
      setState(() {
        _hoverIsActive = false;
      });
    }
    _hoverController.reverse();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }
}

/// An inherited widget that defines the configuration for
/// [Scrollbar]s in this widget's subtree.
///
/// Values specified here are used for [Scrollbar] properties that are not
/// given an explicit non-null value.
class ScrollbarTheme extends InheritedTheme {
  /// Creates a scrollbar theme that controls the configurations for
  /// [Scrollbar].
  const ScrollbarTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Scrollbar] widgets.
  final ScrollbarThemeData data;

  /// Creates a button theme that controls how descendant [Scrollbar]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required ScrollbarThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ScrollbarTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static ScrollbarThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ScrollbarTheme>();
    return theme?.data ?? FluentTheme.of(context).scrollbarTheme;
  }

  /// Returns the [data] from the closest [ScrollbarTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.scrollbarTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ScrollbarThemeData theme = ScrollbarTheme.of(context);
  /// ```
  static ScrollbarThemeData of(BuildContext context) {
    return ScrollbarThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ScrollbarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ScrollbarTheme oldWidget) => data != oldWidget.data;
}

@immutable
class ScrollbarThemeData with Diagnosticable {
  /// Thickness of the scrollbar in its cross-axis in logical
  /// pixels. If null, `2.0` is used
  final double? thickness;

  /// Thickness of the scrollbar in its cross-axis in logical
  /// pixels when the user is hovering or pressing it. If null,
  /// `16.0` is used
  final double? hoveringThickness;

  /// The background color of the scrollbar when the user is
  /// hovering or pressing it. If null, `Color(0xFFe9e9e9)` is
  /// used for light theme and `Color(0xFF1b1b1b)` is used for
  /// dark theme.
  final Color? backgroundColor;

  /// The color of the scrollbar thumb on its default state. If
  /// null, `Color(0xFF8c8c8c)` is used for light theme and
  /// `Color(0xFF767676)` is used for dark theme.
  final Color? scrollbarColor;

  /// The color of the scrollbar thumb when the user is hovering
  /// or pressing it. If null, `const Color(0xFF5d5d5d)` is used
  /// for light theme and `Color(0xFFa4a4a4)` is used for dark
  /// theme by default.
  final Color? scrollbarPressingColor;

  /// The default radius of the scrollbar. Defaults to
  /// `Radius.circular(100.0)`
  final Radius? radius;

  /// The radius of the scrollbar when the user is hovering or
  /// pressing. Defaults to `Radius.circular(0.0)`
  final Radius? hoveringRadius;

  /// Distance from the scrollbar's start and end to the edge of
  /// the viewport in logical pixels. It affects the amount of
  /// available paint area. Defaults to `2.0`
  final double? mainAxisMargin;

  /// Distance from the scrollbar's start and end to the edge of
  /// the viewport in logical pixels. It affects the amount of
  /// available paint area. Defaults to `0.0`
  final double? hoveringMainAxisMargin;

  /// Distance from the scrollbar's side to the nearest edge in
  /// logical pixels. Defaults to `0.0`
  final double? crossAxisMargin;

  /// Distance from the scrollbar's side to the nearest edge in
  /// logical pixels when the user is hovering or pressing.
  /// Defaults to `2.0`
  final double? hoveringCrossAxisMargin;

  /// Sets the preferred smallest size the scrollbar can shrink
  /// to when the total scrollable extent is large, the current
  /// visible viewport is small, and the viewport is not overscrolled.
  /// Defaults to `48.0`
  final double? minThumbLength;

  /// [Color] of the track border. Defaults to [Colors.transparent]
  final Color? trackBorderColor;

  /// [Color] of the track border when the user is hovering or pressing.
  /// Defaults to [Colors.transparent]
  final Color? hoveringTrackBorderColor;

  /// The duration of the animation. Defaults to [ThemeData.fasterAnimationDuration].
  /// To disable the animation, set this to [Duration.zero]
  final Duration? animationDuration;

  /// The curve used during the animation. Defaults to [ThemeData.animationCurve]
  final Curve? animationCurve;

  const ScrollbarThemeData({
    this.thickness,
    this.hoveringThickness,
    this.backgroundColor,
    this.scrollbarColor,
    this.scrollbarPressingColor,
    this.radius,
    this.hoveringRadius,
    this.mainAxisMargin,
    this.hoveringMainAxisMargin,
    this.crossAxisMargin,
    this.hoveringCrossAxisMargin,
    this.minThumbLength,
    this.trackBorderColor,
    this.hoveringTrackBorderColor,
    this.animationDuration,
    this.animationCurve,
  });

  factory ScrollbarThemeData.standard(ThemeData style) {
    final brightness = style.brightness;
    return ScrollbarThemeData(
      scrollbarColor: brightness.isLight
          ? const Color(0xFF8c8c8c)
          : const Color(0xFF767676),
      scrollbarPressingColor: brightness.isLight
          ? const Color(0xFF5d5d5d)
          : const Color(0xFFa4a4a4),
      thickness: 2.0,
      hoveringThickness: 6.0,
      backgroundColor: brightness.isLight
          ? const Color(0xFFf9f9f9)
          : const Color(0xFF2c2f2a),
      radius: const Radius.circular(100.0),
      hoveringRadius: const Radius.circular(100.0),
      crossAxisMargin: 4.0,
      hoveringCrossAxisMargin: 4.0,
      mainAxisMargin: 2.0,
      hoveringMainAxisMargin: 2.0,
      minThumbLength: 48.0,
      trackBorderColor: Colors.transparent,
      hoveringTrackBorderColor: Colors.transparent,
      animationDuration: style.fasterAnimationDuration,
      animationCurve: Curves.linear,
    );
  }

  static ScrollbarThemeData lerp(
      ScrollbarThemeData? a, ScrollbarThemeData? b, double t) {
    return ScrollbarThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      scrollbarColor: Color.lerp(a?.scrollbarColor, b?.scrollbarColor, t),
      scrollbarPressingColor:
          Color.lerp(a?.scrollbarPressingColor, b?.scrollbarPressingColor, t),
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      hoveringThickness:
          lerpDouble(a?.hoveringThickness, b?.hoveringThickness, t),
      radius: Radius.lerp(a?.radius, b?.radius, t),
      hoveringRadius: Radius.lerp(a?.hoveringRadius, b?.hoveringRadius, t),
      crossAxisMargin: lerpDouble(a?.crossAxisMargin, b?.crossAxisMargin, t),
      hoveringCrossAxisMargin:
          lerpDouble(a?.hoveringCrossAxisMargin, b?.hoveringCrossAxisMargin, t),
      mainAxisMargin: lerpDouble(a?.mainAxisMargin, b?.mainAxisMargin, t),
      hoveringMainAxisMargin:
          lerpDouble(a?.hoveringMainAxisMargin, b?.hoveringMainAxisMargin, t),
      minThumbLength: lerpDouble(a?.minThumbLength, b?.minThumbLength, t),
      trackBorderColor: Color.lerp(a?.trackBorderColor, b?.trackBorderColor, t),
      hoveringTrackBorderColor: Color.lerp(
          a?.hoveringTrackBorderColor, b?.hoveringTrackBorderColor, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(a?.animationDuration ?? Duration.zero,
          b?.animationDuration ?? Duration.zero, t),
    );
  }

  ScrollbarThemeData merge(ScrollbarThemeData? style) {
    if (style == null) return this;
    return ScrollbarThemeData(
      backgroundColor: style.backgroundColor ?? backgroundColor,
      scrollbarColor: style.scrollbarColor ?? scrollbarColor,
      scrollbarPressingColor:
          style.scrollbarPressingColor ?? scrollbarPressingColor,
      hoveringThickness: style.hoveringThickness ?? hoveringThickness,
      thickness: style.thickness ?? thickness,
      radius: style.radius ?? radius,
      hoveringRadius: style.hoveringRadius ?? hoveringRadius,
      crossAxisMargin: style.crossAxisMargin ?? crossAxisMargin,
      hoveringCrossAxisMargin:
          style.hoveringCrossAxisMargin ?? hoveringCrossAxisMargin,
      mainAxisMargin: style.mainAxisMargin ?? mainAxisMargin,
      hoveringMainAxisMargin:
          style.hoveringMainAxisMargin ?? hoveringMainAxisMargin,
      minThumbLength: style.minThumbLength ?? minThumbLength,
      hoveringTrackBorderColor:
          style.hoveringTrackBorderColor ?? hoveringTrackBorderColor,
      trackBorderColor: style.trackBorderColor ?? trackBorderColor,
      animationCurve: style.animationCurve ?? animationCurve,
      animationDuration: style.animationDuration ?? animationDuration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('scrollbarColor', scrollbarColor));
    properties.add(
      ColorProperty('scrollbarPressingColor', scrollbarPressingColor),
    );
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DoubleProperty('thickness', thickness, defaultValue: 2.0));
    properties.add(DoubleProperty(
      'hoveringThickness',
      hoveringThickness,
      defaultValue: 16.0,
    ));
    properties.add(DiagnosticsProperty<Radius>(
      'radius',
      radius,
      defaultValue: const Radius.circular(100),
    ));
    properties.add(DiagnosticsProperty<Radius>(
      'hoveringRadius',
      hoveringRadius,
      defaultValue: Radius.zero,
    ));
    properties.add(
      DoubleProperty('mainAxisMargin', mainAxisMargin, defaultValue: 2.0),
    );
    properties.add(DoubleProperty(
      'hoveringMainAxisMargin',
      hoveringMainAxisMargin,
      defaultValue: 0.0,
    ));
    properties.add(
      DoubleProperty('crossAxisMargin', mainAxisMargin, defaultValue: 2.0),
    );
    properties.add(DoubleProperty(
      'hoveringCrossAxisMargin',
      hoveringMainAxisMargin,
      defaultValue: 0.0,
    ));
    properties.add(
      DoubleProperty('minThumbLength', minThumbLength, defaultValue: 48.0),
    );
    properties.add(ColorProperty('trackBorderColor', trackBorderColor));
    properties.add(
      ColorProperty('hoveringTrackBorderColor', hoveringTrackBorderColor),
    );
    properties.add(DiagnosticsProperty<Duration>(
      'animationDuration',
      animationDuration,
      defaultValue: const Duration(milliseconds: 90),
    ));
    properties.add(DiagnosticsProperty<Curve>(
      'animationCurve',
      animationCurve,
      defaultValue: Curves.linear,
    ));
  }
}
