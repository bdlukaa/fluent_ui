import 'package:fluent_ui/fluent_ui.dart';

/// A page that creates a fluent style [PageRoute].
///
/// By default, when the created route is replaced by another, the previous
/// route remains in memory. To free all the resources when this is not
/// necessary, set [maintainState] to false.
///
/// The `fullscreenDialog` property specifies whether the created route is a
/// fullscreen modal dialog. On iOS, those routes animate from the bottom to the
/// top rather than horizontally.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.transitionDelegate] by
/// providing the optional `result` argument to the
/// [RouteTransitionRecord.markForPop] in the [TransitionDelegate.resolve].
///
/// See also:
///
///  * [FluentPageRoute], which is the [PageRoute] version of this class
class FluentPage<T> extends Page<T> {
  /// Creates a windows-styled page.
  const FluentPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.allowSnapshotting}
  final bool allowSnapshotting;

  @override
  Route<T> createRoute(BuildContext context) {
    return FluentPageRoute(
      builder: (_) => child,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      settings: this,
    );
  }
}

/// A modal route that replaces the entire screen.
class FluentPageRoute<T> extends PageRoute<T> {
  late final WidgetBuilder _builder;
  // ignore: prefer_final_fields
  bool _maintainState = true;
  final String? _barrierLabel;

  /// Creates a modal route that replaces the entire screen.
  FluentPageRoute({
    required WidgetBuilder builder,
    bool maintainState = true,
    String? barrierLabel,
    super.settings,
    super.fullscreenDialog,
  }) : _maintainState = maintainState,
       _barrierLabel = barrierLabel,
       _builder = builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => _barrierLabel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    assert(debugCheckHasFluentTheme(context));
    final result = _builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: DrillInPageTransition(
        animation: CurvedAnimation(
          parent: animation,
          curve: FluentTheme.of(context).animationCurve,
        ),
        child: result,
      ),
    );
  }

  @override
  bool get maintainState => _maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}
