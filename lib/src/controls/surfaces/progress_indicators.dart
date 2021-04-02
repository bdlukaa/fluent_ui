import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kMinProgressRingIndicatorSize = 36.0;
const double _kMinProgressBarWidth = 130.0;

class ProgressBar extends StatefulWidget {
  ProgressBar({
    Key? key,
    this.value,
    this.strokeWidth = 4.5,
    this.semanticsLabel,
  })  : assert(() {
          if (value == null) return true;
          return value >= 0 && value <= 100;
        }()),
        super(key: key);

  final double? value;
  final double strokeWidth;
  final String? semanticsLabel;

  @override
  _ProgressBarState createState() => _ProgressBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value, ifNull: 'indeterminate'));
    properties.add(DoubleProperty('strokeWidth', strokeWidth));
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
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double p1 = 0, p2 = 0;
  double idleFrames = 15, cycle = 1, idle = 1;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    return Container(
      height: widget.strokeWidth,
      constraints: BoxConstraints(minWidth: _kMinProgressBarWidth),
      child: Semantics(
        label: widget.semanticsLabel,
        value: widget.value?.toStringAsFixed(2),
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, child) => CustomPaint(
            painter: _ProgressBarPainter(
              value: widget.value == null ? null : widget.value! / 100,
              strokeWidth: widget.strokeWidth,
              activeColor: style.accentColor!,
              backgroundColor: style.inactiveBackgroundColor!,
              p1: p1,
              p2: p2,
              idleFrames: idleFrames,
              cycle: cycle,
              idle: idle,
              onUpdate: (values) {
                p1 = values[0];
                p2 = values[1];
                idleFrames = values[2];
                cycle = values[3];
                idle = values[4];
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  static const _step1 = 0.015, _step2 = 0.025, _velocityScale = 0.8;
  static const _short = 0.4; // percentage of short line (0..1)
  static const _long = 80 / 130; // percentage of long line (0..1)

  double p1, p2, idleFrames, cycle, idle;

  ValueChanged<List<double>> onUpdate;

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
    required this.onUpdate,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.activeColor,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    void drawLine(Offset xy1, Offset xy2, Color color) {
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
      return Offset(
        size.width * percentage,
        size.height,
      );
    }

    double calcVelocity(double p) {
      return 1 + math.cos(math.pi * p - (math.pi / 2)) * _velocityScale;
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

class ProgressRing extends StatefulWidget {
  ProgressRing({
    Key? key,
    this.value,
    this.strokeWidth = 4.5,
    this.semanticsLabel,
  })  : assert(() {
          if (value == null) return true;
          return value >= 0 && value <= 100;
        }()),
        super(key: key);

  final double? value;
  final double strokeWidth;
  final String? semanticsLabel;

  @override
  _ProgressRingState createState() => _ProgressRingState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value, ifNull: 'indeterminate'));
    properties.add(DoubleProperty('strokeWidth', strokeWidth));
  }
}

class _ProgressRingState extends State<ProgressRing>
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
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double d1 = 0, d2 = 0, lowSpeed = 8, highSpeed = 12;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    return Container(
      constraints: BoxConstraints(
        minWidth: _kMinProgressRingIndicatorSize,
        minHeight: _kMinProgressRingIndicatorSize,
      ),
      child: Semantics(
        label: widget.semanticsLabel,
        value: widget.value?.toStringAsFixed(2),
        child: () {
          if (widget.value == null)
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, value) {
                return CustomPaint(
                  painter: _RingPainter(
                    backgroundColor: style.inactiveBackgroundColor!,
                    value: widget.value,
                    color: style.accentColor!,
                    strokeWidth: widget.strokeWidth,
                    d1: d1,
                    d2: d2,
                    lowSpeed: lowSpeed,
                    highSpeed: highSpeed,
                    onUpdate: (v) {
                      d1 = v[0];
                      d2 = v[1];
                      lowSpeed = v[2];
                      highSpeed = v[3];
                    },
                  ),
                );
              },
            );
          return CustomPaint(
            painter: _RingPainter(
              backgroundColor: style.inactiveBackgroundColor!,
              value: widget.value,
              color: style.accentColor!,
              strokeWidth: widget.strokeWidth,
              d1: d1,
              d2: d2,
              lowSpeed: lowSpeed,
              highSpeed: highSpeed,
              onUpdate: (v) {},
            ),
          );
        }(),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double? value;
  final double d1, d2, lowSpeed, highSpeed;
  final ValueChanged onUpdate;

  const _RingPainter({
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.value,
    required this.d1,
    required this.d2,
    required this.lowSpeed,
    required this.highSpeed,
    required this.onUpdate,
  });

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;
  static const double _deg2Rad = (2 * math.pi) / 360;

  @override
  void paint(Canvas canvas, Size size) {
    // Background line
    canvas.drawArc(
      Offset.zero & size,
      _startAngle,
      100,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (value == null) {
      double d1 = this.d1,
          d2 = this.d2,
          speed1 = this.lowSpeed,
          speed2 = this.highSpeed;

      void drawArc() {
        canvas.drawArc(
          Offset.zero & size,
          (90 - d2) * _deg2Rad,
          ((d2 - d1) * _deg2Rad),
          false,
          paint,
        );
      }

      void update() {
        d1 += speed1;
        d2 += speed2;
        if (d1 > 360 && d2 > 360) {
          d1 -= 360;
          d2 -= 360;
        }
        if ((d1 - d2).abs() >= 180) {
          final _speed1 = speed1;
          speed1 = speed2;
          speed2 = _speed1;
        }
        // update the values changed above
        onUpdate([d1, d2, speed1, speed2]);
      }

      update();
      if (d1 == d2 && d1 % 360 == 0) return;
      drawArc();
    } else
      canvas.drawArc(
        Offset.zero & size,
        _startAngle,
        (value! / 100).clamp(0, 1) * _sweep,
        false,
        paint,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_RingPainter oldDelegate) => false;
}
