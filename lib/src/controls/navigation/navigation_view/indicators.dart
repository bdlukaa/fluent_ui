// ignore_for_file: use_key_in_widget_constructors

part of 'view.dart';

const kIndicatorAnimationDuration = Duration(milliseconds: 500);

/// A indicator used by [NavigationPane] to render the selected
/// indicator.
class NavigationIndicator extends StatefulWidget {
  /// Creates a navigation indicator used by [NavigationPane]
  /// to render the selected indicator.
  const NavigationIndicator({
    this.curve = Curves.linear,
    this.color,
    this.duration = kIndicatorAnimationDuration,
  });

  /// The curve used on the animation, if any
  ///
  /// For sticky navigation indicator, [Curves.easeIn] is recommended
  final Curve curve;

  /// The duration used on the animation, if any
  ///
  /// 500 milliseconds is used by default
  final Duration duration;

  /// The highlight color
  final Color? color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('curve', curve, defaultValue: Curves.linear))
      ..add(ColorProperty('highlight color', color))
      ..add(DiagnosticsProperty<Duration>(
        'duration',
        duration,
        defaultValue: kIndicatorAnimationDuration,
      ));
  }

  @override
  NavigationIndicatorState createState() => NavigationIndicatorState();
}

class NavigationIndicatorState<T extends NavigationIndicator> extends State<T> {
  Iterable<Offset>? offsets;

  @override
  void initState() {
    super.initState();
    fetch();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  void fetch() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;

      final localOffsets = pane.effectiveItems._getPaneItemsOffsets(
        pane.paneKey,
      );
      if (offsets != localOffsets) {
        offsets = localOffsets;
      }
    });
  }

  NavigationPane get pane {
    return InheritedNavigationView.of(context).pane!;
  }

  int get selectedIndex {
    return pane.selected ?? -1;
  }

  bool get isSelected {
    return pane.isSelected(item);
  }

  Axis get axis {
    if (InheritedNavigationView.maybeOf(context)?.displayMode ==
        PaneDisplayMode.top) {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  int get itemIndex {
    return InheritedNavigationView.of(context).currentItemIndex;
  }

  int get previousItemIndex {
    return InheritedNavigationView.of(context).previousItemIndex;
  }

  PaneItem get item {
    return pane.effectiveItems[itemIndex];
  }

  /// The parent of this item, if any
  PaneItemExpander? get parent {
    final items = pane.effectiveItems;

    final expandableItems = items.whereType<PaneItemExpander>();
    if (expandableItems.isEmpty) return null;

    for (final expandable in expandableItems) {
      if (expandable.items.contains(item)) return expandable;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// The end navigation indicator
class EndNavigationIndicator extends NavigationIndicator {
  /// The color of the indicator when the item is not selected
  final Color unselectedColor;

  const EndNavigationIndicator({
    super.color,
    this.unselectedColor = Colors.transparent,
  });

  @override
  NavigationIndicatorState<EndNavigationIndicator> createState() =>
      _EndNavigationIndicatorState();
}

class _EndNavigationIndicatorState
    extends NavigationIndicatorState<EndNavigationIndicator> {
  @override
  Widget build(BuildContext context) {
    if (selectedIndex.isNegative) return const SizedBox.shrink();
    assert(debugCheckHasFluentTheme(context));

    final isTop = axis == Axis.vertical;
    final theme = NavigationPaneTheme.of(context);

    return IgnorePointer(
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
            color: itemIndex != selectedIndex
                ? widget.unselectedColor
                : widget.color ?? theme.highlightColor,
          ),
        ),
      ),
    );
  }
}

/// A sticky navigation indicator.
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    super.curve,
    super.color,
    super.duration,
    this.topPadding = 12.0,
    this.leftPadding = kPaneItemMinHeight * 0.3,
    this.indicatorSize = 2.75,
  });

  /// The padding used on both horizontal sides of the indicator when the
  /// current display mode is top.
  ///
  /// Defaults to 12.0
  final double topPadding;

  /// The padding used on both vertical sides of the indicator when the current
  /// display mode is not top.
  ///
  /// Defaults to 10.0
  final double leftPadding;

  /// The size of the indicator.
  ///
  /// On top display mode, this represents the height of the indicator. On other
  /// display modes, this represents the width of the indicator.
  ///
  /// Defaults to 2.0
  final double indicatorSize;

  @override
  NavigationIndicatorState<StickyNavigationIndicator> createState() =>
      _StickyNavigationIndicatorState();
}

