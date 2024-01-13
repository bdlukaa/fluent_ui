import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class FluentTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const FluentTheme({
    super.key,
    required this.data,
    required this.child,
  });

  /// Specifies the color and typography values for descendant widgets.
  final FluentThemeData data;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  static FluentThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FluentTheme>()!.data;
  }

  static FluentThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FluentTheme>()?.data;
  }

  @override
  Widget build(BuildContext context) {
    return _FluentTheme(
      data: data,
      child: IconTheme(
        data: data.iconTheme,
        child: DefaultTextStyle(
          style: data.typography.body!,
          child: child,
        ),
      ),
    );
  }
}

class _FluentTheme extends InheritedTheme {
  const _FluentTheme({
    required this.data,
    required super.child,
  });

  final FluentThemeData data;

  @override
  bool updateShouldNotify(covariant _FluentTheme oldWidget) =>
      oldWidget.data != data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return _FluentTheme(data: data, child: child);
  }
}

/// An interpolation between two [FluentThemeData]s.
///
/// This class specializes the interpolation of [Tween<FluentThemeData>] to call the
/// [FluentThemeData.lerp] method.
///
/// See [Tween] for a discussion on how to use interpolation objects.
class FluentThemeDataTween extends Tween<FluentThemeData> {
  /// Creates a [FluentThemeData] tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  FluentThemeDataTween({super.begin, super.end});

  @override
  FluentThemeData lerp(double t) => FluentThemeData.lerp(begin!, end!, t);
}

/// Animated version of [Theme] which automatically transitions the colors,
/// etc, over a given duration whenever the given theme changes.
///
/// Here's an illustration of what using this widget looks like, using a [curve]
/// of [Curves.elasticInOut].
/// {@animation 250 266 https://flutter.github.io/assets-for-api-docs/assets/widgets/animated_theme.mp4}
///
/// See also:
///
///  * [FluentTheme], which [AnimatedFluentTheme] uses to actually apply the interpolated
///    theme.
///  * [FluentThemeData], which describes the actual configuration of a theme.
///  * [FluentApp], which includes an [AnimatedFluentTheme] widget configured via
///    the [FluentApp.theme] argument.
class AnimatedFluentTheme extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme.
  ///
  /// By default, the theme transition uses a linear curve. The [data] and
  /// [child] arguments must not be null.
  const AnimatedFluentTheme({
    super.key,
    required this.data,
    super.curve,
    super.duration = kThemeAnimationDuration,
    super.onEnd,
    required this.child,
  });

  /// Specifies the color and typography values for descendant widgets.
  final FluentThemeData data;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFluentTheme> createState() =>
      _AnimatedFluentThemeState();
}

class _AnimatedFluentThemeState
    extends AnimatedWidgetBaseState<AnimatedFluentTheme> {
  FluentThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
            _data,
            widget.data,
            (dynamic value) =>
                FluentThemeDataTween(begin: value as FluentThemeData))!
        as FluentThemeDataTween;
  }

  @override
  Widget build(BuildContext context) {
    return FluentTheme(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<FluentThemeDataTween>('data', _data,
        showName: false, defaultValue: null));
  }
}

extension BrightnessExtension on Brightness {
  /// Whether this is light
  ///
  /// ```dart
  /// final isLight = FluentTheme.of(context).brightness.isLight;
  /// ```
  bool get isLight => this == Brightness.light;

  /// Whether this is light
  ///
  /// ```dart
  /// final isDark = FluentTheme.of(context).brightness.isDark;
  /// ```
  bool get isDark => this == Brightness.dark;

  /// Gets the opposite brightness from this
  Brightness get opposite => isLight ? Brightness.dark : Brightness.light;
}

const standardCurve = Curves.easeInOut;

/// Defines the default theme for a [FluentApp] or [FluentTheme].
@immutable
class FluentThemeData with Diagnosticable {
  final Typography typography;
  final Map<Object, ThemeExtension<dynamic>> extensions;

  /// The accent color.
  ///
  /// Defaults to [Colors.blue]
  final AccentColor accentColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveBackgroundColor;
  final Color shadowColor;
  final Color scaffoldBackgroundColor;
  final Color acrylicBackgroundColor;
  final Color micaBackgroundColor;
  final Color menuColor;
  final Color cardColor;
  final Color selectionColor;

