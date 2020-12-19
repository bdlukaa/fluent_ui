import 'package:fluent_ui/fluent_ui.dart';

class Theme extends InheritedWidget {
  const Theme({Key key, @required this.data, @required this.child})
      : super(key: key, child: child);

  final ThemeData data;
  final Widget child;

  static ThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Theme>()
        ?.data
        ?.build(context);
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => oldWidget.data != data;
}

class ThemeData {
  final Color accentColor;

  final Brightness brightness;

  final Color scaffoldBackgroundColor;
  final Color bottomNavigationBackgroundColor;

  final AppBarThemeData appBarTheme;
  final ButtonThemeData buttonTheme;
  final CardThemeData cardTheme;

  ThemeData({
    this.accentColor,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBackgroundColor,
    this.appBarTheme,
    this.buttonTheme,
    this.cardTheme,
  });

  ThemeData build(BuildContext context) {
    if (this.brightness == null || this.brightness == Brightness.light)
      return ThemeData(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBackgroundColor: Colors.white,
        appBarTheme:
            appBarTheme ?? AppBarThemeData.defaultTheme(Brightness.light),
        buttonTheme:
            buttonTheme ?? ButtonThemeData.defaultTheme(Brightness.light),
        cardTheme: cardTheme ?? CardThemeData.defaultTheme(Brightness.light),
      );
    else
      return ThemeData(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[160],
        appBarTheme:
            appBarTheme ?? AppBarThemeData.defaultTheme(Brightness.dark),
        buttonTheme:
            buttonTheme ?? ButtonThemeData.defaultTheme(Brightness.dark),
        cardTheme: cardTheme ?? CardThemeData.defaultTheme(Brightness.dark),
      );
  }

  static ThemeData fallback(BuildContext context, [Brightness brightness]) {
    return ThemeData(brightness: brightness).build(context);
  }

  Widget provider(Widget child) {
    Widget w = child;
    if (appBarTheme != null) w = AppBarTheme(data: appBarTheme, child: w);
    if (buttonTheme != null) w = ButtonTheme(data: buttonTheme, child: w);
    if (cardTheme != null) w = CardTheme(data: cardTheme, child: w);
    return w;
  }
}
