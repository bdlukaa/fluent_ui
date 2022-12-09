import 'package:fluent_ui/fluent_ui.dart';

/// A button gives the user a way to trigger an immediate action.
///
/// ![Button Example](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/button.png)
///
/// See also:
///
///   * [ToggleButton], a button that can be on and off.
///   * [SplitButtonBar], A button with two sides. One side initiates
///     an action, and the other side opens a menu.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/buttons>
class Button extends BaseButton {
  /// Creates a button.
  const Button({
    Key? key,
    required Widget child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    FocusNode? focusNode,
    bool autofocus = false,
    ButtonStyle? style,
    bool focusable = true,
  }) : super(
          key: key,
          child: child,
          focusNode: focusNode,
          autofocus: autofocus,
          onLongPress: onLongPress,
          onPressed: onPressed,
          style: style,
          focusable: focusable,
        );

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final ThemeData theme = FluentTheme.of(context);
    return ButtonStyle(
      // elevation: ButtonState.resolveWith((states) {
      //   if (states.isPressing) return 0.0;
      //   return 0.3;
      // }),
      shadowColor: ButtonState.all(theme.shadowColor),
      padding: ButtonState.all(const EdgeInsetsDirectional.only(
        start: 11.0,
        top: 5.0,
        end: 11.0,
        bottom: 5.0,
      )),
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
