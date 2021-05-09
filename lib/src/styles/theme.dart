import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class FluentTheme extends InheritedWidget {
  const FluentTheme({Key? key, required this.data, required this.child})
      : super(key: key, child: child);

  final ThemeData data;
  final Widget child;

  static ThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FluentTheme>()!.data;
  }

  static ThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FluentTheme>()?.data;
  }

  @override
  bool updateShouldNotify(covariant FluentTheme oldWidget) =>
      oldWidget.data != data;
}

extension themeContext on BuildContext {
  ThemeData get theme => FluentTheme.of(this);
  ThemeData? get maybeTheme => FluentTheme.maybeOf(this);
}

extension brightnessExtension on Brightness {
  bool get isLight => this == Brightness.light;
  bool get isDark => this == Brightness.dark;

  Brightness get opposite => isLight ? Brightness.dark : Brightness.light;
}

const standartCurve = Curves.easeInOut;

/// Defines the default theme for a [FluentApp] or [FluentTheme].
@immutable
class ThemeData with Diagnosticable {
  final Typography typography;

  final AccentColor accentColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveBackgroundColor;
  final Color disabledColor;
  final Color shadowColor;
  final Color scaffoldBackgroundColor;
  final Color acrylicBackgroundColor;

  final Duration fasterAnimationDuration;
  final Duration fastAnimationDuration;
  final Duration mediumAnimationDuration;
  final Duration slowAnimationDuration;
  final Curve animationCurve;

  /// The mouse cursor used by many inputs, such as [Button],
  /// [RadioButton] and [ToggleSwitch]. By default, if the
  /// state is pressing or hovering, [SystemMouseCursors.click]
  /// is used, otherwise [MouseCursor.defer] is used.
  final ButtonState<MouseCursor> inputMouseCursor;

  final Brightness brightness;

  final NavigationPaneThemeData navigationPaneTheme;
  final CheckboxThemeData checkboxTheme;
  final ContentDialogThemeData dialogTheme;
  final DividerThemeData dividerTheme;
  final FocusThemeData focusTheme;
  final IconThemeData iconTheme;
  final InfoBarThemeData infoBarTheme;
  final RadioButtonThemeData radioButtonTheme;
  final ScrollbarThemeData scrollbarTheme;
  final SliderThemeData sliderTheme;
  final SplitButtonThemeData splitButtonTheme;
  final ToggleButtonThemeData toggleButtonTheme;
  final ToggleSwitchThemeData toggleSwitchTheme;
  final TooltipThemeData tooltipTheme;

  final ButtonThemeData buttonTheme;

  const ThemeData.raw({
    required this.typography,
    required this.accentColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveBackgroundColor,
    required this.disabledColor,
    required this.shadowColor,
    required this.fasterAnimationDuration,
    required this.fastAnimationDuration,
    required this.mediumAnimationDuration,
    required this.slowAnimationDuration,
    required this.animationCurve,
    required this.brightness,
    required this.scaffoldBackgroundColor,
    required this.acrylicBackgroundColor,
    required this.buttonTheme,
    required this.checkboxTheme,
    required this.toggleSwitchTheme,
    required this.iconTheme,
    required this.splitButtonTheme,
    required this.dialogTheme,
    required this.tooltipTheme,
    required this.dividerTheme,
    required this.navigationPaneTheme,
    required this.radioButtonTheme,
    required this.toggleButtonTheme,
    required this.sliderTheme,
    required this.infoBarTheme,
    required this.focusTheme,
    required this.scrollbarTheme,
    required this.inputMouseCursor,
  });

  static ThemeData light() {
    return ThemeData(brightness: Brightness.light);
  }

  static ThemeData dark() {
    return ThemeData(brightness: Brightness.dark);
  }

