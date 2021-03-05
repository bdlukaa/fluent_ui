import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class RadioButton extends StatelessWidget {
  const RadioButton({
    Key? key,
    required this.selected,
    required this.onChanged,
    this.style,
  }) : super(key: key);

  final bool selected;
  final ValueChanged<bool>? onChanged;

  final RadioButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = context.theme?.radioButtonStyle?.copyWith(this.style);
    return HoverButton(
      onPressed: onChanged == null ? null : () => onChanged!(!selected),
      builder: (context, state) {
        return AnimatedContainer(
          duration: style?.animationDuration ?? Duration(milliseconds: 300),
          height: 20,
          width: 20,
          decoration: selected
              ? style?.checkedDecoration!(state)
              : style?.uncheckedDecoration!(state),
        );
      },
    );
  }
}

class RadioButtonStyle {
  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final ButtonState<MouseCursor>? cursor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const RadioButtonStyle({
    this.cursor,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  static RadioButtonStyle defaultTheme(Style style, [Brightness? brightness]) {
    final def = RadioButtonStyle(
      cursor: buttonCursor,
      animationDuration: style.animationDuration,
      animationCurve: style.animationCurve,
      checkedDecoration: (state) => BoxDecoration(
        border: Border.all(
          color: checkedInputColor(style, state)!,
          width: 4.5,
        ),
        shape: BoxShape.circle,
      ),
      uncheckedDecoration: (state) => BoxDecoration(
        color: uncheckedInputColor(style, state),
        border: Border.all(
          width: 1,
          color: state.isNone
              ? Colors.grey[150]!
              : uncheckedInputColor(style, state)!,
        ),
        shape: BoxShape.circle,
      ),
    );
    return def;
  }

  RadioButtonStyle copyWith(RadioButtonStyle? style) {
    return RadioButtonStyle(
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }
}
