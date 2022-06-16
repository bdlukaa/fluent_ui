import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  /// Creates a card
  const Card({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.margin,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  }) : super(key: key);

  /// The card content
  final Widget child;

  /// The padding around [child]
  final EdgeInsets padding;

  /// The margin around [child]
  final EdgeInsets? margin;

  /// The card's background color.
  ///
  /// If null, [ThemeData.cardColor] is used
  final Color? backgroundColor;

  /// The rounded corners of this card
  ///
  /// A circular border with a 4.0 radius is used by default
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    final theme = FluentTheme.of(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
