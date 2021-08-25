import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';

/// A Split Button has two parts that can be invoked separately.
/// One part behaves like a standard button and invokes an immediate action.
/// The other part invokes a flyout that contains additional options that the
/// user can choose from.
///
/// ![SplitButton Preview](https://github.com/bdlukaa/fluent_ui#split-button)
///
/// See also:
///   - [Button]
///   - [IconButton]
class SplitButtonBar extends StatelessWidget {
  /// Creates a button bar with space in between the buttons.
  ///
  /// It provides a [ButtonThemeData] above each button to make them
  /// fell natural within the bar.
  const SplitButtonBar({
    Key? key,
    required this.buttons,
    this.style,
  })  : assert(buttons.length == 2, 'There must 2 buttons'),
        super(key: key);

  /// The buttons in this button bar. Must be only two buttons
  ///
  /// Usually a List of [Button]s
  final List<Widget> buttons;

  /// The style applied to this button bar. If non-null, it's
  /// merged with [ThemeData.splitButtonThemeData]
  final SplitButtonThemeData? style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('buttonsAmount', buttons.length))
      ..add(DiagnosticsProperty<SplitButtonThemeData?>('style', style));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final style = SplitButtonTheme.of(context).merge(this.style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttons.length, (index) {
        final buttonStyle = index == buttons.length - 1
            ? style.actionButtonStyle
            : style.primaryButtonStyle;
        final button = ButtonTheme.merge(
          data: ButtonThemeData.all(
            ButtonStyle(
              shape: ButtonState.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.disabledColor.withOpacity(0.75),
                    width: 0.1,
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0
                        ? style.borderRadius?.topLeft ?? Radius.zero
                        : Radius.zero,
                    right: index == buttons.length - 1
                        ? style.borderRadius?.topRight ?? Radius.zero
                        : Radius.zero,
                  ),
                ),
              ),
            ).merge(buttonStyle),
          ),
          child: FocusTheme(
            data: FocusThemeData(renderOutside: false),
            child: buttons[index],
          ),
        );
        if (index == 0) return button;
        return Padding(
          padding: EdgeInsets.only(left: style.interval ?? 0),
          child: button,
        );
      }),
    );
  }
}

class SplitButtonTheme extends InheritedTheme {
  /// Creates a button theme that controls how descendant [SplitButtonBar]s should
  /// look like.
  const SplitButtonTheme({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key, child: child);

  final Widget child;
  final SplitButtonThemeData data;

  /// Creates a button theme that controls how descendant [SplitButtonBar]s should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required SplitButtonThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return SplitButtonTheme(
        key: key,
        data: _getInheritedSplitButtonThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [ThemeData.splitButtonTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SplitButtonThemeData theme = SplitButtonTheme.of(context);
  /// ```
  static SplitButtonThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return SplitButtonThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedSplitButtonThemeData(context),
    );
  }

  static SplitButtonThemeData _getInheritedSplitButtonThemeData(
      BuildContext context) {
    final SplitButtonTheme? checkboxTheme =
        context.dependOnInheritedWidgetOfExactType<SplitButtonTheme>();
    return checkboxTheme?.data ?? FluentTheme.of(context).splitButtonTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SplitButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SplitButtonTheme oldWidget) {
    return oldWidget.data != data;
  }
}

@immutable
class SplitButtonThemeData with Diagnosticable {
  final BorderRadius? borderRadius;
  final double? interval;

  final ButtonStyle? primaryButtonStyle;
  final ButtonStyle? actionButtonStyle;

  const SplitButtonThemeData({
    this.borderRadius,
    this.interval,
    this.primaryButtonStyle,
    this.actionButtonStyle,
  });

  factory SplitButtonThemeData.standard(ThemeData style) {
    return SplitButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      interval: 1,
      primaryButtonStyle: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
      ),
      actionButtonStyle: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.all(6)),
      ),
    );
  }

  static SplitButtonThemeData lerp(
    SplitButtonThemeData? a,
    SplitButtonThemeData? b,
    double t,
  ) {
    return SplitButtonThemeData(
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      interval: lerpDouble(a?.interval, b?.interval, t),
      primaryButtonStyle:
          ButtonStyle.lerp(a?.primaryButtonStyle, b?.primaryButtonStyle, t),
      actionButtonStyle:
          ButtonStyle.lerp(a?.actionButtonStyle, b?.actionButtonStyle, t),
    );
  }

  SplitButtonThemeData merge(SplitButtonThemeData? style) {
    return SplitButtonThemeData(
      borderRadius: style?.borderRadius ?? borderRadius,
      interval: style?.interval ?? interval,
      primaryButtonStyle: style?.primaryButtonStyle ?? primaryButtonStyle,
      actionButtonStyle: style?.actionButtonStyle ?? actionButtonStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius', borderRadius))
      ..add(DoubleProperty('interval', interval))
      ..add(DiagnosticsProperty('primaryButtonStyle', primaryButtonStyle))
      ..add(DiagnosticsProperty('actionButtonStyle', actionButtonStyle));
  }
}
