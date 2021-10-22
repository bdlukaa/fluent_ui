part of 'view.dart';

/// Creates a navigation indicator from a function.
///
/// [pane] is the current NavigationPane used
///
/// [axis], if null, defaults to [Axis.horinzontal]
typedef NavigationIndicatorBuilder = Widget Function({
  required BuildContext context,
  required NavigationPane pane,
  Axis? axis,
  required Widget child,
});

/// A indicator used by [NavigationPane] to render the selected
/// indicator.
class NavigationIndicator extends StatefulWidget {
  /// Creates a navigation indicator used by [NavigationPane]
  /// to render the selected indicator.
  const NavigationIndicator({
    Key? key,
    required this.offsets,
    required this.sizes,
    required this.index,
    required this.child,
    required this.axis,
    this.curve = Curves.linear,
    this.color,
  }) : super(key: key);

  /// The [NavigationPane]. It can be open, compact, closed or top.
  final Widget child;

  /// The current selected index;
  final int index;

  /// A function that tells the indicator the item offsets.
  final List<Offset> Function() offsets;

  /// A function that tells the indicator the item sizes. The sizes
  /// must not be [Size.infinite]
  final List<Size> Function() sizes;

  /// The axis corresponding to the current navigation pane. If it's
  /// a top pane, [Axis.vertical] will be provided, otherwise
  /// [Axis.horizontal].
  final Axis axis;

  /// The curve used on the animation, if any
  final Curve curve;

  /// The highlight color
  final Color? color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(EnumProperty('axis', axis));
    properties
        .add(DiagnosticsProperty('curve', curve, defaultValue: Curves.linear));
    properties.add(ColorProperty('highlight color', color));
  }

  @override
  NavigationIndicatorState createState() => NavigationIndicatorState();
}

class NavigationIndicatorState<T extends NavigationIndicator> extends State<T> {
  List<Offset>? offsets;
  List<Size>? sizes;

  @override
  void initState() {
    super.initState();
    fetch();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  void fetch() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final _offsets = widget.offsets();
      final _sizes = widget.sizes();
      if (mounted && offsets != _offsets && _sizes != sizes) {
        offsets = _offsets;
        sizes = _sizes;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// The end navigation indicator
class EndNavigationIndicator extends NavigationIndicator {
  const EndNavigationIndicator({
    Key? key,
    required List<Offset> Function() offsets,
    required List<Size> Function() sizes,
    required int index,
    required Widget child,
    required Axis axis,
    Curve curve = Curves.easeInOut,
    Color? color,
  }) : super(
          key: key,
          axis: axis,
          child: child,
          index: index,
          offsets: offsets,
          sizes: sizes,
          curve: curve,
          color: color,
        );

  @override
  _EndNavigationIndicatorState createState() => _EndNavigationIndicatorState();
}

class _EndNavigationIndicatorState
    extends NavigationIndicatorState<EndNavigationIndicator> {
  @override
  Widget build(BuildContext context) {
    if (offsets == null || sizes == null) return widget.child;
    fetch();
    return Stack(clipBehavior: Clip.none, children: [
      widget.child,
      ...List.generate(offsets!.length, (index) {
        if (widget.index != index) return const SizedBox.shrink();
        final isTop = widget.axis != Axis.horizontal;
        final offset = offsets![index];

        final size = sizes![index];

        final indicator = IgnorePointer(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: isTop ? 0.0 : 10.0,
              horizontal: isTop ? 10.0 : 0.0,
            ),
            width: isTop ? size.width : 6.0,
            height: isTop ? 4 : size.height,
            color: widget.color,
          ),
        );

        // debugPrint('at $offset with $size');

        if (isTop) {
          return Positioned(
            top: offset.dy,
            left: offset.dx,
            width: size.width,
            height: size.height,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: indicator,
            ),
          );
        } else {
          return Positioned(
            top: offset.dy,
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: indicator,
            ),
          );
        }
      }),
    ]);
  }
}

/// A sticky navigation indicator.
///
/// Made by [@raitonubero](https://github.com/raitonoberu). Make
/// sure to [check him out](https://gist.github.com/raitonoberu/af76d9b5813b7879e8db940bafa0f325).
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    Key? key,
    required List<Offset> Function() offsets,
    required List<Size> Function() sizes,
    required int index,
    required Widget child,
    required Axis axis,
    this.topPadding = EdgeInsets.zero,
    Curve curve = Curves.linear,
    Color? color,
  }) : super(
          key: key,
          axis: axis,
          child: child,
          index: index,
          offsets: offsets,
          sizes: sizes,
          curve: curve,
          color: color,
        );

  /// The padding applied to the indicator if [axis] is [Axis.vertical]
  final EdgeInsets topPadding;

  @override
  _StickyNavigationIndicatorState createState() =>
      _StickyNavigationIndicatorState();
}

