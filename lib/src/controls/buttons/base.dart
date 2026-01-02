import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// {@template fluent_ui.buttons.base}
/// A button gives the user a way to trigger an immediate action. Some buttons
/// are specialized for particular tasks, such as navigation, repeated actions,
/// or presenting menus.
/// {@endtemplate}
///
/// {@tool snippet}
/// This example shows how to use a basic button:
///
/// ```dart
/// Button(
///   child: Text('Click me'),
///   onPressed: () {
///     print('Button pressed!');
///   },
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [HyperlinkButton], a borderless button with mainly text-based content
///  * [OutlinedButton], an outlined button
///  * [FilledButton], a colored button for primary actions
///  * [IconButton], a button that displays only an icon
///  * [ToggleButton], a button that can be toggled on and off
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/buttons>
abstract class BaseButton extends StatefulWidget {
  /// Creates a base button.
  const BaseButton({
    required this.onPressed,
    required this.onLongPress,
    required this.onTapDown,
    required this.onTapUp,
    required this.style,
    required this.focusNode,
    required this.autofocus,
    required this.child,
    required this.focusable,
    super.key,
  });

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback, [onLongPress], [onTapDown], and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final GestureTapCallback? onPressed;

  /// Called when the button is pressed.
  ///
  /// If this callback, [onLongPress], [onPressed] and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final GestureTapDownCallback? onTapDown;

  /// Called when the button is released.
  ///
  /// If this callback, [onLongPress], [onPressed] and [onTapDown] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final GestureTapUpCallback? onTapUp;

  /// Called when the button is long-pressed.
  ///
  /// If this callback, [onPressed], [onTapDown] and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final GestureLongPressCallback? onLongPress;

  /// Customizes this button's appearance.
  final ButtonStyle? style;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Typically the button's label.
  ///
  /// Usually a [Text] widget
  final Widget child;

  /// Whether this button can be focused.
  final bool focusable;

  /// Returns the default style for this button type based on the context.
  @protected
  ButtonStyle defaultStyleOf(BuildContext context);

  /// Returns the theme style for this button type, if defined.
  @protected
  ButtonStyle? themeStyleOf(BuildContext context);

  /// Whether the button is enabled or disabled.
  ///
  /// Buttons are disabled by default. To enable a button, set its [onPressed],
  /// [onLongPress], [onTapDown] or [onTapUp] properties to a non-null value.
  bool get enabled =>
      onPressed != null ||
      onLongPress != null ||
      onTapDown != null ||
      onTapUp != null;

  @override
  State<BaseButton> createState() => _BaseButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(
        DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'focusNode',
          focusNode,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false),
      );
  }
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final widgetStyle = widget.style;
    final themeStyle = widget.themeStyleOf(context);
    final defaultStyle = widget.defaultStyleOf(context);

    T? effectiveValue<T>(T? Function(ButtonStyle? style) getProperty) {
      final widgetValue = getProperty(widgetStyle);
      final themeValue = getProperty(themeStyle);
      final defaultValue = getProperty(defaultStyle);
      return widgetValue ?? themeValue ?? defaultValue;
    }

    return HoverButton(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      focusEnabled: widget.focusable,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      builder: (context, states) {
        T? resolve<T>(
          WidgetStateProperty<T>? Function(ButtonStyle? style) getProperty,
        ) {
          return effectiveValue((style) => getProperty(style)?.resolve(states));
        }

        final resolvedElevation = resolve<double?>((style) => style?.elevation);
        final resolvedTextStyle = theme.typography.body?.merge(
          resolve<TextStyle?>((style) => style?.textStyle),
        );
        final resolvedBackgroundColor = resolve<Color?>(
          (style) => style?.backgroundColor,
        );
        final resolvedForegroundColor = resolve<Color?>(
          (style) => style?.foregroundColor,
        );
        final resolvedShadowColor = resolve<Color?>(
          (style) => style?.shadowColor,
        );
        final resolvedPadding =
            resolve<EdgeInsetsGeometry?>((style) => style?.padding) ??
            EdgeInsetsDirectional.zero;
        final resolvedShape =
            resolve<ShapeBorder?>((style) => style?.shape) ??
            const RoundedRectangleBorder();

        final padding = resolvedPadding
            .add(
              EdgeInsetsDirectional.symmetric(
                horizontal: theme.visualDensity.horizontal,
                vertical: theme.visualDensity.vertical,
              ),
            )
            .clamp(EdgeInsetsDirectional.zero, EdgeInsetsGeometry.infinity);
        final iconSize = resolve<double?>((style) => style?.iconSize);
        final Widget result = PhysicalModel(
          color: Colors.transparent,
          shadowColor: resolvedShadowColor ?? Colors.black,
          elevation: resolvedElevation ?? 0.0,
          borderRadius: resolvedShape is RoundedRectangleBorder
              ? resolvedShape.borderRadius is BorderRadius
                    ? resolvedShape.borderRadius as BorderRadius
                    : BorderRadius.zero
              : BorderRadius.zero,
          child: AnimatedContainer(
            duration: theme.fasterAnimationDuration,
            curve: theme.animationCurve,
            decoration: ShapeDecoration(
              shape: resolvedShape,
              color: resolvedBackgroundColor,
            ),
            padding: padding,
            child: IconTheme.merge(
              data: IconThemeData(
                color: resolvedForegroundColor,
                size: iconSize ?? 14.0,
              ),
              child: AnimatedDefaultTextStyle(
                duration: theme.fastAnimationDuration,
                curve: theme.animationCurve,
                style: DefaultTextStyle.of(context).style.merge(
                  (resolvedTextStyle ?? const TextStyle()).copyWith(
                    color: resolvedForegroundColor,
                  ),
                ),
                textAlign: TextAlign.center,
                // used to align the child without expanding the button
                child: Center(
                  heightFactor: 1,
                  widthFactor: 1,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
        return Semantics(
          container: true,
          button: true,
          enabled: widget.enabled,
          child: FocusBorder(focused: states.isFocused, child: result),
        );
      },
    );
  }
}
