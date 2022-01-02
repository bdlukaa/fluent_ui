import 'package:fluent_ui/fluent_ui.dart';

/// A borderless button with mainly text-based content
///
/// {@macro fluent_ui.buttons.base}
///
/// See also:
///
///   * [OutlinedButton], an outlined button
///   * [FilledButton], a colored button
class TextButton extends BaseButton {
  /// Creates a text-button.
  const TextButton({
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
      backgroundColor: ButtonState.all(Colors.transparent),
      padding: ButtonState.all(const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8.0,
      )),
      foregroundColor: ButtonState.resolveWith((states) {
        late Color color;
        if (states.isDisabled) {
          color = theme.disabledColor;
        } else if (states.isPressing) {
          color = theme.accentColor.resolveFromBrightness(
            theme.brightness,
            level: 1,
          );
        } else if (states.isHovering) {
          color = theme.accentColor.resolveFromBrightness(theme.brightness);
        } else {
          color = theme.accentColor;
        }
        return color;
      }),
      textStyle: ButtonState.all(const TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      )),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).outlinedButtonStyle;
  }
}
