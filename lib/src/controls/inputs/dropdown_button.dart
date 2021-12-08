import 'package:fluent_ui/fluent_ui.dart';

const double _kDefaultPadding = 5.0;
const double _kVerticalOffset = 20.0;
const double _kContentWidth = 100.0;

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

  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final EdgeInsets? padding;
  final double? verticalOffset;
  final double? contentWidth;
  final List<DropDownButtonItem> items;
  final FlyoutController controller;
  final bool closeAfterClick;
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

  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback onTap;
}
