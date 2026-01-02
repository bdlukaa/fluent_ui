import 'package:fluent_ui/fluent_ui.dart';

/// A card is a container that slightly separates its content from the
/// surrounding UI, giving it a subtle but distinct appearance.
///
/// Cards are commonly used to group related pieces of information. They provide
/// a consistent structure, background, and border that help organize content
/// and make it easier to scan.
///
/// {@tool snippet}
/// This example shows a basic card with some text content:
///
/// ```dart
/// Card(
///   child: Column(
///     children: [
///       Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
///       SizedBox(height: 8),
///       Text('This is the card content.'),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a card with custom styling:
///
/// ```dart
/// Card(
///   backgroundColor: Colors.blue.lightest,
///   borderColor: Colors.blue,
///   borderRadius: BorderRadius.circular(8.0),
///   padding: EdgeInsetsDirectional.all(16.0),
///   child: Text('Custom styled card'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Expander], a control that displays a header with a collapsible body
///  * [InfoBar], a control that displays app-wide status messages
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/>
class Card extends StatelessWidget {
  /// Creates a fluent-styled card.
  const Card({
    required this.child,
    super.key,
    this.padding = const EdgeInsetsDirectional.all(12),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The amount of space by which to inset the [child].
  ///
  /// Defaults to `EdgeInsetsDirectional.all(12.0)`.
  ///
  /// The padding is applied inside the card's border.
  final EdgeInsetsGeometry padding;

  /// Empty space to surround the card.
  ///
  /// Defaults to `null` (no margin).
  ///
  /// This is useful when arranging multiple cards in a [Column] or [ListView]
  /// to provide consistent spacing between cards.
  final EdgeInsetsGeometry? margin;

  /// The card's background color.
  ///
  /// If null, defaults to [FluentThemeData.cardColor].
  ///
  /// The background color fills the entire card, including the area inside
  /// the border but outside the padding.
  final Color? backgroundColor;

  /// The color of the card's border.
  ///
  /// If null, defaults to [ResourceDictionary.cardStrokeColorDefault].
  ///
  /// To remove the border entirely, you can use [Colors.transparent].
  final Color? borderColor;

  /// The border radius of the card's corners.
  ///
  /// Defaults to `BorderRadius.all(Radius.circular(4.0))`.
  ///
  /// Use [BorderRadius.circular] for uniform corners, or specify different
  /// radii for each corner using [BorderRadius.only].
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
