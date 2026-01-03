part of 'view.dart';

class _ForceShowIndicator extends InheritedWidget {
  const _ForceShowIndicator({required super.child, this.forceShow = false});

  final bool forceShow;

  static bool forceShowOf(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<_ForceShowIndicator>();
    return widget?.forceShow ?? false;
  }

  @override
  bool updateShouldNotify(_ForceShowIndicator oldWidget) =>
      forceShow != oldWidget.forceShow;
}

/// A indicator used by [NavigationPane] to render the selected
/// indicator.
///
/// The indicator is rendered locally inside each [PaneItem], not globally.
/// This approach:
/// - Eliminates memory overhead from storing global coordinates
/// - Ensures pixel-perfect positioning
/// - Simplifies the animation logic
abstract class NavigationIndicator extends StatefulWidget {
  /// Creates a navigation indicator used by [NavigationPane]
  /// to render the selected indicator.
  const NavigationIndicator({super.key, this.curve, this.color, this.duration});

  /// The curve used on the animation, if any
  ///
  /// For sticky navigation indicator, [Curves.easeIn] is recommended
  final Curve? curve;

  /// The duration used on the animation, if any
  ///
  /// 500 milliseconds is used by default
  final Duration? duration;

  /// The highlight color
  final Color? color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('curve', curve, defaultValue: Curves.linear))
      ..add(ColorProperty('highlight color', color))
      ..add(DiagnosticsProperty<Duration>('duration', duration));
  }
}