class _StickyNavigationIndicatorState
    extends NavigationIndicatorState<StickyNavigationIndicator>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController upController;
  late AnimationController downController;

  @override
  void initState() {
    super.initState();
    upController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
    downController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
  }

  Animation<double>? upAnimation;
  Animation<double>? downAnimation;

  int _old = -1;

  @override
  void dispose() {
    upController.dispose();
    downController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StickyNavigationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      upController.duration = downController.duration = widget.duration;
    }
  }

  bool get isShowing {
    if (itemIndex.isNegative) return false;

    if (itemIndex == selectedIndex) return true;
    return itemIndex == previousItemIndex && _old != previousItemIndex;
  }

  bool get isAbove => previousItemIndex < selectedIndex;
  bool get isBelow => previousItemIndex > selectedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animate();
  }

  Future<void> animate() async {
    if (!mounted) {
      return;
    }

    _old = (PageStorage.of(context).readState(
          context,
          identifier: 'previousItemIndex$itemIndex',
        ) as num?)
            ?.toInt() ??
        _old;

    // do not perform the animation twice
    if (_old == previousItemIndex) {
      return;
    }

    if (isShowing) {
      if (isBelow) {
        if (isSelected) {
          downAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(
              curve: Interval(0.5, 1.0, curve: widget.curve),
              parent: downController,
            ),
          );
          upAnimation = null;
          downController.forward(from: 0.0);
        } else {
          upAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(curve: widget.curve, parent: upController),
          );
          downAnimation = null;
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
          downAnimation = null;
          upController.forward(from: 0.0);
        } else {
          downAnimation = Tween<double>(begin: 0, end: 1.0).animate(
            CurvedAnimation(curve: widget.curve, parent: downController),
          );
          upAnimation = null;
          downController.reverse(from: 1.0);
        }
      }
    }

    _old = previousItemIndex;
    if (mounted) {
      PageStorage.of(context).writeState(
        context,
        _old,
        identifier: 'previousItemIndex$itemIndex',
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offsets == null || !isShowing || selectedIndex.isNegative) {
      return const SizedBox.shrink();
    }

    // Ensure it is only kept alive after if it's showing and after the offets
    // are fetched
    super.build(context);
    assert(debugCheckHasFluentTheme(context));

    final theme = NavigationPaneTheme.of(context);
    final isHorizontal = axis == Axis.horizontal;

    final decoration = BoxDecoration(
      color: widget.color ?? theme.highlightColor,
      borderRadius: BorderRadius.circular(100),
    );

    return SizedBox(
      height: double.infinity,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([upController, downController]),
          child: isHorizontal
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: widget.indicatorSize,
                    decoration: decoration,
                  ),
                )
              : Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Container(
                    height: widget.indicatorSize,
                    decoration: decoration,
                  ),
                ),
          builder: (context, child) {
            if (!isSelected) {
              if (upController.status == AnimationStatus.dismissed ||
                  downController.status == AnimationStatus.dismissed) {
                return const SizedBox.shrink();
              }
            }
            return Padding(
              padding: isHorizontal
                  ? EdgeInsetsDirectional.only(
                      start: () {
                        final x = offsets!.elementAt(itemIndex).dx;
                        if (parent != null) {
                          final isOpen =
                              parent!.expanderKey.currentState?._open ?? false;
                          if (isOpen) {
                            return x + _PaneItemExpander.leadingPadding.start;
                          }

                          final parentIndex =
                              pane.effectiveItems.indexOf(parent!);
                          final parentX = offsets!.elementAt(parentIndex).dx;
                          return parentX;
                        }
                        return x;
                      }(),
                      top: widget.leftPadding * (upAnimation?.value ?? 1.0),
                      bottom:
                          widget.leftPadding * (downAnimation?.value ?? 1.0),
                    )
                  : EdgeInsetsDirectional.only(
                      start: widget.topPadding * (upAnimation?.value ?? 1.0),
                      end: widget.topPadding * (downAnimation?.value ?? 1.0),
                    ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
