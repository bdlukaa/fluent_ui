import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// {@macro flutter.widgets.Scrollbar}
class Scrollbar extends RawScrollbar {
  /// Creates a windows-styled scrollbar that wraps the given [child].
  ///
  /// The [child], or a descendant of the [child], should be a source of
  /// [ScrollNotification] notifications, typically a [Scrollable] widget.
  ///
  /// The [child], [fadeDuration], [pressDuration], and [timeToFade] arguments
  /// must not be null.
  const Scrollbar({
    required super.child,
    super.key,
    super.controller,
    super.thumbVisibility = true,
    this.style,
    super.fadeDuration = const Duration(milliseconds: 300),
    super.timeToFade = const Duration(milliseconds: 600),
    super.interactive,
    super.notificationPredicate,
    super.scrollbarOrientation,
    super.pressDuration,
    super.minOverscrollLength,
  });

  /// The style applied to the scroll bar. If non-null, it's mescled
  /// with [FluentThemeData.scrollbarThemeData]
  final ScrollbarThemeData? style;

  @override
  RawScrollbarState<Scrollbar> createState() => _ScrollbarState();
}

class _ScrollbarState extends RawScrollbarState<Scrollbar> {
  late AnimationController _hoverAnimationController;
  late ScrollbarThemeData _scrollbarTheme;
  bool _dragIsActive = false;
  bool _hoverIsActive = false;

  late Tween<double> _thicknessTween;
  late Tween<double> _crossAxisMarginTween;
  late Tween<double> _mainAxisMarginTween;

  @override
  void initState() {
    super.initState();
    _hoverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _hoverAnimationController.addListener(updateScrollbarPainter);
  }

  @override
  void didChangeDependencies() {
    assert(debugCheckHasFluentTheme(context));
    _scrollbarTheme = ScrollbarTheme.of(context).merge(widget.style);
    _hoverAnimationController.duration =
        _scrollbarTheme.expandContractAnimationDuration ?? Duration.zero;
    _thicknessTween = Tween<double>(
      begin: _scrollbarTheme.thickness ?? 2.0,
      end: _scrollbarTheme.hoveringThickness ?? 16.0,
    );
    _crossAxisMarginTween = Tween<double>(
      begin: _scrollbarTheme.crossAxisMargin ?? 0.0,
      end: _scrollbarTheme.hoveringCrossAxisMargin ?? 0.0,
    );
    _mainAxisMarginTween = Tween<double>(
      begin: _scrollbarTheme.mainAxisMargin ?? 6.0,
      end: _scrollbarTheme.hoveringMainAxisMargin ?? 0.0,
    );
    super.didChangeDependencies();
  }

  Set<WidgetState> get _currentState {
    return {
      if (_dragIsActive) WidgetState.pressed,
      if (_hoverIsActive) WidgetState.hovered,
    };
  }

  Color _trackColor(Set<WidgetState> state) {
    if (state.isAllOf({WidgetState.hovered, WidgetState.pressed})) {
      return _scrollbarTheme.backgroundColor ?? Colors.transparent;
    }
    return Colors.transparent;
  }

  Color _thumbColor(Set<WidgetState> state) {
    Color? color;
    if (state.isPressed) {
      color = _scrollbarTheme.scrollbarPressingColor;
    }
    return color ?? _scrollbarTheme.scrollbarColor ?? Colors.transparent;
  }

