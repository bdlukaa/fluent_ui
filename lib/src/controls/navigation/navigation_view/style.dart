part of 'view.dart';

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
    return NavigationPaneThemeData.standard(FluentTheme.of(context)).merge(
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
  /// The pane background color. If null, [ThemeData.acrylicBackgroundColor]
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

  /// The cursor used by the tiles. [ThemeData.inputMouseCursor] is used by default
  final ButtonState<MouseCursor>? cursor;

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
    this.cursor,
    this.itemHeaderTextStyle,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.animationDuration,
    this.animationCurve,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  factory NavigationPaneThemeData.standard(ThemeData style) {
    final disabledTextStyle = TextStyle(
      color: style.disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPaneThemeData(
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
      backgroundColor: style.acrylicBackgroundColor,
      tileColor: ButtonState.resolveWith((states) {
        return ButtonThemeData.uncheckedInputColor(style, states);
      }),
      highlightColor: style.accentColor,
      itemHeaderTextStyle: style.typography.base,
      selectedTextStyle: ButtonState.resolveWith((states) {
        return states.isDisabled
            ? disabledTextStyle
            : style.typography.body!.copyWith(color: style.accentColor);
      }),
      unselectedTextStyle: ButtonState.resolveWith((states) {
        return states.isDisabled ? disabledTextStyle : style.typography.body!;
      }),
      cursor: style.inputMouseCursor,
      labelPadding: EdgeInsets.only(right: 10.0),
      iconPadding: EdgeInsets.symmetric(horizontal: 12.0),
      selectedIconColor: ButtonState.all(style.accentColor),
      unselectedIconColor: ButtonState.all(style.inactiveColor),
    );
  }

  static NavigationPaneThemeData lerp(
    NavigationPaneThemeData? a,
    NavigationPaneThemeData? b,
    double t,
  ) {
    return NavigationPaneThemeData(
      cursor: t < 0.5 ? a?.cursor : b?.cursor,
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
      cursor: style?.cursor ?? cursor,
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
    properties.add(ObjectFlagProperty.has('tileColor', tileColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('highlightColor', highlightColor));
    properties.add(ObjectFlagProperty.has('cursor', cursor));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
      'labelPadding',
      labelPadding,
    ));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
      'iconPadding',
      iconPadding,
    ));
    properties.add(DiagnosticsProperty<Duration>(
      'animationDuration',
      animationDuration,
    ));
    properties.add(DiagnosticsProperty<Curve>(
      'animationCurve',
      animationCurve,
    ));
    properties.add(ObjectFlagProperty.has(
      'selectedTextStyle',
      selectedTextStyle,
    ));
    properties.add(ObjectFlagProperty.has(
      'unselectedTextStyle',
      unselectedTextStyle,
    ));
    properties.add(ObjectFlagProperty.has(
      'selectedIconColor',
      selectedIconColor,
    ));
    properties.add(ObjectFlagProperty.has(
      'unselectedIconColor',
      unselectedIconColor,
    ));
  }
}
