import 'package:fluent_ui/fluent_ui.dart';

/// A colored button.
///
/// {@macro fluent_ui.buttons.base}
///
/// See also:
///
///   * [Button], the default button
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
    final buttonTheme = ButtonTheme.of(context);
    return buttonTheme.filledButtonStyle;
  }

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final theme = FluentTheme.of(context);

    final def = ButtonStyle(
      backgroundColor: ButtonState.resolveWith((states) {
        return backgroundColor(theme, states);
      }),
      foregroundColor: ButtonState.resolveWith(
        (states) => foregroundColor(theme, states),
      ),
    );

    return super.defaultStyleOf(context).merge(def) ?? def;
  }

  static Color backgroundColor(ThemeData theme, Set<ButtonStates> states) {
    if (states.isDisabled) {
      return theme.resources.accentFillColorDisabled;
    } else if (states.isPressing) {
      return theme.accentColor.tertiaryBrushFor(theme.brightness);
    } else if (states.isHovering) {
      return theme.accentColor.secondaryBrushFor(theme.brightness);
    } else {
      return theme.accentColor.defaultBrushFor(theme.brightness);
    }
  }

  static Color foregroundColor(ThemeData theme, Set<ButtonStates> states) {
    final res = theme.resources;
    if (states.isPressing) {
      return res.textOnAccentFillColorSecondary;
    } else if (states.isHovering) {
      return res.textOnAccentFillColorPrimary;
    } else if (states.isDisabled) {
      return res.textOnAccentFillColorDisabled;
    }
    return res.textOnAccentFillColorPrimary;
  }
}
