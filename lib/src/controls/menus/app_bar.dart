import 'package:fluent_ui/fluent_ui.dart';

/// Implementation of TopAppBar to Android
///
/// https://developer.microsoft.com/en-us/fluentui#/controls/android/topappbar
class AppBar extends StatelessWidget {
  const AppBar({
    Key key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
    this.insertTopPadding = true,
    this.style,
    this.minHeight,
    this.maxHeight,
  })  : assert(insertTopPadding != null),
        super(key: key);

  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final List<Widget> trailing;
  final Widget bottom;

  final double minHeight;
  final double maxHeight;

  final bool insertTopPadding;

  final AppBarStyle style;

  @override
  Widget build(BuildContext context) {
    final style = AppBarTheme.of(context).copyWith(this.style);
    final topPadding = insertTopPadding ? MediaQuery.of(context).viewPadding.top : 0;
    return Container(
      constraints: BoxConstraints(
        minHeight: (minHeight ?? 52.0) + topPadding,
        maxHeight: (maxHeight ?? (bottom != null ? 64 + 48.0 : 64)) + topPadding,
      ),
      margin: style?.margin,
      padding: ((style?.padding ?? EdgeInsets.zero) as EdgeInsets) +
          EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
          borderRadius: style?.borderRadius,
          color: style?.backgroundColor,
          boxShadow: elevationShadow(
            style?.elevation,
            color: style?.elevationColor,
          )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) leading,
              if (title != null || subtitle != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      DefaultTextStyle(
                        style: style?.titleTextStyle,
                        textAlign: TextAlign.start,
                        child: title,
                      ),
                    if (subtitle != null)
                      DefaultTextStyle(
                        style: style?.subtitleTextStyle,
                        textAlign: TextAlign.start,
                        child: subtitle,
                      ),
                  ],
                ),
              Spacer(),
              if (trailing != null) ...trailing,
            ],
          ),
          if (bottom != null) bottom,
        ],
      ),
    );
  }
}

class AppBarStyle {
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  final int elevation;
  final Color elevationColor;

  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;

  AppBarStyle({
    this.backgroundColor,
    this.borderRadius,
    this.margin,
    this.padding,
    this.elevation,
    this.elevationColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
  });

  static AppBarStyle defaultTheme(Brightness brightness) {
    final def = AppBarStyle(
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12),
      elevation: 8,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(AppBarStyle(
        backgroundColor: Colors.blue,
        elevationColor: Colors.black.withOpacity(0.1),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ));
    else
      return def.copyWith(AppBarStyle(
        backgroundColor: Colors.grey[200],
        elevationColor: Colors.white.withOpacity(0.1),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ));
  }

  AppBarStyle copyWith(AppBarStyle style) {
    if (style == null) return this;
    return AppBarStyle(
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      borderRadius: style?.borderRadius ?? borderRadius,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      titleTextStyle: style?.titleTextStyle ?? titleTextStyle,
      subtitleTextStyle: style?.subtitleTextStyle ?? subtitleTextStyle,
    );
  }
}

class AppBarTheme extends InheritedTheme {
  /// Creates a tooltip theme that controls the configurations for
  /// [Tooltip].
  ///
  /// The data argument must not be null.
  const AppBarTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties for descendant [Tooltip] widgets.
  final AppBarStyle data;

  /// Returns the [data] from the closest [AppBarTheme] ancestor. If there is
  /// no ancestor, it returns [Style.AppBarTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// AppBarStyle theme = AppBarTheme.of(context);
  /// ```
  static AppBarStyle of(BuildContext context) {
    final AppBarTheme theme =
        context.dependOnInheritedWidgetOfExactType<AppBarTheme>();
    return theme?.data ?? AppBarStyle();
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final AppBarTheme ancestorTheme =
        context.findAncestorWidgetOfExactType<AppBarTheme>();
    return identical(this, ancestorTheme)
        ? child
        : AppBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(AppBarTheme oldWidget) => data != oldWidget.data;
}
