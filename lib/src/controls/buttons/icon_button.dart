import 'package:fluent_ui/fluent_ui.dart';

enum IconButtonMode { tiny, small, large }

class IconButton extends BaseButton {
  const IconButton({
    super.key,
    required Widget icon,
    required super.onPressed,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.focusNode,
    super.autofocus = false,
    super.style,
    super.focusable = true,
    this.iconButtonMode,
  }) : super(child: icon);

  /// How this icon button will behave.
  ///
  /// If null, this may be affected by a [SmallIconButton] in the tree, if any.
  /// If null and without a [SmallIconButton], defaults to large.
  final IconButtonMode? iconButtonMode;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final isIconSmall = SmallIconButton.of(context) != null ||
        iconButtonMode == IconButtonMode.tiny;
    final isSmall = iconButtonMode != null
        ? iconButtonMode != IconButtonMode.large
        : SmallIconButton.of(context) != null;
    return ButtonStyle(
      iconSize: WidgetStatePropertyAll(isIconSmall ? 11.0 : null),
      padding: WidgetStatePropertyAll(
          isSmall ? kDefaultButtonPadding : const EdgeInsets.all(8.0)),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.isDisabled) {
          return ButtonThemeData.buttonColor(context, states);
        } else {
          return ButtonThemeData.uncheckedInputColor(
            theme,
            states,
            transparentWhenNone: true,
          );
        }
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.isDisabled) return theme.resources.textFillColorDisabled;
        return null;
      }),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
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

/// Makes its icon button children small.
///
/// See also:
///
///  * [IconButton], which turns small when wrapped in this.
class SmallIconButton extends InheritedWidget {
  /// Creates a small icon button.
  const SmallIconButton({super.key, required super.child});

  static SmallIconButton? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SmallIconButton>();
  }

  @override
  bool updateShouldNotify(SmallIconButton oldWidget) {
    return true;
  }
}
