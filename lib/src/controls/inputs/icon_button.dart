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
    final style = IconButtonTheme.of(context).copyWith(this.style);
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
      borderRadius: BorderRadius.circular(2),
      color: (state) {
        if (state.isDisabled)
          return Colors.grey[40];
        else if (state.isPressing)
          return Colors.grey[30];
        else if (state.isHovering)
          return Colors.grey[20];
        else
          return Colors.transparent;
      },
      border: (_) => Border.all(style: BorderStyle.none),
      padding: EdgeInsets.all(4),
    );
    return def;
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

class IconButtonTheme extends TreeTheme<IconButtonStyle> {
  /// Creates a theme style that controls design for
  /// [IconButton].
  ///
  /// The data argument must not be null.
  const IconButtonTheme({
    Key key,
    @required IconButtonStyle data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child, data: data);

  /// Returns the [data] from the closest [ButtonTheme] ancestor. If there is
  /// no ancestor, it returns [Style.ButtonTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ButtonStyle theme = ButtonTheme.of(context);
  /// ```
  static IconButtonStyle of(BuildContext context) {
    final IconButtonTheme theme =
        context.dependOnInheritedWidgetOfExactType<IconButtonTheme>();
    return theme?.data ??
        IconButtonStyle.defaultTheme(context.theme?.brightness);
  }
}