/// The state for a [NavigationIndicator] widget.
///
/// This state is designed to work with local positioning inside each PaneItem,
/// rather than using global coordinates. This eliminates memory overhead and
/// ensures pixel-perfect indicator positioning.
abstract class NavigationIndicatorState<T extends NavigationIndicator>
    extends State<T> {
  /// The currently selected item index.
  int get selectedIndex {
    return NavigationView.dataOf(context).pane!.selected ?? -1;
  }

  /// Whether the current item is selected.
  bool get isSelected {
    return itemIndex == selectedIndex;
  }

  /// The axis of the navigation indicator based on the display mode.
  Axis get axis {
    if (NavigationView.dataOf(context).displayMode == PaneDisplayMode.top) {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  /// The index of the current item.
  int get itemIndex {
    return _PaneItemContext.of(context).index;
  }

  /// The index of the previously selected item.
  int get previousItemIndex {
    return NavigationView.dataOf(context).previousItemIndex;
  }

  /// The current pane item.
  PaneItem get item {
    return NavigationView.dataOf(context).pane!.effectiveItems[itemIndex];
  }

  /// Whether this indicator should be visible
  bool get shouldShow {
    if (selectedIndex.isNegative) return false;
    return isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// The end navigation indicator
///
/// A simple indicator that shows a colored bar at the edge of the selected item.
class EndNavigationIndicator extends NavigationIndicator {
  /// The color of the indicator when the item is not selected
  final Color unselectedColor;

  /// Creates an end navigation indicator.
  const EndNavigationIndicator({
    super.key,
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
    final forceShow = _ForceShowIndicator.forceShowOf(context);

    final isTop = axis == Axis.vertical;
    final theme = NavigationPaneTheme.of(context);

    return IgnorePointer(
      child: Align(
        alignment: isTop
            ? AlignmentDirectional.bottomCenter
            : AlignmentDirectional.centerStart,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsetsDirectional.symmetric(
            vertical: isTop ? 0.0 : 10.0,
            horizontal: isTop ? 12.0 : 0.0,
          ),
          width: isTop ? 20.0 : 6.0,
          height: isTop ? 3.0 : double.infinity,
          decoration: BoxDecoration(
            color: isSelected || forceShow
                ? (widget.color ?? theme.highlightColor)
                : widget.unselectedColor,
          ),
        ),
      ),
    );
  }
}

/// A sticky navigation indicator.
///
/// This indicator animates between navigation items with a "sticky" effect,
/// stretching and contracting smoothly as the selection changes.
///
/// ## Behavior
///
/// **At rest (not transitioning):**
/// The indicator is displayed in the center of the selected item with equal
/// padding on both ends.
///
/// **During transition:**
/// - The **old item's** indicator shrinks towards the new item (padding
///   increases on the side facing the new item)
/// - The **new item's** indicator grows from the direction of the old item
///   (padding decreases on the side facing the old item)
///
/// This creates a "sticky" stretching effect as if the indicator is being
/// pulled from one item to another.
class StickyNavigationIndicator extends NavigationIndicator {
  /// Creates a sticky navigation indicator.
  const StickyNavigationIndicator({
    super.key,
    super.curve,
    super.color,
    super.duration,
    this.topPadding = 12.0,
    this.leftPadding = 10.0,
    this.indicatorSize = 3.0,
  });

  /// The padding used on both horizontal sides of the indicator when the
  /// current display mode is top.
  ///
  /// Defaults to 12.0
  final double topPadding;

  /// The padding used on both vertical sides of the indicator when the current
  /// display mode is not top.
  ///
  /// Defaults to 10.0px, which provides 10px padding on each side for a
  /// properly sized indicator that matches WinUI3 specifications.
  final double leftPadding;

  /// The size of the indicator.
  ///
  /// On top display mode, this represents the height of the indicator. On other
  /// display modes, this represents the width of the indicator.
  ///
  /// Defaults to 3.0px to match WinUI3 NavigationView standard.
  final double indicatorSize;

  @override
  NavigationIndicatorState<StickyNavigationIndicator> createState() =>
      _StickyNavigationIndicatorState();
}

class _StickyNavigationIndicatorState
    extends NavigationIndicatorState<StickyNavigationIndicator>
    with TickerProviderStateMixin {
  /// Controller for animating the indicator shrinking out from the old item.
  late AnimationController _shrinkController;

  /// Controller for animating the indicator growing into the new item.
  late AnimationController _growController;

  /// Controller for animating the indicator expanding into the new item.
  late AnimationController _expandController;

  Curve _cachedCurve = Curves.easeInOut;
  int _cachedPreviousIndex = -1;
  int _cachedSelectedIndex = -1;

  /// Whether the transition is moving downward in the list.
  ///
  /// - `true`: New item is below the old item (moving down)
  /// - `false`: New item is above the old item (moving up)
  bool _goingDown = true;

  @override
  void initState() {
    super.initState();
    _shrinkController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 150),
    );
    _growController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 150),
      value: 1,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 150),
      value: 0,
    );
  }

  bool _isForceShow = false;
  bool _isAnimatingForceShow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = FluentTheme.of(context);
    _cachedCurve = widget.curve ?? theme.animationCurve;

    final duration = widget.duration ?? theme.slowAnimationDuration;
    _shrinkController.duration = duration;
    _growController.duration = duration;
    _expandController.duration = duration;
    _updateAnimation();
  }

  @override
  void didUpdateWidget(StickyNavigationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      final duration =
          widget.duration ?? FluentTheme.of(context).fastAnimationDuration;
      _shrinkController.duration = duration;
      _growController.duration = duration;
      _expandController.duration = duration;
    }
    if (widget.curve != oldWidget.curve) {
      _cachedCurve = widget.curve ?? FluentTheme.of(context).animationCurve;
    }
  }

  /// Updates the animation state when selection changes.
  ///
  /// This method:
  /// - Determines the direction of the transition (up or down)
  /// - Starts the grow animation for the newly selected item
  /// - Starts the shrink animation for the previously selected item
  /// - Caches the current state to avoid redundant updates
  void _updateAnimation() {
    if (!mounted) return;

    final currentPreviousIndex = previousItemIndex;
    final currentSelectedIndex = selectedIndex;

    if (_cachedPreviousIndex == currentPreviousIndex &&
        _cachedSelectedIndex == currentSelectedIndex) {
      return;
    }

    _goingDown = currentPreviousIndex > currentSelectedIndex;

    if (isSelected) {
      _growController.forward(from: 0);
    } else if (itemIndex == currentPreviousIndex &&
        currentPreviousIndex != currentSelectedIndex) {
      _shrinkController.forward(from: 0);
    }

    _cachedPreviousIndex = currentPreviousIndex;
    _cachedSelectedIndex = currentSelectedIndex;
  }

  /// Ensures the force show animation is running.
  ///
  /// This method needs to be called at build time.
  void _ensureForceShowAnimation() {
    final isForceShow = _ForceShowIndicator.forceShowOf(context);
    if (isForceShow != _isForceShow) {
      if (isForceShow) {
        _isAnimatingForceShow = true;
        _expandController.forward(from: 0).then((_) {
          _isAnimatingForceShow = false;
          if (mounted) setState(() {});
        });
      } else {
        _isAnimatingForceShow = true;
        _expandController.reverse(from: 1).then((_) {
          _isAnimatingForceShow = false;
          if (mounted) setState(() {});
        });
      }
    }
    _isForceShow = isForceShow;
  }

  @override
  void dispose() {
    _shrinkController.dispose();
    _growController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  bool get _shouldRender {
    if (isSelected || _isForceShow || _isAnimatingForceShow) return true;
    if (selectedIndex.isNegative || previousItemIndex.isNegative) return false;
    if (itemIndex == previousItemIndex && _shrinkController.isAnimating) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _ensureForceShowAnimation();
    if (!_shouldRender) {
      return const IgnorePointer(child: SizedBox.shrink());
    }

    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = NavigationView.dataOf(context);
    final itemContext = _PaneItemContext.of(context);
    final isHorizontal = axis == Axis.horizontal;
    final isVertical = axis == Axis.vertical;

    final decoration = BoxDecoration(
      color: widget.color ?? theme.highlightColor,
      borderRadius: BorderRadius.circular(100),
    );

    return IgnorePointer(
      child: Align(
        alignment: switch (axis) {
          Axis.horizontal => AlignmentDirectional.centerStart,
          Axis.vertical => AlignmentDirectional.bottomCenter,
        },
        child: SizedBox(
          width: isVertical ? kPaneItemTopMinWidth : null,
          height: isHorizontal ? kPaneItemMinHeight : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: Listenable.merge([
                  _shrinkController,
                  _growController,
                  _expandController,
                ]),
                builder: (context, child) {
                  var topPadding = widget.leftPadding;
                  var bottomPadding = widget.leftPadding;

                  if (view.displayMode == PaneDisplayMode.minimal) {
                    // On minimal mode, animation is disabled.
                    if (itemIndex == previousItemIndex) {
                      return const SizedBox.shrink();
                    }
                  } else if (!_isForceShow && !_isAnimatingForceShow) {
                    if (isSelected) {
                      final growAnimation = CurvedAnimation(
                        parent: _growController,
                        curve: Interval(0.5, 1, curve: _cachedCurve),
                      );
                      final growProgress = growAnimation.value;

                      if (growProgress == 0) {
                        return const SizedBox.shrink();
                      }

                      if (_goingDown) {
                        bottomPadding = widget.leftPadding * growProgress;
                      } else {
                        topPadding = widget.leftPadding * growProgress;
                      }
                    } else if (itemIndex == previousItemIndex) {
                      final shrinkAnimation = CurvedAnimation(
                        parent: _shrinkController,
                        curve: Interval(0, 0.5, curve: _cachedCurve),
                      );
                      final shrinkProgress = shrinkAnimation.value;

                      if (shrinkProgress == 1) {
                        return const SizedBox.shrink();
                      }

                      if (_goingDown) {
                        topPadding =
                            widget.leftPadding * (1.0 - shrinkProgress);
                      } else {
                        bottomPadding =
                            widget.leftPadding * (1.0 - shrinkProgress);
                      }
                    }
                  } else {
                    final expandAnimation = CurvedAnimation(
                      parent: _expandController,
                      curve: _cachedCurve,
                    );
                    final expandProgress = expandAnimation.value;
                    final tileHeight = constraints.maxHeight;
                    final distanceToBottom = tileHeight - widget.leftPadding;
                    topPadding = (distanceToBottom * (1.0 - expandProgress))
                        .clamp(widget.leftPadding, distanceToBottom);
                  }

                  return Padding(
                    padding: isHorizontal
                        ? EdgeInsetsDirectional.only(
                            top: topPadding,
                            bottom: bottomPadding,
                            start: 6 + (itemContext.depth * 28.0),
                            end: 6,
                          )
                        : EdgeInsetsDirectional.only(
                            start: topPadding,
                            end: bottomPadding,
                          ),
                    child: child,
                  );
                },
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
              );
            },
          ),
        ),
      ),
    );
  }
}
