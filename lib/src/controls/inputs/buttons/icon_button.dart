import 'package:fluent_ui/fluent_ui.dart';

import 'base.dart';
import 'theme.dart';

class IconButton extends BaseButton {
  const IconButton({
    Key? key,
    required Widget icon,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    FocusNode? focusNode,
    bool autofocus = false,
    ButtonStyle? style,
  }) : super(
          key: key,
          child: icon,
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
      padding: ButtonState.all(const EdgeInsets.all(10.0)),
      backgroundColor: ButtonState.resolveWith((states) {
        return states.isDisabled
            ? ButtonThemeData.buttonColor(theme.brightness, states)
            : ButtonThemeData.uncheckedInputColor(theme, states)
                .withOpacity(states.isNone ? 0 : 0.2);
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) return theme.disabledColor;
      }),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      )),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).iconButtonStyle;
  }
}
