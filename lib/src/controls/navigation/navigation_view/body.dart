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
  final _pageKey = GlobalKey<State<PageView>>();
  PageController? _pageController;

  PageController get pageController => _pageController!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final view = InheritedNavigationView.of(context);
    final selected = view.pane?.selected ?? 0;

    _pageController ??= PageController(initialPage: selected);

    if (pageController.hasClients) {
      if (view.previousItemIndex != selected ||
          pageController.page != selected) {
        pageController.jumpToPage(selected);
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = InheritedNavigationView.of(context);
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
            // Other transtitions other than default is only applied to top nav
            // when clicking overflow on topnav, transition is from bottom
            // otherwise if prevItem is on right side of nextActualItem, transition is from left
            //           if prevItem is on left side of nextActualItem, transition is from right
            // click on Settings item is considered Default
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
                  ? FocusTraversalGroup(
                      // body is guaranteed to be non-null since effectiveItems
                      // filters out items with null body
                      child: view.pane!.selectedItem.body!,
                    )
                  : null,
            );
          } else {
            // Use PageView for efficient page management
            // Pages can use AutomaticKeepAliveClientMixin to preserve state
            return KeyedSubtree(
              key: widget.itemKey,
              child: PageView.builder(
                key: _pageKey,
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                // Allow pages to stay alive when using AutomaticKeepAliveClientMixin
                allowImplicitScrolling: true,
                itemCount: view.pane!.effectiveItems.length,
                itemBuilder: (context, index) {
                  final isSelected = view.pane!.selected == index;
                  final item = view.pane!.effectiveItems[index];

                  // Wrap in a _KeepAlivePage to help preserve state
                  return _KeepAlivePage(
                    key: ValueKey('nav_page_$index'),
                    child: ExcludeFocus(
                      excluding: !isSelected,
                      child: FocusTraversalGroup(
                        policy: WidgetOrderTraversalPolicy(),
                        // body is guaranteed to be non-null since effectiveItems
                        // filters out items with null body
                        child: item.body!,
                      ),
                    ),
                  );
                },
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
    // RepaintBoundary isolates this page's repaints from affecting
    // the parent navigation body or other pages
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
class InheritedNavigationView extends InheritedWidget {
  /// Creates an inherited navigation view.
  const InheritedNavigationView({
    required super.child,
    required this.displayMode,
    super.key,
    this.minimalPaneOpen = false,
    this.pane,
    this.previousItemIndex = 0,
    this.currentItemIndex = -1,
    this.isTransitioning = false,
    this.itemDepth = 0,
  });

  /// The current pane display mode according to the current state.
  final PaneDisplayMode displayMode;

  /// Whether the minimal pane is open or not
  final bool minimalPaneOpen;

  /// The current navigation pane, if any
  final NavigationPane? pane;

  /// The previous index selected index.
  ///
  /// Used by [NavigationIndicator]s to animate from the old item to the new one.
  /// This enables the "sticky" indicator effect where the indicator stretches
  /// from the previous position to the new position.
  final int previousItemIndex;

  /// Used by [NavigationIndicator] to know what's the current index of the
  /// item being rendered.
  final int currentItemIndex;

  /// Whether the navigation panes are transitioning or not.
  ///
  /// When true, interactive features on pane items (like info badges) are hidden
  /// to provide a cleaner transition animation.
  final bool isTransitioning;

  /// The depth level of the current item in the navigation hierarchy (0 = root level).
  ///
  /// Used by [NavigationIndicator]s to adjust padding based on nesting level.
  final int itemDepth;

  /// Returns the closest [InheritedNavigationView] ancestor, if any.
  static InheritedNavigationView? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedNavigationView>();
  }

  /// Returns the closest [InheritedNavigationView] ancestor.
  ///
  /// Throws if no ancestor is found.
  static InheritedNavigationView of(BuildContext context) {
    return maybeOf(context)!;
  }

  /// Creates a widget that merges the current navigation view state with
  /// the given values.
  ///
  /// This is used internally by [PaneItem] to provide indicator-specific
  /// context without creating a full new inherited widget.
  static Widget merge({
    required Widget child,
    Key? key,
    int? currentItemIndex,
    NavigationPane? pane,
    PaneDisplayMode? displayMode,
    bool? minimalPaneOpen,
    int? previousItemIndex,
    bool? currentItemSelected,
    bool? isTransitioning,
    int? itemDepth,
  }) {
    return Builder(
      builder: (context) {
        final current = InheritedNavigationView.maybeOf(context);
        return InheritedNavigationView(
          key: key,
          displayMode:
              displayMode ?? current?.displayMode ?? PaneDisplayMode.open,
          minimalPaneOpen: minimalPaneOpen ?? current?.minimalPaneOpen ?? false,
          currentItemIndex: currentItemIndex ?? current?.currentItemIndex ?? -1,
          pane: pane ?? current?.pane,
          previousItemIndex:
              previousItemIndex ?? current?.previousItemIndex ?? 0,
          isTransitioning: isTransitioning ?? current?.isTransitioning ?? false,
          itemDepth: itemDepth ?? current?.itemDepth ?? 0,
          child: child,
        );
      },
    );
  }

  @override
  bool updateShouldNotify(covariant InheritedNavigationView oldWidget) {
    return oldWidget.displayMode != displayMode ||
        oldWidget.minimalPaneOpen != minimalPaneOpen ||
        oldWidget.pane != pane ||
        oldWidget.previousItemIndex != previousItemIndex ||
        oldWidget.currentItemIndex != currentItemIndex ||
        oldWidget.isTransitioning != isTransitioning ||
        oldWidget.itemDepth != itemDepth;
  }
}
