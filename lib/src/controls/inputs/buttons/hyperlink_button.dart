import 'package:fluent_ui/fluent_ui.dart';

/// A borderless button with mainly text-based content
///
/// {@macro fluent_ui.buttons.base}
///
/// See also:
///
///   * [OutlinedButton], an outlined button
///   * [FilledButton], a colored button
///   * <https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.hyperlinkbutton>
///   * <https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/HyperlinkButton_themeresources.xaml>
class HyperlinkButton extends BaseButton {
  /// Creates a text-button.
  const HyperlinkButton({
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
      backgroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.subtleFillColorDisabled;
        } else if (states.isPressing) {
          return theme.resources.subtleFillColorTertiary;
        } else if (states.isHovering) {
          return theme.resources.subtleFillColorSecondary;
        } else {
          return theme.resources.subtleFillColorTransparent;
        }
      }),
      shape: ButtonState.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
      padding: ButtonState.all(kDefaultButtonPadding),
      foregroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlFillColorDisabled;
        } else if (states.isPressing) {
          return theme.accentColor.tertiaryBrushFor(theme.brightness);
        } else if (states.isHovering) {
          return theme.accentColor.secondaryBrushFor(theme.brightness);
        } else {
          return theme.accentColor.defaultBrushFor(theme.brightness);
        }
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
    return ButtonTheme.of(context).hyperlinkButtonStyle;
  }
}
