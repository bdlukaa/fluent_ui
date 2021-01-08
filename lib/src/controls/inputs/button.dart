import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'hover_button.dart';

Color darkButtonBackgroundColor(
  ButtonStates state, {
  Color disabledColor,
  Color pressingColor,
  Color hoveringColor,
  Color defaultColor,
}) {
  if (state.isDisabled)
    return disabledColor ?? Colors.grey[40];
  else if (state.isPressing)
    return pressingColor ?? Colors.grey[140].withOpacity(0.6);
  else if (state.isHovering)
    return hoveringColor ?? Colors.grey[150].withOpacity(0.6);
  return defaultColor ?? Colors.transparent;
}

Color lightButtonBackgroundColor(
  ButtonStates state, {
  Color disabledColor,
  Color pressingColor,
  Color hoveringColor,
  Color defaultColor,
}) {
  if (state.isDisabled)
    return disabledColor ?? Colors.grey[40];
  else if (state.isPressing)
    return pressingColor ?? Colors.grey[30].withOpacity(0.6);
  else if (state.isHovering)
    return hoveringColor ?? Colors.grey[20].withOpacity(0.6);
  return defaultColor ?? Colors.transparent;
}

MouseCursor buttonCursor(ButtonStates state) {
  if (state.isDisabled)
    return SystemMouseCursors.forbidden;
  else if (state.isHovering || state.isPressing)
    return SystemMouseCursors.click;
  else
    return MouseCursor.defer;
}

enum _ButtonType { def, compound, action, contextual, icon, primary }

class Button extends StatelessWidget {
  /// Implementation for DefaultButton, PrimaryButton, CompoundButton, ActionButton
  /// and ContextualButton
  ///
  /// More info at https://developer.microsoft.com/en-us/fluentui#/controls/web/button
  const Button({
    Key key,
    @required this.text,
    this.subtext,
    this.icon,
    this.trailingIcon,
    this.style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
  })  : type = _ButtonType.def,
        super(key: key);

  /// Creates a PrimaryButton
  const Button.primary({
    @required this.text,
    this.style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
  })  : subtext = null,
        icon = null,
        trailingIcon = null,
        type = _ButtonType.primary;

  /// Creates a CompoundButton
  const Button.compound({
    Key key,
    @required this.text,
    @required this.subtext,
    this.style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
  })  : icon = null,
        trailingIcon = null,
        type = _ButtonType.compound,
        super(key: key);

  /// Creates an Icon Button. Uses [IconButton] under the hood
  Button.icon({
    Key key,
    @required this.icon,
    Widget menu,
    IconButtonStyle style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
  })  : text = IconButton.menu(
          icon: icon,
          menu: menu,
          onPressed: onPressed,
          onLongPress: onLongPress,
          semanticsLabel: semanticsLabel,
          style: style,
        ),
        subtext = null,
        style = null,
        trailingIcon = null,
        type = _ButtonType.icon,
        super(key: key);

  /// Creates a ContextualButton
  const Button.contextual({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.trailingIcon,
    this.onLongPress,
    this.onPressed,
    this.style,
    this.semanticsLabel,
  })  : subtext = null,
        type = _ButtonType.contextual,
        super(key: key);

  /// Creates an ActionButton
  const Button.action({
    Key key,
    @required this.icon,
    @required this.text,
    this.onLongPress,
    this.onPressed,
    this.style,
    this.semanticsLabel,
  })  : trailingIcon = null,
        subtext = null,
        type = _ButtonType.action,
        super(key: key);

  final _ButtonType type;

  /// The icon used for ActionButton and ContextualIcon
  final Widget icon;

  /// The icon used for ContextualIcon
  final Widget trailingIcon;

  /// The main text of the button
  final Widget text;

  /// The secondary text of the button. Used with [CompoundButton]
  final Widget subtext;

  /// The style of the button
  final ButtonStyle style;

  /// Callback to when the button get pressed. If this and onLongPress == null,
  /// the button will be considered disabled
  final VoidCallback onPressed;

  /// Callback to when the button gets pressed for a long time. If this and onPressed
  /// == null, the button will be considered disabled
  final VoidCallback onLongPress;

