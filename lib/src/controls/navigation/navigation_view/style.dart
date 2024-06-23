part of 'view.dart';

WidgetStateProperty<Color?> kDefaultPaneItemColor(
    BuildContext context, bool isTop) {
  assert(debugCheckHasFluentTheme(context));

  return WidgetStateProperty.resolveWith((states) {
    if (isTop) return Colors.transparent;
    final res = FluentTheme.of(context).resources;
    if (states.isPressed) {
      return res.subtleFillColorTertiary;
    } else if (states.isHovered) {
      return res.subtleFillColorSecondary;
    } else {
      return res.subtleFillColorTransparent;
    }
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
    super.key,
    required this.data,
    required super.child,
  });

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
  /// no ancestor, it returns [FluentThemeData.navigationPaneTheme]. Applications can assume
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
  /// The pane background color.
  final Color? backgroundColor;

  /// The pane background color when there is an overlay, such as minimal or
  /// compact display modes.
  final Color? overlayBackgroundColor;

  /// The color of the tiles.
  ///
  /// If null, [ButtonThemeData.uncheckedInputColor] is used
  final WidgetStateProperty<Color?>? tileColor;

  /// The highlight color used on the tiles.
  ///
  /// If null, [FluentThemeData.accentColor] is used.
  final Color? highlightColor;

  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? iconPadding;

  /// The padding applied to the header. This padding is not applied when
  /// display mode is top
  final EdgeInsetsGeometry? headerPadding;

  final TextStyle? itemHeaderTextStyle;
  final WidgetStateProperty<TextStyle?>? selectedTextStyle;
  final WidgetStateProperty<TextStyle?>? unselectedTextStyle;
  final WidgetStateProperty<TextStyle?>? selectedTopTextStyle;
  final WidgetStateProperty<TextStyle?>? unselectedTopTextStyle;
  final WidgetStateProperty<Color?>? selectedIconColor;
  final WidgetStateProperty<Color?>? unselectedIconColor;

  final IconData? paneNavigationButtonIcon;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const NavigationPaneThemeData({
    this.backgroundColor,
    this.overlayBackgroundColor,
    this.tileColor,
    this.highlightColor,
    this.labelPadding,
    this.iconPadding,
    this.headerPadding,
    this.itemHeaderTextStyle,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedTopTextStyle,
    this.unselectedTopTextStyle,
    this.animationDuration,
    this.animationCurve,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.paneNavigationButtonIcon,
  });

  /// The default navigation pane theme data.
  ///
  /// This is initialized on [FluentThemeData] with the required properties.
  factory NavigationPaneThemeData.fromResources({
    required ResourceDictionary resources,
    required Duration animationDuration,
    required Curve animationCurve,
    required Color highlightColor,
    required Typography typography,
  }) {
    return NavigationPaneThemeData(
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      backgroundColor: resources.solidBackgroundFillColorBase,
      overlayBackgroundColor: resources.systemFillColorSolidNeutralBackground,
      highlightColor: highlightColor,
      itemHeaderTextStyle: typography.bodyStrong,
      selectedTextStyle: WidgetStateProperty.resolveWith((states) {
        return typography.body?.copyWith(
          color: states.isPressed
              ? resources.textFillColorSecondary
              : states.isDisabled
                  ? resources.textFillColorDisabled
                  : resources.textFillColorPrimary,
        );
      }),
      unselectedTextStyle: WidgetStateProperty.resolveWith((states) {
        return typography.body?.copyWith(
          color: states.isPressed
              ? resources.textFillColorSecondary
              : states.isDisabled
                  ? resources.textFillColorDisabled
                  : resources.textFillColorPrimary,
        );
      }),
      selectedTopTextStyle: WidgetStateProperty.resolveWith((states) {
        return typography.body?.copyWith(
          color: states.isPressed
              ? resources.textFillColorTertiary
              : states.isHovered
                  ? resources.textFillColorSecondary
                  : resources.textFillColorPrimary,
        );
      }),
      unselectedTopTextStyle: WidgetStateProperty.resolveWith((states) {
        return typography.body?.copyWith(
          color: states.isPressed
              ? resources.textFillColorSecondary
              : states.isDisabled
                  ? resources.textFillColorDisabled
                  : resources.textFillColorPrimary,
        );
      }),
      labelPadding: const EdgeInsetsDirectional.only(end: 10.0),
      iconPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      headerPadding: const EdgeInsetsDirectional.only(top: 10.0),
      paneNavigationButtonIcon: FluentIcons.global_nav_button,
    );
  }

  static NavigationPaneThemeData lerp(
    NavigationPaneThemeData? a,
    NavigationPaneThemeData? b,
    double t,
  ) {
    return NavigationPaneThemeData(
      iconPadding: EdgeInsetsGeometry.lerp(a?.iconPadding, b?.iconPadding, t),
      labelPadding:
          EdgeInsetsGeometry.lerp(a?.labelPadding, b?.labelPadding, t),
      headerPadding:
          EdgeInsetsGeometry.lerp(a?.headerPadding, b?.headerPadding, t),
      tileColor: WidgetStateProperty.lerp<Color?>(
          a?.tileColor, b?.tileColor, t, Color.lerp),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      overlayBackgroundColor:
          Color.lerp(a?.overlayBackgroundColor, b?.overlayBackgroundColor, t),
      itemHeaderTextStyle:
          TextStyle.lerp(a?.itemHeaderTextStyle, b?.itemHeaderTextStyle, t),
      selectedTextStyle: WidgetStateProperty.lerp<TextStyle?>(
          a?.selectedTextStyle, b?.selectedTextStyle, t, TextStyle.lerp),
      unselectedTextStyle: WidgetStateProperty.lerp<TextStyle?>(
          a?.unselectedTextStyle, b?.unselectedTextStyle, t, TextStyle.lerp),
      selectedTopTextStyle: WidgetStateProperty.lerp<TextStyle?>(
          a?.selectedTextStyle, b?.selectedTextStyle, t, TextStyle.lerp),
      unselectedTopTextStyle: WidgetStateProperty.lerp<TextStyle?>(
          a?.unselectedTextStyle, b?.unselectedTextStyle, t, TextStyle.lerp),
      highlightColor: Color.lerp(a?.highlightColor, b?.highlightColor, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(a?.animationDuration ?? Duration.zero,
          b?.animationDuration ?? Duration.zero, t),
      selectedIconColor: WidgetStateProperty.lerp<Color?>(
          a?.selectedIconColor, b?.selectedIconColor, t, Color.lerp),
      unselectedIconColor: WidgetStateProperty.lerp<Color?>(
          a?.unselectedIconColor, b?.unselectedIconColor, t, Color.lerp),
      paneNavigationButtonIcon:
          t < 0.5 ? a?.paneNavigationButtonIcon : b?.paneNavigationButtonIcon,
    );
  }

  NavigationPaneThemeData merge(NavigationPaneThemeData? style) {
    return NavigationPaneThemeData(
      iconPadding: style?.iconPadding ?? iconPadding,
      labelPadding: style?.labelPadding ?? labelPadding,
      headerPadding: style?.headerPadding ?? headerPadding,
      tileColor: style?.tileColor ?? tileColor,
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      overlayBackgroundColor:
          style?.overlayBackgroundColor ?? overlayBackgroundColor,
      itemHeaderTextStyle: style?.itemHeaderTextStyle ?? itemHeaderTextStyle,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      selectedTopTextStyle: style?.selectedTopTextStyle ?? selectedTopTextStyle,
      unselectedTopTextStyle:
          style?.unselectedTopTextStyle ?? unselectedTopTextStyle,
      highlightColor: style?.highlightColor ?? highlightColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      selectedIconColor: style?.selectedIconColor ?? selectedIconColor,
      unselectedIconColor: style?.unselectedIconColor ?? unselectedIconColor,
      paneNavigationButtonIcon:
          style?.paneNavigationButtonIcon ?? paneNavigationButtonIcon,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('tileColor', tileColor))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('overlayBackgroundColor', overlayBackgroundColor))
      ..add(ColorProperty('highlightColor', highlightColor))
      ..add(
          DiagnosticsProperty<EdgeInsetsGeometry>('labelPadding', labelPadding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('iconPadding', iconPadding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>(
          'headerPadding', headerPadding))
      ..add(
          DiagnosticsProperty<Duration>('animationDuration', animationDuration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(DiagnosticsProperty('selectedTextStyle', selectedTextStyle))
      ..add(DiagnosticsProperty('unselectedTextStyle', unselectedTextStyle))
      ..add(DiagnosticsProperty('selectedTopTextStyle', selectedTextStyle))
      ..add(DiagnosticsProperty('unselectedTopTextStyle', unselectedTextStyle))
      ..add(DiagnosticsProperty('selectedIconColor', selectedIconColor))
      ..add(DiagnosticsProperty('unselectedIconColor', unselectedIconColor))
      ..add(IconDataProperty(
          'paneNavigationButtonIcon', paneNavigationButtonIcon));
  }
}
