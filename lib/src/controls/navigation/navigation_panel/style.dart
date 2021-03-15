part of 'navigation_panel.dart';

class NavigationPanelStyle {
  final ButtonState<Color?>? color;
  final Color? highlightColor;

  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;

  final ButtonState<MouseCursor>? cursor;

  final ButtonState<TextStyle>? selectedTextStyle;
  final ButtonState<TextStyle>? unselectedTextStyle;
  final ButtonState<Color?>? selectedIconColor;
  final ButtonState<Color?>? unselectedIconColor;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const NavigationPanelStyle({
    this.color,
    this.highlightColor,
    this.labelPadding,
    this.iconPadding,
    this.cursor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.animationDuration,
    this.animationCurve,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  static NavigationPanelStyle defaultTheme(Style style) {
    final disabledTextStyle = TextStyle(
      color: style.disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPanelStyle(
      animationDuration: style.mediumAnimationDuration,
      animationCurve: style.animationCurve,
      color: (state) => uncheckedInputColor(style, state),
      highlightColor: style.accentColor,
      selectedTextStyle: (state) => state.isDisabled
          ? disabledTextStyle
          : style.typography!.base!.copyWith(color: style.accentColor),
      unselectedTextStyle: (state) =>
          state.isDisabled ? disabledTextStyle : style.typography!.base!,
      cursor: buttonCursor,
      labelPadding: EdgeInsets.zero,
      iconPadding: EdgeInsets.only(right: 10, left: 8),
      selectedIconColor: (_) => style.accentColor!,
      unselectedIconColor: (_) => null,
    );
  }

  NavigationPanelStyle copyWith(NavigationPanelStyle? style) {
    return NavigationPanelStyle(
      cursor: style?.cursor ?? cursor,
      iconPadding: style?.iconPadding ?? iconPadding,
      labelPadding: style?.labelPadding ?? labelPadding,
      color: style?.color ?? color,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      highlightColor: style?.highlightColor ?? highlightColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      selectedIconColor: style?.selectedIconColor ?? selectedIconColor,
      unselectedIconColor: style?.unselectedIconColor ?? unselectedIconColor,
    );
  }
}
