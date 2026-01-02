import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// The default padding for the [MenuFlyout] content.
const kDefaultMenuPadding = EdgeInsetsDirectional.symmetric(vertical: 2);

/// The default margin around each item in a [MenuFlyout].
const kDefaultMenuItemMargin = EdgeInsetsDirectional.symmetric(
  horizontal: 4,
  vertical: 2,
);

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
class MenuFlyout extends StatefulWidget {
  /// Creates a menu flyout.
  const MenuFlyout({
    super.key,
    this.items = const [],
    this.color,
    this.shape,
    this.shadowColor = Colors.black,
    this.elevation = 8.0,
    this.constraints,
    this.itemMargin = kDefaultMenuItemMargin,
  });

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
  /// {@endtemplate}
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

  /// The spacing between the items.
  final EdgeInsetsGeometry itemMargin;

  @override
  State<MenuFlyout> createState() => _MenuFlyoutState();
}

class _MenuFlyoutState extends State<MenuFlyout> {
  List<GlobalKey<State<StatefulWidget>>> keys = <GlobalKey>[];

  void generateKeys() {
    if (widget.items.whereType<MenuFlyoutSubItem>().isNotEmpty) {
      keys = widget.items.map((item) {
        if (item is MenuFlyoutSubItem) {
          return GlobalKey<_MenuFlyoutSubItemState>();
        }

        return GlobalKey(debugLabel: 'MenuFlyout key#$item');
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    generateKeys();
  }

  @override
  Widget build(BuildContext context) {
    final hasLeading = widget.items.whereType<MenuFlyoutItem>().any(
      (item) => item.leading != null,
    );

    final menuInfo = MenuInfoProvider.of(context);
    final parent = Flyout.maybeOf(context);

    Widget content = IntrinsicWidth(
      child: FlyoutContent(
        color: widget.color,
        constraints: widget.constraints ?? kFlyoutMinConstraints,
        elevation: widget.elevation,
        shadowColor: widget.shadowColor,
        shape: widget.shape,
        padding: kDefaultMenuPadding,
        useAcrylic: DisableAcrylic.of(context) != null,
        child: ScrollConfiguration(
          behavior: const _MenuScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                if (item is MenuFlyoutItem) {
                  item._useIconPlaceholder = hasLeading;
                }
                if (item is MenuFlyoutSubItem && keys.isNotEmpty) {
                  item
                    .._key = keys[index] as GlobalKey<_MenuFlyoutSubItemState>?
                    ..disableAcyrlic = DisableAcrylic.of(context) != null;
                }
                return KeyedSubtree(
                  key: item.key,
                  child: Padding(
                    padding: widget.itemMargin,
                    child: item.build(context),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );

    if (keys.isNotEmpty) {
      content = MouseRegion(
        onHover: (event) {
          for (final subItem
              in keys.whereType<GlobalKey<_MenuFlyoutSubItemState>>()) {
            final state = subItem.currentState;
            if (state == null || subItem.currentContext == null) continue;
            if (!state.isShowing(menuInfo)) continue;
            if (parent == null) continue;

            final itemBox =
                subItem.currentContext!.findRenderObject()! as RenderBox;
            final parentBox =
                parent.widget.root!.context.findRenderObject as RenderBox;
            final translation = parentBox.getTransformTo(null).getTranslation();
            final offset = Offset(translation[0], translation[1]);
            final itemRect =
                (itemBox.localToGlobal(Offset.zero, ancestor: parentBox) +
                    offset) &
                itemBox.size;

            if (!itemRect.contains(event.position)) {
              state.close(menuInfo);
            }
          }
        },
        child: content,
      );
    }

    return content;
  }
}

// Do not use the platform-specific default scroll configuration.
// Menus should never overscroll or display an overscroll indicator.
class _MenuScrollBehavior extends FluentScrollBehavior {
  const _MenuScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

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
abstract class MenuFlyoutItemBase with Diagnosticable {
  /// The key for this item, used by the framework for identification.
  final Key? key;

  /// Creates a base menu flyout item.
  const MenuFlyoutItemBase({this.key});

  /// Builds the widget representation of this item.
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
  /// The builder function that creates the widget.
  final WidgetBuilder builder;

  /// Creates a menu flyout item builder
  const MenuFlyoutItemBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) => builder(context);
}

/// The standard flyout item used inside a [MenuFlyout]
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
///  * [ToggleMenuFlyoutItem], which represents a menu item that a user can
///    change between two states, checked or unchecked
///  * [RadioMenuFlyoutItem], which represents a menu item that is mutually
///    exclusive with other radio menu items in its group
class MenuFlyoutItem extends MenuFlyoutItemBase {
  /// Creates a menu flyout item
  MenuFlyoutItem({
    required this.text,
    required this.onPressed,
    super.key,
    this.leading,
    this.trailing,
    this.onLongPress,
    this.focusNode,
    this.selected = false,
    this.closeAfterClick = true,
  });

  /// Displayed before [text].
  ///
  /// Don't feel obligated to provide icons for commands that don't have a
  /// standard visualization. Cryptic icons aren't helpful, create visual
  /// clutter, and prevent users from focusing on the important menu items.
  ///
  /// ![](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
  ///
  /// Usually an [Icon] widget.
  final Widget? leading;

  /// The text displayed in this item.
  ///
  /// Usually a [Text] widget.
  final Widget text;

  /// Displayed after [text].
  ///
  /// Usually an [Icon] widget.
  final Widget? trailing;

  /// Called when the item is pressed.
  ///
  /// If `null`, the item will be marked as disabled.
  final VoidCallback? onPressed;

  /// Called when the item is long pressed.
  final VoidCallback? onLongPress;

  /// The focus node of the item.
  final FocusNode? focusNode;

  /// Whether this item is selected or not.
  final bool selected;

  /// Whether to close the menu after the item is clicked.
  ///
  /// Defaults to `true`.
  final bool closeAfterClick;

  bool _useIconPlaceholder = false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('selected', value: selected, ifTrue: 'selected'),
    );
    properties.add(
      FlagProperty(
        'closeAfterClick',
        value: closeAfterClick,
        ifFalse: 'keeps open',
      ),
    );
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed),
    );
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress),
    );
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<Widget?>('leading', leading));
    properties.add(DiagnosticsProperty<Widget>('text', text));
    properties.add(DiagnosticsProperty<Widget?>('trailing', trailing));
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutListTile(
      margin: EdgeInsetsDirectional.zero,
      selected: selected,
      showSelectedIndicator: false,
      icon:
          leading ??
          () {
            if (_useIconPlaceholder) return const Icon(null);
            return null;
          }(),
      text: text,
      trailing: IconTheme.merge(
        data: const IconThemeData(size: 12),
        child: trailing ?? const SizedBox.shrink(),
      ),
      onPressed: onPressed == null
          ? null
          : () {
              if (closeAfterClick) Navigator.of(context).maybePop();
              onPressed?.call();
            },
      onLongPress: onLongPress,
      focusNode: focusNode,
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
///  * [ToggleMenuFlyoutItem], which represents a menu item that a user can
///    change between two states, checked or unchecked
///  * [RadioMenuFlyoutItem], which represents a menu item that is mutually
///    exclusive with other radio menu items in its group
class MenuFlyoutSeparator extends MenuFlyoutItemBase {
  /// Creates a menu flyout separator
  const MenuFlyoutSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(bottom: 5),
      child: Divider(
        style: DividerThemeData(horizontalMargin: EdgeInsetsDirectional.zero),
      ),
    );
  }
}

/// Represents an item in a [MenuFlyout] that a user can change between two
/// states, checked or unchecked.
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
///  * [RadioMenuFlyoutItem], which represents a menu item that is mutually
///    exclusive with other radio menu items in its group
class ToggleMenuFlyoutItem extends MenuFlyoutItem {
  /// The value of the toggle item.
  final bool value;

