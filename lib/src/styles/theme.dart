import 'package:fluent_ui/fluent_ui.dart';

class Theme extends InheritedWidget {
  const Theme({Key key, @required this.data, @required this.child})
      : super(key: key, child: child);

  final ThemeData data;
  final Widget child;

  static ThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Theme>()?.data?.build();
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => oldWidget.data != data;
}

class ThemeData {
  final Brightness brightness;

  final Color scaffoldBackgroundColor;
  final Color bottomNavigationBackgroundColor;

  final AppBarThemeData appBarTheme;
  final CardThemeData cardTheme;

  ThemeData({
    this.brightness,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBackgroundColor,
    this.appBarTheme,
    this.cardTheme,
  });

  ThemeData build() {
    if (this.brightness == null || this.brightness == Brightness.light)
      return ThemeData(
        brightness: this.brightness ?? Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBackgroundColor: Colors.white,
        appBarTheme:
            this.appBarTheme ?? AppBarThemeData.defaultTheme(Brightness.light),
        cardTheme:
            this.cardTheme ?? CardThemeData.defaultTheme(Brightness.light),
      );
    else
      return ThemeData(
        brightness: this.brightness ?? Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[160],
        appBarTheme:
            this.appBarTheme ?? AppBarThemeData.defaultTheme(Brightness.dark),
        cardTheme:
            this.cardTheme ?? CardThemeData.defaultTheme(Brightness.dark),
      );
  }

  static ThemeData fallback([Brightness brightness]) {
    return ThemeData(brightness: brightness).build();
  }

  Widget provider(Widget child) {
    Widget w = child;
    if (appBarTheme != null) w = AppBarTheme(data: appBarTheme, child: w);
    if (cardTheme != null) w = CardTheme(data: cardTheme, child: w);
    return w;
  }
}
