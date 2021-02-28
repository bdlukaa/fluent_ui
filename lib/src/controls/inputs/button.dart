import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'hover_button.dart';

enum _ButtonType { def, icon, dropdown }

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
    this.focusNode,
  })  : type = _ButtonType.def,
        super(key: key);

  /// Creates an Icon Button. Uses [IconButton] under the hood
  Button.icon({
    Key key,
    @required this.icon,
    IconButtonStyle style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
    this.focusNode,
  })  : text = IconButton(
          icon: icon,
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

  Button.dropdown({
    Key key,
    @required Widget content,
    @required Widget dropdown,
    this.style,
    bool disabled = false,
    bool startOpen = false,
    bool adoptDropdownWidth = true,
    bool horizontal = false,
    this.semanticsLabel,
    this.focusNode,
  })  : text = DropDownButton(
          key: key,
          content: content,
          dropdown: dropdown,
          adoptDropdownWidth: adoptDropdownWidth,
          disabled: disabled,
          horizontal: horizontal,
          semanticsLabel: semanticsLabel,
          startOpen: startOpen,
          style: style,
          focusNode: focusNode,
        ),
        icon = null,
        onLongPress = null,
        onPressed = null,
        subtext = null,
        trailingIcon = null,
        type = _ButtonType.dropdown,
        assert(content != null),
        assert(dropdown != null),
        assert(disabled != null),
        assert(adoptDropdownWidth != null),
        assert(startOpen != null),
        assert(horizontal != null),
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

  final FocusNode focusNode;

  bool get enabled => onPressed != null || onLongPress != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'enabled',
      value: enabled,
      ifFalse: 'disabled',
    ));
    // TODO(bdlukaa): make style a `Diagnosticable`
    // properties.add(DiagnosticsProperty<ButtonStyle>(
    //   'style',
    //   style,
    //   defaultValue: null,
    // ));
    properties.add(DiagnosticsProperty<FocusNode>(
      'focusNode',
      focusNode,
      defaultValue: null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    ButtonStyle style;
    switch (type) {
      case _ButtonType.icon:
      case _ButtonType.dropdown:
        return text;
      case _ButtonType.def:
      default:
        style = context.theme.buttonStyle;
        break;
    }
    style = style.copyWith(this.style);
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: style.cursor,
      onPressed: onPressed,
      onLongPress: onLongPress,
      builder: (context, state) {
        return AnimatedContainer(
          duration: style?.animationDuration,
          curve: style?.animationCurve,
          padding: style.padding,
          decoration: style.decoration(state),
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
    );
  }
}

class ButtonStyle {
  final ButtonState<Decoration> decoration;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<TextStyle> textStyle;

  // compoused button
  final ButtonState<TextStyle> subtextStyle;

  final Duration animationDuration;
  final Curve animationCurve;

  const ButtonStyle({
    this.decoration,
    this.padding,
    this.margin,
    this.cursor,
    this.textStyle,
    this.subtextStyle,
    this.animationDuration,
    this.animationCurve,
  });

  static ButtonStyle defaultTheme(Style style, [Brightness brightness]) {
    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(2),
    );

    final defButton = ButtonStyle(
      animationDuration: style.animationDuration,
      animationCurve: style.animationCurve,
      cursor: buttonCursor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      decoration: (state) {
        return defaultDecoration.copyWith(
          border: Border.all(
            color: state.isNone
                ? style.inactiveColor
                : uncheckedInputColor(style, state),
            width: 0.6,
          ),
          color: uncheckedInputColor(style, state),
        );
      },
    );
    final disabledTextStyle = TextStyle(
      color: Colors.grey[100],
      fontWeight: FontWeight.bold,
    );

    if (brightness == null || brightness == Brightness.light)
      return defButton.copyWith(ButtonStyle(
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        subtextStyle: (state) => TextStyle(color: Colors.black, fontSize: 12),
      ));
    else
      return defButton.copyWith(ButtonStyle(
        textStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        subtextStyle: (state) => TextStyle(color: Colors.white, fontSize: 12),
      ));
  }

  ButtonStyle copyWith(ButtonStyle style) {
    if (style == null) return this;
    return ButtonStyle(
      decoration: style?.decoration ?? decoration,
      cursor: style?.cursor ?? cursor,
      textStyle: style?.textStyle ?? textStyle,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      subtextStyle: style?.subtextStyle ?? subtextStyle,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
    );
  }
}
