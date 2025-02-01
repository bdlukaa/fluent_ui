import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  /// Creates a card
  const Card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  /// The card content
  final Widget child;

  /// The padding around [child]
  final EdgeInsetsGeometry padding;

  /// The margin around [child]
  final EdgeInsetsGeometry? margin;

  /// The card's background color.
  ///
  /// If null, [FluentThemeData.cardColor] is used
  final Color? backgroundColor;

  /// The card's border color.
  ///
  /// If null, [ResourceDictionary.cardStrokeColorDefault] is used
  final Color? borderColor;

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
          color: borderColor ?? theme.resources.cardStrokeColorDefault,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
