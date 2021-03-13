import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.semanticsLabel,
    this.focusNode,
  }) : super(key: key);

  final Widget? icon;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final IconButtonStyle? style;

  final String? semanticsLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme!.iconButtonStyle!.copyWith(this.style);
    return Button(
      focusNode: focusNode,
      text: icon,
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticsLabel: semanticsLabel,
      style: ButtonStyle(
        decoration: (state) => BoxDecoration(
          border: style.border!(state),
          borderRadius: style.borderRadius,
          color: style.color!(state),
        ),
        cursor: style.cursor,
        margin: style.margin,
        padding: style.padding,
      ),
    );
  }
}

class IconButtonStyle {
  final ButtonState<Color?>? color;

  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Border>? border;
  final BorderRadiusGeometry? borderRadius;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const IconButtonStyle({
    this.color,
    this.cursor,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  static IconButtonStyle defaultTheme(Style style) {
    final def = IconButtonStyle(
      cursor: buttonCursor,
      borderRadius: BorderRadius.circular(2),
      border: (_) => Border.all(style: BorderStyle.none),
      padding: EdgeInsets.all(4),
      color: (state) => uncheckedInputColor(style, state),
    );
    return def;
  }

  IconButtonStyle copyWith(IconButtonStyle? style) {
    return IconButtonStyle(
      border: style?.border ?? border,
      borderRadius: style?.borderRadius ?? borderRadius,
      color: style?.color ?? color,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
    );
  }
}
