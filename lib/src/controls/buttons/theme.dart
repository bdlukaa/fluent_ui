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

  final WidgetStateProperty<TextStyle?>? textStyle;

  final WidgetStateProperty<Color?>? backgroundColor;

  final WidgetStateProperty<Color?>? foregroundColor;

  final WidgetStateProperty<Color?>? shadowColor;

  final WidgetStateProperty<double?>? elevation;

  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  final WidgetStateProperty<ShapeBorder?>? shape;

  final WidgetStateProperty<double?>? iconSize;

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
      textStyle: lerpWidgetStateProperty<TextStyle?>(
        a?.textStyle,
        b?.textStyle,
        t,
        TextStyle.lerp,
      ),
      backgroundColor: lerpWidgetStateProperty<Color?>(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: lerpWidgetStateProperty<Color?>(
        a?.foregroundColor,
        b?.foregroundColor,
        t,
        Color.lerp,
      ),
      shadowColor: lerpWidgetStateProperty<Color?>(
        a?.shadowColor,
        b?.shadowColor,
        t,
        Color.lerp,
      ),
      elevation: lerpWidgetStateProperty<double?>(
        a?.elevation,
        b?.elevation,
        t,
        lerpDouble,
      ),
      padding: lerpWidgetStateProperty<EdgeInsetsGeometry?>(
        a?.padding,
        b?.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      shape: lerpWidgetStateProperty<ShapeBorder?>(
        a?.shape,
        b?.shape,
        t,
        ShapeBorder.lerp,
      ),
      iconSize: lerpWidgetStateProperty<double?>(
        a?.iconSize,
        b?.iconSize,
        t,
        lerpDouble,
      ),
    );
  }

  ButtonStyle copyWith({
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? shadowColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<EdgeInsetsGeometry?>? padding,
    WidgetStateProperty<ShapeBorder?>? shape,
    WidgetStateProperty<double?>? iconSize,
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
  /// Creates a theme that controls how descendant [Button]s should look like.
  const ButtonTheme({required super.child, required this.data, super.key});

  /// The properties for descendant [Button] widgets.
  final ButtonThemeData data;

  /// Creates a theme that merges the nearest [ButtonTheme] with [data].
  static Widget merge({
    required ButtonThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return ButtonTheme(
          key: key,
          data: ButtonTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [ButtonThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Global theme from [FluentThemeData.buttonTheme]
  /// 2. Local [ButtonTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ButtonThemeData theme = ButtonTheme.of(context);
  /// ```
  static ButtonThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<ButtonTheme>();
    return theme.buttonTheme.merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ButtonTheme oldWidget) => data != oldWidget.data;
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
      ..add(
        DiagnosticsProperty<ButtonStyle>(
          'outlinedButtonStyle',
          outlinedButtonStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStyle>(
          'filledButtonStyle',
          filledButtonStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStyle>(
          'hyperlinkButtonStyle',
          hyperlinkButtonStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStyle>(
          'defaultButtonStyle',
          defaultButtonStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStyle>('iconButtonStyle', iconButtonStyle),
      );
  }

  /// Defines the default color used by [Button]s using the current brightness
  /// and state.
  static Color buttonColor(
    BuildContext context,
    Set<WidgetState> states, {
    bool transparentWhenNone = false,
  }) {
    final res = FluentTheme.of(context).resources;
    if (states.isPressed) {
      return res.controlFillColorTertiary;
    } else if (states.isHovered) {
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
    Set<WidgetState> states,
  ) {
    final res = FluentTheme.of(context).resources;
    if (states.isPressed) {
      return res.textFillColorSecondary;
    } else if (states.isDisabled) {
      return res.textFillColorDisabled;
    }
    return res.textFillColorPrimary;
  }

  static ShapeBorder shapeBorder(
    BuildContext context,
    Set<WidgetState> states,
  ) {
    final theme = FluentTheme.of(context);
    if (states.isPressed || states.isDisabled) {
      return RoundedRectangleBorder(
        side: BorderSide(color: theme.resources.controlStrokeColorDefault),
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      return RoundedRectangleGradientBorder(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.center,
          end: const Alignment(0, 3),
          colors: [
            theme.resources.controlStrokeColorSecondary,
            theme.resources.controlStrokeColorDefault,
          ],
          stops: const [0.3, 1.0],
        ),
      );
    }
  }

  /// Defines the default color used for inputs when checked, such as checkbox,
  /// radio button and toggle switch. It's based on the current style and the
  /// current state.
  static Color checkedInputColor(
    FluentThemeData theme,
    Set<WidgetState> states,
  ) {
    return FilledButton.backgroundColor(theme, states);
  }

  static Color uncheckedInputColor(
    FluentThemeData theme,
    Set<WidgetState> states, {
    bool transparentWhenNone = false,
    bool transparentWhenDisabled = false,
  }) {
    final res = theme.resources;
    if (states.isDisabled) {
      if (transparentWhenDisabled) return res.subtleFillColorTransparent;
      return res.controlAltFillColorDisabled;
    }
    if (states.isPressed) return res.subtleFillColorTertiary;
    if (states.isHovered) return res.subtleFillColorSecondary;
    return transparentWhenNone
        ? res.subtleFillColorTransparent
        : res.controlAltFillColorSecondary;
  }
}
