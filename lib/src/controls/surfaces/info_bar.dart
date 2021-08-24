import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;

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
    final style = InfoBarTheme.of(context).merge(this.style);
    final icon = style.icon?.call(severity);
    final closeIcon = style.closeIcon;
    final title = DefaultTextStyle(
      style: FluentTheme.of(context).typography.base ?? TextStyle(),
      child: this.title,
    );
    final content = () {
      if (this.content == null) return null;
      return DefaultTextStyle(
        style: FluentTheme.of(context).typography.body ?? const TextStyle(),
        child: this.content!,
        softWrap: true,
      );
    }();
    final action = () {
      if (this.action == null) return null;
      return ButtonTheme.merge(
        child: this.action!,
        data: style.actionStyle ?? const ButtonThemeData(),
      );
    }();
    return Container(
      decoration: style.decoration?.call(severity),
      child: Padding(
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
      ),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [InfoBar]s in this widget's subtree.
///
/// Values specified here are used for [InfoBar] properties that are not
/// given an explicit non-null value.
class InfoBarTheme extends InheritedTheme {
  /// Creates a info bar theme that controls the configurations for
  /// [InfoBar].
  const InfoBarTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [InfoBar] widgets.
  final InfoBarThemeData data;

  /// Creates a button theme that controls how descendant [InfoBar]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required InfoBarThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return InfoBarTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static InfoBarThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<InfoBarTheme>();
    return theme?.data ?? FluentTheme.of(context).infoBarTheme;
  }

  /// Returns the [data] from the closest [InfoBarTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.infoBarTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// InfoBarThemeData theme = InfoBarTheme.of(context);
  /// ```
  static InfoBarThemeData of(BuildContext context) {
    final InfoBarTheme? theme =
        context.dependOnInheritedWidgetOfExactType<InfoBarTheme>();
    return InfoBarThemeData.standard(FluentTheme.of(context)).merge(
      theme?.data ?? FluentTheme.of(context).infoBarTheme,
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return InfoBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(InfoBarTheme oldWidget) => data != oldWidget.data;
}

typedef InfoBarSeverityCheck<T> = T Function(InfoBarSeverity severity);

class InfoBarThemeData with Diagnosticable {
  final InfoBarSeverityCheck<Decoration?>? decoration;
  final InfoBarSeverityCheck<Color?>? iconColor;
  final InfoBarSeverityCheck<IconData>? icon;
  final IconData? closeIcon;
  final ButtonThemeData? actionStyle;
  final EdgeInsetsGeometry? padding;

  const InfoBarThemeData({
    this.decoration,
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
      decoration: (severity) {
        late Color color;
        switch (severity) {
          case InfoBarSeverity.info:
            color = isDark ? Color(0xFF272727) : Color(0xFFf4f4f4);
            break;
          case InfoBarSeverity.warning:
            color = Colors.warningSecondaryColor.resolveFromBrightness(style.brightness);
            break;
          case InfoBarSeverity.success:
            color = Colors.successSecondaryColor.resolveFromBrightness(style.brightness);
            break;
          case InfoBarSeverity.error:
            color = Colors.errorSecondaryColor.resolveFromBrightness(style.brightness);
            break;
        }
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: kElevationToShadow[2],
        );
      },
      closeIcon: FluentIcons.close,
      icon: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return FluentIcons.info_solid;
          case InfoBarSeverity.warning:
            return FluentIcons.critical_error_solid;
          case InfoBarSeverity.success:
            return Icons.check_circle;
          case InfoBarSeverity.error:
            return Icons.cancel;
        }
      },
      iconColor: (severity) {
        switch (severity) {
          case InfoBarSeverity.info:
            return style.accentColor.resolveFromReverseBrightness(style.brightness);
          case InfoBarSeverity.warning:
            return isDark ? Colors.yellow : Colors.warningPrimaryColor;
          case InfoBarSeverity.success:
            return Colors.successPrimaryColor;
          case InfoBarSeverity.error:
            return isDark ? Colors.red : Colors.errorPrimaryColor;
        }
      },
      actionStyle: ButtonThemeData.all(ButtonStyle(
        padding: ButtonState.all(EdgeInsets.all(6)),
      )),
    );
  }

  static InfoBarThemeData lerp(
    InfoBarThemeData? a,
    InfoBarThemeData? b,
    double t,
  ) {
    return InfoBarThemeData(
      closeIcon: t < 0.5 ? a?.closeIcon : b?.closeIcon,
      icon: t < 0.5 ? a?.icon : b?.icon,
      decoration: (severity) {
        return Decoration.lerp(
          a?.decoration?.call(severity),
          b?.decoration?.call(severity),
          t,
        );
      },
      actionStyle: ButtonThemeData.lerp(a?.actionStyle, b?.actionStyle, t),
      iconColor: (severity) {
        return Color.lerp(
          a?.iconColor?.call(severity),
          b?.iconColor?.call(severity),
          t,
        );
      },
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
    );
  }

  InfoBarThemeData merge(InfoBarThemeData? style) {
    if (style == null) return this;
    return InfoBarThemeData(
      closeIcon: style.closeIcon ?? closeIcon,
      icon: style.icon ?? icon,
      decoration: style.decoration ?? decoration,
      actionStyle: style.actionStyle ?? actionStyle,
      iconColor: style.iconColor ?? iconColor,
      padding: style.padding ?? padding,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty.has('icon', icon));
    properties.add(ObjectFlagProperty.has('closeIcon', closeIcon));
    properties.add(ObjectFlagProperty.has('decoration', decoration));
    properties.add(ObjectFlagProperty.has('iconColor', iconColor));
    properties.add(DiagnosticsProperty<ButtonThemeData>(
      'actionStyle',
      actionStyle,
      ifNull: 'no style',
    ));
  }
}
