import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

const double _kMinProgressRingIndicatorSize = 36.0;
const double _kMinProgressBarWidth = 130.0;

enum ProgressState {
  running,
  paused,
  error,
}

// TODO: indeterminate progress bar and ring

class ProgressBar extends StatefulWidget {
  ProgressBar({
    Key? key,
    this.state = ProgressState.running,
    this.value,
    this.strokeWidth = 4.0,
  })  : assert(() {
          if (value == null) return true;
          return value >= 0 && value <= 100;
        }()),
        super(key: key);

  final ProgressState state;
  final double? value;
  final double strokeWidth;

  @override
  _ProgressBarState createState() => _ProgressBarState();
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

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!;
    final radius = BorderRadius.circular(55);
    return Container(
      height: widget.strokeWidth,
      constraints: BoxConstraints(
        minWidth: _kMinProgressBarWidth,
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, consts) {
          final size = consts.biggest;
          switch (widget.state) {
            case ProgressState.error:
            case ProgressState.paused:
              final color = widget.state == ProgressState.error
                  ? style.brightness!.isDark
                      ? Colors.yellow
                      : Colors.red
                  : style.disabledColor;
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: radius,
                ),
                margin: EdgeInsets.symmetric(horizontal: size.width / 10),
              );
            default:
              break;
          }
          double right = 0;
          double left = 0;
          if (widget.value != null) {
            right = size.width -
                (size.width.clamp(0, 1) * widget.value!.clamp(0, 100) * 3);
          } else {
            right = size.width;
          }
          final inside = Container(
            decoration: BoxDecoration(
              color: style.accentColor,
              borderRadius: radius,
            ),
            margin: EdgeInsets.only(right: right, left: left),
          );
          return inside;
        },
      ),
    );
  }
}

class ProgressRing extends StatefulWidget {
  ProgressRing({
    Key? key,
    this.value,
    this.strokeWidth = 4.0,
  })  : assert(() {
          if (value == null) return true;
          return value >= 0 && value <= 100;
        }()),
        super(key: key);

  final double? value;
  final double strokeWidth;

  @override
  _ProgressRingState createState() => _ProgressRingState();
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

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!;
    return Container(
      constraints: BoxConstraints(
        minWidth: _kMinProgressRingIndicatorSize,
        minHeight: _kMinProgressRingIndicatorSize,
      ),
      child: CustomPaint(
        painter: _RingPainter(
          backgroundColor: Colors.grey,
          value: widget.value,
          color: style.accentColor!,
          strokeWidth: widget.strokeWidth,
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

  const _RingPainter({
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    this.value,
  });

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
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
