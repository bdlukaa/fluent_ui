// import 'package:flutter/material.dart' as m;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// {@template fluent_ui.buttons.base}
/// Buttons give people a way to trigger an action. They’re typically found in
/// forms, dialog panels, and dialogs.
/// {@endtemplate}
///
/// See also:
///
///   * <https://developer.microsoft.com/en-us/fluentui#/controls/android/button>
///   * <https://developer.microsoft.com/en-us/fluentui#/controls/web/button>
///   * [HyperlinkButton], a borderless button with mainly text-based content
///   * [OutlinedButton], an outlined button
///   * [FilledButton], a colored button
abstract class BaseButton extends StatefulWidget {
  const BaseButton({
    super.key,
    required this.onPressed,
    required this.onLongPress,
    required this.onTapDown,
    required this.onTapUp,
    required this.style,
    required this.focusNode,
    required this.autofocus,
    required this.child,
    required this.focusable,
  });

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback, [onLongPress], [onTapDown], and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onPressed;

  /// Called when the button is pressed.
  ///
  /// If this callback, [onLongPress], [onPressed] and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onTapDown;

  /// Called when the button is released.
  ///
  /// If this callback, [onLongPress], [onPressed] and [onTapDown] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onTapUp;

  /// Called when the button is long-pressed.
  ///
  /// If this callback, [onPressed], [onTapDown] and [onTapUp] are null,
  /// then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onLongPress;

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

  @protected
  ButtonStyle defaultStyleOf(BuildContext context);

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
          DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
          defaultValue: null));
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
            ButtonState<T>? Function(ButtonStyle? style) getProperty) {
          return effectiveValue(
            (ButtonStyle? style) => getProperty(style)?.resolve(states),
          );
        }

        final resolvedElevation =
            resolve<double?>((ButtonStyle? style) => style?.elevation);
        final resolvedTextStyle = theme.typography.body?.merge(
            resolve<TextStyle?>((ButtonStyle? style) => style?.textStyle));
        final resolvedBackgroundColor =
            resolve<Color?>((ButtonStyle? style) => style?.backgroundColor);
        final resolvedForegroundColor =
            resolve<Color?>((ButtonStyle? style) => style?.foregroundColor);
        final resolvedShadowColor =
            resolve<Color?>((ButtonStyle? style) => style?.shadowColor);
        final resolvedPadding = resolve<EdgeInsetsGeometry?>(
                (ButtonStyle? style) => style?.padding) ??
            EdgeInsets.zero;
        final resolvedShape =
            resolve<ShapeBorder?>((ButtonStyle? style) => style?.shape) ??
                const RoundedRectangleBorder();

        final padding = resolvedPadding
            .add(EdgeInsets.symmetric(
              horizontal: theme.visualDensity.horizontal,
              vertical: theme.visualDensity.vertical,
            ))
            .clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity);
        final iconSize = resolve<double?>((style) => style?.iconSize);
        Widget result = PhysicalModel(
          color: Colors.transparent,
          shadowColor: resolvedShadowColor ?? Colors.black,
          elevation: resolvedElevation ?? 0.0,
          borderRadius: resolvedShape is RoundedRectangleBorder
              ? resolvedShape.borderRadius is BorderRadius
                  ? resolvedShape.borderRadius as BorderRadius
                  : BorderRadius.zero
              : BorderRadius.zero,
          child: AnimatedContainer(
            duration: FluentTheme.of(context).fasterAnimationDuration,
            curve: FluentTheme.of(context).animationCurve,
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
                duration: FluentTheme.of(context).fastAnimationDuration,
                curve: FluentTheme.of(context).animationCurve,
                style: DefaultTextStyle.of(context).style.merge(
                      (resolvedTextStyle ?? const TextStyle())
                          .copyWith(color: resolvedForegroundColor),
                    ),
                textAlign: TextAlign.center,
                child: widget.child,
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
