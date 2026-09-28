part of 'view.dart';

/// A helper widget that implements fluent page transitions into
/// [NavigationView].
///
/// See also:
///   * [NavigationView], used alongside this to navigate through pages
class _NavigationBody extends StatefulWidget {
  /// Creates a navigation body.
  ///
  /// [index] must be greater than 0 and less than [children.length]
  const _NavigationBody({
    required this.itemKey,
    this.paneBodyBuilder,
    this.transitionBuilder,
    this.animationCurve,
    this.animationDuration,
  });

  final ValueKey<Object> itemKey;

  final NavigationContentBuilder? paneBodyBuilder;

  /// The transition builder.
  ///
  /// It can be detect the display mode of the parent [NavigationView], if any,
  /// and change the transition accordingly. By default, if the display mode is
  /// top, [HorizontalSlidePageTransition] is used, otherwise
  /// [EntrancePageTransition] is used.
  ///
  /// ```dart
  /// transitionBuilder: (child, animation) {
  ///   return DrillInPageTransition(child: child, animation: animation);
  /// },
  /// ```
  ///
  /// See also:
  ///
  ///  * [EntrancePageTransition], used by default
  ///  * [HorizontalSlidePageTransition], used by default on top navigation
  ///  * [DrillInPageTransition], used when users navigate deeper into an app
  ///  * [SuppressPageTransition], to have no animation at all
  ///  * <https://docs.microsoft.com/en-us/windows/apps/design/motion/page-transitions>
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// The curve used by the transition.
  ///
  /// See also:
  ///
  ///   * [Curves], a collection of common animation easing curves.
  final Curve? animationCurve;

  /// The duration of the transition. [NavigationPaneThemeData.animationDuration]
  /// is used by default.
  ///
  /// See also:
  ///   * [FluentThemeData.fastAnimationDuration], the duration used by default.
  final Duration? animationDuration;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration),
      );
  }

  @override
  State<_NavigationBody> createState() => _NavigationBodyState();
}

class _NavigationBodyState extends State<_NavigationBody> {
  final Map<Object, Widget> _pages = {};
  final Set<Object> _keptAlive = {};
  Object? _currentKey;

  void _keepAlive(Object key) => _keptAlive.add(key);

  void _releaseKeepAlive(Object key) {
    if (!_keptAlive.remove(key) || key == _currentKey) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && key != _currentKey && !_keptAlive.contains(key)) {
        setState(() => _pages.remove(key));
      }
    });
  }

  Widget _buildPage(BuildContext context, NavigationViewContext view) {
    final paneBodyBuilder = widget.paneBodyBuilder;
    if (paneBodyBuilder != null) {
      return paneBodyBuilder.call(
        view.pane?.selected != null ? view.pane!.selectedItem : null,
        view.pane?.selected != null
            ? FocusTraversalGroup(child: view.pane!.selectedItem.body!)
            : null,
      );
    }
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: view.pane!.selectedItem.body!,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationViewContext.of(context);
    final theme = FluentTheme.of(context);

    if (widget.paneBodyBuilder != null) {
      return ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: _buildPage(context, view),
      );
    }

    final pane = view.pane!;
    final validPageKeys = <Object>{};
    for (final (index, item) in pane.effectiveItems.indexed) {
      final itemKey = item.key ?? index;
      validPageKeys.add(itemKey);
      if (_pages.containsKey(itemKey)) {
        _pages[itemKey] = FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: item.body!,
        );
      }
    }
    _pages.removeWhere((pageKey, _) => !validPageKeys.contains(pageKey));
    _keptAlive.removeWhere((pageKey) => !validPageKeys.contains(pageKey));

    final key = widget.itemKey.value;
    final previous = _currentKey;
    if (previous != null && previous != key && !_keptAlive.contains(previous)) {
      _pages.remove(previous);
    }
    _currentKey = key;
    _pages[key] = _buildPage(context, view);

    final duration = widget.animationDuration ?? theme.fastAnimationDuration;
    final curve = widget.animationCurve ?? theme.animationCurve;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final entry in _pages.entries)
            _NavigationPageEntry(
              key: ValueKey(entry.key),
              active: entry.key == key,
              duration: duration,
              curve: curve,
              transitionBuilder: widget.transitionBuilder,
              isTop: view.displayMode == PaneDisplayMode.top,
              fromLeft: view.previousItemIndex > (view.pane?.selected ?? 0),
              onKeepAlive: () => _keepAlive(entry.key),
              onReleaseKeepAlive: () => _releaseKeepAlive(entry.key),
              child: entry.value,
            ),
        ],
      ),
    );
  }
}

class _NavigationPageEntry extends StatefulWidget {
  const _NavigationPageEntry({
    required this.active,
    required this.duration,
    required this.curve,
    required this.transitionBuilder,
    required this.isTop,
    required this.fromLeft,
    required this.onKeepAlive,
    required this.onReleaseKeepAlive,
    required this.child,
    super.key,
  });

