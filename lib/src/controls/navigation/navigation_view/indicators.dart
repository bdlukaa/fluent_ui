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
      if (mounted && (offsets != _offsets)) {
        offsets = _offsets;
      }
    });
  }

  NavigationPane get pane {
    return InheritedNavigationView.of(context).pane!;
  }

  int get index {
    return pane.selected ?? 0;
  }

  bool get isSelected {
    return pane.isSelected(pane.effectiveItems[itemIndex]);
  }

  Axis get axis {
    if (InheritedNavigationView.maybeOf(context)?.displayMode ==
        PaneDisplayMode.top) {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  int get itemIndex {
    return InheritedNavigationView.maybeOf(context)?.itemIndex ?? -1;
  }

  int get oldIndex {
    return InheritedNavigationView.maybeOf(context)?.oldIndex ?? 0;
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
    final isTop = axis == Axis.vertical;

    final theme = NavigationPaneTheme.of(context);

    final indicator = IgnorePointer(
      child: Align(
        alignment: isTop
            ? AlignmentDirectional.bottomCenter
            : AlignmentDirectional.centerStart,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 75),
          reverseDuration: Duration.zero,
          child: Container(
            key: ValueKey<int>(itemIndex),
            margin: EdgeInsets.symmetric(
              vertical: isTop ? 0.0 : 10.0,
              horizontal: isTop ? 10.0 : 0.0,
            ),
            width: isTop ? 20.0 : 6.0,
            height: isTop ? 4.5 : double.infinity,
            color: itemIndex != index
                ? Colors.transparent
                : widget.color ?? theme.highlightColor,
          ),
        ),
      ),
    );

    if (isTop) {
      return indicator;
    } else {
      return indicator;
    }
  }
}

/// A sticky navigation indicator.
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    Key? key,
    this.topPadding = EdgeInsets.zero,
    Curve curve = Curves.easeIn,
    Color? color,
  }) : super(key: key, curve: curve, color: color);

  /// The padding applied to the indicator if [axis] is [Axis.vertical]
  final EdgeInsets topPadding;

  static const Duration duration = Duration(milliseconds: 500);

  @override
  _StickyNavigationIndicatorState createState() =>
      _StickyNavigationIndicatorState();
}

class _StickyNavigationIndicatorState
    extends NavigationIndicatorState<StickyNavigationIndicator>
    with TickerProviderStateMixin {
  late AnimationController upController;
  late AnimationController downController;

  @override
  void initState() {
    super.initState();
    upController = AnimationController(
      vsync: this,
      duration: StickyNavigationIndicator.duration,
      value: 1.0,
    )..addListener(_updateListener);
    downController = AnimationController(
      vsync: this,
      duration: StickyNavigationIndicator.duration,
      value: 1.0,
    )..addListener(_updateListener);
  }

  void _updateListener() => setState(() {});

  Animation<double>? upAnimation;
  Animation<double>? downAnimation;

  @override
  void dispose() {
    upController.dispose();
    downController.dispose();
    super.dispose();
  }

  bool get isShowing =>
      !itemIndex.isNegative && (itemIndex == oldIndex || itemIndex == index);

  bool get isAbove => oldIndex < index;
  bool get isBelow => oldIndex > index;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    downController.value = 1.0;
    upController.value = 1.0;

    animate();
  }

  void animate() async {
    // await Future.delayed(StickyNavigationIndicator.duration);

    if (!mounted) return;

    if (isShowing) {
      if (isBelow) {
        if (isSelected) {
          downAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(
              curve: Interval(0.5, 1.0, curve: widget.curve),
              parent: downController,
            ),
          );
          downController.forward(from: 0.0);
        } else {
          upAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(curve: widget.curve, parent: upController),
          );
          upController.reverse(from: 1.0);
        }
      } else if (isAbove) {
        if (isSelected) {
          upAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(
              curve: Interval(0.5, 1.0, curve: widget.curve),
              parent: upController,
            ),
          );
          upController.forward(from: 0.0);
        } else {
          downAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(curve: widget.curve, parent: downController),
          );
          downController.reverse(from: 1.0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offsets == null || !isShowing) {
      return const SizedBox.shrink();
    }
    assert(debugCheckHasFluentTheme(context));

    final theme = NavigationPaneTheme.of(context);

    return SizedBox(
      height: double.infinity,
      child: IgnorePointer(
        child: Builder(builder: (context) {
          final child = Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 2.5,
              decoration: BoxDecoration(
                color: widget.color ?? theme.highlightColor,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
          if (!isSelected) {
            if (upController.status == AnimationStatus.dismissed ||
                downController.status == AnimationStatus.dismissed) {
              return const SizedBox.shrink();
            }
          } else {
            if (upAnimation?.value == 0.0 || downAnimation?.value == 0.0) {
              return const SizedBox.shrink();
            }
          }
          return Padding(
            padding: EdgeInsets.only(
              left: offsets![itemIndex].dx,
              top: 10.0 * (upAnimation?.value ?? 1.0),
              bottom: 10.0 * (downAnimation?.value ?? 1.0),
            ),
            child: child,
          );
        }),
      ),
    );
  }
}
