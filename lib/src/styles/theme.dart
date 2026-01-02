import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Applies a Fluent Design theme to descendant widgets.
///
/// A [FluentTheme] widget provides color, typography, and other design tokens
/// that are used by Fluent UI widgets throughout your application.
///
/// To obtain the current theme, use [FluentTheme.of] to access the nearest
/// [FluentThemeData] in the widget tree:
///
/// ```dart
/// final theme = FluentTheme.of(context);
/// final accentColor = theme.accentColor;
/// ```
///
/// {@tool snippet}
/// This example shows how to apply a custom theme to a subtree:
///
/// ```dart
/// FluentTheme(
///   data: FluentThemeData(
///     accentColor: Colors.green,
///     brightness: Brightness.dark,
///   ),
///   child: MyWidget(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [FluentThemeData], which describes the actual theme configuration
///  * [AnimatedFluentTheme], which animates theme transitions
///  * [FluentApp], which applies a theme to the entire application
class FluentTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const FluentTheme({required this.data, required this.child, super.key});

  /// Specifies the color and typography values for descendant widgets.
  final FluentThemeData data;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Returns the [FluentThemeData] from the closest [FluentTheme] ancestor.
  ///
  /// If there is no ancestor, this will throw an error. Use [maybeOf] if
  /// the theme might not exist.
  ///
  /// Typical usage:
  ///
  /// ```dart
  /// final theme = FluentTheme.of(context);
  /// ```
  static FluentThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FluentTheme>()!.data;
  }

  /// Returns the [FluentThemeData] from the closest [FluentTheme] ancestor,
  /// or null if there is no ancestor.
  ///
  /// Use this when the theme might not exist in the widget tree.
  static FluentThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FluentTheme>()?.data;
  }

  @override
  Widget build(BuildContext context) {
    return _FluentTheme(
      data: data,
      child: IconTheme(
        data: data.iconTheme,
        child: DefaultTextStyle(style: data.typography.body!, child: child),
      ),
    );
  }
}

class _FluentTheme extends InheritedTheme {
  const _FluentTheme({required this.data, required super.child});

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
    required this.data,
    required this.child,
    super.key,
    super.curve,
    super.duration = kThemeAnimationDuration,
    super.onEnd,
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
    _data =
        visitor(
              _data,
              widget.data,
              (dynamic value) =>
                  FluentThemeDataTween(begin: value as FluentThemeData),
            )!
            as FluentThemeDataTween;
  }

  @override
  Widget build(BuildContext context) {
    return FluentTheme(data: _data!.evaluate(animation), child: widget.child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<FluentThemeDataTween>(
        'data',
        _data,
        showName: false,
        defaultValue: null,
      ),
    );
  }
}

/// The default animation curve used throughout the Fluent Design System.
///
/// This curve provides a smooth ease-in-out motion for animations.
const standardCurve = Curves.easeInOut;

/// Defines the configuration for a Fluent Design theme.
///
/// A [FluentThemeData] contains all the colors, typography, and component
/// theme data used to style Fluent UI widgets. It can be provided to a
/// [FluentTheme] or [FluentApp] to apply the theme throughout the widget tree.
///
/// {@tool snippet}
/// This example shows how to create a custom theme:
///
/// ```dart
/// FluentThemeData(
///   brightness: Brightness.light,
///   accentColor: Colors.orange,
///   typography: Typography.fromBrightness(brightness: Brightness.light),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows how to create a dark theme:
///
/// ```dart
/// FluentThemeData.dark().copyWith(
///   accentColor: Colors.teal,
/// )
/// ```
/// {@end-tool}
///
/// ## Theme customization
///
/// Use [copyWith] to create a modified copy of a theme, or pass individual
/// parameters to the factory constructor to override specific values.
///
/// ## Component themes
///
/// Each component type has an associated theme data class that can be
/// customized:
///
/// * [buttonTheme] - Styling for buttons
/// * [checkboxTheme] - Styling for checkboxes
/// * [toggleSwitchTheme] - Styling for toggle switches
/// * [navigationPaneTheme] - Styling for navigation pane
/// * And many more...
///
/// See also:
///
///  * [FluentTheme], which applies this theme data to a widget subtree
///  * [ResourceDictionary], which provides system-level color resources
///  * <https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/color>
@immutable
class FluentThemeData with Diagnosticable {
  /// The text styles for this theme.
  ///
  /// Use [typography] to access predefined text styles like [Typography.title],
  /// [Typography.body], [Typography.caption], etc.
  final Typography typography;

