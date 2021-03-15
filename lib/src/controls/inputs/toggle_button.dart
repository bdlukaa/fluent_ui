import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.child,
    this.style,
    this.semanticsLabel,
    this.focusNode,
  }) : super(key: key);

  final Widget? child;

  final bool checked;
  final ValueChanged<bool>? onChanged;

  final ToggleButtonStyle? style;

  final String? semanticsLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!.toggleButtonStyle?.copyWith(this.style);
    return Button(
      text: child,
      onPressed: onChanged == null ? null : () => onChanged!(!checked),
      style: ButtonStyle(
        decoration: (state) => checked
            ? style?.checkedDecoration!(state)
            : style?.uncheckedDecoration!(state),
        padding: style?.padding,
        animationCurve: style?.animationCurve,
        animationDuration: style?.animationDuration,
        cursor: style?.cursor,
        margin: style?.margin,
        scaleFactor: style?.scaleFactor,
      ),
    );
  }
}

class ToggleButtonStyle {
  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final double? scaleFactor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const ToggleButtonStyle({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.scaleFactor,
  });

  static ToggleButtonStyle defaultTheme(Style style, [Brightness? brightness]) {
    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
    );
    final def = ToggleButtonStyle(
      scaleFactor: 0.95,
      cursor: buttonCursor,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(style, state),
        border: Border.all(width: 0.6, color: checkedInputColor(style, state)),
      ),
      uncheckedDecoration: (state) {
        if (state.isHovering || state.isPressing)
          return defaultDecoration.copyWith(
            color: uncheckedInputColor(style, state),
            border: Border.all(
              width: 0.6,
              color: uncheckedInputColor(style, state),
            ),
          );
        return defaultDecoration.copyWith(
          color: buttonColor(style, state),
          border: Border.all(width: 0.6, color: Colors.transparent),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
    );

    return def;
  }

  ToggleButtonStyle copyWith(ToggleButtonStyle? style) {
    if (style == null) return this;
    return ToggleButtonStyle(
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      cursor: style.cursor ?? cursor,
      animationCurve: style.animationCurve ?? animationCurve,
      animationDuration: style.animationDuration ?? animationDuration,
      checkedDecoration: style.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style.uncheckedDecoration ?? uncheckedDecoration,
      scaleFactor: style.scaleFactor ?? scaleFactor,
    );
  }
}