  /// Called when the value of the toggle item changes.
  final ValueChanged<bool>? onChanged;

  /// Creates a menu flyout item that can be toggled on and off.
  ToggleMenuFlyoutItem({
    required super.text,
    required this.value,
    required this.onChanged,
    super.trailing,
    super.closeAfterClick,
  }) : super(
         leading: Icon(value ? FluentIcons.check_mark : null, size: 12),
         onPressed: onChanged == null ? null : () => onChanged(!value),
       );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('value', value));
    properties.add(
      ObjectFlagProperty<ValueChanged<bool>?>.has('onChanged', onChanged),
    );
  }
}

/// Represents a menu item that is mutually exclusive with other radio menu
/// items in its group
///
/// See also:
///
///  * [MenuFlyout], which displays a list of commands or options
///  * [MenuFlyoutItem], a single item in the list of items
///  * [MenuFlyoutSeparator], which represents a horizontal line that
///    separates items in a [MenuFlyout].
///  * [MenuFlyoutSubItem], which represents a menu item that displays a
///    sub-menu in a [MenuFlyout]
///  * [ToggleMenuFlyoutItem], which represents a menu item that a user can
///    change between two states, checked or unchecked
class RadioMenuFlyoutItem<T extends Object> extends MenuFlyoutItem {
  /// The value of the item.
  final T value;

