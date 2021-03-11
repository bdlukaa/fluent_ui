import 'package:fluent_ui/fluent_ui.dart';

class Typography {

  final TextStyle? header;
  final TextStyle? subheader;
  final TextStyle? title;
  final TextStyle? subtitle;
  final TextStyle? base;
  final TextStyle? body;
  final TextStyle? caption;

  const Typography({
    this.header,
    this.subheader,
    this.title,
    this.subtitle,
    this.base,
    this.body,
    this.caption,
  });

  static Typography defaultTypography({
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
      title: TextStyle(
        fontSize: 24,
        color: color,
        fontWeight: FontWeight.w600
      ),
      subtitle: TextStyle(
        fontSize: 20,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      base: TextStyle(
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

}
