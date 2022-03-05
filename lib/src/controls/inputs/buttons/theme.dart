import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';

class ButtonStyle with Diagnosticable {
  const ButtonStyle({
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.elevation,
    this.padding,
    this.border,
    this.shape,
    this.iconSize,
  });

  final ButtonState<TextStyle?>? textStyle;

  final ButtonState<Color?>? backgroundColor;

  final ButtonState<Color?>? foregroundColor;

  final ButtonState<Color?>? shadowColor;

  final ButtonState<double?>? elevation;

  final ButtonState<EdgeInsetsGeometry?>? padding;

  final ButtonState<BorderSide?>? border;

  final ButtonState<OutlinedBorder?>? shape;

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
      border: other.border ?? border,
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
      border: ButtonState.lerp(a?.border, b?.border, t, (a, b, t) {
        if (a == null && b == null) return null;
        if (a == null) return b;
        if (b == null) return a;
        return BorderSide.lerp(a, b, t);
      }),
      shape: ButtonState.lerp(a?.shape, b?.shape, t, (a, b, t) {
        return ShapeBorder.lerp(a, b, t) as OutlinedBorder;
      }),
      iconSize: ButtonState.lerp(
        a?.iconSize,
        b?.iconSize,
        t,
        lerpDouble,
      ),
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
    Key? key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

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
  /// Defaults to [ThemeData.buttonTheme]
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
    final ButtonTheme? buttonTheme =
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
  final ButtonStyle? textButtonStyle;
  final ButtonStyle? outlinedButtonStyle;
  final ButtonStyle? iconButtonStyle;

  const ButtonThemeData({
    this.defaultButtonStyle,
    this.filledButtonStyle,
    this.textButtonStyle,
    this.outlinedButtonStyle,
    this.iconButtonStyle,
  });

  const ButtonThemeData.all(ButtonStyle? style)
      : defaultButtonStyle = style,
        filledButtonStyle = style,
        textButtonStyle = style,
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
      textButtonStyle: style.textButtonStyle ?? textButtonStyle,
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
      ..add(
          DiagnosticsProperty<ButtonStyle>('textButtonStyle', textButtonStyle))
      ..add(DiagnosticsProperty<ButtonStyle>(
          'defaultButtonStyle', defaultButtonStyle))
      ..add(
          DiagnosticsProperty<ButtonStyle>('iconButtonStyle', iconButtonStyle));
  }

  /// Defines the default color used by [Button]s using the current brightness
  /// and state.
  ///
  /// The color used for none and disabled are the same. Only the button
  /// content color should be changed. This can be done using the function
  /// [Color.basedOnLuminance] to define the contrast color.
  // Values eyeballed from Windows 10
  // Used when the state is not recieving any user
  // interaction or is disabled
  static Color buttonColor(Brightness brightness, Set<ButtonStates> states) {
    late Color color;
    if (brightness == Brightness.light) {
      if (states.isPressing) {
        color = const Color(0xFFf2f2f2);
      } else if (states.isHovering) {
        color = const Color(0xFFF6F6F6);
      } else {
        color = Colors.white;
      }
      return color;
    } else {
      if (states.isPressing) {
        color = const Color(0xFF272727);
      } else if (states.isHovering) {
        color = const Color(0xFF323232);
      } else {
        color = const Color(0xFF2b2b2b);
      }
      return color;
    }
  }

  /// Defines the default color used for inputs when checked, such as checkbox,
  /// radio button and toggle switch. It's based on the current style and the
  /// current state.
  static Color checkedInputColor(ThemeData theme, Set<ButtonStates> states) {
    final bool isDark = theme.brightness == Brightness.dark;
    return states.isPressing
        ? isDark
            ? theme.accentColor.darker
            : theme.accentColor.lighter
        : states.isHovering
            ? isDark
                ? theme.accentColor.dark
                : theme.accentColor.light
            : theme.accentColor;
  }

  static Color uncheckedInputColor(ThemeData style, Set<ButtonStates> states) {
    if (style.brightness == Brightness.light) {
      if (states.isDisabled) return style.disabledColor;
      if (states.isPressing) return const Color(0xFF221D08).withOpacity(0.155);
      if (states.isHovering) return const Color(0xFF221D08).withOpacity(0.055);
      return Colors.transparent;
    } else {
      if (states.isDisabled) return style.disabledColor;
      if (states.isPressing) return const Color(0xFFFFF3E8).withOpacity(0.080);
      if (states.isHovering) return const Color(0xFFFFF3E8).withOpacity(0.12);
      return Colors.transparent;
    }
  }
}
