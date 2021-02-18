import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class RadioButton extends StatelessWidget {
  const RadioButton({
    Key key,
    @required this.selected,
    @required this.onChanged,
    this.style,
  }) : super(key: key);

  final bool selected;
  final ValueChanged<bool> onChanged;

  final RadioButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.radioButtonStyle.copyWith(this.style);
    return HoverButton(
      onPressed: onChanged == null ? null : () => onChanged(!selected),
      builder: (context, state) {
        return AnimatedContainer(
          duration: style.animationDuration ?? Duration(milliseconds: 300),
          height: 20,
          width: 20,
          decoration: selected
              ? style?.checkedDecoration(state)
              : style?.uncheckedDecoration(state),
        );
      },
    );
  }
}

class RadioButtonStyle {
  final ButtonState<Decoration> checkedDecoration;
  final ButtonState<Decoration> uncheckedDecoration;

  final ButtonState<MouseCursor> cursor;

  final Duration animationDuration;
  final Curve animationCurve;

  RadioButtonStyle({
    this.cursor,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  static RadioButtonStyle defaultTheme([Brightness brightness]) {
    Color disabledColor = Colors.grey[100].withOpacity(0.6);
    final def = RadioButtonStyle(
      cursor: (state) => state.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(RadioButtonStyle(
        uncheckedDecoration: (state) => BoxDecoration(
          border: Border.all(
            width: 1.3,
            color: state.isDisabled ? disabledColor : Colors.grey[220],
          ),
          shape: BoxShape.circle,
        ),
        checkedDecoration: (state) => BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 4.5,
          ),
          shape: BoxShape.circle,
        ),
      ));
    else
      return def.copyWith(RadioButtonStyle(
        uncheckedDecoration: (state) => BoxDecoration(
          border: Border.all(
            width: 1.3,
            color: state.isDisabled ? disabledColor : Colors.grey[220],
          ),
          shape: BoxShape.circle,
        ),
        checkedDecoration: (state) => BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 4.5,
          ),
          shape: BoxShape.circle,
        ),
      ));
  }

  RadioButtonStyle copyWith(RadioButtonStyle style) {
    if (style == null) return this;
    return RadioButtonStyle(
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }
}
