import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// Represents a top-level menu in a [MenuBar] control.
@immutable
class MenuBarItem with Diagnosticable {
  /// The text label of the menu.
  final String title;

  /// The collection of commands for this item.
  final List<MenuFlyoutItemBase> items;

  /// Creates a menu bar item.
  const MenuBarItem({required this.title, required this.items});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MenuBarItem) return false;
    return title == other.title && items == other.items;
  }

  @override
  int get hashCode => Object.hash(title, items);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IterableProperty<MenuFlyoutItemBase>('items', items));
  }
}

/// Use a Menu Bar to show a set of multiple top-level menus in a horizontal
/// row.
///
/// ![MenuBar example](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/menu-bar-submenu.png)
///
/// See also:
///
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/menus#create-a-menu-bar>
///  * <https://bdlukaa.github.io/fluent_ui/#/popups/menu_bar>
///  * [MenuBarItem], the items used in this menu bar
///  * [MenuFlyout], a popup that shows a list of items
///  * [CommandBar], a toolbar that provides a customizable layout for commands
class MenuBar extends StatefulWidget with Diagnosticable {
  /// The items to display in the menu bar.
  ///
  /// Must not be empty.
  final List<MenuBarItem> items;

  /// Creates a windows-styled menu bar.
  MenuBar({required this.items, super.key})
    : assert(items.isNotEmpty, 'items must not be empty');

  @override
  State<MenuBar> createState() => MenuBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<MenuBarItem>('items', items));
  }
}

/// The state for a [MenuBar] widget.
///
/// Provides methods to programmatically control the menu bar, such as
/// [showItem], [showItemAt], and [closeFlyout].
class MenuBarState extends State<MenuBar> {
  final MenuController _menuController = MenuController();

  /// The default padding for menu bar items.
  static const barPadding = EdgeInsetsDirectional.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  /// The default margin between menu bar items.
  static const barMargin = EdgeInsetsDirectional.all(4);

  MenuBarItem? _currentOpenItem;
  final Map<MenuBarItem, MenuController> _itemControllers = {};

  /// The currently open item in the menu bar.
  ///
  /// If null, no item is open.
  MenuBarItem? get currentOpenItem => _currentOpenItem;

  @override
  void dispose() {
    _menuController.close();
    _itemControllers.clear();
    super.dispose();
  }

  MenuController _controllerFor(MenuBarItem item) {
    return _itemControllers.putIfAbsent(item, MenuController.new);
  }

  // --- Public programmatic API ---

  /// Show the flyout of the given item.
  ///
  /// If the item is not in the menu bar, a [StateError] will be thrown.
  ///
  /// [closeIfOpen] determines whether the flyout should be closed if it is
  /// already open. Defaults to `true`.
  Future<void> showItem(MenuBarItem item, [bool closeIfOpen = true]) {
    if (!widget.items.contains(item)) {
      throw StateError('The item is not in the menu bar.');
    }
    final controller = _controllerFor(item);
    if (controller.isOpen && closeIfOpen) {
      controller.close();
      setState(() => _currentOpenItem = null);
      return Future<void>.value();
    }
    if (!controller.isOpen) {
      controller.open();
    }
    setState(() => _currentOpenItem = item);
    return Future<void>.value();
  }

  /// Show the flyout of the item at the given index.
  ///
  /// If the index is out of range, a [RangeError] will be thrown.
  ///
  /// [closeIfOpen] determines whether the flyout should be closed if it is
  /// already open. Defaults to `true`.
  Future<void> showItemAt(int index, [bool closeIfOpen = true]) {
    return showItem(widget.items[index], closeIfOpen);
  }

  /// Close the currently open flyout.
  ///
  /// If no flyout is open, this method does nothing.
  Future<void> closeFlyout() {
    if (_currentOpenItem case final item?) {
      _controllerFor(item).close();
      setState(() => _currentOpenItem = null);
    }
    return Future<void>.value();
  }

  // --- Internal helpers ---

  void _onItemPressed(MenuBarItem item, MenuController controller) {
    if (_currentOpenItem == item) {
      controller.close();
      setState(() => _currentOpenItem = null);
    } else {
      // Close any previously open sibling.
      if (_currentOpenItem case final prev?) {
        _controllerFor(prev).close();
      }
      controller.open();
      setState(() => _currentOpenItem = item);
    }
  }

  void _onItemHovered(MenuBarItem item, MenuController controller) {
    if (!_menuController.isOpen) return;
    if (_currentOpenItem != item) {
      if (_currentOpenItem case final prev?) {
        _controllerFor(prev).close();
      }
      controller.open();
      setState(() => _currentOpenItem = item);
    }
  }