  @override
  void updateScrollbarPainter() {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMediaQuery(context));
    final direction = Directionality.of(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final animation = _hoverAnimationController;
    scrollbarPainter
      ..color = _thumbColor(_currentState)
      ..trackColor = _trackColor(_currentState)
      ..trackBorderColor =
          Color.lerp(
            _scrollbarTheme.trackBorderColor,
            _scrollbarTheme.hoveringTrackBorderColor,
            animation.value,
          ) ??
          Colors.transparent
      ..trackRadius = const Radius.circular(6)
      ..textDirection = direction
      ..thickness = _thicknessTween.evaluate(animation)
      ..radius = _hoverAnimationController.status != AnimationStatus.dismissed
          ? _scrollbarTheme.hoveringRadius
          : _scrollbarTheme.radius
      ..crossAxisMargin = _crossAxisMarginTween.evaluate(animation)
      ..mainAxisMargin = _mainAxisMarginTween.evaluate(animation)
      ..minLength = _scrollbarTheme.minThumbLength ?? 48.0
      ..minOverscrollLength =
          widget.minOverscrollLength ?? _scrollbarTheme.minThumbLength ?? 48.0
      ..padding =
          EdgeInsets.lerp(
            _scrollbarTheme.padding?.resolve(direction) ?? EdgeInsets.zero,
            _scrollbarTheme.hoveringPadding?.resolve(direction) ??
                EdgeInsets.zero,
            animation.value,
          )! +
          viewPadding;
  }

  Future<void> get contractDelay =>
      Future<void>.delayed(_scrollbarTheme.contractDelay ?? Duration.zero);

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    if (mounted) {
      setState(() => _dragIsActive = true);
      _updateAnimation();
    }
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    if (mounted) {
      setState(() => _dragIsActive = false);
      _updateAnimation();
    }
  }

  @override
  Future<void> handleHover(PointerHoverEvent event) async {
    super.handleHover(event);
    // Check if the position of the pointer falls over the painted scrollbar
    if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
      // Pointer is hovering over the scrollbar
      await contractDelay;
      if (mounted) {
        setState(() => _hoverIsActive = true);
        _updateAnimation();
      }
    } else if (_hoverIsActive) {
      await contractDelay;
      if (mounted) {
        // Pointer was, but is no longer over painted scrollbar.
        setState(() => _hoverIsActive = false);
        _updateAnimation();
      }
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    if (mounted) {
      setState(() => _hoverIsActive = false);
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _hoverAnimationController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (_currentState.isEmpty) {
      _hoverAnimationController.reverse();
    } else {
      _hoverAnimationController.forward();
    }
  }
}

/// An inherited widget that defines the configuration for
/// [Scrollbar]s in this widget's subtree.
///
/// Values specified here are used for [Scrollbar] properties that are not
/// given an explicit non-null value.
class ScrollbarTheme extends InheritedTheme {
  /// Creates a theme that controls how descendant [Scrollbar]s should look like.
  const ScrollbarTheme({required this.data, required super.child, super.key});

  /// The properties for descendant [Scrollbar] widgets.
  final ScrollbarThemeData data;

