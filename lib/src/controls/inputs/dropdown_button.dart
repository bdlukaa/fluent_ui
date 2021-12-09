import 'package:fluent_ui/fluent_ui.dart';

const EdgeInsets _kDefaultPadding = EdgeInsets.all(5.0);
const double _kVerticalOffset = 20.0;
const double _kContentWidth = 100.0;

/// A button that can be opened for show sub-button.
/// This button is a shortcut to a specific Flyout.
///
/// See also:
///   * [Flyout], a light dismiss container that can show arbitrary UI as its content
///   * [ComboBox], a list of items that a user can select from
class DropDownButton extends StatelessWidget {
  const DropDownButton({
    Key? key,
    required this.items,
    required this.controller,
    this.leading,
    this.title,
    this.trailing,
    this.padding = _kDefaultPadding,
    this.verticalOffset = _kVerticalOffset,
    this.contentWidth = _kContentWidth,
    this.closeAfterClick = true,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  })  : assert(items.length > 0, 'You must provide at least one item'),
        super(key: key);

  /// Leading show a content at the left of this widget.
  final Widget? leading;

  /// Title show a content at the center of this widget.
  ///
  /// Usually a [Text]
  final Widget? title;

  /// Trailing show a content at the right of this widget.
  /// If trailing is null, an Icon chevron_down is displayed.
  final Widget? trailing;

  /// Applied horizontally to the widgets, adding a space between leading,
  /// title and trailing.
  ///
  /// When leading is not null, padding.right is applied on leading.
  /// When trailing is not null, padding.left is applied on trailing.
  /// padding.top and padding.bottom are not used.
  ///
  /// If null, [_kDefaultPadding] is used.
  final EdgeInsets padding;

  /// The space between the button and the flyout.
  ///
  /// [_kVerticalOffset] is used by default
  final double verticalOffset;

  /// The width of the flyout.
  ///
  /// [_kContentWidth] is used by default.
  final double contentWidth;

  /// The items in the flyout. Must not be empty
  final List<DropDownButtonItem> items;

  /// Controls whether the button is opened or not.
  final FlyoutController controller;

  /// If `true`, the flyout is closed after an item is tapped
  final bool closeAfterClick;

  /// If `true`, the button won't be clickable.
  final bool disabled;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    final buttonChildren = <Widget>[
      if (leading != null)
        Padding(
          padding: EdgeInsets.only(right: padding.right),
          child: leading,
        ),
      if (title != null) title!,
      Padding(
        padding: EdgeInsets.only(left: padding.left),
        child: trailing ?? const Icon(FluentIcons.chevron_down, size: 12),
      ),
    ];

    return Flyout(
      content: Padding(
        padding: const EdgeInsets.only(left: 27),
        child: FlyoutContent(
          padding: EdgeInsets.zero,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (c, i) => TappableListTile(
              leading: items[i].leading,
              title: items[i].title,
              onTap: () {
                if (closeAfterClick) {
                  controller.open = false;
                }
                items[i].onTap();
              },
              trailing: items[i].trailing,
            ),
          ),
        ),
      ),
      verticalOffset: verticalOffset,
      contentWidth: contentWidth,
      controller: controller,
      child: Button(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buttonChildren,
        ),
        onPressed: disabled ? null : () => controller.open = true,
        autofocus: autofocus,
        focusNode: focusNode,
      ),
    );
  }
}

/// An item for DropDownButton.
/// This item is transformed as a button.
class DropDownButtonItem {
  const DropDownButtonItem({
    required this.onTap,
    this.leading,
    this.title,
    this.trailing,
  }) : assert(
          leading != null || title != null || trailing != null,
          'You must provide at least one property: leading, title or trailing',
        );

  /// Show a content at the left of this button.
  final Widget? leading;

  /// Show a content at the center of this button.
  final Widget? title;

  /// Show a content at the right of this widget.
  final Widget? trailing;

  /// When the button is clicked, onTap is executed.
  final VoidCallback onTap;
}
