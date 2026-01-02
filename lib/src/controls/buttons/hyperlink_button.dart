import 'package:fluent_ui/fluent_ui.dart';

/// A borderless button styled like a hyperlink.
///
/// The [HyperlinkButton] is used for less prominent actions or for inline
/// actions within text. It has a transparent background and displays text
/// in the accent color, similar to a web hyperlink.
///
/// {@tool snippet}
/// This example shows a basic hyperlink button:
///
/// ```dart
/// HyperlinkButton(
///   child: Text('Learn more'),
///   onPressed: () => launchUrl(Uri.parse('https://example.com')),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a hyperlink button used for navigation:
///
/// ```dart
/// Row(
///   children: [
///     Text('Don\'t have an account?'),
///     HyperlinkButton(
///       child: Text('Sign up'),
///       onPressed: () => navigateToSignUp(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Button], for standard button actions
///  * [FilledButton], for primary actions
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/hyperlinks>
class HyperlinkButton extends BaseButton {
  /// Creates a hyperlink button.
  ///
  /// The [child] is typically a [Text] widget styled as a link.
  const HyperlinkButton({
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
      backgroundColor: backgroundColor(theme),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      padding: const WidgetStatePropertyAll(kDefaultButtonPadding),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlFillColorDisabled;
        } else if (states.isPressed) {
          return theme.accentColor.tertiaryBrushFor(theme.brightness);
        } else if (states.isHovered) {
          return theme.accentColor.secondaryBrushFor(theme.brightness);
        } else {
          return theme.accentColor.defaultBrushFor(theme.brightness);
        }
      }),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).hyperlinkButtonStyle;
  }

  /// Returns the background color for a hyperlink button based on its state.
  static WidgetStateColor backgroundColor(FluentThemeData theme) {
    return WidgetStateColor.resolveWith((states) {
      if (states.isDisabled) {
        return theme.resources.subtleFillColorDisabled;
      } else if (states.isPressed) {
        return theme.resources.subtleFillColorTertiary;
      } else if (states.isHovered) {
        return theme.resources.subtleFillColorSecondary;
      } else {
        return theme.resources.subtleFillColorTransparent;
      }
    });
  }
}
