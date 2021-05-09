part of 'view.dart';

/// The theme data used by [NavigationView]
class NavigationPanelThemeData with Diagnosticable {
  final Color? backgroundColor;
  final ButtonState<Color?>? tileColor;
  final Color? highlightColor;

  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;

  final ButtonState<MouseCursor>? cursor;

  final TextStyle? itemHeaderTextStyle;
  final ButtonState<TextStyle>? selectedTextStyle;
  final ButtonState<TextStyle>? unselectedTextStyle;
  final ButtonState<Color>? selectedIconColor;
  final ButtonState<Color>? unselectedIconColor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const NavigationPanelThemeData({
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

  static NavigationPanelThemeData of(BuildContext context) {
    return NavigationPanelThemeData.standard(context.theme).copyWith(
      context.theme.navigationPanelTheme,
    );
  }

  factory NavigationPanelThemeData.standard(ThemeData style) {
    final disabledTextStyle = TextStyle(
      color: style.disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPanelThemeData(
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
      backgroundColor: AccentColor('normal', {
        'normal': Color.fromARGB(255, 230, 230, 230),
        'dark': Color.fromARGB(255, 25, 25, 25)
      }).resolveFromBrightness(style.brightness),
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

  NavigationPanelThemeData copyWith(NavigationPanelThemeData? style) {
    return NavigationPanelThemeData(
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
