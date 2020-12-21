import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    Key key,
    @required this.icon,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.semanticsLabel,
  })  : menu = null,
        super(key: key);

  const IconButton.menu({
    Key key,
    @required this.icon,
    @required this.menu,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.semanticsLabel,
  }) : super(key: key);

  final Widget icon;
  final Widget menu;

  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  final IconButtonStyle style;

  final String semanticsLabel;

  // TODO: tooltip
  // final String tooltip;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.iconButtonStyle.copyWith(this.style);
    return Button(
      text: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon,
          if (menu != null) menu,
        ],
      ),
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticsLabel: semanticsLabel,
      style: ButtonStyle(
        border: style.border,
        borderRadius: style.borderRadius,
        color: style.color,
        cursor: style.cursor,
        margin: style.margin,
        padding: style.padding,
      ),
    );
  }
}

class IconButtonStyle {
  final ButtonState<Color> color;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<Border> border;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  IconButtonStyle({
    this.color,
    this.cursor,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  static IconButtonStyle defaultTheme([Brightness brightness]) {
    final def = IconButtonStyle(
      cursor: buttonCursor,
      borderRadius: BorderRadius.circular(2),
      border: (_) => Border.all(style: BorderStyle.none),
      padding: EdgeInsets.all(4),
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(IconButtonStyle(color: lightButtonBackgroundColor));
    else
      return def.copyWith(IconButtonStyle(color: darkButtonBackgroundColor));
  }

  IconButtonStyle copyWith(IconButtonStyle style) {
    if (style == null) return this;
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
