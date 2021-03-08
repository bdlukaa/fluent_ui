import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ToggleButton extends StatefulWidget {
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
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  double buttonScale = 1;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!.toggleButtonStyle?.copyWith(this.widget.style);
    return HoverButton(
      focusNode: widget.focusNode,
      semanticsLabel: widget.semanticsLabel,
      cursor: style?.cursor,
      margin: style?.margin,
      onTapDown: () {
        if (mounted) setState(() => buttonScale = style?.scaleFactor ?? 0.95);
      },
      onLongPressStart: () {
        if (mounted) setState(() => buttonScale = style?.scaleFactor ?? 0.95);
      },
      onLongPressEnd: () {
        if (mounted) setState(() => buttonScale = 1);
      },
      onPressed: widget.onChanged == null
          ? null
          : () async {
              widget.onChanged!(!widget.checked);
              if (mounted)
                setState(() => buttonScale = style?.scaleFactor ?? 0.95);
              await Future.delayed(Duration(milliseconds: 120));
              if (mounted) setState(() => buttonScale = 1);
            },
      builder: (context, state) {
        return AnimatedContainer(
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(buttonScale, buttonScale, 1.0),
          duration: style?.animationDuration ?? Duration.zero,
          curve: style?.animationCurve ?? Curves.linear,
          padding: style?.padding,
          decoration: widget.checked
              ? style?.checkedDecoration!(state)
              : style?.uncheckedDecoration!(state),
          child: AnimatedDefaultTextStyle(
            duration: style?.animationDuration ?? Duration.zero,
            curve: style?.animationCurve ?? Curves.linear,
            style: TextStyle(
              color: widget.checked
                  ? context.theme?.activeColor
                  : context.theme?.inactiveColor,
            ),
            child: widget.child ?? SizedBox(),
          ),
        );
      },
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
    Color? borderColor = brightness == null || brightness == Brightness.light
        ? Colors.grey[220]
        : Colors.white;

    final def = ToggleButtonStyle(
      scaleFactor: 0.95,
      cursor: buttonCursor,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: checkedInputColor(style, state),
        border: Border.all(width: 0.6, color: checkedInputColor(style, state)!),
      ),
      uncheckedDecoration: (state) {
        if (state.isHovering || state.isPressing)
          return defaultDecoration.copyWith(
            color: uncheckedInputColor(style, state),
            border: Border.all(
              width: 0.6,
              color: uncheckedInputColor(style, state)!,
            ),
          );
        return defaultDecoration.copyWith(
          border: Border.all(
            width: 0.6,
            color: state.isDisabled ? style.disabledColor! : borderColor!,
          ),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      animationDuration: style.animationDuration,
      animationCurve: style.animationCurve,
    );

    return def;
  }

  ToggleButtonStyle copyWith(ToggleButtonStyle? style) {
    return ToggleButtonStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
      scaleFactor: style?.scaleFactor ?? scaleFactor,
    );
  }
}
