part of 'view.dart';

/// A helper widget that implements fluent page transitions into
/// [NavigationView].
///
/// See also:
///   * [NavigationView], used alongside this to navigate through pages
///   * [NavigationAppBar], the app top bar
class NavigationBody extends StatefulWidget {
  /// Creates a navigation body.
  ///
  /// [index] must be greater than 0 and less than [children.length]
  const NavigationBody({
    Key? key,
    required this.index,
    required List<Widget> children,
    this.transitionBuilder,
    this.animationCurve,
    this.animationDuration,
  })  : assert(index >= 0 && index <= children.length),
        // ignore: prefer_initializing_formals
        children = children,
        itemBuilder = null,
        itemCount = null,
        super(key: key);

  /// Creates a navigation body that uses a builder to supply child pages
  ///
  /// [index] must be greater than 0 and less than [itemCount] if it is provided
  const NavigationBody.builder({
    Key? key,
    required this.index,
    required IndexedWidgetBuilder itemBuilder,
    this.itemCount,
    this.transitionBuilder,
    this.animationCurve,
    this.animationDuration,
  })  : assert(index >= 0 && (itemCount == null || index <= itemCount)),
        // ignore: prefer_initializing_formals
        itemBuilder = itemBuilder,
        children = null,
        super(key: key);

  /// The pages this body can have
  final List<Widget>? children;

  /// The builder that will be used to build the pages
  final IndexedWidgetBuilder? itemBuilder;

  /// Optional number of items to assume builder can create.
  final int? itemCount;

  /// The current page index. It must be greater than 0 and less
  /// than [children.length] or [itemCount].
  final int index;

  /// The transition builder.
  ///
  /// It can be detect the display mode of the [NavigationView] above
  /// it, if any, and change the transition accordingly. By default,
  /// if the display mode is top, [HorizontalSlidePageTransition] is
  /// used, otherwise [DrillInPageTransition] is used.
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// The curve used by the transition. [NavigationPaneThemeData.animationCurve]
  /// is used by default.
  ///
  /// See also:
  ///   * [Curves], a collection of common animation easing curves.
  final Curve? animationCurve;

  /// The duration of the transition. [NavigationPaneThemeData.animationDuration]
  /// is used by default.
  ///
  /// See also:
  ///   * [ThemeData.fastAnimationDuration], the duration used by default.
  final Duration? animationDuration;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(
      DiagnosticsProperty<Curve>('animationCurve', animationCurve),
    );
    properties.add(
      DiagnosticsProperty<Duration>('animationDuration', animationDuration),
    );
  }

  @override
  _NavigationBodyState createState() => _NavigationBodyState();
}

class _NavigationBodyState extends State<NavigationBody> {
  late int previousIndex;

  @override
  void initState() {
    super.initState();
    previousIndex = widget.index;
  }

  @override
  void didUpdateWidget(NavigationBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    previousIndex = oldWidget.index;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final _body = _NavigationBody.maybeOf(context);
    final theme = FluentTheme.of(context);
    final NavigationPaneThemeData paneTheme = NavigationPaneTheme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: AnimatedSwitcher(
        switchInCurve:
            widget.animationCurve ?? paneTheme.animationCurve ?? Curves.linear,
        duration: widget.animationDuration ??
            paneTheme.animationDuration ??
            Duration.zero,
        layoutBuilder: (child, children) {
          return SizedBox(child: child);
        },
        transitionBuilder: (child, animation) {
          if (widget.transitionBuilder != null) {
            return widget.transitionBuilder!(child, animation);
          }
          bool useDrillTransition = true;
          if (_body != null && _body.displayMode != null) {
            if (_body.displayMode! == PaneDisplayMode.top) {
              useDrillTransition = false;
            }
          }
          if (useDrillTransition) {
            return DrillInPageTransition(
              child: child,
              animation: animation,
            );
          } else {
            return HorizontalSlidePageTransition(
              child: child,
              animation: animation,
              fromLeft: previousIndex > widget.index,
            );
          }
        },
        child: SizedBox(
          key: ValueKey<int>(widget.index),
          child: widget.itemBuilder?.call(context, widget.index) ??
              widget.children![widget.index],
        ),
      ),
    );
  }
}

/// A widget that tells [NavigationBody] what's the panel display
/// mode of the parent [NavigationView], if any.
class _NavigationBody extends InheritedWidget {
  const _NavigationBody({
    Key? key,
    required Widget child,
    required this.displayMode,
    required this.minimalPaneOpen,
  }) : super(key: key, child: child);

  final PaneDisplayMode? displayMode;
  final bool minimalPaneOpen;

  static _NavigationBody? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NavigationBody>();
  }

  @override
  bool updateShouldNotify(_NavigationBody oldWidget) {
    return true;
  }
}
