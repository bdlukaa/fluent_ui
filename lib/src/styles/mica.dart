import 'package:fluent_ui/fluent_ui.dart';

class Mica extends StatelessWidget {
  const Mica({Key? key, required this.child,}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Color(0xFF202020) : Color(0xFFf3f3f3),
      child: child,
    );
  }
}