  factory ThemeData({
    Brightness? brightness,
    Typography? typography,
    AccentColor? accentColor,
    Color? activeColor,
    Color? inactiveColor,
    Color? inactiveBackgroundColor,
    Color? disabledColor,
    Color? scaffoldBackgroundColor,
    Color? acrylicBackgroundColor,
    Color? shadowColor,
    ButtonState<MouseCursor>? inputMouseCursor,
    Duration? fasterAnimationDuration,
    Duration? fastAnimationDuration,
    Duration? mediumAnimationDuration,
    Duration? slowAnimationDuration,
    Curve? animationCurve,
    ButtonThemeData? buttonTheme,
    CheckboxThemeData? checkboxTheme,
    ToggleSwitchThemeData? toggleSwitchTheme,
    IconThemeData? iconTheme,
    SplitButtonThemeData? splitButtonTheme,
    ContentDialogThemeData? dialogTheme,
    TooltipThemeData? tooltipTheme,
    DividerThemeData? dividerTheme,
    NavigationPaneThemeData? navigationPaneTheme,
    RadioButtonThemeData? radioButtonTheme,
    ToggleButtonThemeData? toggleButtonTheme,
    SliderThemeData? sliderTheme,
    InfoBarThemeData? infoBarTheme,
    FocusThemeData? focusTheme,
    ScrollbarThemeData? scrollbarTheme,
  }) {
    brightness ??= Brightness.light;
    fasterAnimationDuration ??= Duration(milliseconds: 90);
    fastAnimationDuration ??= Duration(milliseconds: 150);
    mediumAnimationDuration ??= Duration(milliseconds: 300);
    slowAnimationDuration ??= Duration(milliseconds: 500);
    animationCurve ??= standartCurve;
    accentColor ??= Colors.blue;
    activeColor ??= Colors.white;
    inactiveColor ??= AccentColor('normal', {
      'normal': Colors.black,
      'dark': Colors.white,
    }).resolveFromBrightness(brightness);
    inactiveBackgroundColor ??= AccentColor('normal', {
      'normal': Color(0xFFd6d6d6),
      'dark': Color(0xFF292929),
    }).resolveFromBrightness(brightness);
    disabledColor ??= Colors.grey[100]!.withOpacity(0.6);
    shadowColor ??= AccentColor('normal', {
      'normal': Colors.black,
      'dark': Colors.grey[130]!,
    }).resolveFromBrightness(brightness);
    scaffoldBackgroundColor ??= AccentColor('normal', {
      'normal': Colors.white,
      'dark': Colors.black,
    }).resolveFromBrightness(brightness);
    acrylicBackgroundColor ??= acrylicBackgroundColor ??
        AccentColor('normal', {
          'normal': Color.fromARGB(255, 230, 230, 230),
          'dark': Color.fromARGB(255, 25, 25, 25)
        }).resolveFromBrightness(brightness);
    typography =
        Typography.standart(brightness: brightness).copyWith(typography);
    inputMouseCursor ??= (state) {
      if (state.isHovering || state.isPressing)
        return SystemMouseCursors.click;
      else
        return MouseCursor.defer;
    };
    focusTheme = FocusThemeData.standard(
      glowColor: accentColor.withOpacity(0.15),
      primaryBorderColor: inactiveColor,
      secondaryBorderColor: scaffoldBackgroundColor,
      animationCurve: animationCurve,
      animationDuration: fasterAnimationDuration,
    ).copyWith(focusTheme);
    buttonTheme ??= const ButtonThemeData();
    checkboxTheme ??= const CheckboxThemeData();
    toggleButtonTheme ??= const ToggleButtonThemeData();
    toggleSwitchTheme ??= const ToggleSwitchThemeData();
    iconTheme ??= const IconThemeData();
    splitButtonTheme ??= const SplitButtonThemeData();
    dialogTheme ??= const ContentDialogThemeData();
    tooltipTheme ??= const TooltipThemeData();
    dividerTheme ??= const DividerThemeData();
    navigationPaneTheme ??= const NavigationPaneThemeData();
    radioButtonTheme ??= const RadioButtonThemeData();
    sliderTheme ??= const SliderThemeData();
    infoBarTheme ??= const InfoBarThemeData();
    scrollbarTheme ??= const ScrollbarThemeData();
    return ThemeData.raw(
      brightness: brightness,
      fasterAnimationDuration: fasterAnimationDuration,
      fastAnimationDuration: fastAnimationDuration,
      mediumAnimationDuration: mediumAnimationDuration,
      slowAnimationDuration: slowAnimationDuration,
      animationCurve: animationCurve,
      accentColor: accentColor,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      inactiveBackgroundColor: inactiveBackgroundColor,
      disabledColor: disabledColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      acrylicBackgroundColor: acrylicBackgroundColor,
      shadowColor: shadowColor,
      buttonTheme: buttonTheme,
      checkboxTheme: checkboxTheme,
      dialogTheme: dialogTheme,
      dividerTheme: dividerTheme,
      focusTheme: focusTheme,
      iconTheme: iconTheme,
      infoBarTheme: infoBarTheme,
      navigationPaneTheme: navigationPaneTheme,
      radioButtonTheme: radioButtonTheme,
      scrollbarTheme: scrollbarTheme,
      sliderTheme: sliderTheme,
      splitButtonTheme: splitButtonTheme,
      toggleButtonTheme: toggleButtonTheme,
      toggleSwitchTheme: toggleSwitchTheme,
      tooltipTheme: tooltipTheme,
      typography: typography,
      inputMouseCursor: inputMouseCursor,
    );
  }

