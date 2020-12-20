import 'package:fluent_ui/fluent_ui.dart';

class TreeTheme<T> extends InheritedTheme {
  const TreeTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties for descendant [Tooltip] widgets.
  final T data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final TreeTheme<T> ancestorTheme =
        context.findAncestorWidgetOfExactType<TreeTheme<T>>();
    return identical(this, ancestorTheme)
        ? child
        : TreeTheme<T>(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TreeTheme<T> oldWidget) => data != oldWidget.data;
}

class Theme extends InheritedWidget {
  const Theme({Key key, @required this.data, @required this.child})
      : super(key: key, child: child);

  final Style data;
  final Widget child;

  static Style of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Theme>()
        ?.data
        ?.build(context);
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => oldWidget.data != data;
}

extension themeContext on BuildContext {
  Style get theme => Theme.of(this);
}

class Style {
  final Color accentColor;

  final Brightness brightness;

  final Color scaffoldBackgroundColor;
  final Color bottomNavigationBackgroundColor;

  final AppBarStyle appBarStyle;
  final ButtonStyle buttonStyle;
  final CardStyle cardStyle;
  final IconButtonStyle iconButtonStyle;

  Style({
    this.accentColor,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBackgroundColor,
    this.appBarStyle,
    this.buttonStyle,
    this.cardStyle,
    this.iconButtonStyle,
  });

  Style build(BuildContext context) {
    if (this.brightness == null || this.brightness == Brightness.light)
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBackgroundColor: Colors.white,
        appBarStyle: appBarStyle ?? AppBarStyle.defaultTheme(Brightness.light),
        buttonStyle: buttonStyle ?? ButtonStyle.defaultTheme(Brightness.light),
        cardStyle: cardStyle ?? CardStyle.defaultTheme(Brightness.light),
      );
    else
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[160],
        appBarStyle: appBarStyle ?? AppBarStyle.defaultTheme(Brightness.dark),
        buttonStyle: buttonStyle ?? ButtonStyle.defaultTheme(Brightness.dark),
        cardStyle: cardStyle ?? CardStyle.defaultTheme(Brightness.dark),
      );
  }

  static Style fallback(BuildContext context, [Brightness brightness]) {
    return Style(brightness: brightness).build(context);
  }

  Widget provider(Widget child) {
    Widget w = child;
    if (appBarStyle != null) w = AppBarTheme(data: appBarStyle, child: w);
    if (buttonStyle != null) w = ButtonTheme(data: buttonStyle, child: w);
    if (cardStyle != null) w = CardTheme(data: cardStyle, child: w);
    if (iconButtonStyle != null)
      w = IconButtonTheme(data: iconButtonStyle, child: w);
    return w;
  }
}