  final Duration fasterAnimationDuration;
  final Duration fastAnimationDuration;
  final Duration mediumAnimationDuration;
  final Duration slowAnimationDuration;
  final Curve animationCurve;

  final Brightness brightness;
  final VisualDensity visualDensity;

  final NavigationPaneThemeData navigationPaneTheme;
  final BottomNavigationThemeData bottomNavigationTheme;
  final CheckboxThemeData checkboxTheme;
  final ContentDialogThemeData dialogTheme;
  final DividerThemeData dividerTheme;
  final FocusThemeData focusTheme;
  final IconThemeData iconTheme;
  final InfoBarThemeData infoBarTheme;
  final RadioButtonThemeData radioButtonTheme;
  final ScrollbarThemeData scrollbarTheme;
  final SliderThemeData sliderTheme;
  final ToggleButtonThemeData toggleButtonTheme;
  final ToggleSwitchThemeData toggleSwitchTheme;
  final TooltipThemeData tooltipTheme;

  final ButtonThemeData buttonTheme;

  final ResourceDictionary resources;

  factory FluentThemeData({
    Iterable<ThemeExtension<dynamic>>? extensions,
    Brightness? brightness,
    VisualDensity? visualDensity,
    Typography? typography,
    String? fontFamily,
    AccentColor? accentColor,
    Color? activeColor,
    Color? inactiveColor,
    Color? inactiveBackgroundColor,
    Color? scaffoldBackgroundColor,
    Color? acrylicBackgroundColor,
    Color? micaBackgroundColor,
    Color? shadowColor,
    Color? menuColor,
    Color? cardColor,
    Color? selectionColor,
    Duration? fasterAnimationDuration,
    Duration? fastAnimationDuration,
    Duration? mediumAnimationDuration,
    Duration? slowAnimationDuration,
    Curve? animationCurve,
    BottomNavigationThemeData? bottomNavigationTheme,
    ButtonThemeData? buttonTheme,
    CheckboxThemeData? checkboxTheme,
    ToggleSwitchThemeData? toggleSwitchTheme,
    IconThemeData? iconTheme,
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
    ResourceDictionary? resources,
  }) {
    brightness ??= Brightness.light;
    extensions ??= [];

    final isLight = brightness == Brightness.light;

    visualDensity ??= VisualDensity.adaptivePlatformDensity;
    fasterAnimationDuration ??= const Duration(milliseconds: 83);
    fastAnimationDuration ??= const Duration(milliseconds: 167);
    mediumAnimationDuration ??= const Duration(milliseconds: 250);
    slowAnimationDuration ??= const Duration(milliseconds: 358);
    resources ??= isLight
        ? const ResourceDictionary.light()
        : const ResourceDictionary.dark();
    animationCurve ??= standardCurve;
    accentColor ??= Colors.blue;
    activeColor ??= Colors.white;
    inactiveColor ??= isLight ? Colors.black : Colors.white;
    inactiveBackgroundColor ??=
        isLight ? const Color(0xFFd6d6d6) : const Color(0xFF292929);
    shadowColor ??= isLight ? Colors.black : Colors.grey[130];
    scaffoldBackgroundColor ??= resources.layerOnAcrylicFillColorDefault;
    acrylicBackgroundColor ??= isLight
        ? resources.layerOnAcrylicFillColorDefault
        : const Color(0xFF2c2c2c);
    micaBackgroundColor ??= resources.solidBackgroundFillColorBase;
    menuColor ??= isLight ? const Color(0xFFf9f9f9) : const Color(0xFF2c2c2c);
    cardColor ??= resources.cardBackgroundFillColorDefault;
    selectionColor ??= accentColor.normal;
    typography = Typography.fromBrightness(
      brightness: brightness,
      color: resources.textFillColorPrimary,
    ).merge(typography).apply(fontFamily: fontFamily);
    focusTheme ??= const FocusThemeData();
    buttonTheme ??= const ButtonThemeData();
    checkboxTheme ??= const CheckboxThemeData();
    toggleButtonTheme ??= const ToggleButtonThemeData();
    toggleSwitchTheme ??= const ToggleSwitchThemeData();
    iconTheme ??= isLight
        ? const IconThemeData(color: Colors.black, size: 18.0)
        : const IconThemeData(color: Colors.white, size: 18.0);
    dialogTheme ??= const ContentDialogThemeData();
    tooltipTheme ??= const TooltipThemeData();
    dividerTheme ??= const DividerThemeData();
    navigationPaneTheme = NavigationPaneThemeData.fromResources(
      resources: resources,
      animationCurve: animationCurve,
      animationDuration: fastAnimationDuration,
      highlightColor: accentColor.defaultBrushFor(brightness),
      typography: typography,
    ).merge(navigationPaneTheme);
    radioButtonTheme ??= const RadioButtonThemeData();
    sliderTheme ??= const SliderThemeData();
    infoBarTheme ??= const InfoBarThemeData();
    scrollbarTheme ??= const ScrollbarThemeData();
    bottomNavigationTheme ??= const BottomNavigationThemeData();

    return FluentThemeData.raw(
      brightness: brightness,
      extensions: _themeExtensionIterableToMap(extensions),
      visualDensity: visualDensity,
      fasterAnimationDuration: fasterAnimationDuration,
      fastAnimationDuration: fastAnimationDuration,
      mediumAnimationDuration: mediumAnimationDuration,
      slowAnimationDuration: slowAnimationDuration,
      animationCurve: animationCurve,
      accentColor: accentColor,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      inactiveBackgroundColor: inactiveBackgroundColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      acrylicBackgroundColor: acrylicBackgroundColor,
      micaBackgroundColor: micaBackgroundColor,
      shadowColor: shadowColor,
      bottomNavigationTheme: bottomNavigationTheme,
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
      toggleButtonTheme: toggleButtonTheme,
      toggleSwitchTheme: toggleSwitchTheme,
      tooltipTheme: tooltipTheme,
      typography: typography,
      menuColor: menuColor,
      cardColor: cardColor,
      resources: resources,
      selectionColor: selectionColor,
    );
  }