  final bool active;
  final Duration duration;
  final Curve curve;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final bool isTop;
  final bool fromLeft;
  final VoidCallback onKeepAlive;
  final VoidCallback onReleaseKeepAlive;
  final Widget child;

  @override
  State<_NavigationPageEntry> createState() => _NavigationPageEntryState();
}

class _NavigationPageEntryState extends State<_NavigationPageEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.active ? 1 : 0,
  );
  Listenable? _keepAliveHandle;

  @override
  void didUpdateWidget(_NavigationPageEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.active && !oldWidget.active) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _keepAliveHandle?.removeListener(widget.onReleaseKeepAlive);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<KeepAliveNotification>(
      onNotification: (notification) {
        if (!identical(_keepAliveHandle, notification.handle)) {
          _keepAliveHandle?.removeListener(widget.onReleaseKeepAlive);
          _keepAliveHandle = notification.handle
            ..addListener(widget.onReleaseKeepAlive);
          widget.onKeepAlive();
        }
        return true;
      },
      child: RepaintBoundary(child: widget.child),
    );

    return Offstage(
      offstage: !widget.active,
      child: TickerMode(
        enabled: widget.active,
        child: AnimatedBuilder(
          animation: _controller,
          child: child,
          builder: (context, child) {
            final animation = CurvedAnimation(
              parent: _controller,
              curve: widget.curve,
            );
            if (widget.transitionBuilder case final builder?) {
              return builder(child!, animation);
            }
            if (widget.isTop) {
              return HorizontalSlidePageTransition(
                animation: animation,
                fromLeft: widget.fromLeft,
                child: child!,
              );
            }
            return EntrancePageTransition(animation: animation, child: child!);
          },
        ),
      ),
    );
  }
}

/// A widget that tells what's the the current state of a parent
/// [NavigationView], if any.
///
/// This provides context information about the navigation state to descendant
/// widgets, including the current display mode, selected item, and navigation
/// history for smooth indicator animations.
///
/// See also:
///
///  * [NavigationView], which provides the information for this
class NavigationViewContext extends InheritedWidget {
  /// Creates an inherited navigation view.
  const NavigationViewContext({
    required super.child,
    required this.displayMode,
    required this.isMinimalPaneOpen,
    required this.isCompactOverlayOpen,
    required this.pane,
    required this.previousItemIndex,
    required this.isTransitioning,
    required this.toggleButtonPosition,
    required this.canPop,
    super.key,
  });

  factory NavigationViewContext.copy({
    required NavigationViewContext parent,
    required Widget child,
  }) {
    return NavigationViewContext(
      displayMode: parent.displayMode,
      isMinimalPaneOpen: parent.isMinimalPaneOpen,
      isCompactOverlayOpen: parent.isCompactOverlayOpen,
      pane: parent.pane,
      previousItemIndex: parent.previousItemIndex,
      isTransitioning: parent.isTransitioning,
      toggleButtonPosition: parent.toggleButtonPosition,
      canPop: parent.canPop,
      child: child,
    );
  }

  /// The current pane display mode according to the current state.
  final PaneDisplayMode displayMode;

  /// Whether the minimal pane is open or not
  final bool isMinimalPaneOpen;

  final bool isCompactOverlayOpen;

  /// The current navigation pane, if any
  final NavigationPane? pane;

  /// The previous selected index.
  ///
  /// Used by [NavigationIndicator]s to animate from the old item to the new one.
  /// This enables the "sticky" indicator effect where the indicator stretches
  /// from the previous position to the new position.
  final int previousItemIndex;

  /// Whether the navigation panes are transitioning or not.
  ///
  /// When true, interactive features on pane items (like info badges) are
  /// hidden to provide a cleaner transition animation.
  final bool isTransitioning;

  /// The position of the toggle pane button.
  final PaneToggleButtonPosition toggleButtonPosition;

  /// Whether the navigation view can pop the current item.
  final bool canPop;

  /// Returns the closest [NavigationViewContext] ancestor, if any.
  static NavigationViewContext? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationViewContext>();
  }

  /// Returns the closest [NavigationViewContext] ancestor.
  ///
  /// Throws if no ancestor is found.
  static NavigationViewContext of(BuildContext context) {
    return maybeOf(context)!;
  }

  @override
  bool updateShouldNotify(covariant NavigationViewContext oldWidget) {
    return oldWidget.displayMode != displayMode ||
        oldWidget.isMinimalPaneOpen != isMinimalPaneOpen ||
        oldWidget.isCompactOverlayOpen != isCompactOverlayOpen ||
        oldWidget.pane != pane ||
        oldWidget.previousItemIndex != previousItemIndex ||
        oldWidget.isTransitioning != isTransitioning ||
        oldWidget.toggleButtonPosition != toggleButtonPosition ||
        oldWidget.canPop != canPop;
  }
}
