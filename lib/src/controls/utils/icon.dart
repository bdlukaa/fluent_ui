import 'package:fluent_ui/fluent_ui.dart';

class Icon extends StatelessWidget {
  const Icon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  }) : super(key: key);

  final IconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    assert(this.textDirection != null || debugCheckHasDirectionality(context));
    final TextDirection textDirection =
        this.textDirection ?? Directionality.of(context);

    debugCheckHasFluentTheme(context);
    final iconTheme = context.theme.iconStyle;

    final double? iconSize = size ?? iconTheme!.size;

    if (icon == null) {
      return Semantics(
        label: semanticLabel,
        child: SizedBox(width: iconSize, height: iconSize),
      );
    }

    final double? iconOpacity = iconTheme!.opacity;
    Color? iconColor = color ?? iconTheme.color;
    if (iconOpacity != 1.0)
      iconColor = iconColor!.withOpacity(iconColor.opacity * iconOpacity!);

    Widget iconWidget = RichText(
      overflow: TextOverflow.visible, // Never clip.
      textDirection:
          textDirection, // Since we already fetched it for the assert...
      text: TextSpan(
        text: String.fromCharCode(icon!.codePoint),
        style: TextStyle(
          inherit: false,
          color: iconColor,
          fontSize: iconSize,
          fontFamily: icon!.fontFamily,
          package: icon!.fontPackage,
        ),
      ),
    );

    if (icon!.matchTextDirection) {
      switch (textDirection) {
        case TextDirection.rtl:
          iconWidget = Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: Alignment.center,
            transformHitTests: false,
            child: iconWidget,
          );
          break;
        case TextDirection.ltr:
          break;
      }
    }

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: Center(
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}

class IconStyle {
  final Color? color;
  final double? size;
  final double? opacity;

  IconStyle({this.color, this.size, this.opacity});

  static IconStyle defaultTheme([Brightness? brightness]) {
    final def = IconStyle(size: 22, opacity: 1);
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(IconStyle(color: Colors.black));
    else
      return def.copyWith(IconStyle(color: Colors.white));
  }

  IconStyle copyWith(IconStyle? style) {
    return IconStyle(
      color: style?.color ?? color,
      size: style?.size ?? size,
      opacity: style?.opacity ?? opacity,
    );
  }
}