  /// The value of the group.
  final T groupValue;

  /// Called when the value of the item changes.
  final ValueChanged<T>? onChanged;

  /// Creates a radio menu item.
  RadioMenuFlyoutItem({
    required super.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.trailing,
    super.closeAfterClick,
  }) : super(
         leading: Icon(
           value == groupValue ? FluentIcons.radio_bullet : null,
           size: 12,
         ),
         onPressed: onChanged == null ? null : () => onChanged(value),
       );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('value', value));
    properties.add(DiagnosticsProperty<T>('groupValue', groupValue));
    properties.add(
      ObjectFlagProperty<ValueChanged<T>?>.has('onChanged', onChanged),
    );
  }
}

@Deprecated('Use SubItemShowAction instead.')
typedef SubItemShowBehavior = SubItemShowAction;

/// Represents the action that will show the sub-menu in a [MenuFlyoutSubItem].
enum SubItemShowAction {
  /// Whether the sub-menu will be shown on item press
  press,

  /// Whether the sub-menu will be shown on item hover
  ///
  /// This is the default behavior.
  hover,
}

/// A builder function that creates a list of menu items.
///
/// Used by [MenuFlyoutSubItem] to build its child items lazily.
typedef MenuItemsBuilder =
    List<MenuFlyoutItemBase> Function(BuildContext context);

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
///  * [ToggleMenuFlyoutItem], which represents a menu item that a user can
///    change between two states, checked or unchecked
///  * [RadioMenuFlyoutItem], which represents a menu item that is mutually
///    exclusive with other radio menu items in its group
class MenuFlyoutSubItem extends MenuFlyoutItem {
  /// Creates a menu flyout sub item
  MenuFlyoutSubItem({
    required super.text,
    required this.items,
    super.key,
    super.leading,
    super.trailing = const WindowsIcon(WindowsIcons.chevron_right),
    this.showBehavior = SubItemShowAction.hover,
    this.showHoverDelay = const Duration(milliseconds: 450),
  }) : super(onPressed: null);

  /// It is the key of `_MenuFlyoutSubItem`, built in the `build` method. It
  /// can not use the parent `key` widget because it's already used by
  /// `MenuFlyout` to build the widget. It is assigned by `MenuFlyout` with a
  /// key generated by `generateKeys()`. It is used to close the child menu when
  /// its parent is closed
  GlobalKey<_MenuFlyoutSubItemState>? _key;

  /// The colletion used to generate the content of the menu.
  ///
  /// {@macro fluent_ui.flyouts.menu.items}
  final MenuItemsBuilder items;

  /// Represent which user action will show the sub-menu.
  ///
  /// Defaults to [SubItemShowAction.hover]
  final SubItemShowAction showBehavior;

  /// The sub-menu will be only shown after this delay
  ///
  /// Only applied if [showBehavior] is [SubItemShowAction.hover]
  final Duration showHoverDelay;

  /// Whether to disable the acrylic effect for this sub-menu.
  ///
  /// This is set internally by [MenuFlyout].
  bool disableAcyrlic = false;

  @override
  Widget build(BuildContext context) {
    return _MenuFlyoutSubItem(key: _key, item: this, items: items);
  }
}

class _MenuFlyoutSubItem extends StatefulWidget {
  final MenuFlyoutSubItem item;
  final MenuItemsBuilder items;

  const _MenuFlyoutSubItem({
    required this.item,
    required this.items,
    super.key,
  });

  @override
  State<_MenuFlyoutSubItem> createState() => _MenuFlyoutSubItemState();
}

