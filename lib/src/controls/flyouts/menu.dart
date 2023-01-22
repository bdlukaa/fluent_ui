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
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
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

abstract class MenuFlyoutItemInterface {
  final Key? key;

  const MenuFlyoutItemInterface({this.key});

  Widget build(BuildContext context);
}

class MenuFlyoutItemBuilder extends MenuFlyoutItemInterface {
  final WidgetBuilder builder;

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
///   * [MenuFlyout]
///   * [Flyout]
class MenuFlyoutItem extends MenuFlyoutItemInterface {
  /// Creates a menu flyout item
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
        padding: EdgeInsetsDirectional.only(bottom: 5.0),
        child: Divider(
          style: DividerThemeData(horizontalMargin: EdgeInsets.zero),
        ),
      ),
    );
  }
}

class MenuFlyoutSubItem extends MenuFlyoutItem {
  MenuFlyoutSubItem({
    super.key,
    super.leading,
    required super.text,
    super.trailing = const Icon(FluentIcons.chevron_right),
    required this.items,
  }) : super(onPressed: null);

  final List<MenuFlyoutItemInterface> items;

  @override
  Widget build(BuildContext context) {
    return _MenuFlyoutSubItem(item: this, items: items);
  }
}

typedef _MenuBuilder = Widget Function(
  BuildContext context,
  Iterable<Widget> menus,
  Iterable<GlobalKey> keys,
);

class MenuInfoProvider extends StatefulWidget {
  const MenuInfoProvider({
    Key? key,
    required this.builder,
    required this.flyoutKey,
    required this.additionalOffset,
    required this.margin,
  }) : super(key: key);

  final GlobalKey flyoutKey;
  final _MenuBuilder builder;
  final double additionalOffset;
  final double margin;

  static MenuInfoProviderState of(BuildContext context) {
    return context.findAncestorStateOfType<MenuInfoProviderState>()!;
  }

  @override
  State<MenuInfoProvider> createState() => MenuInfoProviderState();
}

class MenuInfoProviderState extends State<MenuInfoProvider> {
  final _menus = <GlobalKey, Widget>{};

  void add(Widget menu, GlobalKey key) {
    setState(() => _menus.addAll({key: menu}));
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _menus.values, _menus.keys);
  }
}

class _MenuFlyoutSubItem extends StatefulWidget {
  final MenuFlyoutItem item;
  final List<MenuFlyoutItemInterface> items;

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
      key: widget.item.key,
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