  /// Theme extensions that allow third-party packages to extend the theme.
  ///
  /// Use [extension] to retrieve a specific extension by type.
  final Map<Object, ThemeExtension<dynamic>> extensions;

  /// The primary accent color used throughout the application.
  ///
  /// This color is used for interactive elements like buttons, checkboxes,
  /// and focus indicators. It provides visual emphasis and brand identity.
  ///
  /// Defaults to [Colors.blue].
  final AccentColor accentColor;

  /// The color used for active/selected foreground elements.
  ///
  /// Typically used for text or icons on accent-colored backgrounds.
  final Color activeColor;

  /// The color used for inactive/unselected foreground elements.
  ///
  /// Used for default text color and other foreground elements.
  final Color inactiveColor;

  /// The background color for inactive/disabled elements.
  final Color inactiveBackgroundColor;

  /// The color used for shadows and elevation effects.
  final Color shadowColor;

  /// The background color for [ScaffoldPage] and similar scaffolding widgets.
  final Color scaffoldBackgroundColor;

  /// The default background color for [Acrylic] widgets.
  final Color acrylicBackgroundColor;

  /// The default background color for [Mica] widgets.
  final Color micaBackgroundColor;

  /// The background color for menus and flyouts.
  final Color menuColor;

  /// The background color for [Card] widgets.
  final Color cardColor;

  /// The color used for text selection highlights.
  final Color selectionColor;

  /// The duration for the fastest animations (83ms).
  ///
  /// Used for micro-interactions like button state changes.
  final Duration fasterAnimationDuration;

  /// The duration for fast animations (167ms).
  ///
  /// Used for quick transitions like opening small menus.
  final Duration fastAnimationDuration;

  /// The duration for medium animations (250ms).
  ///
  /// Used for standard transitions like page changes.
  final Duration mediumAnimationDuration;

  /// The duration for slow animations (358ms).
  ///
  /// Used for larger, more prominent transitions.
  final Duration slowAnimationDuration;

  /// The default curve for animations.
  ///
  /// Defaults to [standardCurve] (ease-in-out).
  final Curve animationCurve;

  /// Whether to animate the text cursor opacity with high fidelity.
  ///
  /// When true, the cursor opacity smoothly animates, but uses more CPU/GPU.
  /// Defaults to false (recommended for better performance).
  ///
  /// See also: [EditableText.cursorOpacityAnimates]
  final bool cursorOpacityAnimates;

  /// The overall brightness of this theme.
  ///
  /// Use [Brightness.light] for light themes and [Brightness.dark] for dark themes.
  final Brightness brightness;

  /// The visual density of UI components.
  ///
  /// Affects padding and sizing of interactive elements.
  final VisualDensity visualDensity;

  /// Theme data for [NavigationView] and [NavigationPane] widgets.
  final NavigationPaneThemeData navigationPaneTheme;

  /// Theme data for [Checkbox] widgets.
  final CheckboxThemeData checkboxTheme;

  /// Theme data for [ContentDialog] widgets.
  final ContentDialogThemeData dialogTheme;

  /// Theme data for [Divider] widgets.
  final DividerThemeData dividerTheme;

  /// Theme data for focus indicators.
  final FocusThemeData focusTheme;

  /// Theme data for icons.
  final IconThemeData iconTheme;

