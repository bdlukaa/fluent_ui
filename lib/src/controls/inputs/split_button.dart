import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

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
  /// It provides a [ButtonStyle] above each button to make them
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
  /// mescled with [Style.splitButtonStyle]
  final SplitButtonStyle? style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('buttonsAmount', buttons.length));
    properties.add(DiagnosticsProperty<SplitButtonStyle?>('style', style));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.splitButtonStyle?.copyWith(this.style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(buttons.length, (index) {
        final button = buttons[index];
        Widget b = Theme(
          data: context.theme.copyWith(Style(
            buttonStyle: ButtonStyle(
              decoration: (state) => BoxDecoration(
                borderRadius: (index == 0 || index == buttons.length - 1)
                    ? BorderRadius.horizontal(
                        left: index == 0 ? Radius.circular(2) : Radius.zero,
                        right: index == buttons.length - 1
                            ? Radius.circular(2)
                            : Radius.zero,
                      )
                    : null,
                color: ButtonStyle.buttonColor(context.theme, state),
              ),
              margin: EdgeInsets.zero,
            ),
          )),
          child: button,
        );
        if (index == 0) return b;
        return Padding(
          padding: EdgeInsets.only(left: style?.interval ?? 0),
          child: b,
        );
      }),
    );
  }
}

@immutable
class SplitButtonStyle with Diagnosticable {
  final BorderRadius? borderRadius;
  final double? interval;

  final ButtonStyle? defaultButtonStyle;

  const SplitButtonStyle({
    this.borderRadius,
    this.interval,
    this.defaultButtonStyle,
  });

  factory SplitButtonStyle.standard(Style style) {
    return SplitButtonStyle(
      borderRadius: BorderRadius.circular(4),
      interval: 1,
      defaultButtonStyle: style.buttonStyle?.copyWith(ButtonStyle(
        margin: EdgeInsets.zero,
      )),
    );
  }

  SplitButtonStyle copyWith(SplitButtonStyle? style) {
    return SplitButtonStyle(
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
