import 'package:fluent_ui/fluent_ui.dart';

/// A colored button.
///
/// {@macro fluent_ui.buttons.base}
///
/// See also:
///
///   * [OutlinedButton], an outlined button
///   * [TextButton], a borderless button with mainly text-based content
class FilledButton extends Button {
  /// Creates a filled button
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
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    return ButtonStyle(backgroundColor: ButtonState.resolveWith((states) {
      return backgroundColor(theme, states);
    }), foregroundColor: ButtonState.resolveWith((states) {
      return backgroundColor(theme, states).basedOnLuminance();
    }));
  }

  static Color backgroundColor(ThemeData theme, Set<ButtonStates> states) {
    if (states.isDisabled) {
      return ButtonThemeData.buttonColor(theme.brightness, states);
    } else if (states.isPressing) {
      if (theme.brightness.isDark) {
        return theme.accentColor.darker;
      } else {
        theme.accentColor.lighter;
      }
    } else if (states.isHovering) {
      if (theme.brightness.isDark) {
        return theme.accentColor.dark;
      } else {
        theme.accentColor.light;
      }
    }
    return theme.accentColor;
  }
}
