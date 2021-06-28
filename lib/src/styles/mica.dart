import 'package:fluent_ui/fluent_ui.dart';

class Mica extends StatelessWidget {
  const Mica({
    Key? key,
    required this.child,
    this.elevation = 0,
    this.backgroundColor,
  })  : assert(elevation >= 0.0),
        super(key: key);

  final Widget child;
  final double elevation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    final Color boxColor = backgroundColor ?? theme.micaBackgroundColor;
    final Widget result = ColoredBox(color: boxColor, child: child);
    if (elevation > 0.0)
      return PhysicalModel(
        color: boxColor,
        elevation: elevation,
        child: result,
      );
    return result;
  }
}
