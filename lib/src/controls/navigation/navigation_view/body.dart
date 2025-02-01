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
    // ignore: unused_element
    super.key,
    required this.itemKey,
    this.paneBodyBuilder,
    this.transitionBuilder,
    // ignore: unused_element
    this.animationCurve,
    // ignore: unused_element
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
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = InheritedNavigationView.of(context);
    final theme = FluentTheme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: AnimatedSwitcher(
        switchInCurve: widget.animationCurve ?? Curves.ease,
        switchOutCurve: widget.animationCurve ?? Curves.ease,
        duration: widget.animationDuration ?? const Duration(milliseconds: 300),
        reverseDuration:
            widget.animationDuration ?? const Duration(microseconds: 150),
        layoutBuilder: (child, children) {
          return SizedBox(child: child);
        },
        transitionBuilder: (child, animation) {
          if (widget.transitionBuilder != null) {
            return widget.transitionBuilder!(child, animation);
          }

          var isTop = view.displayMode == PaneDisplayMode.top;

          if (isTop) {
            // Other transtitions other than default is only applied to top nav
            // when clicking overflow on topnav, transition is from bottom
            // otherwise if prevItem is on left side of nextActualItem, transition is from left
            //           if prevItem is on right side of nextActualItem, transition is from right
            // click on Settings item is considered Default
            return HorizontalSlidePageTransition(
              animation: animation,
              fromLeft: view.previousItemIndex < (view.pane?.selected ?? 0),
              child: child,
            );
          }

          return EntrancePageTransition(
            animation: animation,
            child: child,
          );
        },
        child: () {
          final paneBodyBuilder = widget.paneBodyBuilder;
          if (paneBodyBuilder != null) {
            return paneBodyBuilder.call(
              view.pane?.selected != null ? view.pane!.selectedItem : null,
              view.pane?.selected != null
                  ? FocusTraversalGroup(
                      child: view.pane!.selectedItem.body,
                    )
                  : null,
            );
          } else {
            return KeyedSubtree(
              key: widget.itemKey,
              child: PageView.builder(
                key: _pageKey,
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                itemCount: view.pane!.effectiveItems.length,
                itemBuilder: (context, index) {
                  final isSelected = view.pane!.selected == index;
                  final item = view.pane!.effectiveItems[index];

                  return ExcludeFocus(
                    excluding: !isSelected,
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: item.body,
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

/// A widget that tells what's the the current state of a parent
/// [NavigationView], if any.
///
/// See also:
///
///  * [NavigationView], which provides the information for this
class InheritedNavigationView extends InheritedWidget {
  /// Creates an inherited navigation view.
  const InheritedNavigationView({
    super.key,
    required super.child,
    required this.displayMode,
    this.minimalPaneOpen = false,
    this.pane,
    this.previousItemIndex = 0,
    this.currentItemIndex = -1,
    this.isTransitioning = false,
  });

  /// The current pane display mode according to the current state.
  final PaneDisplayMode displayMode;

  /// Whether the minimal pane is open or not
  final bool minimalPaneOpen;

  /// The current navigation pane, if any
  final NavigationPane? pane;

  /// The previous index selected index.
  ///
  /// Usually used by a [NavigationIndicator]s to display the animation from the
  /// old item to the new one.
  final int previousItemIndex;

  /// Used by [NavigationIndicator] to know what's the current index of the
  /// item
  final int currentItemIndex;

  /// Whether the navigation panes are transitioning or not.
  final bool isTransitioning;

  static InheritedNavigationView? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedNavigationView>();
  }

  static InheritedNavigationView of(BuildContext context) {
    return maybeOf(context)!;
  }

  static Widget merge({
    Key? key,
    required Widget child,
    int? currentItemIndex,
    NavigationPane? pane,
    PaneDisplayMode? displayMode,
    bool? minimalPaneOpen,
    int? previousItemIndex,
    bool? currentItemSelected,
    bool? isTransitioning,
  }) {
    return Builder(builder: (context) {
      final current = InheritedNavigationView.maybeOf(context);
      return InheritedNavigationView(
        key: key,
        displayMode:
            displayMode ?? current?.displayMode ?? PaneDisplayMode.open,
        minimalPaneOpen: minimalPaneOpen ?? current?.minimalPaneOpen ?? false,
        currentItemIndex: currentItemIndex ?? current?.currentItemIndex ?? -1,
        pane: pane ?? current?.pane,
        previousItemIndex: previousItemIndex ?? current?.previousItemIndex ?? 0,
        isTransitioning: isTransitioning ?? current?.isTransitioning ?? false,
        child: child,
      );
    });
  }

  @override
  bool updateShouldNotify(covariant InheritedNavigationView oldWidget) {
    return oldWidget.displayMode != displayMode ||
        oldWidget.minimalPaneOpen != minimalPaneOpen ||
        oldWidget.pane != pane ||
        oldWidget.previousItemIndex != previousItemIndex ||
        oldWidget.currentItemIndex != currentItemIndex ||
        oldWidget.isTransitioning != isTransitioning;
  }
}

/// Makes the [GlobalKey]s for [PaneItem]s accesible on the scope.
class PaneItemKeys extends InheritedWidget {
  const PaneItemKeys({
    super.key,
    required super.child,
    required this.keys,
  });

  final Map<int, GlobalKey> keys;

  /// Gets the item global key based on the index
  static GlobalKey of(int index, BuildContext context) {
    final reference =
        context.dependOnInheritedWidgetOfExactType<PaneItemKeys>()!;
    return reference.keys[index]!;
  }

  @override
  bool updateShouldNotify(PaneItemKeys oldWidget) {
    return keys != oldWidget.keys;
  }
}
