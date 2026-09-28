import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kMinProgressRingIndicatorSize = 36;
const double _kMinProgressBarWidth = 130;

/// A linear progress indicator that shows operation progress.
///
/// Progress bars provide visual feedback about ongoing operations, helping
/// users understand that the app is working and approximately how long they
/// might need to wait.
///
/// The progress bar can operate in two modes:
///
/// * **Determinate** - Shows specific progress from 0-100%. Use when you can
///   measure or estimate the operation's progress.
///
/// ![Determinate Progress Bar](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/progressbar-determinate.png)
///
/// * **Indeterminate** - Shows an animation without specific progress. Use when
///   the operation duration is unknown.
///
/// ![Indeterminate Progress Bar](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/progressbar-indeterminate.gif)
///
/// {@tool snippet}
/// This example shows a determinate progress bar:
///
/// ```dart
/// ProgressBar(value: 75)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows an indeterminate progress bar:
///
/// ```dart
/// ProgressBar()
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ProgressRing], a circular progress indicator
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/progress-controls>
class ProgressBar extends StatefulWidget {
  /// Creates a new progress bar.
  ///
  /// [value], if non-null, must be in the range of 0 to 100.
  ///
  /// [strokeWidth] must be equal or greater than 0
  const ProgressBar({
    super.key,
    this.value,
    this.strokeWidth = 4.5,
    this.semanticLabel,
    this.backgroundColor,
    this.activeColor,
  }) : assert(value == null || value >= 0 && value <= 100),
       assert(strokeWidth >= 0);

  /// The current value of the indicator. If non-null, a determinate progress
  /// bar is created:
  ///
  /// ![Determinate Progress Bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressbar-determinate.png)
  ///
  /// If null, an indeterminate progress bar is created:
  ///
  /// ![Indeterminate Progress Bar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressbar-indeterminate.gif)
  final double? value;

  /// The height of the progess bar. Defaults to 4.5 logical pixels
  final double strokeWidth;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// The background color of the progress bar. If null,
  /// [FluentThemeData.inactiveColor] is used
  final Color? backgroundColor;

  /// The active color of the progress bar. If null,
  /// [FluentThemeData.accentColor] is used
  final Color? activeColor;

  @override
  State<ProgressBar> createState() => _ProgressBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value, ifNull: 'indeterminate'))
      ..add(DoubleProperty('strokeWidth', strokeWidth))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('activeColor', activeColor));
  }
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _animationState = _ProgressBarAnimationState();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    final direction = Directionality.of(context);
    return Container(
      height: widget.strokeWidth,
      constraints: const BoxConstraints(minWidth: _kMinProgressBarWidth),
      child: Semantics(
        label: widget.semanticLabel,
        value: widget.value?.toStringAsFixed(2),
        maxValueLength: 100,
        child: CustomPaint(
          painter: _ProgressBarPainter(
            animation: _controller,
            animationState: _animationState,
            value: widget.value == null ? null : widget.value! / 100,
            strokeWidth: widget.strokeWidth,
            activeColor:
                widget.activeColor ??
                theme.accentColor.defaultBrushFor(theme.brightness),
            backgroundColor:
                widget.backgroundColor ?? theme.inactiveBackgroundColor,
            textDirection: direction,
          ),
        ),
      ),
    );
  }
}

class _ProgressBarAnimationState {
  double p1 = 0;
  double p2 = 0;
  double idleFrames = 15;
  double cycle = 1;
  double idle = 1;
  double lastValue = 0;

  double deltaFor(double value) {
    var delta = value - lastValue;
    lastValue = value;
    if (delta < 0) delta++; // repeat
    return delta;
  }
}

class _ProgressBarPainter extends CustomPainter {
  static const _step1 = 2.7;
  static const _step2 = 4.5;
  static const _velocityScale = 0.8;
  static const _short = 0.4; // percentage of short line (0..1)
  static const _long = 80 / 130; // percentage of long line (0..1)

  final Animation<double> animation;
  final _ProgressBarAnimationState animationState;
  final double strokeWidth;
  final Color backgroundColor;
  final Color activeColor;
  final TextDirection textDirection;
  final double? value;
  final Paint _backgroundPaint;
  final Paint _activePaint;