class _StickyNavigationIndicatorState
    extends NavigationIndicatorState<StickyNavigationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late int oldIndex;
  late int newIndex;

  static const double step = 0.5;
  static const double startDelay = 8;
  static const double indicatorPadding = 8.0;

  double p1Start = 0.0;
  double p2Start = 0.0;
  double p1End = 0.0;
  double p2End = 0.0;

  double p1 = 0; // percentage of 1st point (0..1)
  double p2 = 0; // percentage of 2st point (0..1)

  double delay = 0;

  @override
  void initState() {
    super.initState();
    newIndex = widget.index;
    oldIndex = widget.index;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void update(int index) {
    if (index != newIndex) {
      oldIndex = newIndex;
      newIndex = index;
      p1 = 0;
      p2 = 0;
      delay = startDelay;
    }
    final minIndex = oldIndex;
    final maxIndex = newIndex;

    fetch();

    final double hFactor = () {
      if (widget.axis == Axis.horizontal) {
        return sizes![widget.index].height * 0.7;
      } else {
        // 6.0 of padding
        return sizes![widget.index].width - widget.topPadding.horizontal - 6.0;
      }
    }();

    final minOffsetAxis = offsets![minIndex].fromAxis(widget.axis);
    final maxOffsetAxis = offsets![maxIndex].fromAxis(widget.axis);

    if (widget.axis == Axis.horizontal) {
      p1Start = minOffsetAxis - (hFactor / 2);
      p1End = maxOffsetAxis - (hFactor / 2);

      p2Start = minOffsetAxis;
      p2End = maxOffsetAxis;
    } else {
      p1Start = minOffsetAxis;
      p1End = maxOffsetAxis;

      p2Start = minOffsetAxis + hFactor;
      p2End = maxOffsetAxis + hFactor;
    }

    double calcVelocity(double p) {
      return widget.curve.transform(p) + 0.05;
    }

    if (p2Start > p2End) {
      // move up
      final v1 = calcVelocity(p1);
      p1 = min(p1 + step * v1, 1);
      if (delay == 0) {
        final v2 = calcVelocity(p2);
        p2 = min(p2 + step * v2, 1);
      }
    } else {
      // move down
      final v2 = calcVelocity(p2);
      p2 = min(p2 + step * v2, 1);
      if (delay == 0) {
        final v1 = calcVelocity(p1);
        p1 = min(p1 + step * v1, 1);
      }
    }
    if (delay > 0) delay -= 1;
  }

  @override
  Widget build(BuildContext context) {
    if (offsets == null || sizes == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        update(widget.index);
        return CustomPaint(
          foregroundPainter: _StickyPainter(
            y: widget.axis == Axis.horizontal
                ? sizes!.first.height / 1.6
                : sizes!.first.height - (indicatorPadding / 2),
            padding: widget.axis == Axis.horizontal
                ? indicatorPadding
                : widget.topPadding.left + 4.0,
            p1: p1,
            p1Start: p1Start,
            p1End: p1End,
            p2: p2,
            p2Start: p2Start,
            p2End: p2End,
            color: widget.color ??
                FluentTheme.maybeOf(context)?.accentColor ??
                Colors.transparent,
            axis: widget.axis,
          ),
          child: child,
        );
      },
    );
  }
}

class _StickyPainter extends CustomPainter {
  final double y;
  final double padding;
  final double p1;
  final double p1Start;
  final double p1End;
  final double p2;
  final double p2Start;
  final double p2End;

  final Color color;

  final Axis axis;

  final double strokeWidth;

  const _StickyPainter({
    this.y = 0,
    required this.padding,
    required this.p1,
    required this.p1Start,
    required this.p1End,
    required this.p2,
    required this.p2Start,
    required this.p2End,
    required this.color,
    required this.axis,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final double first = p1Start + (p1End - p1Start) * p1;
    final double second = p2Start + (p2End - p2Start) * p2;

    if (first.isNegative || second.isNegative) return;

    // debugPrint('from $first to $second within $size');

    switch (axis) {
      case Axis.horizontal:
        canvas.drawLine(
          Offset(padding, y + first),
          Offset(padding, y + second),
          paint,
        );
        break;
      case Axis.vertical:
        canvas.drawLine(
          Offset(padding + first, y),
          Offset(padding + second, y),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_StickyPainter oldDelegate) {
    return y != oldDelegate.y ||
        padding != oldDelegate.padding ||
        p1 != oldDelegate.p1 ||
        p1Start != oldDelegate.p1Start ||
        p1End != oldDelegate.p1End ||
        p2 != oldDelegate.p2 ||
        p2Start != oldDelegate.p2Start ||
        p2End != oldDelegate.p2End ||
        color != oldDelegate.color;
  }

  @override
  bool shouldRebuildSemantics(_StickyPainter oldDelegate) => false;
}

extension OffsetExtension on Offset {
  double fromAxis(Axis axis) {
    if (axis == Axis.horizontal) {
      return dy;
    } else {
      return dx;
    }
  }
}

// extension _size on Size {
//   double fromAxis(Axis axis) {
//     if (axis == Axis.horizontal)
//       return height;
//     else
//       return width;
//   }
// }
