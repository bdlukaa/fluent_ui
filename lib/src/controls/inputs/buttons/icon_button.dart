import 'package:fluent_ui/fluent_ui.dart';

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
    final isSmall = SmallIconButton.of(context) != null;
    return ButtonStyle(
      iconSize: ButtonState.all(isSmall ? 12.0 : 0.0),
      padding: ButtonState.all(isSmall
          ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
          : const EdgeInsets.all(8.0)),
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

class SmallIconButton extends InheritedWidget {
  const SmallIconButton({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  static SmallIconButton? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SmallIconButton>();
  }

  @override
  bool updateShouldNotify(SmallIconButton oldWidget) {
    return true;
  }
}
