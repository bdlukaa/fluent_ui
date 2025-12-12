import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

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

/// Use a Menu Bar to show a set of multiple top-level menus in a horizontal row.
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
  final _controller = FlyoutController();

  /// The default padding for menu bar items.
  static const barPadding = EdgeInsetsDirectional.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  /// The default margin between menu bar items.
  static const barMargin = EdgeInsetsDirectional.all(4);

  final Map<MenuBarItem, GlobalKey> _keys = {};
  GlobalKey? _keyOf(MenuBarItem item) {
    if (_controller.isOpen) {
      final menuBar = _controller.attachState.context
          .findAncestorStateOfType<MenuBarState>();
      if (menuBar == null) return null;
      return menuBar._keys[item] ??= GlobalKey();
    } else {
      return _keys[item] ??= GlobalKey();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _locked = false;
  MenuBarItem? _currentOpenItem;

  /// The currently open item in the menu bar.
  ///
  /// If null, no item is open.
  MenuBarItem? get currentOpenItem => _currentOpenItem;
  Future<void> _showFlyout(
    BuildContext context, [
    MenuBarItem? item,
    bool closeIfOpen = true,
  ]) async {
    if (_locked) return;
    _locked = true;
    final textDirection = Directionality.of(context);
    item ??= widget.items.first;

    // Checks the position of the item itself. Context is the MenuBarItem button.
    // Position needs to be checked before the flyout is closed, otherwise an
    // error will be thrown.
    final renderBox = context.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(
      Offset.zero,
      ancestor: this.context.findRenderObject(),
    );
    if (_controller.isOpen) {
      if (_currentOpenItem == item) {
        if (closeIfOpen) closeFlyout();
        _currentOpenItem = null;
        _locked = false;
        if (mounted) setState(() {});
        return;
      }
      await closeFlyout();
    }

    _locked = false;
    _currentOpenItem = item;
    final resolvedBarMargin = barMargin.resolve(textDirection);
    final future = _controller.showFlyout<void>(
      buildTarget: true,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomLeft.resolve(textDirection),
      ),
      additionalOffset: 0,
      horizontalOffset: position.dx + resolvedBarMargin.left,
      reverseTransitionDuration: Duration.zero,
      barrierColor: Colors.transparent,
      builder: (context) {
        return TapRegion(
          groupId: MenuBar,
          child: MenuFlyout(items: item!.items),
        );
      },
    );
    setState(() {});
    await future;
    _currentOpenItem = null;
    if (mounted) setState(() {});
  }

  /// Close the currently open flyout.
  ///
  /// If no flyout is open, this method does nothing.
  Future<void> closeFlyout() async {
    if (_controller.isOpen) {
      _controller.close<void>();
      // Waits for the reverse transition duration.
      //
      // Even though the duration is zero, it is necessary to wait for the
      // transition to finish before showing the next flyout. Otherwise, the
      // flyout will fail to show due to [_locked]. Use SchedulerBinding for
      // frame-aligned updates instead of arbitrary delay.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Show the flyout of the given item.
  ///
  /// If the item is not in the menu bar, a [StateError] will be thrown.
  ///
  /// [closeIfOpen] determines whether the flyout should be closed if it is
  /// already open. Defaults to `true`.
  Future<void> showItem(MenuBarItem item, [bool closeIfOpen = true]) {
    final key = _keyOf(item);
    if (key == null) {
      throw StateError('The item is not in the menu bar.');
    }
    final context = key.currentContext;
    if (context == null) {
      throw StateError('The item is not in the widget tree.');
    }
    return _showFlyout(context, item);
  }

  /// Show the flyout of the item at the given index.
  ///
  /// If the index is out of range, a [RangeError] will be thrown.
  ///
  /// [closeIfOpen] determines whether the flyout should be closed if it is
  /// already open. Defaults to `true`.
  Future<void> showItemAt(int index, [bool closeIfOpen = true]) {
    if (index < 0 || index >= widget.items.length) {
      throw RangeError.range(index, 0, widget.items.length - 1);
    }
    return showItem(widget.items[index], closeIfOpen);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);

    return TapRegion(
      groupId: MenuBar,
      onTapOutside: (_) => closeFlyout(),
      child: Container(
        height: 40,
        padding: EdgeInsetsDirectional.only(
          top: barMargin.top,
          bottom: barMargin.bottom,
        ),
        // align to the center so that the flyout is directly connected to the buttons
        // not the bar.
        alignment: AlignmentDirectional.centerStart,
        child: FlyoutTarget(
          controller: _controller,
          child: Builder(
            builder: (context) {
              // Do not use the [Flyout] object because it is only available for the
              // flyout content. [MenuInfoProvider] is available for the entire Flyout
              // popup. This is only available after [FlyoutTarget].
              final flyout = MenuInfoProvider.maybeOf(context);

              /// The flyout menu bar must be invisible because it has transparent
              /// components, which can lead to visual inconsistencies.
              return Visibility.maintain(
                visible: flyout == null,
                child: Row(
                  children: [
                    for (final item in widget.items)
                      Builder(
                        key: _controller.isOpen ? null : _keyOf(item),
                        builder: (context) {
                          final isSelected = _currentOpenItem == item;
                          return HoverButton(
                            margin: EdgeInsetsDirectional.only(
                              start: barMargin.start,
                              end: barMargin.end,
                            ),
                            onPressed: () {
                              _locked = false;
                              _showFlyout(context, item);
                            },
                            onPointerEnter: _controller.isOpen
                                ? (_) {
                                    if (_currentOpenItem != item) {
                                      _showFlyout(context, item);
                                    }
                                  }
                                : null,
                            onFocusChange: (focused) {
                              if (focused && _controller.isOpen) {
                                _showFlyout(context, item);
                              }
                            },
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
                                      theme,
                                    ).resolve(states),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(item.title),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
