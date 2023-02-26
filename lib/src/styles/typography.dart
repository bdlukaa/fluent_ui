import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';

/// The typography applied to a [FluentThemeData]. It implements Windows' [Type Ramp](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#type-ramp)
///
/// | Do                                                  | Don't                                                                             |
/// | :-------------------------------------------------- | :-------------------------------------------------------------------------------- |
/// | Pick one font for your UI.                          | Don't mix multiple fonts.                                                         |
/// | Use [body] for most text                            | Use "Caption" for primary action or any long strings.                             |
/// | Use "Base" for titles when space is constrained.    | Use "Header" or "Subheader" if text needs to wrap.                                |
/// | Keep to 50–60 letters per line for ease of reading. | Less than 20 characters or more than 60 characters per line is difficult to read. |
/// | Clip text, and wrap if multiple lines are enabled.  | Use ellipses to avoid visual clutter.                                             |
///
/// ![Hierarchy](https://docs.microsoft.com/en-us/windows/apps/design/style/images/type/text-block-type-ramp.svg)
///
/// For more info, read [Typography](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography)
class Typography with Diagnosticable {
  /// The header style. Use this as the top of the hierarchy
  ///
  /// Don't use [titleLarge] if the text needs to wrap.
  final TextStyle? display;

  final TextStyle? titleLarge;

  /// The title style.
  final TextStyle? title;

  /// The subtitle style.
  final TextStyle? subtitle;

  final TextStyle? bodyLarge;

  /// The base style. Use [base] for titles when space is constrained.
  final TextStyle? bodyStrong;

  /// The body style. Use [body] for most of the text.
  final TextStyle? body;

  /// The caption style.
  ///
  /// Don't use [caption] for primary action or any long strings.
  final TextStyle? caption;

  /// Creates a new [Typography]. To create the default typography, use [Typography.defaultTypography]
  const Typography.raw({
    this.display,
    this.titleLarge,
    this.title,
    this.subtitle,
    this.bodyLarge,
    this.bodyStrong,
    this.body,
    this.caption,
  });

  /// The default typography according to a brightness or color.
  ///
  /// If [color] is null, [Colors.black] is used if [brightness] is light,
  /// otherwise [Colors.white] is used. If it's not null, [color] will be used.
  factory Typography.fromBrightness({
    Brightness? brightness,
    Color? color,
  }) {
    assert(
      brightness != null || color != null,
      'Either brightness or color must be provided',
    );
    // If color is null, brightness will not be null
    color ??=
        brightness == Brightness.light ? const Color(0xE4000000) : Colors.white;
    return Typography.raw(
      display: TextStyle(
        fontSize: 68,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 40,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      title: TextStyle(
        fontSize: 28,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      subtitle: TextStyle(
        fontSize: 20,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      bodyStrong: TextStyle(
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      body: TextStyle(
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      caption: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  static Typography lerp(Typography? a, Typography? b, double t) {
    return Typography.raw(
      display: TextStyle.lerp(a?.display, b?.display, t),
      titleLarge: TextStyle.lerp(a?.titleLarge, b?.titleLarge, t),
      title: TextStyle.lerp(a?.title, b?.title, t),
      subtitle: TextStyle.lerp(a?.subtitle, b?.subtitle, t),
      bodyLarge: TextStyle.lerp(a?.bodyLarge, b?.bodyLarge, t),
      bodyStrong: TextStyle.lerp(a?.bodyStrong, b?.bodyStrong, t),
      body: TextStyle.lerp(a?.body, b?.body, t),
      caption: TextStyle.lerp(a?.caption, b?.caption, t),
    );
  }

  /// Copy this with a new [typography]
  Typography merge(Typography? typography) {
    if (typography == null) return this;
    return Typography.raw(
      display: typography.display ?? display,
      titleLarge: typography.titleLarge ?? titleLarge,
      title: typography.title ?? title,
      subtitle: typography.subtitle ?? subtitle,
      bodyLarge: typography.bodyLarge ?? bodyLarge,
      bodyStrong: typography.bodyStrong ?? bodyStrong,
      body: typography.body ?? body,
      caption: typography.caption ?? caption,
    );
  }

  Typography apply({
    String? fontFamily,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    Color? displayColor,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
  }) {
    return Typography.raw(
      display: display?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      titleLarge: titleLarge?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      title: title?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      subtitle: subtitle?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      bodyLarge: bodyLarge?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      bodyStrong: bodyStrong?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      body: body?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
      caption: caption?.apply(
        color: displayColor,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        fontFamily: fontFamily,
        fontSizeFactor: fontSizeFactor,
        fontSizeDelta: fontSizeDelta,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextStyle>('header', display))
      ..add(DiagnosticsProperty<TextStyle>('titleLarge', titleLarge))
      ..add(DiagnosticsProperty<TextStyle>('title', title))
      ..add(DiagnosticsProperty<TextStyle>('subtitle', subtitle))
      ..add(DiagnosticsProperty<TextStyle>('bodyLarge', bodyLarge))
      ..add(DiagnosticsProperty<TextStyle>('bodyStrong', bodyStrong))
      ..add(DiagnosticsProperty<TextStyle>('body', body))
      ..add(DiagnosticsProperty<TextStyle>('caption', caption));
  }
}
