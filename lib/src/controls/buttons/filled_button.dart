import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

/// An accent-colored button used for primary or most important actions.
///
/// The [FilledButton] has a filled background using the app's accent color,
/// making it stand out as the primary action in a dialog or page. Use this
/// button for the most important action you want users to take.
///
/// ![FilledButton Example](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/button.png)
///
/// {@tool snippet}
/// This example shows a filled button used as a primary action:
///
/// ```dart
/// FilledButton(
///   child: Text('Save'),
///   onPressed: () => saveDocument(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a dialog with a filled button as the primary action:
///
/// ```dart
/// ContentDialog(
///   title: Text('Save changes?'),
///   content: Text('Do you want to save your changes before closing?'),
///   actions: [
///     Button(
///       child: Text('Cancel'),
///       onPressed: () => Navigator.pop(context),
///     ),
///     FilledButton(
///       child: Text('Save'),
///       onPressed: () {
///         saveChanges();
///         Navigator.pop(context);
///       },
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Button], for secondary or less prominent actions
///  * [OutlinedButton], an outlined button
///  * [HyperlinkButton], a borderless button with mainly text-based content
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons>
class FilledButton extends Button {
  /// Creates a filled button.
  ///
  /// The [child] is typically a [Text] widget. The [onPressed] callback is
  /// required—set it to null to disable the button.
  const FilledButton({
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
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final buttonTheme = ButtonTheme.of(context);
    return buttonTheme.filledButtonStyle;
  }

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final def = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return backgroundColor(theme, states);
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => foregroundColor(theme, states),
      ),
      shape: WidgetStateProperty.resolveWith((states) {
        return shapeBorder(theme, states);
      }),
    );

    return super.defaultStyleOf(context).merge(def) ?? def;
  }

  /// Returns the background color for a filled button based on its state.
  static Color backgroundColor(FluentThemeData theme, Set<WidgetState> states) {
    if (states.isDisabled) {
      return theme.resources.accentFillColorDisabled;
    } else if (states.isPressed) {
      return theme.accentColor.tertiaryBrushFor(theme.brightness);
    } else if (states.isHovered) {
      return theme.accentColor.secondaryBrushFor(theme.brightness);
    } else {
      return theme.accentColor.defaultBrushFor(theme.brightness);
    }
  }

  /// Returns the foreground color for a filled button based on its state.
  static Color foregroundColor(FluentThemeData theme, Set<WidgetState> states) {
    final res = theme.resources;
    if (states.isPressed) {
      return res.textOnAccentFillColorSecondary;
    } else if (states.isHovered) {
      return res.textOnAccentFillColorPrimary;
    } else if (states.isDisabled) {
      return res.textOnAccentFillColorDisabled;
    }
    return res.textOnAccentFillColorPrimary;
  }

  /// Returns the shape border for a filled button based on its state.
  static ShapeBorder shapeBorder(
    FluentThemeData theme,
    Set<WidgetState> states,
  ) {
    return states.isPressed || states.isDisabled
        ? RoundedRectangleBorder(
            side: BorderSide(
              color: theme.resources.controlFillColorTransparent,
            ),
            borderRadius: BorderRadius.circular(4),
          )
        : RoundedRectangleGradientBorder(
            gradient: LinearGradient(
              begin: const Alignment(0, -2),
              end: Alignment.bottomCenter,
              colors: [
                theme.resources.controlStrokeColorOnAccentSecondary,
                theme.resources.controlStrokeColorOnAccentDefault,
              ],
              stops: const [0.33, 1.0],
              transform: const GradientRotation(pi),
            ),
            borderRadius: BorderRadius.circular(4),
          );
  }
}
