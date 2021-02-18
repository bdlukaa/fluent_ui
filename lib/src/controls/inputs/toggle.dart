import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    Key key,
    @required this.checked,
    @required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.thumb,
    this.focusNode,
  }) : super(key: key);

  final bool checked;
  final ValueChanged<bool> onChanged;

  final Widget thumb;

  final ToggleSwitchStyle style;

  final String semanticsLabel;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.toggleSwitchStyle.copyWith(this.style);
    return Semantics(
      label: semanticsLabel,
      child: Padding(
        padding: style.margin,
        child: HoverButton(
          focusNode: focusNode,
          cursor: (_, state) => style.cursor?.call(state),
          onPressed: onChanged == null ? null : () => onChanged(!checked),
          builder: (context, state) {
            return AnimatedContainer(
              alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
              height: 25,
              width: 60,
              duration: style.animationDuration,
              curve: style.animationCurve,
              padding: style.padding,
              decoration: BoxDecoration(
                color: checked
                    ? style.checkedColor(state)
                    : style.uncheckedColor(state),
                border: checked
                    ? style.checkedBorder(state)
                    : style.uncheckedBorder(state),
                borderRadius: style.borderRadius,
              ),
              child: thumb ??
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 8,
                      minWidth: 8,
                      maxHeight: 13,
                      maxWidth: 13,
                    ),
                    decoration: BoxDecoration(
                      color: checked
                          ? style.checkedThumbColor(state)
                          : style.uncheckedThumbColor(state),
                      borderRadius: style.thumbBorderRadius,
                    ),
                  ),
            );
          },
        ),
      ),
    );
  }
}

class ToggleSwitchStyle {
  final ButtonState<Color> checkedColor;
  final ButtonState<Color> uncheckedColor;

  final ButtonState<Color> checkedThumbColor;
  final ButtonState<Color> uncheckedThumbColor;
  final BorderRadiusGeometry thumbBorderRadius;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<Border> checkedBorder;
  final ButtonState<Border> uncheckedBorder;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  ToggleSwitchStyle({
    this.checkedColor,
    this.uncheckedColor,
    this.cursor,
    this.checkedBorder,
    this.uncheckedBorder,
    this.borderRadius,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedThumbColor,
    this.uncheckedThumbColor,
    this.thumbBorderRadius,
  });

  static ToggleSwitchStyle defaultTheme([Brightness brightness]) {
    Color disabledColor = Colors.grey[100].withOpacity(0.6);
    final def = ToggleSwitchStyle(
      cursor: (state) => state.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(25),
      thumbBorderRadius: BorderRadius.circular(100),
      checkedColor: (state) {
        if (state.isDisabled)
          return disabledColor;
        else if (state.isHovering || state.isPressing)
          return Colors.blue[60];
        else
          return Colors.blue[50];
      },
      checkedBorder: (state) => Border.all(style: BorderStyle.none),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: EdgeInsets.all(4),
      uncheckedColor: (_) => Colors.transparent,
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(ToggleSwitchStyle(
        uncheckedBorder: (state) => Border.all(
          width: 0.8,
          color: state.isDisabled ? disabledColor : Colors.grey[220],
        ),
        checkedThumbColor: (_) => Colors.white,
        uncheckedThumbColor: (_) => Colors.black,
      ));
    else
      return def.copyWith(ToggleSwitchStyle(
        uncheckedBorder: (state) => Border.all(
          width: 0.8,
          color: state.isDisabled ? disabledColor : Colors.white,
        ),
        checkedThumbColor: (_) => Colors.white,
        uncheckedThumbColor: (_) => Colors.white,
      ));
  }

  ToggleSwitchStyle copyWith(ToggleSwitchStyle style) {
    if (style == null) return this;
    return ToggleSwitchStyle(
      checkedBorder: style?.checkedBorder ?? checkedBorder,
      uncheckedBorder: style?.uncheckedBorder ?? uncheckedBorder,
      borderRadius: style?.borderRadius ?? borderRadius,
      checkedColor: style?.checkedColor ?? checkedColor,
      uncheckedColor: style?.uncheckedColor ?? uncheckedColor,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedThumbColor: style?.checkedThumbColor ?? checkedThumbColor,
      uncheckedThumbColor: style?.uncheckedThumbColor ?? uncheckedThumbColor,
      thumbBorderRadius: style?.thumbBorderRadius ?? thumbBorderRadius,
    );
  }
}
