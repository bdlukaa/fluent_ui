import 'package:fluent_ui/fluent_ui.dart';

/// An outlined button
///
/// {@macro fluent_ui.buttons.base}
///
/// See also:
///
///   * [FilledButton], a colored button
///   * [HyperlinkButton], a borderless button with mainly text-based content
class OutlinedButton extends BaseButton {
  const OutlinedButton({
    super.key,
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.focusNode,
    super.autofocus = false,
    super.style,
    super.focusable = true,
  });

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ButtonStyle(
      padding: ButtonState.all(kDefaultButtonPadding),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      )),
      border: ButtonState.all(BorderSide(color: theme.inactiveColor)),
      foregroundColor: ButtonState.all(theme.inactiveColor),
      backgroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlFillColorDisabled.withOpacity(0.30);
        } else if (states.isPressing) {
          return theme.inactiveColor.withOpacity(0.25);
        } else if (states.isHovering) {
          return theme.inactiveColor.withOpacity(0.10);
        } else {
          return Colors.transparent;
        }
      }),
      textStyle: ButtonState.all(const TextStyle(
        fontSize: 13.0,
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
