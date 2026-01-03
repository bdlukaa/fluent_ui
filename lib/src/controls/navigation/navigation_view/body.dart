part of 'view.dart';

/// A helper widget that implements fluent page transitions into
/// [NavigationView].
///
/// See also:
///   * [NavigationView], used alongside this to navigate through pages
///   * [NavigationAppBar], the app top bar
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

  final ValueKey<int>? itemKey;

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
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationViewContext.of(context);
    final theme = FluentTheme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: AnimatedSwitcher(
        switchInCurve: widget.animationCurve ?? theme.animationCurve,
        switchOutCurve: widget.animationCurve ?? theme.animationCurve,
        duration: widget.animationDuration ?? theme.fastAnimationDuration,
        reverseDuration:
            (widget.animationDuration ?? theme.fastAnimationDuration) ~/ 2,
        layoutBuilder: (child, children) {
          return SizedBox(child: child);
        },
        transitionBuilder: (child, animation) {
          if (widget.transitionBuilder != null) {
            return widget.transitionBuilder!(child, animation);
          }

          final isTop = view.displayMode == PaneDisplayMode.top;

          if (isTop) {
            return HorizontalSlidePageTransition(
              animation: animation,
              fromLeft: view.previousItemIndex > (view.pane?.selected ?? 0),
              child: child,
            );
          }

          return EntrancePageTransition(animation: animation, child: child);
        },
        child: () {
          final paneBodyBuilder = widget.paneBodyBuilder;
          if (paneBodyBuilder != null) {
            return paneBodyBuilder.call(
              view.pane?.selected != null ? view.pane!.selectedItem : null,
              view.pane?.selected != null
                  ? FocusTraversalGroup(child: view.pane!.selectedItem.body!)
                  : null,
            );
          } else {
            return _KeepAlivePage(
              key: ValueKey('nav_page_${view.pane?.selected}'),
              child: FocusTraversalGroup(
                policy: WidgetOrderTraversalPolicy(),
                child: view.pane!.selectedItem.body!,
              ),
            );
          }
        }(),
      ),
    );
  }
}

/// A wrapper widget that enables keep-alive functionality for navigation pages
/// and isolates repaints.
///
/// This widget:
/// - Uses [AutomaticKeepAliveClientMixin] to help preserve the state
///   of navigation pages when switching between them
/// - Wraps content in [RepaintBoundary] to prevent deeply nested child
///   repaints from causing the entire navigation body to repaint
///   (fixes https://github.com/bdlukaa/fluent_ui/issues/1180)
///
/// For full state preservation, the page widget itself should also implement
/// [AutomaticKeepAliveClientMixin].
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child, super.key});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(child: widget.child);
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
