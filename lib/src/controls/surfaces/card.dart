import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  const Card({
    Key key,
    this.child,
    this.style,
  }) : super(key: key);

  final Widget child;
  final CardThemeData style;

  @override
  Widget build(BuildContext context) {
    final style = CardTheme.of(context).copyWith(this.style);
    return Container(
      child: child,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          top: BorderSide(
            color: Colors.black,
          ),
        )
      ),
    );
  }
}

class CardThemeData {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Color color;

  final int elevation;
  final Color elevationColor;

  CardThemeData({
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.elevationColor,
  });

  static CardThemeData defaultTheme(Brightness brightness) {
    final def = CardThemeData(
      borderRadius: BorderRadius.circular(4),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12),
      elevation: 8,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(CardThemeData(
        elevationColor: Colors.black.withOpacity(0.1),
        color: Colors.white,
      ));
    else
      return def.copyWith(CardThemeData(
        elevationColor: Colors.white.withOpacity(0.1),
        color: Colors.grey,
      ));
  }

  CardThemeData copyWith(CardThemeData style) {
    if (style != null) return this;
    return CardThemeData(
      borderRadius: style?.borderRadius ?? borderRadius,
      padding: style?.padding ?? padding,
      margin: style?.margin ?? margin,
      color: style?.color ?? color,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
    );
  }
}


class CardTheme extends InheritedTheme {
  /// Creates a tooltip theme that controls the configurations for
  /// [Tooltip].
  ///
  /// The data argument must not be null.
  const CardTheme({
    Key key,
    @required this.data,
    Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The properties for descendant [Tooltip] widgets.
  final CardThemeData data;

  /// Returns the [data] from the closest [CardTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.CardTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// CardThemeData theme = CardTheme.of(context);
  /// ```
  static CardThemeData of(BuildContext context) {
    final CardTheme theme =
        context.dependOnInheritedWidgetOfExactType<CardTheme>();
    return theme?.data ?? CardThemeData();
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final CardTheme ancestorTheme =
        context.findAncestorWidgetOfExactType<CardTheme>();
    return identical(this, ancestorTheme)
        ? child
        : CardTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CardTheme oldWidget) => data != oldWidget.data;
}
