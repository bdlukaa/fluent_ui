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
  })  : assert(checked != null),
        super(key: key);

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
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
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
          decoration: checked
              ? style.checkedDecoration(state)
              : style.uncheckedDecoration(state),
          child: thumb ??
              DefaultToggleSwitchThumb(
                checked: checked,
                style: style,
                state: state,
              ),
        );
      },
    );
  }
}

class DefaultToggleSwitchThumb extends StatelessWidget {
  const DefaultToggleSwitchThumb({
    Key key,
    @required this.checked,
    @required this.style,
    @required this.state,
  })  : assert(checked != null),
        assert(style != null),
        assert(state != null),
        super(key: key);

  final bool checked;
  final ToggleSwitchStyle style;
  final ButtonStates state;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 8,
        minWidth: 8,
        maxHeight: 13,
        maxWidth: 13,
      ),
      decoration: checked
          ? style.checkedThumbDecoration(state)
          : style.uncheckedThumbDecoration(state),
    );
  }
}

class ToggleSwitchStyle {
  final ButtonState<Decoration> checkedThumbDecoration;
  final ButtonState<Decoration> uncheckedThumbDecoration;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<Decoration> checkedDecoration;
  final ButtonState<Decoration> uncheckedDecoration;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  const ToggleSwitchStyle({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedThumbDecoration,
    this.uncheckedThumbDecoration,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  static ToggleSwitchStyle defaultTheme(Style style, [Brightness brightness]) {
    final accent = style.accentColor;

    final defaultThumbDecoration = BoxDecoration(
      color: brightness == null || brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      shape: BoxShape.circle,
    );

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(25),
    );

    final def = ToggleSwitchStyle(
      cursor: (state) => state.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(accent, state),
        border: Border.all(style: BorderStyle.none),
      ),
      uncheckedDecoration: (state) {
        final borderColor = brightness == null || brightness == Brightness.light
            ? Colors.grey[220]
            : Colors.white;
        return defaultDecoration.copyWith(
          color: uncheckedInputColor(state),
          border: Border.all(
            width: 0.8,
            color: state.isNone ? borderColor : uncheckedInputColor(state),
          ),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: EdgeInsets.all(4),
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
      checkedThumbDecoration: (_) => defaultThumbDecoration,
      uncheckedThumbDecoration: (_) => defaultThumbDecoration,
    );

    return def;
  }

  ToggleSwitchStyle copyWith(ToggleSwitchStyle style) {
    if (style == null) return this;
    return ToggleSwitchStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedThumbDecoration:
          style?.checkedThumbDecoration ?? checkedThumbDecoration,
      uncheckedThumbDecoration:
          style?.uncheckedThumbDecoration ?? uncheckedThumbDecoration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }
}
