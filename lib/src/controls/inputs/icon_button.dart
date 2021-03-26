import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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

  final Widget icon;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final IconButtonStyle? style;

  final String? semanticsLabel;
  final FocusNode? focusNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>(
      'onPressed',
      onPressed,
      ifNull: 'disabled',
    ));
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onLongPress', onLongPress),
    );
    properties.add(DiagnosticsProperty<IconButtonStyle>('style', style));
    properties.add(StringProperty('semanticsLabel', semanticsLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.iconButtonStyle!.copyWith(this.style);
    return HoverButton(
      onPressed: onPressed == null ? null : () {},
      builder: (context, state) => Button(
        focusNode: focusNode,
        text: Theme(
          data: context.theme.copyWith(Style(
            iconStyle: style.iconStyle?.call(state),
          )),
          child: icon,
        ),
        onPressed: onPressed,
        onLongPress: onLongPress,
        semanticsLabel: semanticsLabel,
        style: ButtonStyle(
          decoration: style.decoration,
          cursor: style.cursor,
          margin: style.margin,
          padding: style.padding,
        ),
      ),
    );
  }
}

@immutable
class IconButtonStyle with Diagnosticable {
  final ButtonState<Decoration?>? decoration;

  final ButtonState<MouseCursor>? cursor;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final ButtonState<IconStyle?>? iconStyle;

  const IconButtonStyle({
    this.decoration,
    this.cursor,
    this.padding,
    this.margin,
    this.iconStyle,
  });

  static IconButtonStyle defaultTheme(Style style) {
    final def = IconButtonStyle(
      cursor: buttonCursor,
      decoration: (state) {
        return BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(style: BorderStyle.none),
          color: uncheckedInputColor(style, state),
        );
      },
      padding: EdgeInsets.all(4),
      iconStyle: (_) => style.iconStyle,
    );
    return def;
  }

  IconButtonStyle copyWith(IconButtonStyle? style) {
    if (style == null) return this;
    return IconButtonStyle(
      decoration: style.decoration ?? decoration,
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      cursor: style.cursor ?? cursor,
      iconStyle: style.iconStyle ?? iconStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<ButtonState<Decoration?>>.has(
      'decoration',
      decoration,
    ));
    properties.add(
      ObjectFlagProperty<ButtonState<MouseCursor>>.has('cursor', cursor),
    );
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
    properties.add(ObjectFlagProperty<ButtonState<IconStyle?>>.has(
      'iconStyle',
      iconStyle,
    ));
  }
}
