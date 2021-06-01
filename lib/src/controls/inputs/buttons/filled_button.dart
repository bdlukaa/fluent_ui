import 'package:fluent_ui/fluent_ui.dart';

import 'base.dart';
import 'theme.dart';

class FilledButton extends BaseButton {
  const FilledButton({
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
      elevation: ButtonState.all(4.0),
      padding: ButtonState.all(const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      )),
      backgroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          switch (theme.brightness) {
            case Brightness.light:
              return Color(0xFFf1f1f1);
            case Brightness.dark:
              return theme.accentColor.darkest;
          }
        } else if (states.isPressing)
          return theme.accentColor.resolveFromBrightness(theme.brightness);
        else if (states.isHovering)
          return theme.accentColor
              .resolveFromBrightness(theme.brightness, level: 1);
        else
          return theme.accentColor;
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) return theme.disabledColor;
      }),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).filledButtonStyle;
  }
}
