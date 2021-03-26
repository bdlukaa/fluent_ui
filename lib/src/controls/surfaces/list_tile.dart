import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class ListTile extends StatelessWidget {
  const ListTile({
    Key? key,
    this.tileColor,
    this.shape,
    this.leading,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
  })  : assert(
          subtitle != null ? title != null : true,
          'To have a subtitle, there must be a title',
        ),
        super(key: key);

  final Color? tileColor;
  final ShapeBorder? shape;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;

  final bool isThreeLine;

  bool get isTwoLine => subtitle != null;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme;
    return Container(
      decoration: ShapeDecoration(
        shape: shape ?? ContinuousRectangleBorder(),
        color: tileColor,
      ),
      height: isThreeLine
          ? 80.0
          : isTwoLine
              ? 56.0
              : 48.0,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(children: [
        if (leading != null)
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: leading,
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              DefaultTextStyle(
                child: title!,
                style: (style.typography?.base ?? TextStyle()).copyWith(
                  fontSize: 16,
                ),
              ),
            if (subtitle != null)
              DefaultTextStyle(
                child: subtitle!,
                style: style.typography?.body ?? TextStyle(),
              ),
          ],
        )
      ]),
    );
  }
}
