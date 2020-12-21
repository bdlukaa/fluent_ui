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
  }) : super(key: key);

  final bool checked;
  final ValueChanged<bool> onChanged;

  final CheckboxStyle style;

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.checkboxStyle.copyWith(this.style);
    return Semantics(
      label: semanticsLabel,
      child: HoverButton(
        cursor: (_, state) => style.cursor?.call(state),
        onPressed: onChanged == null ? null : () => onChanged(!checked),
        builder: (context, state) {
          return AnimatedContainer(
            duration: style.animationDuration,
            curve: style.animationCurve,
            padding: style.padding,
            margin: style.margin,
            decoration: BoxDecoration(
              color: checked
                  ? style.checkedColor(state)
                  : style.uncheckedColor(state),
              border: checked
                  ? style.checkedBorder(state)
                  : style.uncheckedBorder(state),
              borderRadius: style.borderRadius,
            ),
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
      ),
    );
  }
}

class CheckboxStyle {
  final ButtonState<Color> checkedColor;
  final ButtonState<Color> uncheckedColor;

  final IconData icon;
  final ButtonState<Color> checkedIconColor;
  final ButtonState<Color> uncheckedIconColor;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<Border> checkedBorder;
  final ButtonState<Border> uncheckedBorder;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  CheckboxStyle({
    this.checkedColor,
    this.uncheckedColor,
    this.cursor,
    this.checkedBorder,
    this.uncheckedBorder,
    this.borderRadius,
    this.padding,
    this.margin,
    this.icon,
    this.checkedIconColor,
    this.uncheckedIconColor,
    this.animationDuration,
    this.animationCurve,
  });

  static CheckboxStyle defaultTheme([Brightness brightness]) {
    Color disabledColor = Colors.grey[100].withOpacity(0.6);
    final def = CheckboxStyle(
      cursor: buttonCursor,
      borderRadius: BorderRadius.circular(2),
      checkedColor: (state) {
        if (state.isDisabled)
          return disabledColor;
        else if (state.isHovering || state.isPressing)
          return Colors.blue[60];
        else
          return Colors.blue[50];
      },
      checkedBorder: (state) => Border.all(style: BorderStyle.none),
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(4),
      icon: FluentIcons.checkbox_checked_24_filled,
      uncheckedColor: (_) => Colors.transparent,
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(CheckboxStyle(
        uncheckedBorder: (state) => Border.all(
          width: 0.6,
          color: state.isDisabled ? disabledColor : Colors.black,
        ),
        checkedIconColor: (_) => Colors.white,
        uncheckedIconColor: (state) {
          if (state.isHovering || state.isPressing) return Colors.black;
          return Colors.transparent;
        },
      ));
    else
      return def.copyWith(CheckboxStyle(
        uncheckedBorder: (state) => Border.all(
          width: 0.6,
          color: state.isDisabled ? disabledColor : Colors.white,
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
      checkedBorder: style?.checkedBorder ?? checkedBorder,
      uncheckedBorder: style?.uncheckedBorder ?? uncheckedBorder,
      borderRadius: style?.borderRadius ?? borderRadius,
      checkedColor: style?.checkedColor ?? checkedColor,
      uncheckedColor: style?.uncheckedColor ?? uncheckedColor,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      icon: style?.icon ?? icon,
      checkedIconColor: style?.checkedIconColor ?? checkedIconColor,
      uncheckedIconColor: style?.uncheckedIconColor ?? uncheckedIconColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
    );
  }
}
