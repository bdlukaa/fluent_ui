part of 'view.dart';

/// A helper widget that implements fluent page transitions into
/// [NavigationView].
class NavigationBody extends StatefulWidget {
  /// Creates a navigation body.
  ///
  /// [index] must be greater than 0 and less than [children.length]
  const NavigationBody({
    Key? key,
    required this.index,
    required this.children,
    this.transitionBuilder,
    this.animationCurve,
    this.animationDuration,
  })  : assert(index >= 0 && index <= children.length),
        super(key: key);

  /// The pages this body can have.
  final List<Widget> children;

  /// The current page index. It must be greater than 0 and less
  /// than [children.length].
  final int index;

  /// The transition builder.
  ///
  /// It can be detect the display mode of the [NavigationView] above
  /// it, if any, and change the transition accordingly. By default,
  /// if the display mode is top, [HorizontalSlidePageTransition] is
  /// used, otherwise [DrillInPageTransition] is used.
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// The curve used by the transition. If null, [ThemeData.animationCurve]
  /// is used.
  /// 
  /// See also:
  ///   * [Curves], a collection of common animation easing curves.
  final Curve? animationCurve;
  
  /// The duration of the transition. If null, [ThemeData.fastAnimationDuration]
  /// is used.
  final Duration? animationDuration;

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
    final _body = _NavigationBody.maybeOf(context);
    return AnimatedSwitcher(
      switchInCurve: widget.animationCurve ??
          context.maybeTheme?.animationCurve ??
          Curves.linear,
      duration: widget.animationDuration ??
          context.maybeTheme?.fastAnimationDuration ??
          Duration(milliseconds: 300),
      layoutBuilder: (child, children) {
        return SizedBox(child: child);
      },
      transitionBuilder: (child, animation) {
        if (widget.transitionBuilder != null)
          return widget.transitionBuilder!(child, animation);
        bool useDrillTransition = true;
        if (_body != null && _body.displayMode != null) {
          if (_body.displayMode! == PaneDisplayMode.top)
            useDrillTransition = false;
        }
        if (useDrillTransition)
          return DrillInPageTransition(
            child: child,
            animation: animation,
          );
        else
          return HorizontalSlidePageTransition(
            child: child,
            animation: animation,
            fromLeft: previousIndex > widget.index,
          );
      },
      child: SizedBox(
        key: ValueKey<int>(widget.index),
        child: widget.children[widget.index],
      ),
    );
  }
}

class _NavigationBody extends InheritedWidget {
  _NavigationBody({
    Key? key,
    required this.child,
    required this.displayMode,
  }) : super(key: key, child: child);

  final Widget child;

  final PaneDisplayMode? displayMode;

  static _NavigationBody? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NavigationBody>();
  }

  @override
  bool updateShouldNotify(_NavigationBody oldWidget) {
    return true;
  }
}
