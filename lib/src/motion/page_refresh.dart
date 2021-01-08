import 'package:fluent_ui/fluent_ui.dart';

class PageRefreshTransition extends StatelessWidget {
  const PageRefreshTransition({
    Key key,
    @required this.child,
    @required this.animation,
  })  : assert(child != null),
        assert(animation != null),
        super(key: key);

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      alwaysIncludeSemantics: false,
      child: SlideTransition(
        child: child,
        position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0))
            .animate(animation),
      ),
    );
  }
}
