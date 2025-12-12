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
  late AnimationController _controller;

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

  double p1 = 0;
  double p2 = 0;
  double idleFrames = 15;
  double cycle = 1;
  double idle = 1;
  double lastValue = 0;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    return Container(
      height: widget.strokeWidth,
      constraints: const BoxConstraints(minWidth: _kMinProgressBarWidth),
      child: Semantics(
        label: widget.semanticLabel,
        value: widget.value?.toStringAsFixed(2),
        maxValueLength: 100,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            var deltaValue = _controller.value - lastValue;
            lastValue = _controller.value;
            if (deltaValue < 0) deltaValue++; // repeat
            return CustomPaint(
              painter: _ProgressBarPainter(
                value: widget.value == null ? null : widget.value! / 100,
                strokeWidth: widget.strokeWidth,
                activeColor:
                    widget.activeColor ??
                    theme.accentColor.defaultBrushFor(theme.brightness),
                backgroundColor:
                    widget.backgroundColor ?? theme.inactiveBackgroundColor,
                p1: p1,
                p2: p2,
                idleFrames: idleFrames,
                cycle: cycle,
                idle: idle,
                deltaValue: deltaValue,
                onUpdate: (values) {
                  p1 = values[0];
                  p2 = values[1];
                  idleFrames = values[2];
                  cycle = values[3];
                  idle = values[4];
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  static const _step1 = 2.7;
  static const _step2 = 4.5;
  static const _velocityScale = 0.8;
  static const _short = 0.4; // percentage of short line (0..1)
  static const _long = 80 / 130; // percentage of long line (0..1)

  double p1;
  double p2;
  double idleFrames;
  double cycle;
  double idle;
  double deltaValue;

  final ValueChanged<List<double>> onUpdate;

  final double strokeWidth;
  final Color backgroundColor;
  final Color activeColor;

  final double? value;

  _ProgressBarPainter({
    required this.p1,
    required this.p2,
    required this.idle,
    required this.cycle,
    required this.idleFrames,
    required this.deltaValue,
    required this.onUpdate,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.activeColor,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(size.width - strokeWidth / 2, size.height - strokeWidth / 2);

    void drawLine(Offset xy1, Offset xy2, Color color) {
      xy1 += Offset(strokeWidth / 2, 0);
      xy1 = xy1.clamp(Offset.zero, Offset(size.width, size.height));
      xy2 = xy2.clamp(xy1, Offset(size.width, size.height));

      canvas.drawLine(
        xy1,
        xy2,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // background line
    drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      backgroundColor,
    );

    if (value != null) {
      drawLine(
        Offset(0, size.height),
        Offset(value!.clamp(0.0, 1.0) * size.width, size.height),
        activeColor,
      );
      return;
    }

    // The math below is cortesy of raitonuberu:
    // https://gist.github.com/raitonoberu/21dacaee725806b60ddb45ec68147d30
    // https://github.com/raitonoberu

    void update() {
      onUpdate([p1, p2, idleFrames, cycle, idle]);
    }

    Offset coords(double percentage) {
      return Offset(size.width * percentage, size.height);
    }

    double calcVelocity(double p) {
      return (1 + math.cos(math.pi * p - (math.pi / 2)) * _velocityScale) *
          deltaValue;
    }

    final v1 = calcVelocity(p1);
    final v2 = calcVelocity(p2);

    if (cycle == 1) {
      // short line
      p2 = math.min(p2 + _step1 * v2, 1);
      if (p2 - p1 >= _short || p2 == 1) p1 = math.min(p1 + _step1 * v1, 1);
    }
    if (cycle == -1) {
      // long line
      p2 = math.min(p2 + _step2 * v2, 1);
      if (p2 - p1 >= _long || p2 == 1) p1 = math.min(p1 + _step2 * v1, 1);
    }
    if (p1 == 1) {
      // the end reached
      idle = idleFrames;
      cycle *= -1;
      p1 = 0;
      p2 = 0;
    }
    update();

    if (idle != 0) drawLine(coords(p1), coords(p2), activeColor);
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) => true;

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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _RingPainter(
                backgroundColor:
                    widget.backgroundColor ?? theme.inactiveBackgroundColor,
                value: widget.value,
                color:
                    widget.activeColor ??
                    theme.accentColor.defaultBrushFor(theme.brightness),
                strokeWidth: widget.strokeWidth,
                startAngle: _startAngleTween.evaluate(_controller),
                sweepAngle: _sweepAngleTween.evaluate(_controller),
                backwards: widget.backwards,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double? value;
  final double startAngle;
  final double sweepAngle;
  final bool backwards;

  const _RingPainter({
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.value,
    required this.startAngle,
    required this.sweepAngle,
    required this.backwards,
  });

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

    // Background line
    canvas.drawArc(
      offset & size,
      _startAngle,
      100,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (value == null) {
      canvas.drawArc(
        offset & size,
        ((backwards ? -startAngle : startAngle) - 90) * _deg2Rad,
        sweepAngle * _deg2Rad,
        false,
        paint,
      );
    } else {
      canvas.drawArc(
        offset & size,
        _startAngle,
        (value! / 100).clamp(0, 1) * _sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      value == null || value != oldDelegate.value;

  @override
  bool shouldRebuildSemantics(_RingPainter oldDelegate) => false;
}
