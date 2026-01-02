import 'package:fluent_ui/fluent_ui.dart';

/// The default padding applied to fluent-styled buttons.
///
/// This matches the padding used by WinUI button controls.
const kDefaultButtonPadding = EdgeInsetsDirectional.only(
  start: 11,
  top: 5,
  end: 11,
  bottom: 6,
);

/// A standard button control that triggers an immediate action when clicked.
///
/// The [Button] widget is the most common type of button in Windows applications.
/// It has a neutral appearance with a subtle background that responds to hover,
/// press, and focus states.
///
/// ![Button Example](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/button.png)
///
/// {@tool snippet}
/// This example shows a basic button with a text label:
///
/// ```dart
/// Button(
///   child: Text('Click me'),
///   onPressed: () {
///     print('Button was pressed!');
///   },
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a button with an icon and text:
///
/// ```dart
/// Button(
///   child: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       Icon(WindowsIcons.add),
///       SizedBox(width: 8),
///       Text('Add item'),
///     ],
///   ),
///   onPressed: () => addItem(),
/// )
/// ```
/// {@end-tool}
///
/// ## Button states
///
/// The button automatically updates its appearance based on its current state:
///
/// * **Rest**: The default appearance when not interacted with
/// * **Hover**: When the pointer is over the button
/// * **Pressed**: When the button is being pressed
/// * **Disabled**: When [onPressed] is null
/// * **Focused**: When the button has keyboard focus
///
/// ## Accessibility
///
/// The button is automatically accessible to screen readers. The [child] widget's
/// text content is used as the button's accessible label. For buttons with only
/// icons, consider wrapping the button in a [Tooltip] or using [Semantics] to
/// provide an accessible label.
///
/// See also:
///
///  * [FilledButton], an accent-colored button for primary actions
///  * [OutlinedButton], a button with an outlined border
///  * [HyperlinkButton], a borderless button styled like a hyperlink
///  * [IconButton], a button that displays only an icon
///  * [ToggleButton], a button that can be toggled on and off
///  * [SplitButton], a button with two parts - one for the action and one for a menu
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons>
class Button extends BaseButton {
  /// Creates a standard button.
  ///
  /// The [child] and [onPressed] arguments are required. Set [onPressed] to
  /// null to disable the button.
  const Button({
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
      shadowColor: WidgetStatePropertyAll(theme.shadowColor),
      padding: const WidgetStatePropertyAll(kDefaultButtonPadding),
      shape: WidgetStateProperty.resolveWith((states) {
        return ButtonThemeData.shapeBorder(context, states);
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return ButtonThemeData.buttonColor(context, states);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
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
