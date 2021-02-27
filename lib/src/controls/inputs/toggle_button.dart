import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key key,
    @required this.checked,
    @required this.onChanged,
    this.child,
    this.style,
  }) : super(key: key);

  final Widget child;

  final bool checked;
  final ValueChanged<bool> onChanged;

  final ToggleButtonStyle style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.toggleButtonStyle.copyWith(this.style);
    return HoverButton(
      cursor: (context, state) => style.cursor(state),
      margin: style.margin,
      onPressed: onChanged == null ? null : () => onChanged(!checked),
      builder: (context, state) {
        return AnimatedContainer(
          duration: style?.animationDuration,
          curve: style?.animationCurve,
          padding: style.padding,
          decoration: checked
              ? style.checkedDecoration(state)
              : style.uncheckedDecoration(state),
          child: child,
        );
      },
    );
  }
}

class ToggleButtonStyle {
  final ButtonState<MouseCursor> cursor;

  final ButtonState<Decoration> checkedDecoration;
  final ButtonState<Decoration> uncheckedDecoration;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  const ToggleButtonStyle({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  static ToggleButtonStyle defaultTheme(Style style, [Brightness brightness]) {
    final accent = style.accentColor;

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
    );
    Color borderColor = brightness == null || brightness == Brightness.light
        ? Colors.grey[220]
        : Colors.white;

    final def = ToggleButtonStyle(
      cursor: (state) => state.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(accent, state),
        border: Border.all(width: 0.6, color: checkedInputColor(accent, state)),
      ),
      uncheckedDecoration: (state) {
        if (state.isHovering || state.isPressing)
          return defaultDecoration.copyWith(
            color: uncheckedInputColor(state),
            border: Border.all(width: 0.6, color: uncheckedInputColor(state)),
          );
        return defaultDecoration.copyWith(
          border: Border.all(
            width: 0.6,
            color: state.isDisabled ? kDefaultButtonDisabledColor : borderColor,
          ),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );

    return def;
  }

  ToggleButtonStyle copyWith(ToggleButtonStyle style) {
    if (style == null) return this;
    return ToggleButtonStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }
}
