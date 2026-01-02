import 'package:fluent_ui/fluent_ui.dart';

/// A button with a visible border outline.
///
/// The [OutlinedButton] has a transparent background with a visible border,
/// making it suitable for secondary actions that need more visual weight
/// than a [HyperlinkButton] but less prominence than a [FilledButton].
///
/// {@tool snippet}
/// This example shows a basic outlined button:
///
/// ```dart
/// OutlinedButton(
///   child: Text('Cancel'),
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows outlined buttons used alongside a filled button:
///
/// ```dart
/// Row(
///   children: [
///     OutlinedButton(
///       child: Text('Previous'),
///       onPressed: () => goBack(),
///     ),
///     SizedBox(width: 8),
///     FilledButton(
///       child: Text('Next'),
///       onPressed: () => goNext(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Button], a standard button with a subtle background
///  * [FilledButton], an accent-colored button for primary actions
///  * [HyperlinkButton], a borderless button styled like a hyperlink
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons>
class OutlinedButton extends BaseButton {
  /// Creates an outlined button.
  const OutlinedButton({
    required super.child,
    required super.onPressed,
    super.key,
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
      padding: const WidgetStatePropertyAll(kDefaultButtonPadding),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: theme.inactiveColor),
        ),
      ),
      foregroundColor: WidgetStatePropertyAll(theme.inactiveColor),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlFillColorDisabled.withValues(
            alpha: 0.30,
          );
        } else if (states.isPressed) {
          return theme.inactiveColor.withValues(alpha: 0.25);
        } else if (states.isHovered) {
          return theme.inactiveColor.withValues(alpha: 0.10);
        } else {
          return Colors.transparent;
        }
      }),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).outlinedButtonStyle;
  }
}
