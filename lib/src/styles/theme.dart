import 'package:fluent_ui/fluent_ui.dart';

class Theme extends InheritedWidget {
  const Theme({Key? key, required this.data, required this.child})
      : super(key: key, child: child);

  final Style data;
  final Widget child;

  static Style? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Theme>()
        ?.data
        .build(context);
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => oldWidget.data != data;
}

extension themeContext on BuildContext {
  Style? get theme => Theme.of(this);
}

class Style {
  final Typography? typography;

  final Color? accentColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? disabledColor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  final Brightness? brightness;

  final Color? scaffoldBackgroundColor;
  final Color? navigationPanelBackgroundColor;

  final NavigationPanelStyle? navigationPanelStyle;
  final CardStyle? cardStyle;
  final CheckboxStyle? checkboxStyle;
  final ContentDialogStyle? dialogStyle;
  final DividerStyle? dividerStyle;
  final IconStyle? iconStyle;
  final ListCellStyle? listCellStyle;
  final PivotItemStyle? pivotItemStyle;
  final RadioButtonStyle? radioButtonStyle;
  final SliderStyle? sliderStyle;
  final SplitButtonStyle? splitButtonStyle;
  final ToggleButtonStyle? toggleButtonStyle;
  final ToggleSwitchStyle? toggleSwitchStyle;
  final TooltipStyle? tooltipStyle;

  final ButtonStyle? buttonStyle;
  final IconButtonStyle? iconButtonStyle;

  const Style({
    this.typography,
    this.accentColor,
    this.activeColor,
    this.inactiveColor,
    this.disabledColor,
    this.animationDuration,
    this.animationCurve,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.navigationPanelBackgroundColor,
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
    this.navigationPanelStyle,
    this.radioButtonStyle,
    this.toggleButtonStyle,
    this.sliderStyle,
  });

  Style build(BuildContext context) {
    final brightness = this.brightness ?? Brightness.light;
    final defaultStyle = Style(
      animationDuration: Duration(milliseconds: 250),
      animationCurve: Curves.linear,
      brightness: brightness,
      accentColor: accentColor ?? Colors.blue,
      activeColor: activeColor ?? Colors.white,
      inactiveColor: inactiveColor ??
          () {
            if (brightness == Brightness.light)
              return Colors.black;
            else
              return Colors.white;
          }(),
      disabledColor: Colors.grey[100]!.withOpacity(0.6),
      scaffoldBackgroundColor: scaffoldBackgroundColor ??
          () {
            if (brightness == Brightness.light)
              return Colors.white;
            else
              return Colors.black;
          }(),
      navigationPanelBackgroundColor: navigationPanelBackgroundColor ??
          () {
            if (brightness == Brightness.light)
              return Color.fromARGB(255, 246, 246, 246);
            else
              return Color.fromARGB(255, 31, 31, 31);
          }(),
      typography: Typography.defaultTypography(brightness: brightness)
          .copyWith(typography),
    );
    return defaultStyle.copyWith(Style(
      cardStyle: CardStyle.defaultTheme(defaultStyle).copyWith(cardStyle),
      buttonStyle: ButtonStyle.defaultTheme(defaultStyle).copyWith(buttonStyle),
      iconButtonStyle:
          IconButtonStyle.defaultTheme(defaultStyle).copyWith(iconButtonStyle),
      checkboxStyle:
          CheckboxStyle.defaultTheme(defaultStyle).copyWith(checkboxStyle),
      toggleButtonStyle: ToggleButtonStyle.defaultTheme(defaultStyle)
          .copyWith(toggleButtonStyle),
      toggleSwitchStyle: ToggleSwitchStyle.defaultTheme(defaultStyle)
          .copyWith(toggleSwitchStyle),
      pivotItemStyle:
          PivotItemStyle.defaultTheme(brightness).copyWith(pivotItemStyle),
      iconStyle: IconStyle.defaultTheme(brightness).copyWith(iconStyle),
      splitButtonStyle: SplitButtonStyle.defaultTheme(defaultStyle, brightness)
          .copyWith(splitButtonStyle),
      listCellStyle:
          ListCellStyle.defaultTheme(brightness).copyWith(listCellStyle),
      dialogStyle:
          ContentDialogStyle.defaultTheme(defaultStyle).copyWith(dialogStyle),
      tooltipStyle:
          TooltipStyle.defaultTheme(defaultStyle).copyWith(tooltipStyle),
      dividerStyle:
          DividerStyle.defaultTheme(brightness).copyWith(dividerStyle),
      navigationPanelStyle: NavigationPanelStyle.defaultTheme(defaultStyle)
          .copyWith(navigationPanelStyle),
      radioButtonStyle: RadioButtonStyle.defaultTheme(defaultStyle)
          .copyWith(radioButtonStyle),
      sliderStyle: SliderStyle.defaultTheme(defaultStyle).copyWith(sliderStyle),
    ));
  }

  static Style fallback(BuildContext context, [Brightness? brightness]) {
    return Style(brightness: brightness).build(context);
  }

  Style copyWith(Style other) {
    return Style(
      accentColor: other.accentColor ?? accentColor,
      activeColor: other.activeColor ?? activeColor,
      navigationPanelBackgroundColor: other.navigationPanelBackgroundColor ??
          navigationPanelBackgroundColor,
      navigationPanelStyle: other.navigationPanelStyle ?? navigationPanelStyle,
      brightness: other.brightness ?? brightness,
      buttonStyle: other.buttonStyle ?? buttonStyle,
      cardStyle: other.cardStyle ?? cardStyle,
      checkboxStyle: other.checkboxStyle ?? checkboxStyle,
      dialogStyle: other.dialogStyle ?? dialogStyle,
      dividerStyle: other.dividerStyle ?? dividerStyle,
      iconButtonStyle: other.iconButtonStyle ?? iconButtonStyle,
      iconStyle: other.iconStyle ?? iconStyle,
      inactiveColor: other.inactiveColor ?? inactiveColor,
      listCellStyle: other.listCellStyle ?? listCellStyle,
      pivotItemStyle: other.pivotItemStyle ?? pivotItemStyle,
      radioButtonStyle: other.radioButtonStyle ?? radioButtonStyle,
      scaffoldBackgroundColor:
          other.scaffoldBackgroundColor ?? scaffoldBackgroundColor,
      splitButtonStyle: other.splitButtonStyle ?? splitButtonStyle,
      toggleButtonStyle: other.toggleButtonStyle ?? toggleButtonStyle,
      toggleSwitchStyle: other.toggleSwitchStyle ?? toggleSwitchStyle,
      tooltipStyle: other.tooltipStyle ?? tooltipStyle,
      sliderStyle: other.sliderStyle ?? sliderStyle,
      animationCurve: other.animationCurve ?? animationCurve,
      animationDuration: other.animationDuration ?? animationDuration,
      disabledColor: other.disabledColor ?? disabledColor,
      typography: other.typography ?? typography,
    );
  }
}
