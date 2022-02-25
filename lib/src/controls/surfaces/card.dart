import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  const Card({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6.0)),
  }) : super(key: key);

  /// The card content
  final Widget child;

  /// The padding around content
  final EdgeInsets padding;

  /// The background color.
  ///
  /// If null, [ThemeData.cardColor] is used
  final Color? backgroundColor;

  /// The z-coordinate relative to the parent at which to place this card
  ///
  /// The valus is non-negative
  final double elevation;

  /// The rounded corners of this card
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    return PhysicalModel(
      elevation: elevation,
      color: Colors.transparent,
      borderRadius: borderRadius.resolve(Directionality.of(context)),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: borderRadius,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
