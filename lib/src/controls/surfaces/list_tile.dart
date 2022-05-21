import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

const kThreeLineTileHeight = 60.0;
const kTwoLineTileHeight = 52.0;
const kOneLineTileHeight = 40.0;

const kDefaultContentPadding = EdgeInsets.symmetric(
  horizontal: 12.0,
  vertical: 6.0,
);

class ListTile extends StatelessWidget {
  const ListTile({
    Key? key,
    this.tileColor,
    this.shape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.contentPadding = kDefaultContentPadding,
  })  : assert(
          subtitle != null ? title != null : true,
          'To have a subtitle, there must be a title',
        ),
        super(key: key);

  /// The color of the tile
  final Color? tileColor;

  /// The shape of the tile
  final ShapeBorder? shape;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  final bool isThreeLine;

  final EdgeInsetsGeometry contentPadding;

  bool get isTwoLine => subtitle != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('tileColor', tileColor));
    properties.add(FlagProperty(
      'isThreeLine',
      value: isThreeLine,
      ifFalse: isTwoLine ? 'two lines' : 'one line',
    ));
    properties.add(DiagnosticsProperty('shape', shape));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
      'contentPadding',
      contentPadding,
    ));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));
    final style = FluentTheme.of(context);
    return Container(
      decoration: ShapeDecoration(
        shape: shape ?? const ContinuousRectangleBorder(),
        color: tileColor,
      ),
      height: isThreeLine
          ? kThreeLineTileHeight
          : isTwoLine
              ? kTwoLineTileHeight
              : kOneLineTileHeight,
      padding: contentPadding,
      child: Row(children: [
        if (leading != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: leading,
          ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: (style.typography.body ?? const TextStyle()).copyWith(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.clip,
                  child: title!,
                ),
              if (subtitle != null)
                DefaultTextStyle(
                  style: style.typography.caption ?? const TextStyle(),
                  overflow: TextOverflow.clip,
                  child: subtitle!,
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class TappableListTile extends StatelessWidget {
  const TappableListTile({
    Key? key,
    this.tileColor,
    this.shape,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding = kDefaultContentPadding,
  }) : super(key: key);

  final VoidCallback? onTap;

  final ButtonState<Color>? tileColor;
  final ButtonState<ShapeBorder>? shape;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  final bool isThreeLine;

  final FocusNode? focusNode;
  final bool autofocus;

  final EdgeInsetsGeometry contentPadding;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty('onTap', onTap, ifNull: 'disabled'));
    properties.add(FlagProperty(
      'autofocus',
      value: autofocus,
      defaultValue: false,
      ifFalse: 'manual focus',
    ));
    properties.add(ObjectFlagProperty.has('focusNode', focusNode));
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = FluentTheme.of(context);
    return HoverButton(
      onPressed: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, states) {
        final Color tileColor = () {
          if (this.tileColor != null) {
            return this.tileColor!.resolve(states);
          } else if (states.isFocused) {
            return style.accentColor.resolve(context);
          }
          return ButtonThemeData.uncheckedInputColor(style, states);
        }();
        return ListTile(
          contentPadding: contentPadding,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          isThreeLine: isThreeLine,
          tileColor: tileColor,
          shape: shape?.resolve(states),
        );
      },
    );
  }
}