  /// Adapts [MenuFlyoutItemBase] items so that [MenuFlyoutItem.closeAfterClick]
  /// closes the correct [MenuController] instead of calling
  /// [Navigator.maybePop] (which is a no-op inside an [OverlayPortal]).
  List<MenuFlyoutItemBase> _adaptItems(
    List<MenuFlyoutItemBase> items,
    MenuController controller,
  ) {
    return items.map((item) {
      if (item is MenuFlyoutItem &&
          item.closeAfterClick &&
          item.onPressed != null) {
        return _CloseableMenuItem(original: item, onClose: controller.close);
      }
      return item;
    }).toList();
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);

    return RawMenuAnchorGroup(
      controller: _menuController,
      child: Container(
        constraints: BoxConstraints(
          minHeight: (40 + theme.visualDensity.baseSizeAdjustment.dy).clamp(
            0.0,
            double.infinity,
          ),
        ),
        padding: EdgeInsetsDirectional.only(
          top: barMargin.top,
          bottom: barMargin.bottom,
        ),
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            for (final item in widget.items) _buildMenuItem(context, item),
          ],
        ),
      ),
    );
  }

  void _handleMenuClosed(MenuBarItem item) {
    if (mounted && _currentOpenItem == item) {
      setState(() => _currentOpenItem = null);
    }
  }

  Widget _buildMenuItem(BuildContext context, MenuBarItem item) {
    final controller = _controllerFor(item);
    final isSelected = _currentOpenItem == item;

    return RawMenuAnchor(
      controller: controller,
      onClose: () => _handleMenuClosed(item),
      overlayBuilder: (context, info) {
        return MenuInfoProvider(
          builder: (context, rootSize, menus, keys) {
            return Stack(
              children: [
                Positioned(
                  left: info.anchorRect.left,
                  top: info.anchorRect.bottom,
                  child: _MenuBarOverlay(
                    tapRegionGroupId: info.tapRegionGroupId,
                    child: MenuFlyout(
                      items: _adaptItems(item.items, controller),
                    ),
                  ),
                ),
                ...menus,
              ],
            );
          },
        );
      },
      builder: (context, menuController, child) {
        return HoverButton(
          margin: EdgeInsetsDirectional.only(
            start: barMargin.start,
            end: barMargin.end,
          ),
          onPressed: () => _onItemPressed(item, menuController),
          onPointerEnter: (_) => _onItemHovered(item, menuController),
          builder: (context, states) {
            if (isSelected) {
              states = {...states, WidgetState.hovered};
            }
            return FocusBorder(
              focused: states.isFocused,
              child: Container(
                padding: barPadding,
                decoration: BoxDecoration(
                  color: HyperlinkButton.backgroundColor(
                    FluentTheme.of(context),
                  ).resolve(states),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.title),
              ),
            );
          },
        );
      },
    );
  }
}

/// Wraps the overlay content in a [Flyout] to provide the context that
/// [MenuFlyoutSubItem] needs for sub-menu transitions and positioning.
///
/// The [TapRegion] ensures the menu panel participates in the anchor's
/// tap-region group, preventing taps on the menu from closing it.
class _MenuBarOverlay extends StatelessWidget {
  const _MenuBarOverlay({required this.tapRegionGroupId, required this.child});

  final Object tapRegionGroupId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Flyout(
      rootFlyout: GlobalKey(debugLabel: 'MenuBar root flyout'),
      additionalOffset: 0,
      margin: 8,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      root: Navigator.of(context),
      menuKey: null,
      transitionBuilder: (context, animation, mode, flyout) => flyout,
      placementMode: FlyoutPlacementMode.bottomCenter,
      builder: (context) {
        return TapRegion(groupId: tapRegionGroupId, child: child);
      },
    );
  }
}

/// A [MenuFlyoutItemBase] that wraps a [MenuFlyoutItem] and overrides its
/// [closeAfterClick] behavior to use [MenuController.close] instead of
/// [Navigator.maybePop].
class _CloseableMenuItem extends MenuFlyoutItemBase {
  _CloseableMenuItem({required this.original, required this.onClose})
    : super(key: original.key);

  final MenuFlyoutItem original;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return MenuFlyoutItem(
      text: original.text,
      leading: original.leading,
      trailing: original.trailing,
      onPressed: () {
        onClose();
        original.onPressed?.call();
      },
      onLongPress: original.onLongPress,
      focusNode: original.focusNode,
      selected: original.selected,
      closeAfterClick: false,
    ).build(context);
  }
}
