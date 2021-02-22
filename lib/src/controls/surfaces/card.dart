import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  const Card({
    Key key,
    this.child,
    this.style,
  }) : super(key: key);

  final Widget child;
  final CardStyle style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.cardStyle.copyWith(this.style);
    return Container(
      margin: style.margin,
      decoration: BoxDecoration(
        boxShadow: elevationShadow(
          factor: style.elevation ?? 2,
          color: style.elevationColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: style.borderRadius,
        child: Container(
          padding: style.padding,
          decoration: BoxDecoration(
            border: _buildBorder(style),
            color: style.color,
          ),
          child: child,
        ),
      ),
    );
  }

  Border _buildBorder(CardStyle style) {
    final BorderSide Function(HighlightPosition) buildSide = (p) {
      if (style.highlightPosition == p)
        return BorderSide(
          color: style.highlightColor ?? Colors.blue,
          width: style.highlightSize ?? 1.8,
        );
      else
        return BorderSide.none;
    };
    return Border(
      bottom: buildSide(HighlightPosition.bottom),
      left: buildSide(HighlightPosition.left),
      top: buildSide(HighlightPosition.top),
      right: buildSide(HighlightPosition.right),
    );
  }
}

class CardStyle {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Color color;

  final double elevation;
  final Color elevationColor;

  final Color highlightColor;
  final HighlightPosition highlightPosition;
  final double highlightSize;

  const CardStyle({
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.elevationColor,
    this.highlightColor,
    this.highlightPosition,
    this.highlightSize,
  });

  static CardStyle defaultTheme([Brightness brightness]) {
    final def = CardStyle(
      borderRadius: BorderRadius.circular(2),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(12),
      elevation: 0,
      highlightPosition: HighlightPosition.top,
      highlightColor: Colors.blue,
      highlightSize: 1.8,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(CardStyle(
        elevationColor: lightElevationColor,
        color: Colors.white,
      ));
    else
      return def.copyWith(CardStyle(
        elevationColor: darkElevationColor,
        color: Colors.grey,
      ));
  }

  CardStyle copyWith(CardStyle style) {
    if (style == null) return this;
    return CardStyle(
      borderRadius: style?.borderRadius ?? borderRadius,
      padding: style?.padding ?? padding,
      margin: style?.margin ?? margin,
      color: style?.color ?? color,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
      highlightColor: style?.highlightColor ?? highlightColor,
      highlightPosition: style?.highlightPosition ?? highlightPosition,
      highlightSize: style?.highlightSize ?? highlightSize,
    );
  }
}

enum HighlightPosition { top, bottom, left, right }
