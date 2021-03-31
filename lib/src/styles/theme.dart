import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class Theme extends InheritedWidget {
  const Theme({Key? key, required this.data, required this.child})
      : super(key: key, child: child);

  final Style data;
  final Widget child;

  static Style of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Theme>()!.data.build();
  }

  static Style maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Theme>()!.data.build();
  }

  @override
  bool updateShouldNotify(covariant Theme oldWidget) => oldWidget.data != data;
}

extension themeContext on BuildContext {
  Style get theme => Theme.of(this);
  Style? get maybeTheme => Theme.maybeOf(this);
}

extension brightnessExtension on Brightness {
  bool get isLight => this == Brightness.light;
  bool get isDark => this == Brightness.dark;

  Brightness get opposite => isLight ? Brightness.dark : Brightness.light;
}

const standartCurve = Curves.easeInOut;

class Style with Diagnosticable {
  final Typography? typography;

  final Color? accentColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? inactiveBackgroundColor;
  final Color? disabledColor;

  final Duration? fasterAnimationDuration;
  final Duration? fastAnimationDuration;
  final Duration? mediumAnimationDuration;
  final Duration? slowAnimationDuration;
  final Curve? animationCurve;

  final Brightness? brightness;

  final Color? scaffoldBackgroundColor;
  final Color? navigationPanelBackgroundColor;

