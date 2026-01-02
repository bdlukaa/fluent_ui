import 'package:fluent_ui/fluent_ui.dart';

/// The size mode for an [IconButton].
///
/// This determines the overall size and padding of the icon button.
enum IconButtonMode {
  /// A very small icon button, typically used in compact UI areas.
  tiny,

  /// A small icon button, suitable for toolbars and dense layouts.
  small,

  /// A large icon button with more padding, the default size.
  large,
}

/// A button that displays only an icon.
///
/// Icon buttons are commonly used in toolbars, app bars, and other places where
/// space is limited and the icon alone is sufficient to convey the action.
///
/// {@tool snippet}
/// This example shows basic icon buttons:
///
/// ```dart
/// Row(
///   children: [
///     IconButton(
///       icon: Icon(WindowsIcons.add),
///       onPressed: () => addItem(),
///     ),
///     IconButton(
///       icon: Icon(WindowsIcons.delete),
///       onPressed: () => deleteItem(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows icon buttons with different sizes:
///
/// ```dart
/// Row(
///   children: [
///     IconButton(
///       icon: Icon(WindowsIcons.settings),
///       iconButtonMode: IconButtonMode.tiny,
///       onPressed: () {},
///     ),
///     IconButton(
///       icon: Icon(WindowsIcons.settings),
///       iconButtonMode: IconButtonMode.small,
///       onPressed: () {},
///     ),
///     IconButton(
///       icon: Icon(WindowsIcons.settings),
///       iconButtonMode: IconButtonMode.large,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Accessibility
///
/// Since icon buttons have no text label, consider wrapping them in a [Tooltip]
/// to provide context for screen readers and on hover.
///
/// See also:
///
///  * [Button], for buttons with text labels
///  * [Tooltip], to add accessible labels to icon buttons
///  * [SmallIconButton], an inherited widget that makes descendant icon buttons small
class IconButton extends BaseButton {
  /// Creates an icon button.
  ///
  /// The [icon] is typically an [Icon] widget.
  const IconButton({
    required Widget icon,
    required super.onPressed,
    super.key,
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
    final isIconSmall =
        SmallIconButton.of(context) != null ||
        iconButtonMode == IconButtonMode.tiny;
    final isSmall = iconButtonMode != null
        ? iconButtonMode != IconButtonMode.large
        : SmallIconButton.of(context) != null;
    return ButtonStyle(
      iconSize: WidgetStatePropertyAll(isIconSmall ? 11.0 : null),
      padding: WidgetStatePropertyAll(
        isSmall ? kDefaultButtonPadding : const EdgeInsetsDirectional.all(8),
      ),
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
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
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
  const SmallIconButton({required super.child, super.key});

  /// Returns the closest [SmallIconButton] ancestor, if any.
  static SmallIconButton? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SmallIconButton>();
  }

  @override
  bool updateShouldNotify(SmallIconButton oldWidget) {
    return true;
  }
}
