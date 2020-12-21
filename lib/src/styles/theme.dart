import 'package:fluent_ui/fluent_ui.dart';

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
  final CardStyle cardStyle;
  final CheckboxStyle checkboxStyle;
  final IconButtonStyle iconButtonStyle;
  final IconStyle iconStyle;
  final ListCellStyle listCellStyle;
  final PivotItemStyle pivotItemStyle;
  final SplitButtonStyle splitButtonStyle;
  final ToggleStyle toggleStyle;

  final ButtonStyle buttonStyle;
  final ButtonStyle compoundButtonStyle;
  final ButtonStyle actionButtonStyle;
  final ButtonStyle contextualButtonStyle;
  
  Style({
    this.accentColor,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBackgroundColor,
    this.appBarStyle,
    this.buttonStyle,
    this.actionButtonStyle,
    this.compoundButtonStyle,
    this.contextualButtonStyle,
    this.cardStyle,
    this.iconButtonStyle,
    this.checkboxStyle,
    this.toggleStyle,
    this.pivotItemStyle,
    this.iconStyle,
    this.splitButtonStyle,
    this.listCellStyle,
  });

  Style build(BuildContext context) {
    if (this.brightness == null || this.brightness == Brightness.light)
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBackgroundColor: Colors.white,
        appBarStyle: appBarStyle ?? AppBarStyle.defaultTheme(Brightness.light),
        cardStyle: cardStyle ?? CardStyle.defaultTheme(Brightness.light),
        buttonStyle: buttonStyle ?? ButtonStyle.defaultTheme(Brightness.light),
        actionButtonStyle: actionButtonStyle ?? ButtonStyle.defaultActionButtonTheme(Brightness.light),
        compoundButtonStyle: compoundButtonStyle ?? ButtonStyle.defaultTheme(Brightness.light),
        contextualButtonStyle: contextualButtonStyle ?? ButtonStyle.defaultTheme(Brightness.light),
        iconButtonStyle: IconButtonStyle.defaultTheme(Brightness.light),
        checkboxStyle: CheckboxStyle.defaultTheme(Brightness.light),
        toggleStyle: ToggleStyle.defaultTheme(Brightness.light),
        pivotItemStyle: PivotItemStyle.defaultTheme(Brightness.light),
        iconStyle: IconStyle.defaultTheme(Brightness.light),
        splitButtonStyle: SplitButtonStyle.defaultTheme(Brightness.light),
        listCellStyle: ListCellStyle.defaultTheme(Brightness.light),
      );
    else
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[160],
        appBarStyle: appBarStyle ?? AppBarStyle.defaultTheme(Brightness.dark),
        cardStyle: cardStyle ?? CardStyle.defaultTheme(Brightness.dark),
        buttonStyle: buttonStyle ?? ButtonStyle.defaultTheme(Brightness.dark),
        actionButtonStyle: actionButtonStyle ?? ButtonStyle.defaultActionButtonTheme(Brightness.dark),
        compoundButtonStyle: compoundButtonStyle ?? ButtonStyle.defaultTheme(Brightness.dark),
        contextualButtonStyle: contextualButtonStyle ?? ButtonStyle.defaultTheme(Brightness.dark),
        iconButtonStyle: IconButtonStyle.defaultTheme(Brightness.dark),
        checkboxStyle: CheckboxStyle.defaultTheme(Brightness.dark),
        toggleStyle: ToggleStyle.defaultTheme(Brightness.dark),
        pivotItemStyle: PivotItemStyle.defaultTheme(Brightness.dark),
        iconStyle: IconStyle.defaultTheme(Brightness.dark),
        splitButtonStyle: SplitButtonStyle.defaultTheme(Brightness.dark),
        listCellStyle: ListCellStyle.defaultTheme(Brightness.dark),
      );
  }

  static Style fallback(BuildContext context, [Brightness brightness]) {
    return Style(brightness: brightness).build(context);
  }

}