  _ProgressBarPainter({
    required this.animation,
    required this.animationState,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.activeColor,
    required this.textDirection,
    required this.value,
  }) : _backgroundPaint = Paint()
         ..color = backgroundColor
         ..strokeWidth = strokeWidth
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round,
       _activePaint = Paint()
         ..color = activeColor
         ..strokeWidth = strokeWidth
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round,
       super(repaint: animation);

  static double _calcVelocity(double position, double deltaValue) {
    return (1 + math.cos(math.pi * position - (math.pi / 2)) * _velocityScale) *
        deltaValue;
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    Offset xy1,
    Offset xy2,
    Paint paint,
  ) {
    xy1 += Offset(strokeWidth / 2, 0);
    xy1 = xy1.clamp(Offset.zero, Offset(size.width, size.height));
    xy2 = xy2.clamp(xy1, Offset(size.width, size.height));
    canvas.drawLine(xy1, xy2, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    size = Size(size.width - strokeWidth / 2, size.height - strokeWidth / 2);
    if (size.width < 0 || size.height < 0) return;

    // background line
    _drawLine(
      canvas,
      size,
      Offset(0, size.height),
      Offset(size.width, size.height),
      _backgroundPaint,
    );

    if (value != null) {
      _drawLine(
        canvas,
        size,
        Offset(0, size.height),
        Offset(clampDouble(value!, 0, 1) * size.width, size.height),
        _activePaint,
      );
      return;
    }

    // The math below is cortesy of raitonuberu:
    // https://gist.github.com/raitonoberu/21dacaee725806b60ddb45ec68147d30
    // https://github.com/raitonoberu

    final deltaValue = animationState.deltaFor(animation.value);
    final v1 = _calcVelocity(animationState.p1, deltaValue);
    final v2 = _calcVelocity(animationState.p2, deltaValue);

    if (animationState.cycle == 1) {
      // short line
      animationState.p2 = math.min(animationState.p2 + _step1 * v2, 1);
      if (animationState.p2 - animationState.p1 >= _short ||
          animationState.p2 == 1) {
        animationState.p1 = math.min(animationState.p1 + _step1 * v1, 1);
      }
    }
    if (animationState.cycle == -1) {
      // long line
      animationState.p2 = math.min(animationState.p2 + _step2 * v2, 1);
      if (animationState.p2 - animationState.p1 >= _long ||
          animationState.p2 == 1) {
        animationState.p1 = math.min(animationState.p1 + _step2 * v1, 1);
      }
    }
    if (animationState.p1 == 1) {
      // the end reached
      animationState.idle = animationState.idleFrames;
      animationState.cycle *= -1;
      animationState.p1 = 0;
      animationState.p2 = 0;
    }

    if (animationState.idle != 0) {
      _drawLine(
        canvas,
        size,
        Offset(size.width * animationState.p1, size.height),
        Offset(size.width * animationState.p2, size.height),
        _activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      strokeWidth != oldDelegate.strokeWidth ||
      backgroundColor != oldDelegate.backgroundColor ||
      activeColor != oldDelegate.activeColor ||
      textDirection != oldDelegate.textDirection ||
      value != oldDelegate.value;

  @override
  bool shouldRebuildSemantics(_ProgressBarPainter oldDelegate) => false;
}

/// A circular progress indicator that shows operation progress.
///
/// Progress rings provide visual feedback about ongoing operations in a
/// compact, circular format. They're especially useful when horizontal space
/// is limited or when you need a loading indicator.
///
/// The progress ring can operate in two modes:
///
/// * **Determinate** - Shows specific progress from 0-100%. Use when you can
///   measure the operation's progress.
///
/// ![Determinate Progress Ring](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/progress-ring.jpg)
///
/// * **Indeterminate** - Shows a spinning animation. Use when the operation
///   duration is unknown.
///
/// ![Indeterminate Progress Ring](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/progressring-indeterminate.gif)
///
/// {@tool snippet}
/// This example shows an indeterminate progress ring:
///
/// ```dart
/// ProgressRing()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a determinate progress ring:
///
/// ```dart
/// ProgressRing(value: 65)
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ProgressBar], a linear progress indicator
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/progress-controls>
class ProgressRing extends StatefulWidget {
  /// Creates progress ring.
  ///
  /// [value], if non-null, must be in the range of 0 to 100
  ///
  /// [strokeWidth] must be equal or greater than 0
  const ProgressRing({
    super.key,
    this.value,
    this.strokeWidth = 4.5,
    this.semanticLabel,
    this.backgroundColor,
    this.activeColor,
    this.backwards = false,
  }) : assert(value == null || value >= 0 && value <= 100);

  /// The current value of the indicator. This value must be between 0 and 100.
  ///
  /// If non-null, a determinate progress ring is created:
  ///
  /// ![Determinate Progress Ring](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progress_ring.jpg)
  ///
  /// If null, an indeterminate progress ring is created:
  ///
  /// ![Indeterminate Progress Ring](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/progressring-indeterminate.gif)
  final double? value;

  /// The stroke width of the progress ring.
  ///
  /// If null, defaults to 4.5 logical pixels
  final double strokeWidth;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// The background color of the progress ring.
  ///
  /// If null, [FluentThemeData.inactiveColor] is used
  final Color? backgroundColor;

  /// The active color of the progress ring.
  ///
  /// If null, [FluentThemeData.accentColor] is used
  final Color? activeColor;

  /// Whether the indicator spins backwards or not. Defaults to false
  final bool backwards;

  @override
  State<ProgressRing> createState() => _ProgressRingState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value, ifNull: 'indeterminate'))
      ..add(DoubleProperty('strokeWidth', strokeWidth, defaultValue: 4.5))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('activeColor', activeColor))
      ..add(
        FlagProperty(
          'backwards',
          value: backwards,
          defaultValue: false,
          ifFalse: 'forwards',
        ),
      );
  }
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  static final TweenSequence<double> _startAngleTween = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 450), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 450, end: 1080), weight: 1),
  ]);
  static final TweenSequence<double> _sweepAngleTween = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 180), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 180, end: 0), weight: 1),
  ]);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinProgressRingIndicatorSize,
        minHeight: _kMinProgressRingIndicatorSize,
      ),
      child: Semantics(
        label: widget.semanticLabel,
        value: widget.value?.toStringAsFixed(2),
        child: CustomPaint(
          painter: _RingPainter(
            animation: _controller,
            startAngleTween: _startAngleTween,
            sweepAngleTween: _sweepAngleTween,
            backgroundColor:
                widget.backgroundColor ?? theme.inactiveBackgroundColor,
            value: widget.value,
            color:
                widget.activeColor ??
                theme.accentColor.defaultBrushFor(theme.brightness),
            strokeWidth: widget.strokeWidth,
            backwards: widget.backwards,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Animation<double> animation;
  final TweenSequence<double> startAngleTween;
  final TweenSequence<double> sweepAngleTween;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double? value;
  final bool backwards;
  final Paint _backgroundPaint;
  final Paint _activePaint;

  _RingPainter({
    required this.animation,
    required this.startAngleTween,
    required this.sweepAngleTween,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.value,
    required this.backwards,
  }) : _backgroundPaint = Paint()
         ..color = backgroundColor
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth,
       _activePaint = Paint()
         ..color = color
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round
         ..style = PaintingStyle.stroke,
       super(repaint: animation);

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;
  static const double _deg2Rad = (2 * math.pi) / 360;

  @override
  void paint(Canvas canvas, Size size) {
    // Since the indicator is drawn as a stroke, the offset and size need to be
    // adapted so that the stroke will be drawn inside the paint area.
    final offset = Offset(strokeWidth / 2, strokeWidth / 2);
    size = Size(size.width - strokeWidth, size.height - strokeWidth);
    if (size.width < 0 || size.height < 0) return;

    final rect = offset & size;

    // Background line
    canvas.drawArc(rect, _startAngle, 100, false, _backgroundPaint);
    if (value == null) {
      final startAngle = startAngleTween.evaluate(animation);
      final sweepAngle = sweepAngleTween.evaluate(animation);
      canvas.drawArc(
        rect,
        ((backwards ? -startAngle : startAngle) - 90) * _deg2Rad,
        sweepAngle * _deg2Rad,
        false,
        _activePaint,
      );
    } else {
      canvas.drawArc(
        rect,
        _startAngle,
        clampDouble(value! / 100, 0, 1) * _sweep,
        false,
        _activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      color != oldDelegate.color ||
      backgroundColor != oldDelegate.backgroundColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      value != oldDelegate.value ||
      backwards != oldDelegate.backwards ||
      startAngleTween != oldDelegate.startAngleTween ||
      sweepAngleTween != oldDelegate.sweepAngleTween;

  @override
  bool shouldRebuildSemantics(_RingPainter oldDelegate) => false;
}
