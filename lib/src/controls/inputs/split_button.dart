import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class SplitButtonBar extends StatefulWidget {
  const SplitButtonBar({
    Key? key,
    required this.buttons,
    this.style,
  })  : assert(buttons.length > 1, 'There must 2 or more buttons'),
        super(key: key);

  final List<Widget> buttons;
  final SplitButtonStyle? style;

  @override
  _SplitButtonBarState createState() => _SplitButtonBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('buttonsAmount', buttons.length));
    properties.add(DiagnosticsProperty<SplitButtonStyle?>('style', style));
  }
}

class _SplitButtonBarState extends State<SplitButtonBar> {
  bool _showHighlight = false;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.splitButtonStyle?.copyWith(this.widget.style);
    return FocusableActionDetector(
      onShowFocusHighlight: (v) {
        setState(() => _showHighlight = v);
      },
      child: Container(
        decoration: BoxDecoration(border: () {
          if (_showHighlight) return focusedButtonBorder(context.theme);
        }()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.buttons.length, (index) {
            final button = widget.buttons[index];
            Widget b = Theme(
              data: context.theme.copyWith(Style(
                  buttonStyle: ButtonStyle(
                decoration: (state) => BoxDecoration(
                  borderRadius: (index == 0 ||
                          index == widget.buttons.length - 1)
                      ? BorderRadius.horizontal(
                          left: index == 0 ? Radius.circular(2) : Radius.zero,
                          right: index == widget.buttons.length - 1
                              ? Radius.circular(2)
                              : Radius.zero,
                        )
                      : null,
                  color: buttonColor(context.theme, state),
                ),
                margin: EdgeInsets.zero,
              ))),
              child: button,
            );
            if (index == 0) return b;
            return Padding(
              padding: EdgeInsets.only(left: style?.interval ?? 0),
              child: b,
            );
          }),
        ),
      ),
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

  static SplitButtonStyle defaultTheme(Style style) {
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
