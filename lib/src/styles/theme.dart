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
  final DialogStyle dialogStyle;
  final DividerStyle dividerStyle;
  final IconButtonStyle iconButtonStyle;
  final IconStyle iconStyle;
  final ListCellStyle listCellStyle;
  final PivotItemStyle pivotItemStyle;
  final SplitButtonStyle splitButtonStyle;
  final ToggleStyle toggleStyle;
  final TooltipStyle tooltipStyle;

  final ButtonStyle buttonStyle;
  final ButtonStyle compoundButtonStyle;
  final ButtonStyle actionButtonStyle;
  final ButtonStyle contextualButtonStyle;
  final ButtonStyle primaryButtonStyle;
  
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
    this.primaryButtonStyle,
    this.cardStyle,
    this.iconButtonStyle,
    this.checkboxStyle,
    this.toggleStyle,
    this.pivotItemStyle,
    this.iconStyle,
    this.splitButtonStyle,
    this.listCellStyle,
    this.dialogStyle,
    this.tooltipStyle,
    this.dividerStyle,
  });

  Style build(BuildContext context) {
    if (this.brightness == null || this.brightness == Brightness.light)
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.light,
        scaffoldBackgroundColor: scaffoldBackgroundColor ?? Colors.white,
        bottomNavigationBackgroundColor: bottomNavigationBackgroundColor ?? Colors.white,
        appBarStyle: AppBarStyle.defaultTheme().copyWith(appBarStyle),
        cardStyle: CardStyle.defaultTheme().copyWith(cardStyle),
        buttonStyle: ButtonStyle.defaultTheme().copyWith(buttonStyle),
        actionButtonStyle: ButtonStyle.defaultActionButtonTheme().copyWith(actionButtonStyle),
        compoundButtonStyle: ButtonStyle.defaultCompoundButtonTheme().copyWith(compoundButtonStyle),
        contextualButtonStyle: ButtonStyle.defaultTheme().copyWith(contextualButtonStyle),
        primaryButtonStyle: ButtonStyle.defaultPrimaryButtonTheme().copyWith(primaryButtonStyle),
        iconButtonStyle: IconButtonStyle.defaultTheme().copyWith(iconButtonStyle),
        checkboxStyle: CheckboxStyle.defaultTheme().copyWith(checkboxStyle),
        toggleStyle: ToggleStyle.defaultTheme().copyWith(toggleStyle),
        pivotItemStyle: PivotItemStyle.defaultTheme().copyWith(pivotItemStyle),
        iconStyle: IconStyle.defaultTheme().copyWith(iconStyle),
        splitButtonStyle: SplitButtonStyle.defaultTheme().copyWith(splitButtonStyle),
        listCellStyle: ListCellStyle.defaultTheme().copyWith(listCellStyle),
        dialogStyle: DialogStyle.defaultTheme().copyWith(dialogStyle),
        tooltipStyle: TooltipStyle.defaultTheme().copyWith(tooltipStyle),
        dividerStyle: DividerStyle.defaultTheme().copyWith(dividerStyle),
      );
    else
      return Style(
        accentColor: Colors.blue,
        brightness: brightness ?? Brightness.dark,
        scaffoldBackgroundColor: scaffoldBackgroundColor ?? Colors.grey[160],
        appBarStyle: AppBarStyle.defaultTheme(brightness).copyWith(appBarStyle),
        cardStyle: CardStyle.defaultTheme(brightness).copyWith(cardStyle),
        buttonStyle: ButtonStyle.defaultTheme(brightness).copyWith(buttonStyle),
        actionButtonStyle: ButtonStyle.defaultActionButtonTheme(brightness).copyWith(actionButtonStyle),
        compoundButtonStyle: ButtonStyle.defaultCompoundButtonTheme(brightness),
        contextualButtonStyle: ButtonStyle.defaultTheme(brightness).copyWith(contextualButtonStyle),
        primaryButtonStyle: ButtonStyle.defaultPrimaryButtonTheme(brightness).copyWith(primaryButtonStyle),
        iconButtonStyle: IconButtonStyle.defaultTheme(brightness).copyWith(iconButtonStyle),
        checkboxStyle: CheckboxStyle.defaultTheme(brightness).copyWith(checkboxStyle),
        toggleStyle: ToggleStyle.defaultTheme(brightness).copyWith(toggleStyle),
        pivotItemStyle: PivotItemStyle.defaultTheme(brightness).copyWith(pivotItemStyle),
        iconStyle: IconStyle.defaultTheme(brightness).copyWith(iconStyle),
        splitButtonStyle: SplitButtonStyle.defaultTheme(brightness).copyWith(splitButtonStyle),
        listCellStyle: ListCellStyle.defaultTheme(brightness).copyWith(listCellStyle),
        dialogStyle: DialogStyle.defaultTheme(brightness).copyWith(dialogStyle),
        tooltipStyle: TooltipStyle.defaultTheme(brightness).copyWith(tooltipStyle),
        dividerStyle: DividerStyle.defaultTheme(brightness).copyWith(dividerStyle),
      );
  }

  static Style fallback(BuildContext context, [Brightness brightness]) {
    return Style(brightness: brightness).build(context);
  }

}
