import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// A button that can be on or off.
///
/// See also:
///   * [Checkbox](https://github.com/bdlukaa/fluent_ui#checkbox)
///   * [ToggleSwitch](https://github.com/bdlukaa/fluent_ui#toggle-switches)
class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.child,
    this.style,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// The content of the button
  final Widget? child;

  /// Whether this [ToggleButton] is checked
  final bool checked;

  /// Whenever the value of this [ToggleButton] should change
  final ValueChanged<bool>? onChanged;

  /// The style of the button.
  /// This style is merged with [ThemeData.toggleButtonThemeData]
  final ToggleButtonThemeData? style;

  /// The semantics label of the button
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'checked',
      value: checked,
      ifFalse: 'unchecked',
    ));
    properties.add(
      ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'),
    );
    properties.add(DiagnosticsProperty<ToggleButtonThemeData>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(
        FlagProperty('autofocus', value: autofocus, ifFalse: 'manual focus'));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style =
        ToggleButtonThemeData.standard(FluentTheme.of(context)).copyWith(
      FluentTheme.of(context).toggleButtonTheme.copyWith(this.style),
    );
    return Button(
      autofocus: autofocus,
      focusNode: focusNode,
      child: Semantics(child: child, selected: checked),
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      style: ButtonThemeData(
        decoration: ButtonState.resolveWith(
          (states) => checked
              ? style.checkedDecoration?.resolve(states)
              : style.uncheckedDecoration?.resolve(states),
        ),
        textStyle: ButtonState.resolveWith((states) => checked
            ? style.checkedTextStyle?.resolve(states)
            : style.uncheckedTextStyle?.resolve(states)),
        padding: style.padding,
        cursor: style.cursor,
        margin: style.margin,
        scaleFactor: style.scaleFactor,
      ),
    );
  }
}

@immutable
class ToggleButtonThemeData with Diagnosticable {
  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Decoration?>? checkedDecoration;
  final ButtonState<Decoration?>? uncheckedDecoration;

  final ButtonState<TextStyle?>? checkedTextStyle;
  final ButtonState<TextStyle?>? uncheckedTextStyle;

  final double? scaleFactor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ToggleButtonThemeData({
    this.cursor,
    this.padding,
    this.margin,
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.checkedTextStyle,
    this.uncheckedTextStyle,
    this.scaleFactor,
  });

  factory ToggleButtonThemeData.standard(ThemeData style) {
    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
    );
    Color checkedColor(Set<ButtonStates> states) => states.isDisabled
        ? ButtonThemeData.buttonColor(style, states)
        : ButtonThemeData.checkedInputColor(style, states);
    return ToggleButtonThemeData(
      scaleFactor: 0.95,
      cursor: style.inputMouseCursor,
      checkedDecoration: ButtonState.resolveWith(
        (states) => defaultDecoration.copyWith(color: checkedColor(states)),
      ),
      uncheckedDecoration: ButtonState.resolveWith(
        (states) => defaultDecoration.copyWith(
            color: states.isHovering || states.isPressing
                ? ButtonThemeData.uncheckedInputColor(style, states)
                : ButtonThemeData.buttonColor(style, states)),
      ),
      checkedTextStyle: ButtonState.resolveWith((states) {
        return TextStyle(color: checkedColor(states).basedOnLuminance());
      }),
      uncheckedTextStyle: ButtonState.all(style.typography.body),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(4),
    );
  }

  static ToggleButtonThemeData lerp(
    ToggleButtonThemeData? a,
    ToggleButtonThemeData? b,
    double t,
  ) {
    return ToggleButtonThemeData(
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      cursor: t < 0.5 ? a?.cursor : b?.cursor,
      checkedDecoration: ButtonState.lerp(
          a?.checkedDecoration, b?.checkedDecoration, t, Decoration.lerp),
      uncheckedDecoration: ButtonState.lerp(
          a?.uncheckedDecoration, b?.uncheckedDecoration, t, Decoration.lerp),
      scaleFactor: lerpDouble(a?.scaleFactor, b?.scaleFactor, t),
      checkedTextStyle: ButtonState.lerp(
          a?.checkedTextStyle, b?.checkedTextStyle, t, TextStyle.lerp),
      uncheckedTextStyle: ButtonState.lerp(
          a?.uncheckedTextStyle, b?.uncheckedTextStyle, t, TextStyle.lerp),
    );
  }

  ToggleButtonThemeData copyWith(ToggleButtonThemeData? style) {
    if (style == null) return this;
    return ToggleButtonThemeData(
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      cursor: style.cursor ?? cursor,
      checkedDecoration: style.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style.uncheckedDecoration ?? uncheckedDecoration,
      scaleFactor: style.scaleFactor ?? scaleFactor,
      checkedTextStyle: style.checkedTextStyle ?? checkedTextStyle,
      uncheckedTextStyle: style.uncheckedTextStyle ?? uncheckedTextStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties.add(DiagnosticsProperty('padding', padding));
    properties.add(DiagnosticsProperty('cursor', cursor));
    properties.add(DiagnosticsProperty('checkedDecoration', checkedDecoration));
    properties
        .add(DiagnosticsProperty('uncheckedDecoration', uncheckedDecoration));
    properties.add(DoubleProperty('scaleFactor', scaleFactor));
    properties.add(DiagnosticsProperty('checkedTextStyle', checkedTextStyle));
    properties.add(DiagnosticsProperty('uncheckedTextStyle', uncheckedTextStyle));
  }
}