  ThemeData copyWith({
    Brightness? brightness,
    Typography? typography,
    AccentColor? accentColor,
    Color? activeColor,
    Color? inactiveColor,
    Color? inactiveBackgroundColor,
    Color? disabledColor,
    Color? scaffoldBackgroundColor,
    Color? acrylicBackgroundColor,
    Color? shadowColor,
    Duration? fasterAnimationDuration,
    Duration? fastAnimationDuration,
    Duration? mediumAnimationDuration,
    Duration? slowAnimationDuration,
    Curve? animationCurve,
    ButtonState<MouseCursor>? inputMouseCursor,
    ButtonThemeData? buttonTheme,
    CheckboxThemeData? checkboxTheme,
    ToggleSwitchThemeData? toggleSwitchTheme,
    IconThemeData? iconTheme,
    SplitButtonThemeData? splitButtonTheme,
    ContentDialogThemeData? dialogTheme,
    TooltipThemeData? tooltipTheme,
    DividerThemeData? dividerTheme,
    NavigationPaneThemeData? navigationPaneTheme,
    RadioButtonThemeData? radioButtonTheme,
    ToggleButtonThemeData? toggleButtonTheme,
    SliderThemeData? sliderTheme,
    InfoBarThemeData? infoBarTheme,
    FocusThemeData? focusTheme,
    ScrollbarThemeData? scrollbarTheme,
  }) {
    return ThemeData.raw(
      brightness: brightness ?? this.brightness,
      typography: typography ?? this.typography,
      accentColor: accentColor ?? this.accentColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      shadowColor: shadowColor ?? this.shadowColor,
      inactiveBackgroundColor:
          inactiveBackgroundColor ?? this.inactiveBackgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      acrylicBackgroundColor:
          acrylicBackgroundColor ?? this.acrylicBackgroundColor,
      fasterAnimationDuration:
          fasterAnimationDuration ?? this.fasterAnimationDuration,
      fastAnimationDuration:
          fastAnimationDuration ?? this.fastAnimationDuration,
      mediumAnimationDuration:
          mediumAnimationDuration ?? this.mediumAnimationDuration,
      slowAnimationDuration:
          slowAnimationDuration ?? this.slowAnimationDuration,
      inputMouseCursor: inputMouseCursor ?? this.inputMouseCursor,
      animationCurve: animationCurve ?? this.animationCurve,
      buttonTheme: this.buttonTheme.copyWith(buttonTheme),
      checkboxTheme: this.checkboxTheme.copyWith(checkboxTheme),
      dialogTheme: this.dialogTheme.copyWith(dialogTheme),
      dividerTheme: this.dividerTheme.copyWith(dividerTheme),
      focusTheme: this.focusTheme.copyWith(focusTheme),
      iconTheme: this.iconTheme.copyWith(iconTheme),
      infoBarTheme: this.infoBarTheme.copyWith(infoBarTheme),
      navigationPaneTheme:
          this.navigationPaneTheme.copyWith(navigationPaneTheme),
      radioButtonTheme: this.radioButtonTheme.copyWith(radioButtonTheme),
      scrollbarTheme: this.scrollbarTheme.copyWith(scrollbarTheme),
      sliderTheme: this.sliderTheme.copyWith(sliderTheme),
      splitButtonTheme: this.splitButtonTheme.copyWith(splitButtonTheme),
      toggleButtonTheme: this.toggleButtonTheme.copyWith(toggleButtonTheme),
      toggleSwitchTheme: this.toggleSwitchTheme.copyWith(toggleSwitchTheme),
      tooltipTheme: this.tooltipTheme.copyWith(tooltipTheme),
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
      'acrylicBackgroundColor',
      acrylicBackgroundColor,
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
