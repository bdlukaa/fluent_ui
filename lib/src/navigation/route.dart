import 'package:fluent_ui/fluent_ui.dart';

class FluentPageRoute<T> extends PageRoute<T> {
  FluentPageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => 'Dismiss ';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);
}
