part of 'view.dart';

/// The default color for a pane item.
WidgetStateProperty<Color?> kDefaultPaneItemColor(
  BuildContext context,
  bool isTop,
) {
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
  /// Creates a theme that controls how descendant [NavigationPane]s should
  /// look like.
  const NavigationPaneTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The properties for descendant [NavigationPane] widgets.
  final NavigationPaneThemeData data;

  /// Creates a theme that merges the nearest [NavigationPaneTheme] with [data].
  static Widget merge({
    required NavigationPaneThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return NavigationPaneTheme(
          key: key,
          data: NavigationPaneTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [NavigationPaneThemeData] which encloses the given
  /// context.
  ///
  /// Resolution order:
  /// 1. Global theme from [FluentThemeData.navigationPaneTheme]
  /// 2. Local [NavigationPaneTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationPaneThemeData theme = NavigationPaneTheme.of(context);
  /// ```
  static NavigationPaneThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<NavigationPaneTheme>();
    return theme.navigationPaneTheme.merge(inheritedTheme?.data);
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

  /// The padding applied to the label.
  final EdgeInsetsGeometry? labelPadding;

  /// The padding applied to the icon.
  final EdgeInsetsGeometry? iconPadding;

  /// The padding applied to the header. This padding is not applied when
  /// display mode is top
  final EdgeInsetsGeometry? headerPadding;

  /// The text style applied to the item header.
  final TextStyle? itemHeaderTextStyle;

  /// The text style applied to the selected item.
  final WidgetStateProperty<TextStyle?>? selectedTextStyle;

  /// The text style applied to the unselected item.
  final WidgetStateProperty<TextStyle?>? unselectedTextStyle;

  /// The text style applied to the selected top item.
  final WidgetStateProperty<TextStyle?>? selectedTopTextStyle;

  /// The text style applied to the unselected top item.
  final WidgetStateProperty<TextStyle?>? unselectedTopTextStyle;

  /// The color applied to the selected icon.
  final WidgetStateProperty<Color?>? selectedIconColor;

  /// The color applied to the unselected icon.
  final WidgetStateProperty<Color?>? unselectedIconColor;

  /// The icon used for the pane navigation button.
  final IconData? paneNavigationButtonIcon;

  /// The duration of the animation.
  final Duration? animationDuration;

  /// The curve of the animation.
  final Curve? animationCurve;

  /// Creates a navigation pane theme data.
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
      itemHeaderTextStyle: typography.bodyStrong?.copyWith(
        color: resources.textFillColorSecondary,
      ),
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
      labelPadding: const EdgeInsetsDirectional.only(end: 10),
      iconPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      headerPadding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      paneNavigationButtonIcon: FluentIcons.global_nav_button,
    );
  }

  /// Lerps the navigation pane theme data.
  ///
  /// {@macro fluent_ui.lerp.t}
  static NavigationPaneThemeData lerp(
    NavigationPaneThemeData? a,
    NavigationPaneThemeData? b,
    double t,
  ) {
    return NavigationPaneThemeData(
      iconPadding: EdgeInsetsGeometry.lerp(a?.iconPadding, b?.iconPadding, t),
      labelPadding: EdgeInsetsGeometry.lerp(
        a?.labelPadding,
        b?.labelPadding,
        t,
      ),
      headerPadding: EdgeInsetsGeometry.lerp(
        a?.headerPadding,
        b?.headerPadding,
        t,
      ),
      tileColor: lerpWidgetStateProperty<Color?>(
        a?.tileColor,
        b?.tileColor,
        t,
        Color.lerp,
      ),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      overlayBackgroundColor: Color.lerp(
        a?.overlayBackgroundColor,
        b?.overlayBackgroundColor,
        t,
      ),
      itemHeaderTextStyle: TextStyle.lerp(
        a?.itemHeaderTextStyle,
        b?.itemHeaderTextStyle,
        t,
      ),
      selectedTextStyle: lerpWidgetStateProperty<TextStyle?>(
        a?.selectedTextStyle,
        b?.selectedTextStyle,
        t,
        TextStyle.lerp,
      ),
      unselectedTextStyle: lerpWidgetStateProperty<TextStyle?>(
        a?.unselectedTextStyle,
        b?.unselectedTextStyle,
        t,
        TextStyle.lerp,
      ),
      selectedTopTextStyle: lerpWidgetStateProperty<TextStyle?>(
        a?.selectedTextStyle,
        b?.selectedTextStyle,
        t,
        TextStyle.lerp,
      ),
      unselectedTopTextStyle: lerpWidgetStateProperty<TextStyle?>(
        a?.unselectedTextStyle,
        b?.unselectedTextStyle,
        t,
        TextStyle.lerp,
      ),
      highlightColor: Color.lerp(a?.highlightColor, b?.highlightColor, t),
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationDuration: lerpDuration(
        a?.animationDuration ?? Duration.zero,
        b?.animationDuration ?? Duration.zero,
        t,
      ),
      selectedIconColor: lerpWidgetStateProperty<Color?>(
        a?.selectedIconColor,
        b?.selectedIconColor,
        t,
        Color.lerp,
      ),
      unselectedIconColor: lerpWidgetStateProperty<Color?>(
        a?.unselectedIconColor,
        b?.unselectedIconColor,
        t,
        Color.lerp,
      ),
      paneNavigationButtonIcon: t < 0.5
          ? a?.paneNavigationButtonIcon
          : b?.paneNavigationButtonIcon,
    );
  }

  /// Merges the navigation pane theme data with another.
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
        DiagnosticsProperty<EdgeInsetsGeometry>('labelPadding', labelPadding),
      )
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('iconPadding', iconPadding))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>('headerPadding', headerPadding),
      )
      ..add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration),
      )
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(DiagnosticsProperty('selectedTextStyle', selectedTextStyle))
      ..add(DiagnosticsProperty('unselectedTextStyle', unselectedTextStyle))
      ..add(DiagnosticsProperty('selectedTopTextStyle', selectedTextStyle))
      ..add(DiagnosticsProperty('unselectedTopTextStyle', unselectedTextStyle))
      ..add(DiagnosticsProperty('selectedIconColor', selectedIconColor))
      ..add(DiagnosticsProperty('unselectedIconColor', unselectedIconColor))
      ..add(
        IconDataProperty('paneNavigationButtonIcon', paneNavigationButtonIcon),
      );
  }
}
