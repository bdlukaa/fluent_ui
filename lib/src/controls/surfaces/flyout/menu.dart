part of 'flyout.dart';

/// Menu flyouts are used in menu and context menu scenarios to display a list
/// of commands or options when requested by the user. A menu flyout shows a
/// single, inline, top-level menu that can have menu items and sub-menus.
///
/// ![MenuFlyout](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
///
/// See also:
///
///  * [Flyout]
///  * [FlyoutContent]
class MenuFlyout extends StatelessWidget {
  /// Creates a menu flyout.
  const MenuFlyout({
    Key? key,
    this.items = const [],
    this.color,
    this.shape,
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    this.constraints,
  }) : super(key: key);

  final List<MenuFlyoutItemInterface> items;

  /// The background color of the box.
  final Color? color;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// The shadow color.
  final Color shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  final double elevation;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  static const EdgeInsetsGeometry itemsPadding = EdgeInsets.symmetric(
    horizontal: 8.0,
  );

  @override
  Widget build(BuildContext context) {
    final hasLeading = () {
      try {
        items.whereType<MenuFlyoutItem>().firstWhere((i) => i.leading != null);
        return true;
      } catch (e) {
        return false;
      }
    }();
    return FlyoutContent(
      color: color,
      constraints: constraints,
      elevation: elevation,
      shadowColor: shadowColor,
      shape: shape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items.map<Widget>((item) {
          if (item is MenuFlyoutItem) item._useIconPlaceholder = hasLeading;
          return KeyedSubtree(
            key: item.key,
            child: item.build(context),
          );
        }).toList(),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}

abstract class MenuFlyoutItemInterface {
  final Key? key;

  const MenuFlyoutItemInterface({
    this.key,
  });

  Widget build(BuildContext context);
}

class MenuFlyoutItem extends MenuFlyoutItemInterface {
  MenuFlyoutItem({
    Key? key,
    this.leading,
    required this.text,
    this.trailing,
    required this.onPressed,
    this.selected = false,
  }) : super(key: key);

  final Widget? leading;
  final Widget text;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;

  bool _useIconPlaceholder = false;

  @override
  Widget build(BuildContext context) {
    final size = ContentSizeInfo.of(context).size;
    return Container(
      width: size.isEmpty ? null : size.width,
      padding: MenuFlyout.itemsPadding,
      child: FlyoutListTile(
        selected: selected,
        icon: leading ??
            () {
              if (_useIconPlaceholder) return const Icon(null);
              return null;
            }(),
        text: text,
        trailing: IconTheme.merge(
          data: const IconThemeData(size: 12.0),
          child: trailing ?? const SizedBox.shrink(),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class MenuFlyoutSeparator extends MenuFlyoutItemInterface {
  const MenuFlyoutSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = ContentSizeInfo.of(context).size;
    return SizedBox(
      width: size.width,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
      ),
    );
  }
}

class MenuFlyoutSubItem extends MenuFlyoutItem {
  MenuFlyoutSubItem({
    Key? key,
    Widget? leading,
    required Widget text,
    Widget? trailing = const Icon(FluentIcons.chevron_right),
    required this.items,
    this.openMode = FlyoutOpenMode.longHover,
  }) : super(
          key: key,
          leading: leading,
          text: text,
          trailing: trailing,
          onPressed: () {},
        );

  final List<MenuFlyoutItemInterface> items;

  final FlyoutOpenMode openMode;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Flyout(
        openMode: openMode,
        position: FlyoutPosition.side,
        placement: FlyoutPlacement.end,
        verticalOffset: 40.0,
        horizontalOffset: 0.0,
        content: (context) {
          return MenuFlyout(
            items: items,
          );
        },
        onOpen: () => setState(() => _open = true),
        onClose: () => setState(() => _open = false),
        child: MenuFlyoutItem(
          onPressed: () {},
          text: text,
          leading: leading,
          trailing: trailing,
          selected: _open,
        ).build(context),
      );
    });
  }
}