  /// The semantics label to allow screen readers to read the screen
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    // Create only the IconButton
    if (type == _ButtonType.icon) return text;
    ButtonStyle style;
    switch (type) {
      case _ButtonType.contextual:
        style = context.theme.contextualButtonStyle;
        break;
      case _ButtonType.action:
        style = context.theme.actionButtonStyle;
        break;
      case _ButtonType.compound:
        style = context.theme.compoundButtonStyle;
        break;
      case _ButtonType.primary:
        style = context.theme.primaryButtonStyle;
        break;
      case _ButtonType.def:
      default:
        style = context.theme.buttonStyle;
        break;
    }
    style = style.copyWith(this.style);
    return Semantics(
      label: semanticsLabel,
      child: HoverButton(
        cursor: (_, state) => style.cursor?.call(state),
        onPressed: onPressed,
        onLongPress: onLongPress,
        builder: (context, state) {
          return Container(
            padding: style.padding,
            margin: style.margin,
            decoration: BoxDecoration(
              color: style.color?.call(state),
              borderRadius: style.borderRadius,
              border: style.border?.call(state),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) icon,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text != null)
                      DefaultTextStyle(
                        style: (style.textStyle?.call(state)) ?? TextStyle(),
                        textAlign: TextAlign.center,
                        child: text,
                      ),
                    if (subtext != null)
                      DefaultTextStyle(
                        style: (style.subtextStyle?.call(state)) ?? TextStyle(),
                        textAlign: TextAlign.center,
                        child: subtext,
                      )
                  ],
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          );
        },
      ),
    );
  }
}

class ButtonStyle {
  final ButtonState<Color> color;

  final ButtonState<Border> border;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<TextStyle> textStyle;

  // compoused button
  final ButtonState<TextStyle> subtextStyle;

  ButtonStyle({
    this.color,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
    this.cursor,
    this.textStyle,
    this.subtextStyle,
  });

  static ButtonStyle defaultActionButtonTheme([Brightness brightness]) {
    brightness ??= Brightness.light;
    return defaultTheme(brightness).copyWith(ButtonStyle(
      border: (_) => Border.all(style: BorderStyle.none),
      color: (_) => Colors.transparent,
      textStyle: (state) => state.isDisabled
          ? TextStyle(color: Colors.grey[100])
          : state.isHovering || state.isPressing
              ? TextStyle(color: Colors.blue)
              : TextStyle(
                  color: brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
    ));
  }

  static ButtonStyle defaultCompoundButtonTheme([Brightness brightness]) {
    return defaultTheme(brightness).copyWith(ButtonStyle(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ));
  }

  static ButtonStyle defaultPrimaryButtonTheme([Brightness brightness]) {
    final def = defaultTheme(brightness).copyWith(ButtonStyle(
      border: (_) => Border.all(style: BorderStyle.none),
      textStyle: (state) => state.isDisabled
          ? TextStyle(color: Colors.grey[100])
          : TextStyle(color: Colors.white),
    ));
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(ButtonStyle(
        color: (state) {
          if (state.isDisabled)
            return lightButtonBackgroundColor(ButtonStates.disabled);
          else if (state.isPressing)
            return Colors.blue[80];
          else if (state.isHovering) return Colors.blue[70];
          return Colors.blue;
        },
      ));
    else
      return def.copyWith(ButtonStyle(
        color: (state) {
          if (state.isDisabled)
            return darkButtonBackgroundColor(ButtonStates.disabled);
          else if (state.isPressing)
            return Colors.blue[80];
          else if (state.isHovering) return Colors.blue[70];
          return Colors.blue;
        },
      ));
  }

  static ButtonStyle defaultTheme([Brightness brightness]) {
    final defButton = ButtonStyle(
      cursor: buttonCursor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(2),
      margin: EdgeInsets.all(4),
    );
    final disabledBorder = Border.all(style: BorderStyle.none);
    final disabledTextStyle = TextStyle(
      color: Colors.grey[100],
      fontWeight: FontWeight.bold,
    );
    if (brightness == null || brightness == Brightness.light)
      return defButton.copyWith(ButtonStyle(
        border: (state) => state.isDisabled
            ? disabledBorder
            : Border.all(color: Colors.grey[100], width: 0.6),
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        subtextStyle: (state) => TextStyle(color: Colors.black, fontSize: 12),
        color: lightButtonBackgroundColor,
      ));
    else
      return defButton.copyWith(ButtonStyle(
        border: (state) => state.isDisabled
            ? disabledBorder
            : Border.all(color: Colors.white, width: 0.6),
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        subtextStyle: (state) => TextStyle(color: Colors.white, fontSize: 12),
        color: darkButtonBackgroundColor,
      ));
  }

  ButtonStyle copyWith(ButtonStyle style) {
    if (style == null) return this;
    return ButtonStyle(
      border: style?.border ?? border,
      borderRadius: style?.borderRadius ?? borderRadius,
      cursor: style?.cursor ?? cursor,
      textStyle: style?.textStyle ?? textStyle,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      subtextStyle: style?.subtextStyle ?? subtextStyle,
      color: style?.color ?? color,
    );
  }
}
