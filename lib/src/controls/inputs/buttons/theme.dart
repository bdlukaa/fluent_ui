import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class ButtonStyle with Diagnosticable {
  const ButtonStyle({
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.elevation,
    this.padding,
    this.shape,
    this.iconSize,
  });

  final ButtonState<TextStyle?>? textStyle;

  final ButtonState<Color?>? backgroundColor;

  final ButtonState<Color?>? foregroundColor;

  final ButtonState<Color?>? shadowColor;

  final ButtonState<double?>? elevation;

  final ButtonState<EdgeInsetsGeometry?>? padding;

  final ButtonState<ShapeBorder?>? shape;

  final ButtonState<double?>? iconSize;

  ButtonStyle? merge(ButtonStyle? other) {
    if (other == null) return this;
    return ButtonStyle(
      textStyle: other.textStyle ?? textStyle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      shadowColor: other.shadowColor ?? shadowColor,
      elevation: other.elevation ?? elevation,
      padding: other.padding ?? padding,
      shape: other.shape ?? shape,
      iconSize: other.iconSize ?? iconSize,
    );
  }

  static ButtonStyle lerp(ButtonStyle? a, ButtonStyle? b, double t) {
    return ButtonStyle(
      textStyle:
          ButtonState.lerp(a?.textStyle, b?.textStyle, t, TextStyle.lerp),
      backgroundColor: ButtonState.lerp(
          a?.backgroundColor, b?.backgroundColor, t, Color.lerp),
      foregroundColor: ButtonState.lerp(
          a?.foregroundColor, b?.foregroundColor, t, Color.lerp),
      shadowColor:
          ButtonState.lerp(a?.shadowColor, b?.shadowColor, t, Color.lerp),
      elevation: ButtonState.lerp(a?.elevation, b?.elevation, t, lerpDouble),
      padding:
          ButtonState.lerp(a?.padding, b?.padding, t, EdgeInsetsGeometry.lerp),
      shape: ButtonState.lerp(a?.shape, b?.shape, t, ShapeBorder.lerp),
      iconSize: ButtonState.lerp(a?.iconSize, b?.iconSize, t, lerpDouble),
    );
  }

  ButtonStyle copyWith({
    ButtonState<TextStyle?>? textStyle,
    ButtonState<Color?>? backgroundColor,
    ButtonState<Color?>? foregroundColor,
    ButtonState<Color?>? shadowColor,
    ButtonState<double?>? elevation,
    ButtonState<EdgeInsetsGeometry?>? padding,
    ButtonState<ShapeBorder?>? shape,
    ButtonState<double?>? iconSize,
  }) {
    return ButtonStyle(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      shape: shape ?? this.shape,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}

/// An inherited widget that defines the configuration for
/// [Button]s in this widget's subtree.
///
/// Values specified here are used for [Button] properties that are not
/// given an explicit non-null value.
class ButtonTheme extends InheritedTheme {
  /// Creates a button theme that controls the configurations for
  /// [Button].
  const ButtonTheme({
    super.key,
    required super.child,
    required this.data,
  });

  /// The properties for descendant [Button] widgets.
  final ButtonThemeData data;

  /// Creates a button theme that controls how descendant [Button]s should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required ButtonThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return ButtonTheme(
        key: key,
        data: _getInheritedButtonThemeData(context)?.merge(data) ?? data,
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [FluentThemeData.buttonTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ButtonThemeData theme = ButtonTheme.of(context);
  /// ```
  static ButtonThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return FluentTheme.of(context).buttonTheme.merge(
          _getInheritedButtonThemeData(context),
        );
  }

  static ButtonThemeData? _getInheritedButtonThemeData(BuildContext context) {
    final buttonTheme =
        context.dependOnInheritedWidgetOfExactType<ButtonTheme>();
    return buttonTheme?.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ButtonTheme oldWidget) {
    return oldWidget.data != data;
  }
}

@immutable
class ButtonThemeData with Diagnosticable {
  final ButtonStyle? defaultButtonStyle;
  final ButtonStyle? filledButtonStyle;
  final ButtonStyle? hyperlinkButtonStyle;
  final ButtonStyle? outlinedButtonStyle;
  final ButtonStyle? iconButtonStyle;

  const ButtonThemeData({
    this.defaultButtonStyle,
    this.filledButtonStyle,
    this.hyperlinkButtonStyle,
    this.outlinedButtonStyle,
    this.iconButtonStyle,
  });

  const ButtonThemeData.all(ButtonStyle? style)
      : defaultButtonStyle = style,
        filledButtonStyle = style,
        hyperlinkButtonStyle = style,
        outlinedButtonStyle = style,
        iconButtonStyle = style;

  static ButtonThemeData lerp(
    ButtonThemeData? a,
    ButtonThemeData? b,
    double t,
  ) {
    return const ButtonThemeData();
  }

  ButtonThemeData merge(ButtonThemeData? style) {
    if (style == null) return this;
    return ButtonThemeData(
      outlinedButtonStyle: style.outlinedButtonStyle ?? outlinedButtonStyle,
      filledButtonStyle: style.filledButtonStyle ?? filledButtonStyle,
      hyperlinkButtonStyle: style.hyperlinkButtonStyle ?? hyperlinkButtonStyle,
      defaultButtonStyle: style.defaultButtonStyle ?? defaultButtonStyle,
      iconButtonStyle: style.iconButtonStyle ?? iconButtonStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ButtonStyle>(
          'outlinedButtonStyle', outlinedButtonStyle))
      ..add(DiagnosticsProperty<ButtonStyle>(
          'filledButtonStyle', filledButtonStyle))
      ..add(DiagnosticsProperty<ButtonStyle>(
          'hyperlinkButtonStyle', hyperlinkButtonStyle))
      ..add(DiagnosticsProperty<ButtonStyle>(
          'defaultButtonStyle', defaultButtonStyle))
      ..add(
          DiagnosticsProperty<ButtonStyle>('iconButtonStyle', iconButtonStyle));
  }

  /// Defines the default color used by [Button]s using the current brightness
  /// and state.
  static Color buttonColor(
    BuildContext context,
    Set<ButtonStates> states, {
    bool transparentWhenNone = false,
  }) {
    final res = FluentTheme.of(context).resources;
    if (states.isPressing) {
      return res.controlFillColorTertiary;
    } else if (states.isHovering) {
      return res.controlFillColorSecondary;
    } else if (states.isDisabled) {
      return res.controlFillColorDisabled;
    }
    return transparentWhenNone
        ? res.subtleFillColorTransparent
        : res.controlFillColorDefault;
  }

  /// Defines the default foregournd color used by [Button]s using the current brightness
  /// and state.
  static Color buttonForegroundColor(
    BuildContext context,
    Set<ButtonStates> states,
  ) {
    final res = FluentTheme.of(context).resources;
    if (states.isPressing) {
      return res.textFillColorTertiary;
    } else if (states.isHovering) {
      return res.textFillColorSecondary;
    } else if (states.isDisabled) {
      return res.textFillColorDisabled;
    }
    return res.textFillColorPrimary;
  }

  static ShapeBorder shapeBorder(
      BuildContext context, Set<ButtonStates> states) {
    final theme = FluentTheme.of(context);
    return states.isPressing || states.isDisabled
        ? RoundedRectangleBorder(
            side: BorderSide(
              color: theme.resources.controlStrokeColorDefault,
            ),
            borderRadius: BorderRadius.circular(4.0),
          )
        : RoundedRectangleGradientBorder(
            borderRadius: BorderRadius.circular(4.0),
            gradient: LinearGradient(
              begin: const Alignment(0, 0),
              end: const Alignment(0.0, 3),
              colors: [
                theme.resources.controlStrokeColorSecondary,
                theme.resources.controlStrokeColorDefault,
              ],
              stops: const [0.3, 1.0],
            ),
          );
  }

  /// Defines the default color used for inputs when checked, such as checkbox,
  /// radio button and toggle switch. It's based on the current style and the
  /// current state.
  static Color checkedInputColor(
      FluentThemeData theme, Set<ButtonStates> states) {
    return FilledButton.backgroundColor(theme, states);
  }

  static Color uncheckedInputColor(
    FluentThemeData theme,
    Set<ButtonStates> states, {
    bool transparentWhenNone = false,
    bool transparentWhenDisabled = false,
  }) {
    final res = theme.resources;
    if (states.isDisabled) {
      if (transparentWhenDisabled) return res.subtleFillColorTransparent;
      return res.controlAltFillColorDisabled;
    }
    if (states.isPressing) return res.subtleFillColorTertiary;
    if (states.isHovering) return res.subtleFillColorSecondary;
    return transparentWhenNone
        ? res.subtleFillColorTransparent
        : res.controlAltFillColorSecondary;
  }
}
