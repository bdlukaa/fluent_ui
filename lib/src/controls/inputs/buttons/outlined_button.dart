import 'package:fluent_ui/fluent_ui.dart';

import 'base.dart';
import 'theme.dart';

class OutlinedButton extends BaseButton {
  const OutlinedButton({
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

    Color _color(Set<ButtonStates> states) {
      if (states.isDisabled)
        return theme.disabledColor;
      else if (states.isPressing)
        return theme.accentColor
            .resolveFromBrightness(theme.brightness, level: 3);
      else if (states.isHovering)
        return theme.accentColor.resolveFromBrightness(theme.brightness);
      else
        return theme.accentColor;
    }

    return ButtonStyle(
      cursor: theme.inputMouseCursor,
      padding: ButtonState.all(const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      )),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      )),
      border: ButtonState.resolveWith((states) {
        return BorderSide(color: _color(states));
      }),
      foregroundColor: ButtonState.resolveWith(_color),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).outlinedButtonStyle;
  }
}
