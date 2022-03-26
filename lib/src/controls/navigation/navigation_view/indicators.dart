part of 'view.dart';

/// A indicator used by [NavigationPane] to render the selected
/// indicator.
class NavigationIndicator extends StatefulWidget {
  /// Creates a navigation indicator used by [NavigationPane]
  /// to render the selected indicator.
  const NavigationIndicator({
    Key? key,
    this.curve = Curves.linear,
    this.color,
  }) : super(key: key);

  /// The curve used on the animation, if any
  ///
  /// For sticky navigation indicator, [Curves.easeIn] is recommended
  final Curve curve;

  /// The highlight color
  final Color? color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
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
      final _offsets = pane.effectiveItems.getPaneItemsOffsets(
        pane.paneKey,
      );
      final _sizes = pane.effectiveItems.getPaneItemsSizes();
      if (mounted && (offsets != _offsets || _sizes != sizes)) {
        offsets = _offsets;
        sizes = _sizes;
      }
    });
  }

  NavigationPane get pane {
    return _NavigationBody.of(context).pane!;
  }

  int get index {
    return pane.selected ?? 0;
  }

  bool get isSelected {
    return pane.isSelected(pane.effectiveItems[index]);
  }

  Axis get axis {
    if (_NavigationBody.maybeOf(context)?.displayMode == PaneDisplayMode.top) {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// The end navigation indicator
class EndNavigationIndicator extends NavigationIndicator {
  const EndNavigationIndicator({
    Key? key,
    Curve curve = Curves.easeInOut,
    Color? color,
  }) : super(key: key, curve: curve, color: color);

  @override
  _EndNavigationIndicatorState createState() => _EndNavigationIndicatorState();
}

class _EndNavigationIndicatorState
    extends NavigationIndicatorState<EndNavigationIndicator> {
  @override
  Widget build(BuildContext context) {
    if (offsets == null || sizes == null) const SizedBox.shrink();
    fetch();
    return Stack(clipBehavior: Clip.none, children: [
      ...List.generate(offsets!.length, (index) {
        final isTop = axis == Axis.vertical;
        final offset = offsets![index];

        final size = sizes![index];

        final indicator = IgnorePointer(
          child: Align(
            alignment: isTop ? Alignment.bottomCenter : Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 75),
              reverseDuration: Duration.zero,
              child: Container(
                key: ValueKey<int>(this.index),
                margin: EdgeInsets.symmetric(
                  vertical: isTop ? 0.0 : 0,
                  horizontal: isTop ? 10.0 : 0.0,
                ),
                width: isTop ? 20.0 : 6.0,
                height: isTop ? 4.5 : 20.0,
                color: this.index != index ? Colors.transparent : widget.color,
              ),
            ),
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
            child: indicator,
          );
        }
      }),
    ]);
  }
}

/// A sticky navigation indicator.
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    Key? key,
    required this.indexValue,
    this.topPadding = EdgeInsets.zero,
    Curve curve = Curves.easeIn,
    Color? color,
  }) : super(key: key, curve: curve, color: color);

  final int indexValue;

  /// The padding applied to the indicator if [axis] is [Axis.vertical]
  final EdgeInsets topPadding;

  static const Duration duration = Duration(seconds: 1);

  @override
  _StickyNavigationIndicatorState createState() =>
      _StickyNavigationIndicatorState();
}

class _StickyNavigationIndicatorState
    extends NavigationIndicatorState<StickyNavigationIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  NavigationPane? _pane;
  int oldIndex = -1;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: StickyNavigationIndicator.duration,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get isShowing =>
      !widget.indexValue.isNegative &&
      (widget.indexValue == oldIndex || widget.indexValue == index);

  bool get isAbove => oldIndex < index;
  bool get isBelow => oldIndex > index;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_pane == null) {
      _pane = pane;
    } else if (_pane!.selected == pane.selected) {
      return;
    }

    if (oldIndex == -1 || widget.indexValue != index) {
      oldIndex = index;
    }

    if (isShowing) {
      if (isBelow) {
        if (isSelected) {
          controller.forward(
            from: 0.0,
          );
        } else {
          controller.reverse(
            from: 1.0,
          );
        }
      } else if (isAbove) {
        if (isSelected) {
          controller.forward(
            from: 0.0,
          );
        } else {
          controller.reverse(
            from: 1.0,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offsets == null || sizes == null || !isShowing) {
      return const SizedBox.shrink();
    }
    assert(debugCheckHasFluentTheme(context));

    final theme = NavigationPaneTheme.of(context);

    return SizedBox(
      height: sizes![widget.indexValue].height,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: controller,
          curve: widget.curve,
        ),
        child: Container(
          width: 2.5,
          decoration: BoxDecoration(
            color: widget.color ?? theme.highlightColor,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.only(
              left: offsets![widget.indexValue].dx,
              top: 10.0 * (isAbove ? controller.value : 1.0),
              bottom: 10.0 * (isBelow ? controller.value : 1.0),
            ),
            // child: Text('$oldIndex - ${widget.indexValue}'),
            child: child,
          );
        },
      ),
    );
  }
}

extension _OffsetExtension on Offset {
  /// Gets the value based on [axis]
  ///
  /// If [Axis.horizontal], [dy] is going to be returned. Otherwise, [dx] is
  /// returned.
  double fromAxis(Axis axis) {
    if (axis == Axis.horizontal) {
      return dy;
    } else {
      return dx;
    }
  }
}