  const FluentThemeData.raw({
    required this.typography,
    required this.extensions,
    required this.accentColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveBackgroundColor,
    required this.shadowColor,
    required this.fasterAnimationDuration,
    required this.fastAnimationDuration,
    required this.mediumAnimationDuration,
    required this.slowAnimationDuration,
    required this.animationCurve,
    required this.brightness,
    required this.visualDensity,
    required this.scaffoldBackgroundColor,
    required this.acrylicBackgroundColor,
    required this.micaBackgroundColor,
    required this.buttonTheme,
    required this.checkboxTheme,
    required this.toggleSwitchTheme,
    required this.bottomNavigationTheme,
    required this.iconTheme,
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
    required this.menuColor,
    required this.cardColor,
    required this.resources,
    required this.selectionColor,
  });

  static FluentThemeData light() {
    return FluentThemeData(brightness: Brightness.light);
  }

  static FluentThemeData dark() {
    return FluentThemeData(brightness: Brightness.dark);
  }

  static FluentThemeData lerp(FluentThemeData a, FluentThemeData b, double t) {
    return FluentThemeData.raw(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      extensions: t < 0.5 ? a.extensions : b.extensions,
      visualDensity: t < 0.5 ? a.visualDensity : b.visualDensity,
      resources: ResourceDictionary.lerp(a.resources, b.resources, t),
      accentColor: AccentColor.lerp(a.accentColor, b.accentColor, t),
      typography: Typography.lerp(a.typography, b.typography, t),
      activeColor: Color.lerp(a.activeColor, b.activeColor, t)!,
      inactiveColor: Color.lerp(a.inactiveColor, b.inactiveColor, t)!,
      inactiveBackgroundColor:
          Color.lerp(a.inactiveBackgroundColor, b.inactiveBackgroundColor, t)!,
      scaffoldBackgroundColor:
          Color.lerp(a.scaffoldBackgroundColor, b.scaffoldBackgroundColor, t)!,
      acrylicBackgroundColor:
          Color.lerp(a.acrylicBackgroundColor, b.acrylicBackgroundColor, t)!,
      micaBackgroundColor:
          Color.lerp(a.micaBackgroundColor, b.micaBackgroundColor, t)!,
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
      cardColor: Color.lerp(a.cardColor, b.cardColor, t)!,
      fasterAnimationDuration:
          lerpDuration(a.fasterAnimationDuration, b.fasterAnimationDuration, t),
      fastAnimationDuration:
          lerpDuration(a.fastAnimationDuration, b.fastAnimationDuration, t),
      mediumAnimationDuration:
          lerpDuration(a.mediumAnimationDuration, b.mediumAnimationDuration, t),
      slowAnimationDuration:
          lerpDuration(a.slowAnimationDuration, b.slowAnimationDuration, t),
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
      buttonTheme: ButtonThemeData.lerp(a.buttonTheme, b.buttonTheme, t),
      checkboxTheme:
          CheckboxThemeData.lerp(a.checkboxTheme, b.checkboxTheme, t),
      toggleSwitchTheme: ToggleSwitchThemeData.lerp(
          a.toggleSwitchTheme, b.toggleSwitchTheme, t),
      iconTheme: IconThemeData.lerp(a.iconTheme, b.iconTheme, t),
      dialogTheme: ContentDialogThemeData.lerp(a.dialogTheme, b.dialogTheme, t),
      tooltipTheme: TooltipThemeData.lerp(a.tooltipTheme, b.tooltipTheme, t),
      dividerTheme: DividerThemeData.lerp(a.dividerTheme, b.dividerTheme, t),
      navigationPaneTheme: NavigationPaneThemeData.lerp(
          a.navigationPaneTheme, b.navigationPaneTheme, t),
      radioButtonTheme:
          RadioButtonThemeData.lerp(a.radioButtonTheme, b.radioButtonTheme, t),
      toggleButtonTheme: ToggleButtonThemeData.lerp(
          a.toggleButtonTheme, b.toggleButtonTheme, t),
      sliderTheme: SliderThemeData.lerp(a.sliderTheme, b.sliderTheme, t),
      infoBarTheme: InfoBarThemeData.lerp(a.infoBarTheme, b.infoBarTheme, t),
      focusTheme: FocusThemeData.lerp(a.focusTheme, b.focusTheme, t),
      scrollbarTheme:
          ScrollbarThemeData.lerp(a.scrollbarTheme, b.scrollbarTheme, t),
      bottomNavigationTheme: BottomNavigationThemeData.lerp(
          a.bottomNavigationTheme, b.bottomNavigationTheme, t),
      menuColor: Color.lerp(a.menuColor, b.menuColor, t)!,
      selectionColor: Color.lerp(a.selectionColor, b.selectionColor, t)!,
    );
  }

