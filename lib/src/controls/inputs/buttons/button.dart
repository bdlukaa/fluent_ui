import 'package:fluent_ui/fluent_ui.dart';

class Button extends BaseButton {
  const Button({
    Key? key,
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    FocusNode? focusNode,
    bool autofocus = false,
    ButtonStyle? style,
  }) : super(
          key: key,
          child: child,
          focusNode: focusNode,
          autofocus: autofocus,
          onLongPress: onLongPress,
          onPressed: onPressed,
          style: style,
        );

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    return ButtonStyle(
      cursor: theme.inputMouseCursor,
      padding: ButtonState.all(const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      )),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      )),
      backgroundColor: ButtonState.resolveWith((states) {
        return ButtonThemeData.buttonColor(theme.brightness, states);
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) return theme.disabledColor;
        return ButtonThemeData.buttonColor(theme.brightness, states)
            .basedOnLuminance();
      }),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).defaultButtonStyle;
  }
}
