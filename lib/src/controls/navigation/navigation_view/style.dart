part of 'view.dart';

ButtonState<Color?> kDefaultTileColor(BuildContext context, bool isTop) {
  return ButtonState.resolveWith((states) {
    // By default, if it's top, do not show any color
    if (isTop) return Colors.transparent;
    return ButtonThemeData.uncheckedInputColor(
      FluentTheme.of(context),
      states,
    );
  });
}

/// An inherited widget that defines the configuration for
/// [NavigationPane]s in this widget's subtree.
///
/// Values specified here are used for [NavigationPane] properties that are not
/// given an explicit non-null value.
class NavigationPaneTheme extends InheritedTheme {
  /// Creates a navigation pane theme that controls the configurations for
  /// [NavigationPane].
  const NavigationPaneTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [NavigationPane] widgets.
  final NavigationPaneThemeData data;

  /// Creates a button theme that controls how descendant [NavigationPane]s
  /// should look like, and merges in the current slider theme, if any.
  static Widget merge({
    Key? key,
    required NavigationPaneThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return NavigationPaneTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static NavigationPaneThemeData _getInheritedThemeData(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<NavigationPaneTheme>();
    return theme?.data ?? FluentTheme.of(context).navigationPaneTheme;
  }

  /// Returns the [data] from the closest [NavigationPaneTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.navigationPaneTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationPaneThemeData theme = NavigationPaneTheme.of(context);
  /// ```
  static NavigationPaneThemeData of(BuildContext context) {
    return FluentTheme.of(context).navigationPaneTheme.merge(
          _getInheritedThemeData(context),
        );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationPaneTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationPaneTheme oldWidget) =>
      data != oldWidget.data;
}

/// The theme data used by [NavigationView]. The default theme
/// data used is [NavigationPaneThemeData.standard].
class NavigationPaneThemeData with Diagnosticable {
  /// The pane background color. If null, [ThemeData.micaBackgroundColor]
  /// is used.
  final Color? backgroundColor;

  /// The color of the tiles. If null, [ButtonThemeData.uncheckedInputColor]
  /// is used
  final ButtonState<Color?>? tileColor;

  /// The highlight color used on the tiles. If null, [ThemeData.accentColor]
  /// is used.
  final Color? highlightColor;

  final EdgeInsets? labelPadding;
  final EdgeInsets? iconPadding;

  final TextStyle? itemHeaderTextStyle;
  final ButtonState<TextStyle?>? selectedTextStyle;
  final ButtonState<TextStyle?>? unselectedTextStyle;
  final ButtonState<Color?>? selectedIconColor;
  final ButtonState<Color?>? unselectedIconColor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const NavigationPaneThemeData({
    this.backgroundColor,
    this.tileColor,
    this.highlightColor,
    this.labelPadding,
    this.iconPadding,
    this.itemHeaderTextStyle,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.animationDuration,
    this.animationCurve,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  factory NavigationPaneThemeData.standard({
    required Color disabledColor,
    required Duration animationDuration,
    required Curve animationCurve,
    required Color backgroundColor,
    required Color highlightColor,
    required Typography typography,
    required Color inactiveColor,
  }) {
    final disabledTextStyle = TextStyle(
      color: disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPaneThemeData(
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      backgroundColor: backgroundColor,
      highlightColor: highlightColor,
      itemHeaderTextStyle: typography.bodyStrong,
      selectedTextStyle: ButtonState.resolveWith((states) {
        return states.isDisabled ? disabledTextStyle : typography.body;
      }),
      unselectedTextStyle: ButtonState.resolveWith((states) {
        return states.isDisabled ? disabledTextStyle : typography.body!;
      }),
      labelPadding: const EdgeInsets.only(right: 10.0),
      iconPadding: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }

  static NavigationPaneThemeData lerp(
    NavigationPaneThemeData? a,
    NavigationPaneThemeData? b,
    double t,
  ) {
    return NavigationPaneThemeData(
      iconPadding: EdgeInsets.lerp(a?.iconPadding, b?.iconPadding, t),
      labelPadding: EdgeInsets.lerp(a?.labelPadding, b?.labelPadding, t),
      tileColor: ButtonState.lerp(a?.tileColor, b?.tileColor, t, Color.lerp),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      itemHeaderTextStyle:
          TextStyle.lerp(a?.itemHeaderTextStyle, b?.itemHeaderTextStyle, t),
      selectedTextStyle: ButtonState.lerp(
          a?.selectedTextStyle, b?.selectedTextStyle, t, TextStyle.lerp),
      unselectedTextStyle: ButtonState.lerp(
          a?.unselectedTextStyle, b?.unselectedTextStyle, t, TextStyle.lerp),
      highlightColor: Color.lerp(a?.highlightColor, b?.highlightColor, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(a?.animationDuration ?? Duration.zero,
          b?.animationDuration ?? Duration.zero, t),
      selectedIconColor: ButtonState.lerp(
          a?.selectedIconColor, b?.selectedIconColor, t, Color.lerp),
      unselectedIconColor: ButtonState.lerp(
          a?.unselectedIconColor, b?.unselectedIconColor, t, Color.lerp),
    );
  }

  NavigationPaneThemeData merge(NavigationPaneThemeData? style) {
    return NavigationPaneThemeData(
      iconPadding: style?.iconPadding ?? iconPadding,
      labelPadding: style?.labelPadding ?? labelPadding,
      tileColor: style?.tileColor ?? tileColor,
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      itemHeaderTextStyle: style?.itemHeaderTextStyle ?? itemHeaderTextStyle,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      highlightColor: style?.highlightColor ?? highlightColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      selectedIconColor: style?.selectedIconColor ?? selectedIconColor,
      unselectedIconColor: style?.unselectedIconColor ?? unselectedIconColor,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('tileColor', tileColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('highlightColor', highlightColor));
    properties.add(
        DiagnosticsProperty<EdgeInsetsGeometry>('labelPadding', labelPadding));
    properties.add(DiagnosticsProperty('iconPadding', iconPadding));
    properties.add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration));
    properties
        .add(DiagnosticsProperty<Curve>('animationCurve', animationCurve));
    properties.add(DiagnosticsProperty('selectedTextStyle', selectedTextStyle));
    properties
        .add(DiagnosticsProperty('unselectedTextStyle', unselectedTextStyle));
    properties.add(DiagnosticsProperty('selectedIconColor', selectedIconColor));
    properties
        .add(DiagnosticsProperty('unselectedIconColor', unselectedIconColor));
  }
}