  /// Used to obtain a particular [ThemeExtension] from [extensions].
  ///
  /// Obtain with `FluentTheme.of(context).extension<MyThemeExtension>()`.
  ///
  /// See [extensions] for an interactive example.
  T? extension<T>() => extensions[T] as T?;

  /// Convert the [extensionsIterable] passed to [FluentThemeData.new] or [copyWith]
  /// to the stored [extensions] map, where each entry's key consists of the extension's type.
  static Map<Object, ThemeExtension<dynamic>> _themeExtensionIterableToMap(
      Iterable<ThemeExtension<dynamic>> extensionsIterable) {
    return Map<Object, ThemeExtension<dynamic>>.unmodifiable(<Object,
        ThemeExtension<dynamic>>{
      // Strangely, the cast is necessary for tests to run.
      for (final ThemeExtension<dynamic> extension in extensionsIterable)
        extension.type: extension as ThemeExtension<ThemeExtension<dynamic>>,
    });
  }

  FluentThemeData copyWith({
    Brightness? brightness,
    Iterable<ThemeExtension<dynamic>>? extensions,
    VisualDensity? visualDensity,
    Typography? typography,
    AccentColor? accentColor,
    Color? activeColor,
    Color? inactiveColor,
    Color? inactiveBackgroundColor,
    Color? scaffoldBackgroundColor,
    Color? acrylicBackgroundColor,
    Color? micaBackgroundColor,
    Color? shadowColor,
    Color? menuColor,
    Color? cardColor,
    Color? selectionColor,
    Duration? fasterAnimationDuration,
    Duration? fastAnimationDuration,
    Duration? mediumAnimationDuration,
    Duration? slowAnimationDuration,
    Curve? animationCurve,
    ButtonThemeData? buttonTheme,
    BottomNavigationThemeData? bottomNavigationTheme,
    CheckboxThemeData? checkboxTheme,
    ToggleSwitchThemeData? toggleSwitchTheme,
    IconThemeData? iconTheme,
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
    ResourceDictionary? resources,
  }) {
    return FluentThemeData.raw(
      brightness: brightness ?? this.brightness,
      visualDensity: visualDensity ?? this.visualDensity,
      typography: this.typography.merge(typography),
      extensions: extensions != null
          ? _themeExtensionIterableToMap(extensions)
          : this.extensions,
      accentColor: accentColor ?? this.accentColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      shadowColor: shadowColor ?? this.shadowColor,
      inactiveBackgroundColor:
          inactiveBackgroundColor ?? this.inactiveBackgroundColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      acrylicBackgroundColor:
          acrylicBackgroundColor ?? this.acrylicBackgroundColor,
      micaBackgroundColor: micaBackgroundColor ?? this.micaBackgroundColor,
      menuColor: menuColor ?? this.menuColor,
      cardColor: cardColor ?? this.cardColor,
      selectionColor: selectionColor ?? this.selectionColor,
      fasterAnimationDuration:
          fasterAnimationDuration ?? this.fasterAnimationDuration,
      fastAnimationDuration:
          fastAnimationDuration ?? this.fastAnimationDuration,
      mediumAnimationDuration:
          mediumAnimationDuration ?? this.mediumAnimationDuration,
      slowAnimationDuration:
          slowAnimationDuration ?? this.slowAnimationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      buttonTheme: this.buttonTheme.merge(buttonTheme),
      bottomNavigationTheme:
          this.bottomNavigationTheme.merge(bottomNavigationTheme),
      checkboxTheme: this.checkboxTheme.merge(checkboxTheme),
      dialogTheme: this.dialogTheme.merge(dialogTheme),
      dividerTheme: this.dividerTheme.merge(dividerTheme),
      focusTheme: this.focusTheme.merge(focusTheme),
      iconTheme: this.iconTheme.merge(iconTheme),
      infoBarTheme: this.infoBarTheme.merge(infoBarTheme),
      navigationPaneTheme: this.navigationPaneTheme.merge(navigationPaneTheme),
      radioButtonTheme: this.radioButtonTheme.merge(radioButtonTheme),
      scrollbarTheme: this.scrollbarTheme.merge(scrollbarTheme),
      sliderTheme: this.sliderTheme.merge(sliderTheme),
      toggleButtonTheme: this.toggleButtonTheme.merge(toggleButtonTheme),
      toggleSwitchTheme: this.toggleSwitchTheme.merge(toggleSwitchTheme),
      tooltipTheme: this.tooltipTheme.merge(tooltipTheme),
      resources: resources ?? this.resources,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('accentColor', accentColor))
      ..add(ColorProperty('activeColor', activeColor))
      ..add(ColorProperty('inactiveColor', inactiveColor))
      ..add(ColorProperty('inactiveBackgroundColor', inactiveBackgroundColor))
      ..add(ColorProperty('shadowColor', shadowColor))
      ..add(ColorProperty('scaffoldBackgroundColor', scaffoldBackgroundColor))
      ..add(ColorProperty('acrylicBackgroundColor', acrylicBackgroundColor))
      ..add(ColorProperty('micaBackgroundColor', micaBackgroundColor))
      ..add(ColorProperty('menuColor', menuColor))
      ..add(ColorProperty('cardColor', cardColor))
      ..add(ColorProperty('selectionColor', selectionColor))
      ..add(EnumProperty('brightness', brightness))
      ..add(DiagnosticsProperty<Duration>(
          'slowAnimationDuration', slowAnimationDuration))
      ..add(DiagnosticsProperty<Duration>(
          'mediumAnimationDuration', mediumAnimationDuration))
      ..add(DiagnosticsProperty<Duration>(
          'fastAnimationDuration', fastAnimationDuration))
      ..add(DiagnosticsProperty<Duration>(
          'fasterAnimationDuration', fasterAnimationDuration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve));
  }
}