  /// Theme data for [InfoBar] widgets.
  final InfoBarThemeData infoBarTheme;

  /// Theme data for [RadioButton] widgets.
  final RadioButtonThemeData radioButtonTheme;

  /// Theme data for [Scrollbar] widgets.
  final ScrollbarThemeData scrollbarTheme;

  /// Theme data for [Slider] widgets.
  final SliderThemeData sliderTheme;

  /// Theme data for [ToggleButton] widgets.
  final ToggleButtonThemeData toggleButtonTheme;

  /// Theme data for [ToggleSwitch] widgets.
  final ToggleSwitchThemeData toggleSwitchTheme;

  /// Theme data for [Tooltip] widgets.
  final TooltipThemeData tooltipTheme;

  /// Theme data for button widgets.
  final ButtonThemeData buttonTheme;

  /// The system-level color resources.
  ///
  /// These colors match the Windows system color palette and are used
  /// throughout the theme for consistent styling.
  final ResourceDictionary resources;

  /// Creates a new instance of [FluentThemeData].
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
    bool? cursorOpacityAnimates,
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
    cursorOpacityAnimates ??= false;
    accentColor ??= Colors.blue;
    activeColor ??= Colors.white;
    inactiveColor ??= isLight ? Colors.black : Colors.white;
    inactiveBackgroundColor ??= isLight
        ? const Color(0xFFd6d6d6)
        : const Color(0xFF292929);
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
        ? const IconThemeData(color: Colors.black, size: 18)
        : const IconThemeData(color: Colors.white, size: 18);
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

