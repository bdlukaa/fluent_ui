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
  })  : assert(buttons.length > 1, 'There must 2 or more buttons'),
        super(key: key);

  /// The buttons in this button bar. Must be more than 1 button
  ///
  /// Usually a List of [Button]s
  final List<Widget> buttons;

  /// The style applied to this button bar. If non-null, it's
  /// mescled with [ThemeData.splitButtonThemeData]
  final SplitButtonThemeData? style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('buttonsAmount', buttons.length));
    properties.add(DiagnosticsProperty<SplitButtonThemeData?>('style', style));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final SplitButtonThemeData style =
        SplitButtonTheme.of(context).copyWith(this.style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttons.length, (index) {
        final button = ButtonTheme.merge(
          data: ButtonThemeData(
            decoration: ButtonState.resolveWith((states) {
              return BoxDecoration(
                // is the last index
                borderRadius: (index == 0 || index == buttons.length - 1)
                    ? BorderRadius.horizontal(
                        left: index == 0 ? Radius.circular(2) : Radius.zero,
                        right: index == buttons.length - 1
                            ? Radius.circular(2)
                            : Radius.zero,
                      )
                    : null,
                color: ButtonThemeData.buttonColor(
                  FluentTheme.of(context),
                  states,
                ),
              );
            }),
            margin: EdgeInsets.zero,
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
        data: _getInheritedSplitButtonThemeData(context).copyWith(data),
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
    return SplitButtonThemeData.standard(FluentTheme.of(context)).copyWith(
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

  final ButtonThemeData? defaultButtonThemeData;

  const SplitButtonThemeData({
    this.borderRadius,
    this.interval,
    this.defaultButtonThemeData,
  });

  factory SplitButtonThemeData.standard(ThemeData style) {
    return SplitButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      interval: 1,
      defaultButtonThemeData: style.buttonTheme.copyWith(ButtonThemeData(
        margin: EdgeInsets.zero,
      )),
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
      defaultButtonThemeData: ButtonThemeData.lerp(
          a?.defaultButtonThemeData, b?.defaultButtonThemeData, t),
    );
  }

  SplitButtonThemeData copyWith(SplitButtonThemeData? style) {
    return SplitButtonThemeData(
      borderRadius: style?.borderRadius ?? borderRadius,
      interval: style?.interval ?? interval,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BorderRadiusGeometry>(
      'borderRadius',
      borderRadius,
    ));
    properties.add(DoubleProperty('interval', interval));
  }
}
