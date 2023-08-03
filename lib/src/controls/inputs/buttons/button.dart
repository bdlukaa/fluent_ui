import 'package:fluent_ui/fluent_ui.dart';

const kDefaultButtonPadding = EdgeInsetsDirectional.only(
  start: 11.0,
  top: 5.0,
  end: 11.0,
  bottom: 6.0,
);

/// A button gives the user a way to trigger an immediate action.
///
/// ![Button Example](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/button.png)
///
/// See also:
///
///   * [ToggleButton], a button that can be on and off.
///   * [SplitButton], A button with two parts. One part initiates an action,
///     and the other side opens a menu.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/buttons>
class Button extends BaseButton {
  /// Creates a button.
  const Button({
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
      shadowColor: ButtonState.all(theme.shadowColor),
      padding: ButtonState.all(kDefaultButtonPadding),
      shape: ButtonState.resolveWith((states) {
        return RoundedRectangleBorder(
          side: BorderSide(
            color: states.isPressing || states.isDisabled
                ? theme.resources.controlStrokeColorDefault
                : theme.resources.controlStrokeColorSecondary,
            width: 0.33,
          ),
          borderRadius: BorderRadius.circular(4.0),
        );
      }),
      backgroundColor: ButtonState.resolveWith((states) {
        return ButtonThemeData.buttonColor(context, states);
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        return ButtonThemeData.buttonForegroundColor(context, states);
      }),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).defaultButtonStyle;
  }
}
