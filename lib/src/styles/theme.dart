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

  static Style? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Theme>()?.data.build();
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
  final FocusStyle? focusStyle;
  final IconStyle? iconStyle;
  final InfoBarStyle? infoBarStyle;
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
    this.focusStyle,
  });

  Style build() {
    final brightness = this.brightness ?? Brightness.light;
    Style style = Style(
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
    style = style.copyWith(Style(
      focusStyle: FocusStyle.standard(style).copyWith(focusStyle),
    ));
    return style.copyWith(Style(
      buttonStyle: ButtonStyle.standard(style).copyWith(buttonStyle),
      iconButtonStyle:
          IconButtonStyle.standard(style).copyWith(iconButtonStyle),
      checkboxStyle: CheckboxStyle.standard(style).copyWith(checkboxStyle),
      toggleButtonStyle:
          ToggleButtonStyle.standard(style).copyWith(toggleButtonStyle),
      toggleSwitchStyle:
          ToggleSwitchStyle.standard(style).copyWith(toggleSwitchStyle),
      iconStyle: IconStyle.standard(style).copyWith(iconStyle),
      splitButtonStyle:
          SplitButtonStyle.standard(style).copyWith(splitButtonStyle),
      dialogStyle: ContentDialogStyle.standard(style).copyWith(dialogStyle),
      tooltipStyle: TooltipStyle.standard(style).copyWith(tooltipStyle),
      dividerStyle: DividerStyle.standard(style).copyWith(dividerStyle),
      navigationPanelStyle:
          NavigationPanelStyle.standard(style).copyWith(navigationPanelStyle),
      radioButtonStyle:
          RadioButtonStyle.standard(style).copyWith(radioButtonStyle),
      sliderStyle: SliderStyle.standard(style).copyWith(sliderStyle),
      infoBarStyle: InfoBarStyle.standard(style).copyWith(infoBarStyle),
    ));
  }

  factory Style.fallback([Brightness? brightness]) {
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
      focusStyle: other.focusStyle ?? focusStyle,
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
