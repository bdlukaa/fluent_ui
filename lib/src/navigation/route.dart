import 'package:fluent_ui/fluent_ui.dart';

class FluentPageRoute<T> extends PageRoute<T> {
  late WidgetBuilder _builder;
  bool _maintainState = true;
  String? _barrierLabel;

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
    final Widget result = _builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  bool get maintainState => _maintainState;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}