  /// Creates a theme that merges the nearest [ScrollbarTheme] with [data].
  static Widget merge({
    required ScrollbarThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return ScrollbarTheme(
          key: key,
          data: ScrollbarTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [ScrollbarThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Defaults from [ScrollbarThemeData.standard]
  /// 2. Global theme from [FluentThemeData.scrollbarTheme]
  /// 3. Local [ScrollbarTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ScrollbarThemeData theme = ScrollbarTheme.of(context);
  /// ```
  static ScrollbarThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<ScrollbarTheme>();
    return ScrollbarThemeData.standard(
      theme,
    ).merge(theme.scrollbarTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ScrollbarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ScrollbarTheme oldWidget) => data != oldWidget.data;
}

@immutable
/// Theme data for [Scrollbar] widgets.
class ScrollbarThemeData with Diagnosticable {
  /// Thickness of the scrollbar in its cross-axis in logical
  /// pixels. If null, `2.0` is used
  final double? thickness;

  /// Thickness of the scrollbar in its cross-axis in logical
  /// pixels when the user is hovering or pressing it. If null,
  /// `16.0` is used
  final double? hoveringThickness;

  /// The background color of the scrollbar when the user is
  /// hovering or pressing it. If null, `Color(0xFFf8f8f8)` is
  /// used for light theme and `Color(0xFF292929)` is used for
  /// dark theme.
  final Color? backgroundColor;

  /// The color of the scrollbar thumb on its default state. If
  /// null, `Color(0xFF898989)` is used for light theme and
  /// `Color(0xFFa0a0a0)` is used for dark theme.
  final Color? scrollbarColor;

  /// The color of the scrollbar thumb when the user is hovering
  /// or pressing it. If null, `const Color(0xFF898989)` is used
  /// for light theme and `Color(0xFFa0a0a0)` is used for dark
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

  /// The duration of the expand-contract animation.
  ///
  /// Defaults to 100 milliseconds
  final Duration? expandContractAnimationDuration;

  /// The duration of the expand-contract animation.
  ///
  /// Defaults to 500 milliseconds
  final Duration? contractDelay;

  /// The padding around the scrollbar thumb
  final EdgeInsetsGeometry? padding;

  /// The padding around the scrollbar thumb when hovering
  final EdgeInsetsGeometry? hoveringPadding;

  /// Creates a scrollbar theme data.
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
    this.padding,
    this.hoveringPadding,
    this.expandContractAnimationDuration,
    this.contractDelay,
  });

  /// Creates the standard [ScrollbarThemeData] based on the given [theme].
  factory ScrollbarThemeData.standard(FluentThemeData theme) {
    final brightness = theme.brightness;
    return ScrollbarThemeData(
      scrollbarColor: switch (brightness) {
        Brightness.light => const Color(0xFF898989),
        Brightness.dark => const Color(0xFFa0a0a0),
      },
      thickness: 2,
      hoveringThickness: 6,
      backgroundColor: switch (brightness) {
        Brightness.light => const Color(0xFFf8f8f8),
        Brightness.dark => const Color(0xFF292929),
      },
      radius: const Radius.circular(100),
      hoveringRadius: const Radius.circular(100),
      crossAxisMargin: 0,
      hoveringCrossAxisMargin: 3,
      mainAxisMargin: 0,
      hoveringMainAxisMargin: 0,
      minThumbLength: 48,
      trackBorderColor: Colors.transparent,
      hoveringTrackBorderColor: Colors.transparent,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      hoveringPadding: const EdgeInsetsDirectional.symmetric(vertical: 4),
      expandContractAnimationDuration: theme.fasterAnimationDuration,
      contractDelay: const Duration(milliseconds: 500),
    );
  }

  /// Linearly interpolates between two [ScrollbarThemeData] objects.
  ///
  /// {@macro fluent_ui.lerp.t}
  static ScrollbarThemeData lerp(
    ScrollbarThemeData? a,
    ScrollbarThemeData? b,
    double t,
  ) {
    return ScrollbarThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      scrollbarColor: Color.lerp(a?.scrollbarColor, b?.scrollbarColor, t),
      scrollbarPressingColor: Color.lerp(
        a?.scrollbarPressingColor,
        b?.scrollbarPressingColor,
        t,
      ),
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      hoveringThickness: lerpDouble(
        a?.hoveringThickness,
        b?.hoveringThickness,
        t,
      ),
      radius: Radius.lerp(a?.radius, b?.radius, t),
      hoveringRadius: Radius.lerp(a?.hoveringRadius, b?.hoveringRadius, t),
      crossAxisMargin: lerpDouble(a?.crossAxisMargin, b?.crossAxisMargin, t),
      hoveringCrossAxisMargin: lerpDouble(
        a?.hoveringCrossAxisMargin,
        b?.hoveringCrossAxisMargin,
        t,
      ),
      mainAxisMargin: lerpDouble(a?.mainAxisMargin, b?.mainAxisMargin, t),
      hoveringMainAxisMargin: lerpDouble(
        a?.hoveringMainAxisMargin,
        b?.hoveringMainAxisMargin,
        t,
      ),
      minThumbLength: lerpDouble(a?.minThumbLength, b?.minThumbLength, t),
      trackBorderColor: Color.lerp(a?.trackBorderColor, b?.trackBorderColor, t),
      hoveringTrackBorderColor: Color.lerp(
        a?.hoveringTrackBorderColor,
        b?.hoveringTrackBorderColor,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      hoveringPadding: EdgeInsetsGeometry.lerp(
        a?.hoveringPadding,
        b?.hoveringPadding,
        t,
      ),
      expandContractAnimationDuration: lerpDuration(
        a?.expandContractAnimationDuration ?? Duration.zero,
        b?.expandContractAnimationDuration ?? Duration.zero,
        t,
      ),
      contractDelay: lerpDuration(
        a?.contractDelay ?? Duration.zero,
        b?.contractDelay ?? Duration.zero,
        t,
      ),
    );
  }

  /// Merges this [ScrollbarThemeData] with another, with the other taking
  /// precedence.
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
      padding: style.padding ?? padding,
      hoveringPadding: style.hoveringPadding ?? hoveringPadding,
      expandContractAnimationDuration:
          style.expandContractAnimationDuration ??
          expandContractAnimationDuration,
      contractDelay: style.contractDelay ?? contractDelay,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('scrollbarColor', scrollbarColor))
      ..add(ColorProperty('scrollbarPressingColor', scrollbarPressingColor))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(DoubleProperty('thickness', thickness, defaultValue: 2.0))
      ..add(
        DoubleProperty(
          'hoveringThickness',
          hoveringThickness,
          defaultValue: 16.0,
        ),
      )
      ..add(
        DiagnosticsProperty<Radius>(
          'radius',
          radius,
          defaultValue: const Radius.circular(100),
        ),
      )
      ..add(
        DiagnosticsProperty<Radius>(
          'hoveringRadius',
          hoveringRadius,
          defaultValue: Radius.zero,
        ),
      )
      ..add(DoubleProperty('mainAxisMargin', mainAxisMargin, defaultValue: 2.0))
      ..add(
        DoubleProperty(
          'hoveringMainAxisMargin',
          hoveringMainAxisMargin,
          defaultValue: 0.0,
        ),
      )
      ..add(
        DoubleProperty('crossAxisMargin', mainAxisMargin, defaultValue: 2.0),
      )
      ..add(
        DoubleProperty(
          'hoveringCrossAxisMargin',
          hoveringMainAxisMargin,
          defaultValue: 0.0,
        ),
      )
      ..add(
        DoubleProperty('minThumbLength', minThumbLength, defaultValue: 48.0),
      )
      ..add(ColorProperty('trackBorderColor', trackBorderColor))
      ..add(ColorProperty('hoveringTrackBorderColor', hoveringTrackBorderColor))
      ..add(
        DiagnosticsProperty<Duration>(
          'expandContractAnimationDuration',
          expandContractAnimationDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'contractDelay',
          contractDelay,
          defaultValue: const Duration(milliseconds: 500),
        ),
      )
      ..add(
        DiagnosticsProperty(
          'padding',
          padding,
          defaultValue: const EdgeInsetsDirectional.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
        ),
      )
      ..add(
        DiagnosticsProperty(
          'hoveringPadding',
          hoveringPadding,
          defaultValue: const EdgeInsetsDirectional.symmetric(vertical: 4),
        ),
      );
  }
}

/// Provider an extension method to hide vertical scrollbar.
/// May this can help [SingleChildScrollView] looks better.
extension ScrollViewExtension on SingleChildScrollView {
  /// Use [ScrollConfiguration] as wrapper to hide vertical scrollbar.
  Widget hideVerticalScrollbar(
    BuildContext context, {
    ScrollBehavior? behavior,
  }) {
    behavior ??= ScrollConfiguration.of(context);
    final showScrollbar = scrollDirection != Axis.vertical;
    return ScrollConfiguration(
      behavior: behavior.copyWith(scrollbars: showScrollbar),
      child: this,
    );
  }
}
