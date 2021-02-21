import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/rendering.dart';

class Checkbox extends StatelessWidget {
  const Checkbox({
    Key key,
    @required this.checked,
    @required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.focusNode,
  }) : super(key: key);

  final bool checked;
  final ValueChanged<bool> onChanged;

  final CheckboxStyle style;

  final String semanticsLabel;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.checkboxStyle.copyWith(this.style);
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: (_, state) => style.cursor?.call(state),
      onPressed: onChanged == null ? null : () => onChanged(!checked),
      builder: (context, state) {
        return AnimatedContainer(
          duration: style.animationDuration,
          curve: style.animationCurve,
          padding: style.padding,
          decoration: checked
              ? style.checkedDecoration(state)
              : style.uncheckedDecoration(state),
          child: AnimatedSwitcher(
            duration: style.animationDuration,
            switchInCurve: style.animationCurve,
            child: Icon(
              style.icon,
              color: checked
                  ? style.checkedIconColor(state)
                  : style.uncheckedIconColor(state),
              key: ValueKey(state),
            ),
          ),
        );
      },
    );
  }
}

class CheckboxStyle {
  final ButtonState<Decoration> checkedDecoration;
  final ButtonState<Decoration> uncheckedDecoration;
  final ButtonState<Decoration> thirdstateDecoration;

  final IconData icon;
  final ButtonState<Color> checkedIconColor;
  final ButtonState<Color> uncheckedIconColor;
  final ButtonState<Color> thirdstateIconColor;

  final ButtonState<MouseCursor> cursor;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  const CheckboxStyle({
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.thirdstateDecoration,
    this.cursor,
    this.padding,
    this.margin,
    this.icon,
    this.checkedIconColor,
    this.uncheckedIconColor,
    this.thirdstateIconColor,
    this.animationDuration,
    this.animationCurve,
  });

  static CheckboxStyle defaultTheme(Style style, [Brightness brightness]) {
    final disabledColor = Colors.grey[100].withOpacity(0.6);
    final radius = BorderRadius.circular(3);
    final def = CheckboxStyle(
      cursor: buttonCursor,
      checkedDecoration: (state) {
        Color color;
        if (state.isDisabled)
          color = disabledColor;
        else if (state.isHovering || state.isPressing)
          color = Colors.blue[60];
        else
          color = Colors.blue[50];
        return BoxDecoration(
          borderRadius: radius,
          color: color,
          border: Border.all(style: BorderStyle.none),
        );
      },
      thirdstateDecoration: (state) {
        Color color;
        if (state.isDisabled)
          color = disabledColor;
        else if (state.isHovering || state.isPressing)
          color = Colors.blue[60];
        else
          color = Colors.blue[50];
        return BoxDecoration(
          borderRadius: radius,
          color: color,
          border: Border.all(
            width: 4.5,
            color: Colors.blue,
          ),
        );
      },
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(4),
      icon: FluentIcons.checkbox_checked_24_filled,
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(CheckboxStyle(
        uncheckedDecoration: (state) => BoxDecoration(
          border: Border.all(
            width: 0.6,
            color: state.isDisabled ? disabledColor : Colors.black,
          ),
          color: Colors.transparent,
          borderRadius: radius,
        ),
        checkedIconColor: (_) => Colors.white,
        uncheckedIconColor: (state) {
          if (state.isHovering || state.isPressing) return Colors.black;
          return Colors.transparent;
        },
      ));
    else
      return def.copyWith(CheckboxStyle(
        uncheckedDecoration: (state) => BoxDecoration(
          border: Border.all(
            width: 0.6,
            color: state.isDisabled ? disabledColor : Colors.white,
          ),
          color: Colors.transparent,
          borderRadius: radius,
        ),
        checkedIconColor: (_) => Colors.white,
        uncheckedIconColor: (state) {
          if (state.isHovering || state.isPressing) return Colors.white;
          return Colors.transparent;
        },
      ));
  }

  CheckboxStyle copyWith(CheckboxStyle style) {
    if (style == null) return this;
    return CheckboxStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      icon: style?.icon ?? icon,
      checkedIconColor: style?.checkedIconColor ?? checkedIconColor,
      uncheckedIconColor: style?.uncheckedIconColor ?? uncheckedIconColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }
}
