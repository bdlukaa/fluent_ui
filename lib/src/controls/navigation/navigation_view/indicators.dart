// ignore_for_file: use_key_in_widget_constructors

part of 'view.dart';

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
  const NavigationIndicator({this.curve, this.color, this.duration});

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
  /// The current navigation pane from the inherited navigation view.
  NavigationPane get pane {
    return InheritedNavigationView.of(context).pane!;
  }

  /// The currently selected item index.
  int get selectedIndex {
    return pane.selected ?? -1;
  }

  /// Whether the current item is selected.
  bool get isSelected {
    return itemIndex == selectedIndex;
  }

  /// The axis of the navigation indicator based on the display mode.
  Axis get axis {
    if (InheritedNavigationView.maybeOf(context)?.displayMode ==
        PaneDisplayMode.top) {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  /// The index of the current item.
  int get itemIndex {
    return InheritedNavigationView.of(context).currentItemIndex;
  }

  /// The index of the previously selected item.
  int get previousItemIndex {
    return InheritedNavigationView.of(context).previousItemIndex;
  }

  /// The current pane item.
  PaneItem get item {
    return pane.effectiveItems[itemIndex];
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Match WinUI3 NavigationView indicator padding and sizing
          // See: https://github.com/bdlukaa/fluent_ui/issues/1181
          margin: EdgeInsetsDirectional.symmetric(
            vertical: isTop ? 0.0 : 10.0,
            horizontal: isTop ? 12.0 : 0.0,
          ),
          width: isTop ? 20.0 : 3.0,
          height: isTop ? 3.0 : double.infinity,
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.color ?? theme.highlightColor)
                : widget.unselectedColor,
            borderRadius: BorderRadius.circular(100),
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
  ///
  /// Defaults are set according to WinUI3 NavigationView specifications:
  /// - Indicator width: 3.0px
  /// - Vertical padding: 10.0px on each side (for 40px item height)
  /// - Horizontal padding: 12.0px on each side (for top display mode)
  ///
  /// See: https://github.com/bdlukaa/fluent_ui/issues/1181
  const StickyNavigationIndicator({
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
  // Controller for the "shrink out" animation on the old item
  late AnimationController _shrinkController;
  // Controller for the "grow in" animation on the new item
  late AnimationController _growController;

  Curve _cachedCurve = Curves.easeInOut;
  int _cachedPreviousIndex = -1;
  int _cachedSelectedIndex = -1;

  // Track which direction the transition is going
  // true = new item is below old item (going down)
  // false = new item is above old item (going up)
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
      value: 1, // Start fully grown for initially selected item
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = FluentTheme.of(context);
    _cachedCurve = widget.curve ?? theme.animationCurve;

    final duration = widget.duration ?? theme.fasterAnimationDuration;
    _shrinkController.duration = duration;
    _growController.duration = duration;

    _updateAnimation();
  }

  @override
  void didUpdateWidget(StickyNavigationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      final duration =
          widget.duration ?? FluentTheme.of(context).fasterAnimationDuration;
      _shrinkController.duration = duration;
      _growController.duration = duration;
    }
    if (widget.curve != oldWidget.curve) {
      _cachedCurve = widget.curve ?? FluentTheme.of(context).animationCurve;
    }
  }

  void _updateAnimation() {
    if (!mounted) return;

    final currentPreviousIndex = previousItemIndex;
    final currentSelectedIndex = selectedIndex;

    // Check if selection actually changed
    if (_cachedPreviousIndex == currentPreviousIndex &&
        _cachedSelectedIndex == currentSelectedIndex) {
      return;
    }

    // Determine direction: going down means new item is below (has higher index)
    _goingDown = currentPreviousIndex < currentSelectedIndex;

    if (isSelected) {
      // This is the newly selected item - grow the indicator
      // The indicator grows from the side facing the old item
      _growController.forward(from: 0);
    } else if (itemIndex == currentPreviousIndex &&
        currentPreviousIndex != currentSelectedIndex) {
      // This was the previously selected item - shrink the indicator
      // The indicator shrinks towards the side facing the new item
      _shrinkController.forward(from: 0);
    }

    _cachedPreviousIndex = currentPreviousIndex;
    _cachedSelectedIndex = currentSelectedIndex;
  }

  @override
  void dispose() {
    _shrinkController.dispose();
    _growController.dispose();
    super.dispose();
  }

  bool get _shouldRender {
    // Show for selected item (always)
    if (isSelected) return true;
    // Show for previous item while shrinking animation is running
    if (itemIndex == previousItemIndex && _shrinkController.isAnimating) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedIndex.isNegative || !_shouldRender) {
      return const SizedBox.shrink();
    }

    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final isHorizontal = axis == Axis.horizontal;

    final decoration = BoxDecoration(
      color: widget.color ?? theme.highlightColor,
      borderRadius: BorderRadius.circular(100),
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_shrinkController, _growController]),
        builder: (context, child) {
          // Calculate padding values based on animation state
          // At rest: both paddings are at their normal value (widget.leftPadding)
          // During shrink: one side's padding increases to full height
          // During grow: one side's padding decreases from full to normal

          var topPadding = widget.leftPadding;
          var bottomPadding = widget.leftPadding;

          if (isSelected) {
            // Growing animation: reduce padding on the side facing the old item
            final growProgress = CurvedAnimation(
              parent: _growController,
              curve: Interval(0.5, 1, curve: _cachedCurve),
            ).value;

            if (_goingDown) {
              // New item is below old item, so grow from top (reduce top padding)
              // Start with max padding, animate to normal padding
              topPadding = widget.leftPadding * (2.0 - growProgress);
            } else {
              // New item is above old item, so grow from bottom (reduce bottom padding)
              bottomPadding = widget.leftPadding * (2.0 - growProgress);
            }
          } else if (itemIndex == previousItemIndex) {
            // Shrinking animation: increase padding on the side facing the new item
            final shrinkProgress = CurvedAnimation(
              parent: _shrinkController,
              curve: _cachedCurve,
            ).value;

            if (_goingDown) {
              // New item is below, so shrink towards bottom (increase top padding)
              topPadding = widget.leftPadding * (1.0 + shrinkProgress);
            } else {
              // New item is above, so shrink towards top (increase bottom padding)
              bottomPadding = widget.leftPadding * (1.0 + shrinkProgress);
            }
          }

          return Padding(
            padding: isHorizontal
                ? EdgeInsetsDirectional.only(
                    top: topPadding,
                    bottom: bottomPadding,
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
      ),
    );
  }
}