  final NavigationPanelStyle? navigationPanelStyle;
  final CheckboxStyle? checkboxStyle;
  final ContentDialogStyle? dialogStyle;
  final DividerStyle? dividerStyle;
  final IconStyle? iconStyle;
  final InfoBarStyle? infoBarStyle;
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
    this.inactiveBackgroundColor,
    this.disabledColor,
    this.fasterAnimationDuration,
    this.fastAnimationDuration,
    this.mediumAnimationDuration,
    this.slowAnimationDuration,
    this.animationCurve,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.navigationPanelBackgroundColor,
    this.buttonStyle,
    this.iconButtonStyle,
    this.checkboxStyle,
    this.toggleSwitchStyle,
    this.pivotItemStyle,
    this.iconStyle,
    this.splitButtonStyle,
    this.dialogStyle,
    this.tooltipStyle,
    this.dividerStyle,
    this.navigationPanelStyle,
    this.radioButtonStyle,
    this.toggleButtonStyle,
    this.sliderStyle,
    this.infoBarStyle,
  });

  Style build() {
    final brightness = this.brightness ?? Brightness.light;
    final defaultStyle = Style(
      fasterAnimationDuration: Duration(milliseconds: 90),
      fastAnimationDuration: Duration(milliseconds: 150),
      mediumAnimationDuration: Duration(milliseconds: 300),
      slowAnimationDuration: Duration(milliseconds: 500),
      animationCurve: standartCurve,
      brightness: brightness,
      accentColor: accentColor ?? Colors.blue,
      activeColor: activeColor ?? Colors.white,
      inactiveColor: inactiveColor ??
          () {
            if (brightness.isLight)
              return Colors.black;
            else
              return Colors.white;
          }(),
      inactiveBackgroundColor: inactiveBackgroundColor ??
          () {
            if (brightness.isLight)
              return Color(0xFFd6d6d6);
            else
              return Color(0xFF292929);
          }(),
      disabledColor: Colors.grey[100]!.withOpacity(0.6),
      scaffoldBackgroundColor: scaffoldBackgroundColor ??
          () {
            if (brightness.isLight)
              return Colors.white;
            else
              return Colors.black;
          }(),
      navigationPanelBackgroundColor: navigationPanelBackgroundColor ??
          () {
            if (brightness.isLight)
              return Color.fromARGB(255, 230, 230, 230);
            else
              return Color.fromARGB(255, 25, 25, 25);
          }(),
      typography: Typography.defaultTypography(brightness: brightness)
          .copyWith(typography),
    );
    return defaultStyle.copyWith(Style(
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
      splitButtonStyle: SplitButtonStyle.defaultTheme(defaultStyle)
          .copyWith(splitButtonStyle),
      dialogStyle:
          ContentDialogStyle.defaultTheme(defaultStyle).copyWith(dialogStyle),
      tooltipStyle:
          TooltipStyle.defaultTheme(defaultStyle).copyWith(tooltipStyle),
      dividerStyle:
          DividerStyle.defaultTheme(defaultStyle).copyWith(dividerStyle),
      navigationPanelStyle: NavigationPanelStyle.defaultTheme(defaultStyle)
          .copyWith(navigationPanelStyle),
      radioButtonStyle: RadioButtonStyle.defaultTheme(defaultStyle)
          .copyWith(radioButtonStyle),
      sliderStyle: SliderStyle.defaultTheme(defaultStyle).copyWith(sliderStyle),
      infoBarStyle:
          InfoBarStyle.defaultTheme(defaultStyle).copyWith(infoBarStyle),
    ));
  }

  static Style fallback([Brightness? brightness]) {
    return Style(brightness: brightness).build();
  }

  Style copyWith(Style? other) {
    if (other == null) return this;
    return Style(
      accentColor: other.accentColor ?? accentColor,
      activeColor: other.activeColor ?? activeColor,
      navigationPanelBackgroundColor: other.navigationPanelBackgroundColor ??
          navigationPanelBackgroundColor,
      navigationPanelStyle: other.navigationPanelStyle ?? navigationPanelStyle,
      brightness: other.brightness ?? brightness,
      buttonStyle: other.buttonStyle ?? buttonStyle,
      checkboxStyle: other.checkboxStyle ?? checkboxStyle,
      dialogStyle: other.dialogStyle ?? dialogStyle,
      dividerStyle: other.dividerStyle ?? dividerStyle,
      iconButtonStyle: other.iconButtonStyle ?? iconButtonStyle,
      iconStyle: other.iconStyle ?? iconStyle,
      inactiveColor: other.inactiveColor ?? inactiveColor,
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
      disabledColor: other.disabledColor ?? disabledColor,
      typography: other.typography ?? typography,
      fasterAnimationDuration:
          other.fastAnimationDuration ?? fasterAnimationDuration,
      fastAnimationDuration:
          other.fastAnimationDuration ?? fastAnimationDuration,
      mediumAnimationDuration:
          other.mediumAnimationDuration ?? mediumAnimationDuration,
      slowAnimationDuration:
          other.slowAnimationDuration ?? slowAnimationDuration,
      infoBarStyle: other.infoBarStyle ?? infoBarStyle,
      inactiveBackgroundColor:
          other.inactiveBackgroundColor ?? inactiveBackgroundColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('accentColor', accentColor));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(
      ColorProperty('inactiveBackgroundColor', inactiveBackgroundColor),
    );
    properties.add(ColorProperty('disabledColor', disabledColor));
    properties.add(
      ColorProperty('scaffoldBackgroundColor', scaffoldBackgroundColor),
    );
    properties.add(ColorProperty(
      'navigationPanelBackgroundColor',
      navigationPanelBackgroundColor,
    ));
    properties.add(EnumProperty('brightness', brightness));
    properties.add(DiagnosticsProperty<Duration>(
      'slowAnimationDuration',
      slowAnimationDuration,
    ));
    properties.add(DiagnosticsProperty<Duration>(
      'mediumAnimationDuration',
      mediumAnimationDuration,
    ));
    properties.add(DiagnosticsProperty<Duration>(
      'fastAnimationDuration',
      fastAnimationDuration,
    ));
    properties.add(DiagnosticsProperty<Duration>(
      'fasterAnimationDuration',
      fasterAnimationDuration,
    ));
    properties.add(
      DiagnosticsProperty<Curve>('animationCurve', animationCurve),
    );
  }
}