    return FluentThemeData.raw(
      brightness: brightness,
      extensions: _themeExtensionIterableToMap(extensions),
      visualDensity: visualDensity,
      fasterAnimationDuration: fasterAnimationDuration,
      fastAnimationDuration: fastAnimationDuration,
      mediumAnimationDuration: mediumAnimationDuration,
      slowAnimationDuration: slowAnimationDuration,
      animationCurve: animationCurve,
      cursorOpacityAnimates: cursorOpacityAnimates,
      accentColor: accentColor,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      inactiveBackgroundColor: inactiveBackgroundColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      acrylicBackgroundColor: acrylicBackgroundColor,
      micaBackgroundColor: micaBackgroundColor,
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

  /// Creates a new instance of [FluentThemeData].
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
    required this.cursorOpacityAnimates,
    required this.brightness,
    required this.visualDensity,
    required this.scaffoldBackgroundColor,
    required this.acrylicBackgroundColor,
    required this.micaBackgroundColor,
    required this.buttonTheme,
    required this.checkboxTheme,
    required this.toggleSwitchTheme,
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

  /// Creates a default light theme.
  ///
  /// This is a convenience method equivalent to:
  ///
  /// ```dart
  /// FluentThemeData(brightness: Brightness.light)
  /// ```
  static FluentThemeData light() {
    return FluentThemeData(brightness: Brightness.light);
  }

  /// Creates a default dark theme.
  ///
  /// This is a convenience method equivalent to:
  ///
  /// ```dart
  /// FluentThemeData(brightness: Brightness.dark)
  /// ```
  static FluentThemeData dark() {
    return FluentThemeData(brightness: Brightness.dark);
  }

  /// Linearly interpolates between two [FluentThemeData] objects.
  ///
  /// The [t] argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning [a], and 1.0 meaning
  /// that the interpolation has finished, returning [b].
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
      inactiveBackgroundColor: Color.lerp(
        a.inactiveBackgroundColor,
        b.inactiveBackgroundColor,
        t,
      )!,
      scaffoldBackgroundColor: Color.lerp(
        a.scaffoldBackgroundColor,
        b.scaffoldBackgroundColor,
        t,
      )!,
      acrylicBackgroundColor: Color.lerp(
        a.acrylicBackgroundColor,
        b.acrylicBackgroundColor,
        t,
      )!,
      micaBackgroundColor: Color.lerp(
        a.micaBackgroundColor,
        b.micaBackgroundColor,
        t,
      )!,
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
      cardColor: Color.lerp(a.cardColor, b.cardColor, t)!,
      fasterAnimationDuration: lerpDuration(
        a.fasterAnimationDuration,
        b.fasterAnimationDuration,
        t,
      ),
      fastAnimationDuration: lerpDuration(
        a.fastAnimationDuration,
        b.fastAnimationDuration,
        t,
      ),
      mediumAnimationDuration: lerpDuration(
        a.mediumAnimationDuration,
        b.mediumAnimationDuration,
        t,
      ),
      slowAnimationDuration: lerpDuration(
        a.slowAnimationDuration,
        b.slowAnimationDuration,
        t,
      ),
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
      cursorOpacityAnimates: t < 0.5
          ? a.cursorOpacityAnimates
          : b.cursorOpacityAnimates,
      buttonTheme: ButtonThemeData.lerp(a.buttonTheme, b.buttonTheme, t),
      checkboxTheme: CheckboxThemeData.lerp(
        a.checkboxTheme,
        b.checkboxTheme,
        t,
      ),
      toggleSwitchTheme: ToggleSwitchThemeData.lerp(
        a.toggleSwitchTheme,
        b.toggleSwitchTheme,
        t,
      ),
      iconTheme: IconThemeData.lerp(a.iconTheme, b.iconTheme, t),
      dialogTheme: ContentDialogThemeData.lerp(a.dialogTheme, b.dialogTheme, t),
      tooltipTheme: TooltipThemeData.lerp(a.tooltipTheme, b.tooltipTheme, t),
      dividerTheme: DividerThemeData.lerp(a.dividerTheme, b.dividerTheme, t),
      navigationPaneTheme: NavigationPaneThemeData.lerp(
        a.navigationPaneTheme,
        b.navigationPaneTheme,
        t,
      ),
      radioButtonTheme: RadioButtonThemeData.lerp(
        a.radioButtonTheme,
        b.radioButtonTheme,
        t,
      ),
      toggleButtonTheme: ToggleButtonThemeData.lerp(
        a.toggleButtonTheme,
        b.toggleButtonTheme,
        t,
      ),
      sliderTheme: SliderThemeData.lerp(a.sliderTheme, b.sliderTheme, t),
      infoBarTheme: InfoBarThemeData.lerp(a.infoBarTheme, b.infoBarTheme, t),
      focusTheme: FocusThemeData.lerp(a.focusTheme, b.focusTheme, t),
      scrollbarTheme: ScrollbarThemeData.lerp(
        a.scrollbarTheme,
        b.scrollbarTheme,
        t,
      ),
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
    Iterable<ThemeExtension<dynamic>> extensionsIterable,
  ) {
    return Map<Object, ThemeExtension<dynamic>>.unmodifiable(
      <Object, ThemeExtension<dynamic>>{
        // Strangely, the cast is necessary for tests to run.
        for (final ThemeExtension<dynamic> extension in extensionsIterable)
          extension.type: extension as ThemeExtension<ThemeExtension<dynamic>>,
      },
    );
  }

  /// Creates a copy of this [FluentThemeData] with the given fields replaced
  /// with new values.
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
    bool? cursorOpacityAnimates,
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
      cursorOpacityAnimates:
          cursorOpacityAnimates ?? this.cursorOpacityAnimates,
      buttonTheme: this.buttonTheme.merge(buttonTheme),
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
      ..add(
        DiagnosticsProperty<Duration>(
          'slowAnimationDuration',
          slowAnimationDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'mediumAnimationDuration',
          mediumAnimationDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'fastAnimationDuration',
          fastAnimationDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'fasterAnimationDuration',
          fasterAnimationDuration,
        ),
      )
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(
        DiagnosticsProperty<bool>(
          'cursorOpacityAnimates',
          cursorOpacityAnimates,
        ),
      );
  }
}
