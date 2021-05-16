part of 'view.dart';

/// Creates a navigation indicator from a function.
typedef NavigationIndicatorBuilder = Widget Function({
  required BuildContext context,
  int? index,
  required List<Offset> Function() offsets,
  required List<Size> Function() sizes,
  required Axis axis,
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
    this.padding = const EdgeInsets.only(),
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

  /// The padding used on the indicators. [EdgeInsets.zero] used by default
  final EdgeInsets padding;

  /// The curve used on the animation, if any
  final Curve curve;

  /// The highlight color
  final Color? color;

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
  }

  void fetch() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        offsets = widget.offsets();
        sizes = widget.sizes();
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// The end navigation indicator
/// 
/// Works on both top and left display modes
class EndNavigationIndicator extends NavigationIndicator {
  const EndNavigationIndicator({
    Key? key,
    required List<Offset> Function() offsets,
    required List<Size> Function() sizes,
    required int index,
    required Widget child,
    required Axis axis,
    EdgeInsets padding = const EdgeInsets.only(left: 4.0),
    Curve curve = Curves.easeInOut,
    Color? color,
  }) : super(
          key: key,
          axis: axis,
          child: child,
          index: index,
          offsets: offsets,
          sizes: sizes,
          padding: padding,
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
    return Stack(children: [
      widget.child,
      ...List.generate(offsets!.length, (index) {
        if (widget.index != index) return SizedBox.shrink();
        final isTop = widget.axis != Axis.horizontal;
        final offset = offsets![index];
        final size =
            (!isTop ? sizes![index].height : sizes![index].width) * 1.0;

        final indicator = IgnorePointer(
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: isTop ? 6.0 : 6.0,
              horizontal: isTop ? 10.0 : 0.0,
            ),
            width: isTop ? size : 4,
            height: isTop ? 4 : size,
            color: widget.color,
          ),
        );
        if (isTop)
          return Positioned(
            top: offset.dy,
            left: offset.dx,
            width: size,
            child: indicator,
          );
        else {
          return Positioned(
            top: offset.dy - size + 10.0,
            height: size,
            child: indicator,
          );
        }
      }),
    ]);
  }
}

// TODO(bdlukaa): implement sticky navigation indicator on top

/// A sticky navigation indicator.
///
/// Made by [@raitonubero](https://gist.github.com/raitonoberu). Make
/// sure to check him out.
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    Key? key,
    required List<Offset> Function() offsets,
    required List<Size> Function() sizes,
    required int index,
    required Widget child,
    required Axis axis,
    EdgeInsets padding = const EdgeInsets.only(left: 4.0),
    Curve curve = Curves.linear,
    Color? color,
  }) : super(
          key: key,
          axis: axis,
          child: child,
          index: index,
          offsets: offsets,
          sizes: sizes,
          padding: padding,
          curve: curve,
          color: color,
        );

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
      duration: Duration(milliseconds: 1),
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

    final double kFactor = () {
      if (widget.axis == Axis.horizontal) {
        return sizes![widget.index].height;
      } else {
        return -sizes![widget.index].width * 2;
      }
    }();
    fetch();

    this.p1Start = offsets![minIndex].fromAxis(widget.axis) - (kFactor / 2);
    this.p1End = offsets![maxIndex].fromAxis(widget.axis) - (kFactor / 2);

    this.p2Start = offsets![minIndex].fromAxis(widget.axis);
    this.p2End = offsets![maxIndex].fromAxis(widget.axis);

    if (this.p2Start > this.p2End) {
      // move up
      final v1 = calcVelocity(this.p1) + 0.1;
      this.p1 = min(this.p1 + step * v1, 1);
      if (this.delay == 0) {
        final v2 = calcVelocity(this.p2) + 0.1;
        this.p2 = min(this.p2 + step * v2, 1);
      }
    } else {
      // move down
      final v2 = calcVelocity(this.p2) + 0.1;
      this.p2 = min(this.p2 + step * v2, 1);
      if (this.delay == 0) {
        final v1 = calcVelocity(this.p1) + 0.1;
        this.p1 = min(this.p1 + step * v1, 1);
      }
    }
    if (this.delay > 0) this.delay -= 1;
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
            padding: widget.axis == Axis.horizontal
                ? widget.padding.left
                : widget.padding.top,
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

  double calcVelocity(double p) {
    return widget.curve.transform(p);
  }
}

class _StickyPainter extends CustomPainter {
  final double padding;
  final double p1;
  final double p1Start;
  final double p1End;
  final double p2;
  final double p2Start;
  final double p2End;

  final Color color;

  final Axis axis;

  const _StickyPainter({
    required this.padding,
    required this.p1,
    required this.p1Start,
    required this.p1End,
    required this.p2,
    required this.p2Start,
    required this.p2End,
    required this.color,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print('from ${p1Start + (p1End - p1Start) * p1} to ${p2Start + (p2End - p2Start) * p2}');
    final paint = Paint()
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    final first = p1Start + (p1End - p1Start) * p1;
    final second = p2Start + (p2End - p2Start) * p2;
    switch (axis) {
      case Axis.horizontal:
        canvas.drawLine(Offset(padding, first), Offset(padding, second), paint);
        break;
      case Axis.vertical:
        canvas.drawLine(Offset(first, padding), Offset(second, padding), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_StickyPainter oldDelegate) {
    return padding != oldDelegate.padding ||
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

extension _offset on Offset {
  double fromAxis(Axis axis) {
    if (axis == Axis.horizontal)
      return dy;
    else
      return dx;
  }
}
