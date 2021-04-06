import 'package:fluent_ui/fluent_ui.dart';

class FocusBorder extends StatelessWidget {
  const FocusBorder({
    Key? key,
    required this.child,
    required this.focused,
    this.border,
  }) : super(key: key);

  final Widget child;
  final Border? border;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    return AnimatedContainer(
      duration: context.theme.fastAnimationDuration ?? Duration.zero,
      curve: context.theme.animationCurve ?? Curves.linear,
      decoration: BoxDecoration(
        border: focused ? border ?? focusedButtonBorder(context.theme) : null,
      ),
      child: child,
    );
  }
}
