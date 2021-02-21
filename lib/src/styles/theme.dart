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

  final NavigationPanelStyle bottomNavigationStyle;
  final CardStyle cardStyle;
  final CheckboxStyle checkboxStyle;
  final DialogStyle dialogStyle;
  final DividerStyle dividerStyle;
  final IconStyle iconStyle;
  final ListCellStyle listCellStyle;
  final PivotItemStyle pivotItemStyle;
  final RadioButtonStyle radioButtonStyle;
  final SnackbarStyle snackbarStyle;
  final SplitButtonStyle splitButtonStyle;
  final ToggleSwitchStyle toggleSwitchStyle;
  final TooltipStyle tooltipStyle;

  final ButtonStyle buttonStyle;
  final IconButtonStyle iconButtonStyle;

  const Style({
    this.accentColor,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBackgroundColor,
    this.buttonStyle,
    this.cardStyle,
    this.iconButtonStyle,
    this.checkboxStyle,
    this.toggleSwitchStyle,
    this.pivotItemStyle,
    this.iconStyle,
    this.splitButtonStyle,
    this.listCellStyle,
    this.dialogStyle,
    this.tooltipStyle,
    this.dividerStyle,
    this.snackbarStyle,
    this.bottomNavigationStyle,
    this.radioButtonStyle,
  });

  Style build(BuildContext context) {
    return Style(
      accentColor: Colors.blue,
      brightness: brightness ?? Brightness.light,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? Colors.grey[160],
      cardStyle: CardStyle.defaultTheme(brightness).copyWith(cardStyle),
      buttonStyle:
          ButtonStyle.defaultTheme(this, brightness).copyWith(buttonStyle),
      iconButtonStyle: IconButtonStyle.defaultTheme(this, brightness)
          .copyWith(iconButtonStyle),
      checkboxStyle:
          CheckboxStyle.defaultTheme(this, brightness).copyWith(checkboxStyle),
      toggleSwitchStyle: ToggleSwitchStyle.defaultTheme(this, brightness)
          .copyWith(toggleSwitchStyle),
      pivotItemStyle:
          PivotItemStyle.defaultTheme(brightness).copyWith(pivotItemStyle),
      iconStyle: IconStyle.defaultTheme(brightness).copyWith(iconStyle),
      splitButtonStyle: SplitButtonStyle.defaultTheme(this, brightness)
          .copyWith(splitButtonStyle),
      listCellStyle:
          ListCellStyle.defaultTheme(brightness).copyWith(listCellStyle),
      dialogStyle: DialogStyle.defaultTheme(brightness).copyWith(dialogStyle),
      tooltipStyle:
          TooltipStyle.defaultTheme(brightness).copyWith(tooltipStyle),
      dividerStyle:
          DividerStyle.defaultTheme(brightness).copyWith(dividerStyle),
      snackbarStyle:
          SnackbarStyle.defaultTheme(brightness).copyWith(snackbarStyle),
      bottomNavigationStyle: NavigationPanelStyle.defaultTheme(brightness)
          .copyWith(bottomNavigationStyle),
      radioButtonStyle: RadioButtonStyle.defaultTheme(this, brightness)
          .copyWith(radioButtonStyle),
    );
  }

  static Style fallback(BuildContext context, [Brightness brightness]) {
    return Style(brightness: brightness).build(context);
  }
}
