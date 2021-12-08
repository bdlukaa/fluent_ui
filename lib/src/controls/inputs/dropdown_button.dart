import 'package:fluent_ui/fluent_ui.dart';

const double _kDefaultPadding = 5.0;
const double _kVerticalOffset = 20.0;
const double _kContentWidth = 100.0;

/// A button that can be opened for show sub-button.
/// This button is a shortcut to a specific Flyout.
///
/// See also:
///   * [Flyout](https://github.com/bdlukaa/fluent_ui#flyout)
class DropDownButton extends StatelessWidget {
  const DropDownButton({
    Key? key,
    required this.items,
    required this.controller,
    this.leading,
    this.title,
    this.trailing,
    this.padding,
    this.verticalOffset,
    this.contentWidth,
    this.closeAfterClick = true,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// Leading show a content at the left of this widget.
  final Widget? leading;

  /// Title show a content at the center of this widget.
  /// Generally it's a Text.
  final Widget? title;

  /// Trailing show a content at the right of this widget.
  /// If trailing is null, an Icon chevron_down is displayed.
  final Widget? trailing;

  /// When leading is not null, padding.right is applied on leading.
  /// When trailing is not null, padding.left is applied on trailing.
  /// padding.top and padding.bottom are not used.
  /// If padding is null, _kDefaultPadding is used.
  final EdgeInsets? padding;

  /// VerticalOffset define the space between the button and the flyout.
  /// By default it's value is _kVerticalOffset.
  final double? verticalOffset;

  /// ContentWidth define the width of the flyout.
  /// By default it's value is _kContentWidth.
  final double? contentWidth;

  /// Items define the list of buttons in the flyout.
  final List<DropDownButtonItem> items;

  /// A flyout controller for control when the button is opened or not.
  final FlyoutController controller;

  /// If closeAfterClick is true, after a click on an item, the flyout is
  /// automatically closed, otherwise not.
  final bool closeAfterClick;

  /// If value of disabled is true, the DropDownButton can't be clicked.
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
          padding: EdgeInsets.only(right: padding?.right ?? _kDefaultPadding),
          child: leading,
        ),
      if (title != null) title!,
      Padding(
        padding: EdgeInsets.only(left: padding?.left ?? _kDefaultPadding),
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
      verticalOffset: verticalOffset ?? _kVerticalOffset,
      contentWidth: contentWidth ?? _kContentWidth,
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
