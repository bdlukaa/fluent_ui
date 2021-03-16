import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'hover_button.dart';

enum _ButtonType { def, icon, dropdown }

class Button extends StatefulWidget {
  const Button({
    Key? key,
    required this.text,
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
    Key? key,
    required this.icon,
    IconButtonStyle? style,
    this.onPressed,
    this.onLongPress,
    this.semanticsLabel,
    this.focusNode,
  })  : assert(icon != null),
        text = IconButton(
          icon: icon!,
          onPressed: onPressed,
          onLongPress: onLongPress,
          semanticsLabel: semanticsLabel,
          style: style,
        ),
        style = null,
        trailingIcon = null,
        type = _ButtonType.icon,
        super(key: key);

  Button.dropdown({
    Key? key,
    required Widget content,
    required Widget dropdown,
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
        trailingIcon = null,
        type = _ButtonType.dropdown,
        super(key: key);

  final _ButtonType type;

  /// The icon used for ActionButton and ContextualIcon
  final Widget? icon;

  /// The icon used for ContextualIcon
  final Widget? trailingIcon;

  /// The main text of the button
  final Widget? text;

  /// The style of the button
  final ButtonStyle? style;

  /// Callback to when the button get pressed. If this and onLongPress == null,
  /// the button will be considered disabled
  final VoidCallback? onPressed;

  /// Callback to when the button gets pressed for a long time. If this and onPressed
  /// == null, the button will be considered disabled
  final VoidCallback? onLongPress;

  /// The semantics label to allow screen readers to read the screen
  final String? semanticsLabel;

  final FocusNode? focusNode;

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool get enabled => widget.onPressed != null || widget.onLongPress != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'enabled',
      value: enabled,
      ifFalse: 'disabled',
    ));
    // TODO: make style a `Diagnosticable`
    // properties.add(DiagnosticsProperty<ButtonStyle>(
    //   'style',
    //   style,
    //   defaultValue: null,
    // ));
    properties.add(DiagnosticsProperty<FocusNode>(
      'focusNode',
      widget.focusNode,
      defaultValue: null,
    ));
  }

  double buttonScale = 1;

  bool get isDisabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    ButtonStyle? style;
    switch (widget.type) {
      case _ButtonType.icon:
      case _ButtonType.dropdown:
        return widget.text!;
      case _ButtonType.def:
      default:
        style = context.theme!.buttonStyle;
        break;
    }
    style = style?.copyWith(this.widget.style);
    return HoverButton(
      semanticsLabel: widget.semanticsLabel,
      margin: style?.margin,
      focusNode: widget.focusNode,
      cursor: style?.cursor,
      onTapDown: isDisabled
          ? null
          : () {
              if (mounted)
                setState(() => buttonScale = style?.scaleFactor ?? 0.95);
            },
      onLongPressStart: isDisabled
          ? null
          : () {
              if (mounted)
                setState(() => buttonScale = style?.scaleFactor ?? 0.95);
            },
      onLongPressEnd: isDisabled
          ? null
          : () {
              if (mounted) setState(() => buttonScale = 1);
            },
      onPressed: isDisabled
          ? null
          : () async {
              widget.onPressed!();
              if (mounted)
                setState(() => buttonScale = style?.scaleFactor ?? 0.95);
              await Future.delayed(Duration(milliseconds: 120));
              if (mounted) setState(() => buttonScale = 1);
            },
      onLongPress: widget.onLongPress,
      builder: (context, state) {
        return AnimatedContainer(
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(buttonScale, buttonScale, 1.0),
          duration: style?.animationDuration ??
              context.theme!.fastAnimationDuration ??
              Duration.zero,
          curve: style?.animationCurve ??
              context.theme?.animationCurve ??
              standartCurve,
          padding: style!.padding,
          decoration: style.decoration!(state),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) widget.icon!,
              DefaultTextStyle(
                style: (style.textStyle?.call(state)) ?? TextStyle(),
                textAlign: TextAlign.center,
                child: widget.text!,
              ),
              if (widget.trailingIcon != null) widget.trailingIcon!,
            ],
          ),
        );
      },
    );
  }
}

Color buttonColor(Style style, ButtonStates state) {
  if (style.brightness == Brightness.light) {
    late Color? color;
    if (state.isDisabled)
      color = style.disabledColor;
    else if (state.isPressing)
      color = Colors.grey[70];
    else if (state.isHovering)
      color = Colors.grey[40];
    else
      color = Colors.grey[50];
    return color ?? Colors.transparent;
  } else {
    late Color? color;
    if (state.isDisabled)
      color = style.disabledColor;
    else if (state.isPressing)
      color = Color.fromARGB(255, 102, 102, 102);
    else if (state.isHovering)
      color = Color.fromARGB(255, 31, 31, 31);
    else
      color = Color.fromARGB(255, 51, 51, 51);
    return color ?? Colors.transparent;
  }
}

class ButtonStyle {
  final ButtonState<Decoration?>? decoration;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final double? scaleFactor;

  final ButtonState<MouseCursor>? cursor;

  final ButtonState<TextStyle>? textStyle;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const ButtonStyle({
    this.decoration,
    this.padding,
    this.margin,
    this.scaleFactor,
    this.cursor,
    this.textStyle,
    this.animationDuration,
    this.animationCurve,
  });

  static ButtonStyle defaultTheme(Style style) {
    return ButtonStyle(
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
      cursor: buttonCursor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.all(4),
      decoration: (state) => BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: buttonColor(style, state),
      ),
      scaleFactor: 0.95,
      textStyle: (state) =>
          style.typography?.body?.copyWith(
            color: state.isDisabled ? Colors.grey[100] : null,
          ) ??
          TextStyle(),
    );
  }

  ButtonStyle copyWith(ButtonStyle? style) {
    return ButtonStyle(
      decoration: style?.decoration ?? decoration,
      cursor: style?.cursor ?? cursor,
      textStyle: style?.textStyle ?? textStyle,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      scaleFactor: style?.scaleFactor ?? scaleFactor,
    );
  }
}
