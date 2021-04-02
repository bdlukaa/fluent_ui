import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

// This file implements info bar into this library.
// It follows this https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/infobar

enum InfoBarSeverity {
  info,
  warning,
  error,
  success,
}

class InfoBar extends StatelessWidget {
  const InfoBar({
    Key? key,
    required this.title,
    this.content,
    this.action,
    this.severity = InfoBarSeverity.info,
    this.style,
    this.isLong = false,
    this.onClose,
  }) : super(key: key);

  final InfoBarSeverity severity;

  final InfoBarStyle? style;

  final Widget title;
  final Widget? content;
  final Widget? action;

  final void Function()? onClose;

  final bool isLong;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('isLong', value: isLong, ifFalse: 'short'));
    properties.add(EnumProperty('severity', severity));
    properties.add(ObjectFlagProperty.has('onClose', onClose));
    properties.add(DiagnosticsProperty('style', style, ifNull: 'no style'));
  }

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.infoBarStyle?.copyWith(this.style);
    final icon = style?.icon?.call(severity);
    final closeIcon = style?.closeIcon;
    final title = DefaultTextStyle(
      style: context.theme.typography?.base ?? TextStyle(),
      child: this.title,
    );
    final content = () {
      if (this.content == null) return null;
      return DefaultTextStyle(
        style: context.theme.typography?.body ?? TextStyle(),
        child: this.content!,
        softWrap: true,
      );
    }();
    final action = () {
      if (this.action == null) return null;
      return Theme(
        child: this.action!,
        data: context.theme.copyWith(Style(
          buttonStyle: style?.actionStyle,
        )),
      );
    }();
    return Acrylic(
      color: style?.color?.call(severity),
      padding: style?.padding ?? EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment:
            isLong ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(icon),
            ),
          if (isLong)
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (content != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: content,
                    ),
                  if (action != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: action,
                    ),
                ],
              ),
            )
          else
            Flexible(
              fit: FlexFit.loose,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  title,
                  if (content != null) content,
                  if (action != null) action,
                ],
              ),
            ),
          if (closeIcon != null)
            IconButton(
              icon: Icon(closeIcon),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

typedef InfoBarSeverityCheck<T> = T Function(InfoBarSeverity severity);

class InfoBarStyle with Diagnosticable {
  final InfoBarSeverityCheck<Color?>? color;
  final InfoBarSeverityCheck<IconData>? icon;
  final IconData? closeIcon;
  final ButtonStyle? actionStyle;
  final EdgeInsetsGeometry? padding;

  const InfoBarStyle({
    this.color,
    this.icon,
    this.closeIcon,
    this.actionStyle,
    this.padding,
  });

  static InfoBarStyle defaultTheme(Style style) {
    return InfoBarStyle(
      padding: EdgeInsets.all(10),
      color: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return style.navigationPanelBackgroundColor;
          case InfoBarSeverity.warning:
            if (style.brightness!.isDark)
              return Color(0xFF433519);
            else
              return Color(0xFFfff4ce);
          case InfoBarSeverity.success:
            if (style.brightness!.isDark)
              return Color(0xFF393d1b);
            else
              return Color.fromARGB(255, 223, 246, 221);
          case InfoBarSeverity.error:
            if (style.brightness!.isDark)
              return Color(0xFF442726);
            else
              return Color(0xFFfde7e9);
        }
      },
      // TODO: implement close icon (X)
      // closeIcon: Icons.channel_notifications_filled,
      icon: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return Icons.info;
          case InfoBarSeverity.warning:
            return Icons.warning;
          case InfoBarSeverity.success:
            return Icons.checkmark_circle;
          case InfoBarSeverity.error:
            return Icons.error_circle;
        }
      },
      actionStyle: ButtonStyle.defaultTheme(style).copyWith(ButtonStyle(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(6),
      )),
    );
  }

  InfoBarStyle copyWith(InfoBarStyle? style) {
    if (style == null) return this;
    return InfoBarStyle(
      closeIcon: style.closeIcon ?? closeIcon,
      icon: style.icon ?? icon,
      color: style.color ?? color,
      actionStyle: style.actionStyle ?? actionStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty.has('icon', icon));
    properties.add(ObjectFlagProperty.has('closeIcon', closeIcon));
    properties.add(ObjectFlagProperty.has('color', color));
    properties.add(DiagnosticsProperty<ButtonStyle>(
      'actionStyle',
      actionStyle,
      ifNull: 'no style',
    ));
  }
}