class _MenuFlyoutSubItemState extends State<_MenuFlyoutSubItem>
    with SingleTickerProviderStateMixin {
  /// The animation controller responsible for the animation of the flyout
  ///
  /// The duration is defined at build time
  late final transitionController = AnimationController(vsync: this);

  final menuKey = GlobalKey<_MenuFlyoutState>();

  Timer? showTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = Flyout.of(context);
    transitionController.duration = parent.transitionDuration;
    transitionController.reverseDuration = parent.reverseTransitionDuration;
  }

  @override
  void dispose() {
    transitionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MenuFlyoutSubItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final parent = Flyout.of(context);
    if (transitionController.duration == null ||
        transitionController.duration != parent.transitionDuration) {
      transitionController.duration = parent.transitionDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuInfo = MenuInfoProvider.of(context);

    final item = MenuFlyoutItem(
      key: widget.item.key,
      text: widget.item.text,
      leading: widget.item.leading,
      selected: isShowing(menuInfo),
      trailing: widget.item.trailing,
      closeAfterClick: false,
      onPressed: () {
        show(menuInfo);
      },
    ).build(context);

    if (widget.item.showBehavior == SubItemShowAction.hover) {
      return MouseRegion(
        onEnter: (event) {
          showTimer = Timer(widget.item.showHoverDelay, () {
            show(menuInfo);
          });
        },
        onExit: (event) {
          if (showTimer != null && showTimer!.isActive) {
            showTimer!.cancel();
          }
        },
        child: item,
      );
    }

    return item;
  }

  bool isShowing(MenuInfoProviderState menuInfo) {
    return menuInfo.contains(menuKey);
  }

  void show(MenuInfoProviderState menuInfo) {
    final parent = Flyout.of(context);

    final menuFlyout = context.findAncestorWidgetOfExactType<MenuFlyout>();

    final itemBox = context.findRenderObject()! as RenderBox;
    final itemRect =
        itemBox.localToGlobal(
          Offset.zero,
          ancestor: parent.widget.root?.context.findRenderObject(),
        ) &
        itemBox.size;

    menuInfo.add(
      CustomSingleChildLayout(
        delegate: _SubItemPositionDelegate(
          parentRect: itemRect,
          parentSize: itemBox.size,
          margin: parent.margin,
        ),
        child: Flyout(
          rootFlyout: parent.rootFlyout,
          menuKey: menuKey,
          additionalOffset: parent.additionalOffset,
          margin: parent.margin,
          transitionDuration: parent.transitionDuration,
          reverseTransitionDuration: parent.reverseTransitionDuration,
          transitionBuilder: parent.transitionBuilder,
          root: parent.widget.root,
          placementMode: parent.placementMode,
          builder: (context) {
            var w = parent.transitionBuilder.call(
              context,
              transitionController,
              FlyoutPlacementMode.bottomCenter,
              MenuFlyout(
                key: menuKey,
                color: menuFlyout?.color,
                constraints: menuFlyout?.constraints,
                elevation: menuFlyout?.elevation ?? 8.0,
                itemMargin: menuFlyout?.itemMargin ?? kDefaultMenuItemMargin,
                shadowColor: menuFlyout?.shadowColor ?? Colors.black,
                shape: menuFlyout?.shape,
                items: widget.items(context),
              ),
            );

            if (widget.item.disableAcyrlic) {
              w = DisableAcrylic(child: w);
            }

            return w;
          },
        ),
      ),
      menuKey,
    );

    transitionController.forward();
    setState(() {});
  }

  /// Closes this menu and its children
  Future<void> close(MenuInfoProviderState menuInfo) async {
    await Future.wait([
      if (menuKey.currentState != null)
        ...menuKey.currentState!.keys
            .whereType<GlobalKey<_MenuFlyoutSubItemState>>()
            .map((child) => child.currentState!.close(menuInfo)),
      transitionController.reverse(),
    ]);

    menuInfo.remove(menuKey);

    if (mounted) setState(() {});
  }
}

class _SubItemPositionDelegate extends SingleChildLayoutDelegate {
  final Rect parentRect;
  final Size parentSize;
  final double margin;

  const _SubItemPositionDelegate({
    required this.parentRect,
    required this.parentSize,
    required this.margin,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The margin should include a top and a bottom
    final maxHeight = constraints.maxHeight - margin * 2;
    return constraints.loosen().copyWith(maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size rootSize, Size flyoutSize) {
    var x = parentRect.left + parentRect.size.width;

    // if the flyout will overflow the screen on the right
    final willOverflowX = x + flyoutSize.width + margin > rootSize.width;

    // if overflow x on the right, we check for some cases
    //
    // if the space available on the right is greater than the space available on
    // the left, use the right.
    //
    // otherwise, we position the flyout at the end of the screen
    if (willOverflowX) {
      final rightX = parentRect.left - flyoutSize.width;
      if (rightX > margin) {
        x = rightX;
      } else {
        x = clampDouble(
          rootSize.width - flyoutSize.width - margin,
          0,
          rootSize.width,
        );
      }
    }

    var y = parentRect.top;
    final willOverflowY = y + flyoutSize.height + margin > rootSize.height;

    if (willOverflowY) {
      y = parentRect.top + parentRect.height - flyoutSize.height;
      if (y < margin) y = margin;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _SubItemPositionDelegate oldDelegate) {
    return oldDelegate.parentRect != parentRect ||
        oldDelegate.parentSize != parentSize ||
        oldDelegate.margin != margin;
  }
}
