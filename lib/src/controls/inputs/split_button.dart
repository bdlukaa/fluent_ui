import 'package:fluent_ui/fluent_ui.dart';

class SplitButtonBar extends StatelessWidget {
  const SplitButtonBar({
    Key? key,
    required this.buttons,
    this.style,
  })  : assert(buttons.length > 1, 'There must 2 or more buttons'),
        super(key: key);

  final List<Widget> buttons;
  final SplitButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!.splitButtonStyle?.copyWith(this.style);
    // List<Widget> newButtons = [];
    // for (final button in buttons) {
    //   newButtons.add(button.child);
    //   if (buttons.last != button)
    //     newButtons.add(Divider(direction: Axis.vertical));
    // }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttons.length, (index) {
        final button = buttons[index];
        Widget b = Theme(
          data: context.theme!.copyWith(Style(
              buttonStyle: ButtonStyle(
            decoration: (state) => BoxDecoration(
              borderRadius: (index == 0 || index == buttons.length - 1)
                  ? BorderRadius.horizontal(
                      left: index == 0 ? Radius.circular(2) : Radius.zero,
                      right: index == buttons.length - 1
                          ? Radius.circular(2)
                          : Radius.zero,
                    )
                  : null,
              color: buttonColor(context.theme!, state),
            ),
            margin: EdgeInsets.zero,
          ))),
          child: button,
        );
        if (index == 0) return b;
        return Padding(
          padding: EdgeInsets.only(left: style?.interval ?? 0),
          child: b,
        );
      }),
    );
  }
}

class SplitButtonStyle {
  final BorderRadius? borderRadius;
  final double? interval;

  final ButtonStyle? defaultButtonStyle;

  const SplitButtonStyle({
    this.borderRadius,
    this.interval,
    this.defaultButtonStyle,
  });

  static SplitButtonStyle defaultTheme(Style style, [Brightness? brightness]) {
    return SplitButtonStyle(
      borderRadius: BorderRadius.circular(4),
      interval: 1,
      defaultButtonStyle: defaultButtonTheme(style, brightness),
    );
  }

  static ButtonStyle defaultButtonTheme(Style style, [Brightness? brightness]) {
    final defButton = ButtonStyle(
      animationDuration: style.animationDuration,
      animationCurve: style.animationCurve,
      cursor: buttonCursor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.zero,
      decoration: (state) {
        return BoxDecoration(color: uncheckedInputColor(style, state));
      },
    );
    final disabledTextStyle = TextStyle(
      color: Colors.grey[100],
      fontWeight: FontWeight.bold,
    );

    if (brightness == null || brightness == Brightness.light)
      return defButton.copyWith(ButtonStyle(
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ));
    else
      return defButton.copyWith(ButtonStyle(
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ));
  }

  SplitButtonStyle copyWith(SplitButtonStyle? style) {
    return SplitButtonStyle(
      borderRadius: style?.borderRadius ?? borderRadius,
      interval: style?.interval ?? interval,
    );
  }
}
