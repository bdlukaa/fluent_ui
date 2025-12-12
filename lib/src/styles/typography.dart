import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Defines the text styles used throughout a Fluent UI application.
///
/// [Typography] implements the Windows 11 Type Ramp, providing a consistent
/// text hierarchy for your UI. The type ramp establishes crucial relationships
/// between text styles on a page, helping users read content easily.
///
/// ## Type ramp
///
/// | Style       | Size | Line height | Weight   |
/// |:------------|-----:|------------:|:---------|
/// | [display]   | 68px | 92px        | Semibold |
/// | [titleLarge]| 40px | 52px        | Semibold |
/// | [title]     | 28px | 36px        | Semibold |
/// | [subtitle]  | 20px | 28px        | Semibold |
/// | [bodyLarge] | 18px | 24px        | Regular  |
/// | [bodyStrong]| 14px | 20px        | Semibold |
/// | [body]      | 14px | 20px        | Regular  |
/// | [caption]   | 12px | 16px        | Regular  |
///
/// {@tool snippet}
/// Access typography styles from the theme:
///
/// ```dart
/// Text(
///   'Title',
///   style: FluentTheme.of(context).typography.title,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [FluentThemeData.typography], where this is configured
///  * <https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/typography>
class Typography with Diagnosticable {
  /// The largest text style, used for hero moments and display text.
  ///
  /// 68px semibold with 92px line height.
  final TextStyle? display;

  /// A large title style for prominent headings.
  ///
  /// 40px semibold with 52px line height. Avoid using if text needs to wrap.
  final TextStyle? titleLarge;

  /// The standard title style for page and section headers.
  ///
  /// 28px semibold with 36px line height.
  final TextStyle? title;

  /// A secondary heading style below [title].
  ///
  /// 20px semibold with 28px line height.
  final TextStyle? subtitle;

  /// A larger body text style for emphasized content.
  ///
  /// 18px regular with 24px line height.
  final TextStyle? bodyLarge;

  /// An emphasized body text style for important content.
  ///
  /// 14px semibold with 20px line height. Use for labels or emphasized text.
  final TextStyle? bodyStrong;

  /// The default body text style for most content.
  ///
  /// 14px regular with 20px line height. Use this for the majority of text.
  final TextStyle? body;

  /// The smallest text style for supplementary information.
  ///
  /// 12px regular with 16px line height. Avoid using for primary actions
  /// or long strings as it may be difficult to read.
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

  /// Creates a typography with the Windows 11 type ramp values.
  ///
  /// The text color is determined by [brightness] or [color]:
  ///
  /// * If [color] is provided, it's used directly
  /// * If [brightness] is light, a near-black color is used
  /// * If [brightness] is dark, white is used
  ///
  /// The sizes and line heights follow the Windows 11 type ramp as defined in
  /// the [Microsoft Design documentation](https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/typography#type-ramp).
  factory Typography.fromBrightness({Brightness? brightness, Color? color}) {
    assert(
      brightness != null || color != null,
      'Either brightness or color must be provided',
    );
    // If color is null, brightness will not be null
    color ??= brightness == Brightness.light
        ? const Color(0xE4000000)
        : Colors.white;
    return Typography.raw(
      // Display: 68/92 epx, Semibold
      display: TextStyle(
        fontSize: 68,
        height: 92 / 68,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      // Title Large: 40/52 epx, Semibold
      titleLarge: TextStyle(
        fontSize: 40,
        height: 52 / 40,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      // Title: 28/36 epx, Semibold
      title: TextStyle(
        fontSize: 28,
        height: 36 / 28,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      // Subtitle: 20/28 epx, Semibold
      subtitle: TextStyle(
        fontSize: 20,
        height: 28 / 20,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      // Body Large: 18/24 epx, Regular
      bodyLarge: TextStyle(
        fontSize: 18,
        height: 24 / 18,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      // Body Strong: 14/20 epx, Semibold
      bodyStrong: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      // Body: 14/20 epx, Regular
      body: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      // Caption: 12/16 epx, Regular
      caption: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: color,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  /// Linearly interpolates between two [Typography] objects.
  ///
  /// {@template fluent_ui.lerp.t}
  /// The [t] argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning [a], and 1.0 meaning
  /// that the interpolation has finished, returning [b].
  /// {@endtemplate}
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

  /// Returns a new [Typography] with transformations applied to all text styles.
  ///
  /// This method is useful for applying uniform changes like font family
  /// or text decorations across all typography styles.
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
