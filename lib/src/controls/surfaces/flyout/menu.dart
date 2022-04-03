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
    required this.onPressed,
  }) : super(key: key);

  final Widget? leading;
  final Widget text;
  final VoidCallback? onPressed;

  bool _useIconPlaceholder = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MenuFlyout.itemsPadding,
      child: FlyoutListTile(
        icon: leading ??
            () {
              if (_useIconPlaceholder) return const Icon(null);
              return null;
            }(),
        text: text,
        onPressed: onPressed,
      ),
    );
  }
}

class MenuFlyoutSeparator extends MenuFlyoutItemInterface {
  const MenuFlyoutSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      style: DividerThemeData(
        horizontalMargin: EdgeInsets.zero,
      ),
    );
  }
}
