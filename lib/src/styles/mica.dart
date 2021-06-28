import 'package:fluent_ui/fluent_ui.dart';

class Mica extends StatelessWidget {
  const Mica({
    Key? key,
    required this.child,
    this.elevation = 0,
  })  : assert(elevation >= 0.0),
        super(key: key);

  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final bool isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final Color boxColor = isDark ? Color(0xFF202020) : Color(0xFFf3f3f3);
    final Widget result = Container(color: boxColor, child: child);
    if (elevation > 0.0)
      return PhysicalModel(
        color: boxColor,
        elevation: elevation,
        child: result,
      );
    return result;
  }
}
