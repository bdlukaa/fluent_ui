import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The typography applied to a [ThemeData]. It implements Window's [Type Ramp](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography#type-ramp)
///
/// | Do                                                  | Don't                                                                             |
/// | :-------------------------------------------------- | :-------------------------------------------------------------------------------- |
/// | Pick one font for your UI.                          | Don't mix multiple fonts.                                                         |
/// | Use [body] for most text                            | Use "Caption" for primary action or any long strings.                             |
/// | Use "Base" for titles when space is constrained.    | Use "Header" or "Subheader" if text needs to wrap.                                |
/// | Keep to 50–60 letters per line for ease of reading. | Less than 20 characters or more than 60 characters per line is difficult to read. |
/// | Clip text, and wrap if multiple lines are enabled.  | Use ellipses to avoid visual clutter.                                             |
///
/// ![Hierarchy](https://docs.microsoft.com/en-us/windows/uwp/design/style/images/type/type-hierarchy.svg)
///
/// For more info, read [Typography](https://docs.microsoft.com/en-us/windows/uwp/design/style/typography)
class Typography with Diagnosticable {
  /// The header style. Use this as the top of the hierarchy
  ///
  /// Don't use [header] if the text needs to wrap.
  final TextStyle? header;

  /// The subheader style.
  ///
  /// Don't use [subheader] if the text needs to wrap.
  final TextStyle? subheader;

  /// The title style.
  final TextStyle? title;

  /// The subtitle style.
  final TextStyle? subtitle;

  /// The base style. Use [base] for titles when space is constrained.
  final TextStyle? base;

  /// The body style. Use [body] for most of the text.
  final TextStyle? body;

  /// The caption style.
  ///
  /// Don't use [caption] for primary action or any long strings.
  final TextStyle? caption;

  /// Creates a new [Typography]. To create the default typography, use [Typography.defaultTypography]
  const Typography({
    this.header,
    this.subheader,
    this.title,
    this.subtitle,
    this.base,
    this.body,
    this.caption,
  });

  /// The default typography.
  ///
  /// If [color] is null, uses [Colors.black] if [brightness] is [Brightness.dark], otherwise uses [Colors.white]
  factory Typography.standard({
    required Brightness brightness,
    Color? color,
  }) {
    color ??= brightness == Brightness.light ? Colors.black : Colors.white;
    return Typography(
      header: TextStyle(
        fontSize: 42,
        color: color,
        fontWeight: FontWeight.w300,
      ),
      subheader: TextStyle(
        fontSize: 34,
        color: color,
        fontWeight: FontWeight.w300,
      ),
      title: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.w600),
      subtitle: TextStyle(
        fontSize: 20,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      base: TextStyle(
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.bold,
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
    return Typography(
      header: TextStyle.lerp(a?.header, b?.header, t),
      subheader: TextStyle.lerp(a?.subheader, b?.subheader, t),
      title: TextStyle.lerp(a?.title, b?.title, t),
      subtitle: TextStyle.lerp(a?.subtitle, b?.subtitle, t),
      base: TextStyle.lerp(a?.base, b?.base, t),
      body: TextStyle.lerp(a?.body, b?.body, t),
      caption: TextStyle.lerp(a?.caption, b?.caption, t),
    );
  }

  /// Copy this with a new [typography]
  Typography copyWith(Typography? typography) {
    if (typography == null) return this;
    return Typography(
      header: typography.header ?? header,
      subheader: typography.subheader ?? subheader,
      title: typography.title ?? title,
      subtitle: typography.subtitle ?? subtitle,
      base: typography.base ?? base,
      body: typography.body ?? body,
      caption: typography.caption ?? caption,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextStyle>('header', header));
    properties.add(DiagnosticsProperty<TextStyle>('subheader', subheader));
    properties.add(DiagnosticsProperty<TextStyle>('title', title));
    properties.add(DiagnosticsProperty<TextStyle>('subtitle', subtitle));
    properties.add(DiagnosticsProperty<TextStyle>('base', base));
    properties.add(DiagnosticsProperty<TextStyle>('body', body));
    properties.add(DiagnosticsProperty<TextStyle>('caption', caption));
  }
}
