import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

// This file implements info bar into this library.
// It follows this https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/infobar

/// The severities that can be applied to an [InfoBar]
enum InfoBarSeverity {
  /// ![Info InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-default-hyperlink.png)
  info,

  /// ![Warning InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-warning-title-message.png)
  warning,

  /// ![Error InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-error-no-close.png)
  error,

  /// ![Success InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-success-content-wrapping.png)
  success,
}

/// The InfoBar control is for displaying app-wide status messages to
/// users that are highly visible yet non-intrusive. There are built-in
/// Severity levels to easily indicate the type of message shown as well
/// as the option to include your own call to action or hyperlink button.
/// Since the InfoBar is inline with other UI content the option is there
/// for the control to always be visible or dismissed by the user.
///
/// ![](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-success-content-wrapping.png)
class InfoBar extends StatelessWidget {
  /// Creates an info bar.
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

  /// The severity of this InfoBar. Defaults to [InfoBarSeverity.info]
  final InfoBarSeverity severity;

  /// The style applied to this info bar. If non-null, it's
  /// mescled with [ThemeData.infoBarThemeData]
  final InfoBarThemeData? style;

  final Widget title;
  final Widget? content;
  final Widget? action;

  /// Called when the close button is pressed. If this is null,
  /// there will be no close button
  final void Function()? onClose;

  /// If `true`, the info bar will be treated as long.
  ///
  /// ![Long InfoBar](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/infobar-success-content-wrapping.png)
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
    assert(debugCheckHasFluentTheme(context));
    final style = InfoBarThemeData.standard(context.theme).copyWith(
      context.theme.infoBarTheme.copyWith(this.style),
    );
    final icon = style.icon?.call(severity);
    final closeIcon = style.closeIcon;
    final title = DefaultTextStyle(
      style: context.theme.typography.base ?? TextStyle(),
      child: this.title,
    );
    final content = () {
      if (this.content == null) return null;
      return DefaultTextStyle(
        style: context.theme.typography.body ?? TextStyle(),
        child: this.content!,
        softWrap: true,
      );
    }();
    final action = () {
      if (this.action == null) return null;
      return FluentTheme(
        child: this.action!,
        data: context.theme.copyWith(buttonTheme: style.actionStyle),
      );
    }();
    return Acrylic(
      color: style.color?.call(severity),
      padding: style.padding ?? EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isLong ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(icon, color: style.iconColor?.call(severity)),
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
          if (closeIcon != null && onClose != null)
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

class InfoBarThemeData with Diagnosticable {
  final InfoBarSeverityCheck<Color?>? color;
  final InfoBarSeverityCheck<Color?>? iconColor;
  final InfoBarSeverityCheck<IconData>? icon;
  final IconData? closeIcon;
  final ButtonThemeData? actionStyle;
  final EdgeInsetsGeometry? padding;

  const InfoBarThemeData({
    this.color,
    this.icon,
    this.iconColor,
    this.closeIcon,
    this.actionStyle,
    this.padding,
  });

  factory InfoBarThemeData.standard(ThemeData style) {
    final isDark = style.brightness == Brightness.dark;
    return InfoBarThemeData(
      padding: EdgeInsets.all(10),
      color: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return style.acrylicBackgroundColor;
          case InfoBarSeverity.warning:
            return isDark ? Color(0xFF433519) : Colors.warningSecondaryColor;
          case InfoBarSeverity.success:
            return isDark ? Color(0xFF393d1b) : Colors.successSecondaryColor;
          case InfoBarSeverity.error:
            return isDark ? Color(0xFF442726) : Colors.errorSecondaryColor;
        }
      },
      closeIcon: Icons.close,
      icon: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return Icons.info_outlined;
          case InfoBarSeverity.warning:
            return Icons.error_outline;
          case InfoBarSeverity.success:
            return Icons.check_circle_outlined;
          case InfoBarSeverity.error:
            return Icons.cancel_outlined;
        }
      },
      iconColor: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return isDark ? Colors.grey[120] : Colors.grey[160];
          case InfoBarSeverity.warning:
            return isDark ? Colors.yellow : Colors.warningPrimaryColor;
          case InfoBarSeverity.success:
            return Colors.successPrimaryColor;
          case InfoBarSeverity.error:
            return isDark ? Colors.red : Colors.errorPrimaryColor;
        }
      },
      actionStyle: ButtonThemeData.standard(style).copyWith(ButtonThemeData(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(6),
      )),
    );
  }

  InfoBarThemeData copyWith(InfoBarThemeData? style) {
    if (style == null) return this;
    return InfoBarThemeData(
      closeIcon: style.closeIcon ?? closeIcon,
      icon: style.icon ?? icon,
      color: style.color ?? color,
      actionStyle: style.actionStyle ?? actionStyle,
      iconColor: style.iconColor ?? iconColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty.has('icon', icon));
    properties.add(ObjectFlagProperty.has('closeIcon', closeIcon));
    properties.add(ObjectFlagProperty.has('color', color));
    properties.add(ObjectFlagProperty.has('iconColor', iconColor));
    properties.add(DiagnosticsProperty<ButtonThemeData>(
      'actionStyle',
      actionStyle,
      ifNull: 'no style',
    ));
  }
}
