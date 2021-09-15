import 'package:fluent_ui/fluent_ui.dart';

/// A modal route that replaces the entire screen.
class FluentPageRoute<T> extends PageRoute<T> {
  late final WidgetBuilder _builder;
  // ignore: prefer_final_fields
  bool _maintainState = true;
  final String? _barrierLabel;

  /// Creates a modal route that replaces the entire screen.
  FluentPageRoute({
    bool maintainState = true,
    String? barrierLabel,
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : _maintainState = maintainState,
        _barrierLabel = barrierLabel,
        _builder = builder,
        super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

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
    final Widget result = _builder(context);
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
