import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Menu flyouts are used in menu and context menu scenarios to display a list
/// of commands or options when requested by the user. A menu flyout shows a
/// single, inline, top-level menu that can have menu items and sub-menus.
///
/// ![MenuFlyout](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
///
/// See also:
///
///  * [FlyoutController], which displays a flyout to the given target
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/menus>
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
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  }) : super(key: key);

  /// {@template fluent_ui.flyouts.menu.items}
  /// The colletion used to generate the content of the menu.
  ///
  /// See also:
  ///
  ///  * [MenuFlyoutItem], a single item in the list of items
  ///  * [MenuFlyoutSeparator], which represents a horizontal line that
  ///    separates items in a [MenuFlyout].
  ///  * [MenuFlyoutSubItem], which represents a menu item that displays a
  ///    sub-menu in a [MenuFlyout]
  /// {@end-template}
  final List<MenuFlyoutItemBase> items;

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

  /// The padding applied the [items], with correct handling when scrollable
  final EdgeInsetsGeometry? padding;

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
      padding: EdgeInsets.zero,
      child: ScrollConfiguration(
        behavior: const _MenuScrollBehavior(),
        child: SingleChildScrollView(
          padding: padding,
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
        ),
      ),
    );
  }
}

// Do not use the platform-specific default scroll configuration.
// Menus should never overscroll or display an overscroll indicator.
class _MenuScrollBehavior extends FluentScrollBehavior {
  const _MenuScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
///  * [MenuFlyoutItemBuilder], which renders the given widget in the items list
abstract class MenuFlyoutItemBase {
  final Key? key;

  const MenuFlyoutItemBase({this.key});

  Widget build(BuildContext context);
}

/// Render any widget in the items list of a [MenuFlyout]
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
class MenuFlyoutItemBuilder extends MenuFlyoutItemBase {
  final WidgetBuilder builder;

  /// Creates a menu flyout item builder
  const MenuFlyoutItemBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context);
}

/// The standart flyout item used inside a [MenuFlyout]
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
class MenuFlyoutItem extends MenuFlyoutItemBase {
  /// Creates a menu flyout item
  MenuFlyoutItem({
    super.key,
    this.leading,
    required this.text,
    this.trailing,
    required this.onPressed,
    this.selected = false,
  });

  /// Displayed before [text].
  ///
  /// Don't feel obligated to provide icons for commands that don't have a
  /// standard visualization. Cryptic icons aren't helpful, create visual
  /// clutter, and prevent users from focusing on the important menu items.
  ///
  /// ![](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
  ///
  /// Usually an [Icon] widget,
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

/// Represents a horizontal line that separates items in a [MenuFlyout].
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
class MenuFlyoutSeparator extends MenuFlyoutItemBase {
  /// Creates a menu flyout separator
  const MenuFlyoutSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final size = ContentSizeInfo.of(context).size;

    return SizedBox(
      width: size.width,
      child: const Padding(
        padding: EdgeInsetsDirectional.only(bottom: 5.0),
        child: Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
      ),
    );
  }
}

enum SubItemShowBehavior {
  /// Whether the sub-menu will be shown on item press
  press,

  /// Whether the sub-menu will be shown on item hover
  ///
  /// This is the default behavior.
  hover,
}

/// Represents a menu item that displays a sub-menu in a [MenuFlyout].
///
/// ![](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/menu-bar-submenu.png)
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
class MenuFlyoutSubItem extends MenuFlyoutItem {
  /// Creates a menu flyout sub item
  MenuFlyoutSubItem({
    super.key,
    super.leading,
    required super.text,
    super.trailing = const Icon(FluentIcons.chevron_right),
    required this.items,
    this.showBehavior = SubItemShowBehavior.hover,
  }) : super(onPressed: null);

  /// The colletion used to generate the content of the menu.
  ///
  /// {@macro fluent_ui.flyouts.menu.items}
  final List<MenuFlyoutItemBase> items;

  /// Represent which user action will show the sub-menu.
  ///
  /// Defaults to [SubItemShowBehavior.hover]
  final SubItemShowBehavior showBehavior;

  @override
  Widget build(BuildContext context) {
    return _MenuFlyoutSubItem(item: this, items: items);
  }
}

class _MenuFlyoutSubItem extends StatefulWidget {
  final MenuFlyoutSubItem item;
  final List<MenuFlyoutItemBase> items;

  const _MenuFlyoutSubItem({
    Key? key,
    required this.item,
    required this.items,
  }) : super(key: key);

  @override
  State<_MenuFlyoutSubItem> createState() => __MenuFlyoutSubItemState();
}

class __MenuFlyoutSubItemState extends State<_MenuFlyoutSubItem> {
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    final menuInfo = MenuInfoProvider.of(context);

    return MenuFlyoutItem(
      text: widget.item.text,
      leading: widget.item.leading,
      selected: _showing,
      trailing: widget.item.trailing,
      onPressed: () {
        final itemBox = context.findRenderObject() as RenderBox;
        final itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;

        final menuKey = GlobalKey();

        // TODO: add a layout delegate
        menuInfo.add(
          Positioned(
            key: menuKey,
            top: itemRect.top,
            left: itemRect.left + itemBox.size.width,
            child: ContentManager(
              content: (_) => MenuFlyout(
                items: widget.items,
              ),
            ),
          ),
          menuKey,
        );
      },
    ).build(context);
  }
}
