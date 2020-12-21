import 'package:fluent_ui/fluent_ui.dart';

class SplitButtonBar extends StatelessWidget {
  const SplitButtonBar({Key key, @required this.buttons, this.style})
      : assert(buttons != null),
        assert(buttons.length > 1, 'There must 2 or more buttons'),
        super(key: key);

  final List<SplitButton> buttons;
  final SplitButtonStyle style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    // final style = context.theme.splitButtonStyle.copyWith(this.style);
    List<Widget> newButtons = [];
    for (final button in buttons) {
      newButtons.add(button.child);
      if (buttons.last != button)
        newButtons.add(Divider(direction: Axis.vertical));
    }
    return Container(
      child: Row(
        children: List.generate(buttons.length, (index) => null),
      ),
    );
  }
}

class SplitButton {
  final Widget child;
  final SplitButtonStyle style;
  final VoidCallback onPressed;

  const SplitButton({
    @required this.child,
    this.style,
    this.onPressed,
  }) : assert(child != null);
}

class SplitButtonStyle {
  final ButtonState<Color> color;

  final BorderRadiusGeometry borderRadius;
  final ButtonState<Border> border;

  SplitButtonStyle({
    this.color,
    this.borderRadius,
    this.border,
  });

  static SplitButtonStyle defaultTheme([Brightness brightness]) {
    return SplitButtonStyle();
  }

  SplitButtonStyle copyWith(SplitButtonStyle style) {
    if (style == null) return this;
    return SplitButtonStyle();
  }
}
