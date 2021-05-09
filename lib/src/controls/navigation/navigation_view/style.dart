part of 'view.dart';

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

  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;

  /// The cursor used by the tiles. [ThemeData.inputMouseCursor] is used by default
  final ButtonState<MouseCursor>? cursor;

  final TextStyle? itemHeaderTextStyle;
  final ButtonState<TextStyle>? selectedTextStyle;
  final ButtonState<TextStyle>? unselectedTextStyle;
  final ButtonState<Color>? selectedIconColor;
  final ButtonState<Color>? unselectedIconColor;

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

  static NavigationPaneThemeData of(BuildContext context) {
    return NavigationPaneThemeData.standard(context.theme).copyWith(
      context.theme.navigationPaneTheme,
    );
  }

  factory NavigationPaneThemeData.standard(ThemeData style) {
    final disabledTextStyle = TextStyle(
      color: style.disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPaneThemeData(
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
      backgroundColor: style.acrylicBackgroundColor,
      tileColor: (state) => ButtonThemeData.uncheckedInputColor(style, state),
      highlightColor: style.accentColor,
      itemHeaderTextStyle: style.typography.base,
      selectedTextStyle: (state) => state.isDisabled
          ? disabledTextStyle
          : style.typography.body!.copyWith(color: style.accentColor),
      unselectedTextStyle: (state) =>
          state.isDisabled ? disabledTextStyle : style.typography.body!,
      cursor: style.inputMouseCursor,
      labelPadding: EdgeInsets.zero,
      iconPadding: EdgeInsets.only(right: 10, left: 8),
      selectedIconColor: (_) => style.accentColor,
      unselectedIconColor: (_) => style.inactiveColor,
    );
  }

  NavigationPaneThemeData copyWith(NavigationPaneThemeData? style) {
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
