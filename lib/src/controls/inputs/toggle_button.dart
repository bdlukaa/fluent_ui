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
    final style = ToggleButtonTheme.of(context).merge(this.style);
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

/// An inherited widget that defines the configuration for
/// [ToggleButton]s in this widget's subtree.
///
/// Values specified here are used for [ToggleButton] properties that are not
/// given an explicit non-null value.
class ToggleButtonTheme extends InheritedTheme {
  /// Creates a toggle button theme that controls the configurations for
  /// [ToggleButton].
  const ToggleButtonTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [ToggleButton] widgets.
  final ToggleButtonThemeData data;

  /// Creates a button theme that controls how descendant [ToggleButton]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required ToggleButtonThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ToggleButtonTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static ToggleButtonThemeData _getInheritedThemeData(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<ToggleButtonTheme>();
    return theme?.data ?? FluentTheme.of(context).toggleButtonTheme;
  }

  /// Returns the [data] from the closest [ToggleButtonTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.toggleButtonTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ToggleButtonThemeData theme = ToggleButtonTheme.of(context);
  /// ```
  static ToggleButtonThemeData of(BuildContext context) {
    return ToggleButtonThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ToggleButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ToggleButtonTheme oldWidget) =>
      data != oldWidget.data;
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
        ? ButtonThemeData.buttonColor(style.brightness, states)
        : ButtonThemeData.checkedInputColor(style, states);
    Color uncheckedColor(Set<ButtonStates> states) =>
        states.isHovering || states.isPressing
            ? ButtonThemeData.uncheckedInputColor(style, states)
            : ButtonThemeData.buttonColor(style.brightness, states);
    return ToggleButtonThemeData(
      scaleFactor: kButtonDefaultScaleFactor,
      cursor: style.inputMouseCursor,
      checkedDecoration: ButtonState.resolveWith(
        (states) => defaultDecoration.copyWith(color: checkedColor(states)),
      ),
      uncheckedDecoration: ButtonState.resolveWith(
        (states) => defaultDecoration.copyWith(color: uncheckedColor(states)),
      ),
      checkedTextStyle: ButtonState.resolveWith((states) {
        return TextStyle(
          color: states.isDisabled
              ? style.disabledColor
              : checkedColor(states).basedOnLuminance(),
        );
      }),
      uncheckedTextStyle: ButtonState.resolveWith((states) {
        return TextStyle(
          color: states.isDisabled
              ? style.disabledColor
              : uncheckedColor(states).basedOnLuminance(),
        );
      }),
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

  ToggleButtonThemeData merge(ToggleButtonThemeData? style) {
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
    properties
        .add(DiagnosticsProperty('uncheckedTextStyle', uncheckedTextStyle));
  }
}
