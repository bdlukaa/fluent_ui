import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'hover_button.dart';

class Button extends StatelessWidget {
  /// Implementation of DefaultButton, PrimaryButton and CompoundButton.
  ///
  /// More info at https://developer.microsoft.com/en-us/fluentui#/controls/web/button
  const Button({
    Key key,
    @required this.text,
    this.style,
    this.onPressed,
    this.semanticsLabel,
  })  : subtext = null,
        super(key: key);

  Button.compound({
    Key key,
    @required this.text,
    @required this.subtext,
    this.style,
    this.onPressed,
    this.semanticsLabel,
  }) : super(key: key);

  /// The main text of the button
  final Widget text;

  /// The secondary text of the button. Used with [CompoundButton]
  final Widget subtext;

  /// The style of the button
  final ButtonThemeData style;

  /// Callback to when the function get pressed. If this is null, the
  /// button will be considered disabled
  final VoidCallback onPressed;

  /// The semantics label to allow screen readers to read the screen
  final String semanticsLabel;

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final style = ButtonTheme.of(context).copyWith(this.style);
    return Semantics(
      label: semanticsLabel,
      child: HoverButton(
        cursor: _isDisabled ? style.disabledCursor : style.cursor,
        onPressed: onPressed,
        builder: (context, hovering) {
          return Container(
            padding: style.padding,
            margin: style.margin,
            decoration: BoxDecoration(
              color: _isDisabled
                  ? style.disabledColor
                  : hovering
                      ? style.hoverColor
                      : style.backgroundColor,
              borderRadius: style.borderRadius,
              border: _isDisabled
                  ? style.disabledBorder ?? style.border
                  : style.border,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text != null)
                  DefaultTextStyle(
                    style: (_isDisabled
                            ? style.disabledTextStyle
                            : style?.textStyle) ??
                        TextStyle(),
                    child: text,
                  ),
                if (subtext != null)
                  DefaultTextStyle(
                    style: (_isDisabled
                            ? style.disabledSubtextStyle
                            : style?.subtextStyle) ??
                        TextStyle(),
                    child: subtext,
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ButtonThemeData {
  final Color backgroundColor;
  final Color hoverColor;
  final Color disabledColor;

  final Border border;
  final Border disabledBorder;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final MouseCursor cursor;
  final MouseCursor disabledCursor;

  final TextStyle textStyle;
  final TextStyle disabledTextStyle;

  // compoused button
  final TextStyle subtextStyle;
  final TextStyle disabledSubtextStyle;

  ButtonThemeData({
    this.backgroundColor,
    this.hoverColor,
    this.disabledColor,
    this.border,
    this.disabledBorder,
    this.borderRadius,
    this.padding,
    this.margin,
    this.cursor,
    this.disabledCursor,
    this.textStyle,
    this.disabledTextStyle,
    this.subtextStyle,
    this.disabledSubtextStyle,
  });

  static ButtonThemeData defaultTheme([Brightness brightness]) {
    final defButton = ButtonThemeData(
      cursor: SystemMouseCursors.click,
      disabledCursor: SystemMouseCursors.forbidden,
      borderRadius: BorderRadius.circular(2),
      hoverColor: Colors.grey[20],
      backgroundColor: Colors.transparent,
      disabledColor: Colors.grey[40],
      disabledTextStyle: TextStyle(
        color: Colors.grey[100],
        fontWeight: FontWeight.bold,
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(4),
      disabledBorder: Border.all(style: BorderStyle.none),
    );
    if (brightness == null || brightness == Brightness.light)
      return defButton.copyWith(ButtonThemeData(
        border: Border.all(color: Colors.grey[100], width: 0.8),
        textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        subtextStyle: TextStyle(color: Colors.black, fontSize: 12),
      ));
    else
      return defButton.copyWith(ButtonThemeData(
        border: Border.all(color: Colors.white, width: 0.8),
        textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        subtextStyle: TextStyle(color: Colors.white, fontSize: 12),
      ));
  }

  ButtonThemeData copyWith(ButtonThemeData style) {
    if (style == null) return this;
    return ButtonThemeData(
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      border: style?.border ?? border,
      disabledBorder: style?.disabledBorder ?? disabledBorder,
      borderRadius: style?.borderRadius ?? borderRadius,
      cursor: style?.cursor ?? cursor,
      disabledCursor: style?.disabledCursor ?? disabledCursor,
      disabledColor: style?.disabledColor ?? disabledColor,
      hoverColor: style?.hoverColor ?? hoverColor,
      textStyle: style?.textStyle ?? textStyle,
      disabledTextStyle: style?.disabledTextStyle ?? disabledTextStyle,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      subtextStyle: style?.subtextStyle ?? subtextStyle,
      disabledSubtextStyle: style?.disabledSubtextStyle ?? disabledSubtextStyle,
    );
  }
}

class ButtonTheme extends InheritedTheme {
  /// Creates a tooltip theme that controls the configurations for
  /// [Tooltip].
  ///
  /// The data argument must not be null.
  const ButtonTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties for descendant [Tooltip] widgets.
  final ButtonThemeData data;

  /// Returns the [data] from the closest [ButtonTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.ButtonTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ButtonThemeData theme = ButtonTheme.of(context);
  /// ```
  static ButtonThemeData of(BuildContext context) {
    final ButtonTheme theme =
        context.dependOnInheritedWidgetOfExactType<ButtonTheme>();
    return theme?.data ?? ButtonThemeData();
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final ButtonTheme ancestorTheme =
        context.findAncestorWidgetOfExactType<ButtonTheme>();
    return identical(this, ancestorTheme)
        ? child
        : ButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ButtonTheme oldWidget) => data != oldWidget.data;
}
