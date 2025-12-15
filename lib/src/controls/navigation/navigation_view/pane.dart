part of 'view.dart';

/// The width of the Compact Navigation Pane
const double kCompactNavigationPaneWidth = 50;

/// The width of the Open Navigation Pane
const double kOpenNavigationPaneWidth = 320;

/// You can use the PaneDisplayMode property to configure different
/// navigation styles, or display modes, for the NavigationView
///
/// ![Display Modes](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
enum PaneDisplayMode {
  /// The pane is positioned above the content.
  ///
  /// Use top navigation when:
  ///   * You have 5 or fewer top-level navigation categories that
  ///     are equally important, and any additional top-level navigation
  ///     categories that end up in the dropdown overflow menu are
  ///     considered less important.
  ///   * You need to show all navigation options on screen.
  ///   * You want more space for your app content.
  ///   * Icons cannot clearly describe your app's navigation categories.
  ///
  /// ![Top Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-top.png)
  top,

  /// The pane is expanded and positioned to the left of the content.
  ///
  /// Use open navigation when:
  ///   * You have 5-10 equally important top-level navigation categories.
  ///   * You want navigation categories to be very prominent, with less
  ///     space for other app content.
  ///
  /// ![Expanded Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-left.png)
  expanded,

  /// The pane shows only icons until opened and is positioned to the left
  /// of the content.
  ///
  /// ![Compact Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftcompact.png)
  compact,

  /// Only the menu button is shown until the pane is opened. When opened,
  /// it's positioned to the left of the content.
  ///
  /// ![Minimal Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftminimal.png)
  minimal,

  /// Let the [NavigationPane] decide what display mode should be used based on
  /// the width. This is used by default on [NavigationPane]. In Auto mode, the
  /// [NavigationPane] adapts between [minimal] when the window is narrow, to
  /// [compact], and then [expanded] as the window gets wider.
  ///
  /// - An expanded left pane on large window widths (1008px or greater).
  /// - A left, icon-only, nav pane (LeftCompact) on medium window widths
  /// (641px to 1007px).
  /// - Only a menu button (LeftMinimal) on small window widths (640px or less).
  ///
  /// ![Automatic Display Mode](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/adaptive-behavior-minimal.png)
  auto,
}

/// The pane used by [NavigationView].
///
/// The [NavigationView] doesn't perform any navigation tasks automatically.
/// When the user taps on a navigation item, [onChanged], if non-null, is called.
///
/// See also:
///   * [NavigationView], used alongside this to navigate through pages
///   * [PaneDisplayMode], that defines how this pane is rendered
///   * [NavigationBody], the widget that implement transitions to the pages
@immutable
class NavigationPane with Diagnosticable {
  /// Creates a navigation pane.
  ///
  /// If [selected] is non-null, [selected] must be greater or equal to 0
  NavigationPane({
    this.key,
    this.selected,
    this.onChanged,
    this.onItemPressed,
    this.size,
    this.header,
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.autoSuggestBoxReplacement,
    this.displayMode = PaneDisplayMode.auto,
    this.toggleable = true,
    this.customPane,
    this.menuButton,
    this.scrollController,
    this.scrollBehavior,
    this.leading,
    this.indicator = const StickyNavigationIndicator(),
    this.acrylicDisabled,
  }) : assert(
         selected == null || !selected.isNegative,
         'The selected index must not be negative',
       ) {
    _buildHierarchy(items);
    _buildHierarchy(footerItems);
  }

  /// {@macro flutter.widgets.Widget.key}
  final Key? key;

  /// The key for the pane view
  late final GlobalKey paneKey = GlobalKey(
    debugLabel: 'NavigationPane paneKey#$displayMode',
  );

  /// Use this property to customize how the pane will be displayed.
  /// [PaneDisplayMode.auto] is used by default.
  final PaneDisplayMode displayMode;

  /// Whether the pane can be toggled or not.
  ///
  /// This is used when [displayMode] is [PaneDisplayMode.compact]. If false,
  /// the pane will always be closed.
  final bool toggleable;

  /// Creates a Custom pane that will be used
  final NavigationPaneWidget? customPane;

  /// The menu button used by this pane.
  ///
  /// If null, [buildMenuButton] is used
  final Widget? menuButton;

  /// The size of the pane in its various mode.
  final NavigationPaneSize? size;

  /// The header of the pane.
  ///
  /// If null, the space it should have taken will be removed from
  /// the pane ([PaneDisplayMode.minimal] and [PaneDisplayMode.expanded] only).
  ///
  /// Usually a [Text] or an [Image].
  ///
  /// ![Top Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-top.png)
  /// ![Left Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-left.png)
  final Widget? header;

  /// The items used by this panel. These items are displayed before
  /// [autoSuggestBox] and [footerItems].
  ///
  /// Only [PaneItem], [PaneItemSeparator], [PaneItemHeader] and
  /// [PaneItemExpander] are accepted types. If other type is detected, an
  /// [UnsupportedError] is thrown.
  final List<NavigationPaneItem> items;

  /// The footer items used by this panel. These items are displayed at
  /// the end of the panel and they can't be overflown.
  ///
  /// Only [PaneItem], [PaneItemSeparator] and [PaneItemHeader] are
  /// accepted types. If other type is detected, an [UnsupportedError]
  /// is thrown.
  ///
  /// | Top | Left |
  /// | --- | --- |
  /// | ![Top Footer](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-footer-top.png) | ![Left Footer](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-footer-left.png) |
  final List<NavigationPaneItem> footerItems;

  /// An optional control to allow for app-level search. Usually
  /// an [AutoSuggestBox]
  final Widget? autoSuggestBox;

  /// Used when the current display mode is [PaneDisplayMode.compact]
  /// as a replacement to [autoSuggestBox]. It's only displayed if
  /// [autoSuggestBox] is non-null.
  ///
  /// It's usually an [Icon] with [FluentIcons.search] as the icon.
  final Widget? autoSuggestBoxReplacement;

  /// The current selected index.
  ///
  /// If null, none of the items is selected. If non-null, it must be
  /// a positive number.
  ///
  /// This property is called as the index of [allItems], that means it
  /// must be in the range of 0 to [allItems.length]
  ///
  /// See also:
  ///   * [allItems], a getter that merge [items] + [footerItems] into
  ///     a single list
  final int? selected;

  /// Called when the current index changes.
  final ValueChanged<int>? onChanged;

  /// Called when an item is pressed.
  final ValueChanged<int>? onItemPressed;

  /// The scroll controller used by the pane when [displayMode] is
  /// [PaneDisplayMode.compact] and [PaneDisplayMode.expanded].
  ///
  /// If null, a local scroll controller is created to control the scrolling and
  /// keep the state of the scroll when the display mode is toggled.
  final ScrollController? scrollController;

  /// The scroll behavior used by the pane when [displayMode] is
  /// [PaneDisplayMode.compact] and [PaneDisplayMode.expanded].
  ///
  /// If null, [NavigationViewScrollBehavior] is used.
  final ScrollBehavior? scrollBehavior;

  /// The leading Widget for the Pane
  final Widget? leading;

  /// A function called when building the navigation indicator
  final Widget? indicator;

  /// Whether the acrylic effect is disabled for the pane.
  ///
  /// See also:
  ///
  ///   * [DisableAcrylic], which disables all the acrylic effects down the widget tree
  final bool? acrylicDisabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<PaneDisplayMode>(
          'displayMode',
          displayMode,
          defaultValue: PaneDisplayMode.auto,
        ),
      )
      ..add(
        IterableProperty<NavigationPaneItem>('items', items, defaultValue: []),
      )
      ..add(
        IterableProperty<NavigationPaneItem>(
          'footerItems',
          footerItems,
          defaultValue: [],
        ),
      )
      ..add(IntProperty('selected', selected, ifNull: 'none'))
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(
        ObjectFlagProperty('onItemPressed', onItemPressed, ifNull: 'disabled'),
      )
      ..add(
        DiagnosticsProperty<ScrollController>(
          'scrollController',
          scrollController,
        ),
      )
      ..add(DiagnosticsProperty<NavigationPaneSize>('size', size))
      ..add(ObjectFlagProperty<Widget>.has('autoSuggestBox', autoSuggestBox));
  }

  /// Changes the selected item to [item].
  void changeTo(NavigationPaneItem item) {
    final index = effectiveIndexOf(item);
    if (!index.isNegative) onItemPressed?.call(index);
    if (selected != index && !index.isNegative) onChanged?.call(index);
  }

  /// A list of all of the items displayed on this pane.
  ///
  /// This includes both [items] and [footerItems], with expander children
  /// inserted at their appropriate positions in the hierarchy.
  List<NavigationPaneItem> get allItems {
    final all = <NavigationPaneItem>[];

    void traverse(
      Iterable<NavigationPaneItem> items, [
      NavigationPaneItem? parent,
    ]) {
      for (final item in items) {
        item.parent = parent;
        all.add(item);
        if (item is PaneItemExpander) traverse(item.items, item);
      }
    }

    traverse(items);
    traverse(footerItems);

    return all;
  }

  /// All the [PaneItem]s inside [allItems]
  ///
  /// Items with null [body] are excluded as they are not navigable
  /// (e.g., [PaneItemExpander] without a body that only expands/collapses).
  List<PaneItem> get effectiveItems {
    return allItems
        .where((i) => i is PaneItem && i is! PaneItemAction && i.body != null)
        .cast<PaneItem>()
        .toList();
  }

  /// Check if the provided [item] is selected on not.
  bool isSelected(NavigationPaneItem item) {
    return effectiveIndexOf(item) == selected;
  }

  /// Get the current selected item
  PaneItem get selectedItem {
    assert(selected != null, 'There is no item selected');
    return effectiveItems[selected!];
  }

  /// Get the effective index of the navigation pane.
  int effectiveIndexOf(NavigationPaneItem item) {
    if (item is! PaneItem) return -1;
    return effectiveItems.indexOf(item);
  }

  /// Builds the hierarchy of the items.
  List<NavigationPaneItem> _buildHierarchy(
    Iterable<NavigationPaneItem> source, [
    NavigationPaneItem? parent,
  ]) {
    final result = <NavigationPaneItem>[];

    for (final item in source) {
      item.parent = parent;
      result.add(item);
      if (item is PaneItemExpander) {
        result.addAll(_buildHierarchy(item.items, item));
      }
    }
    return result;
  }

  /// Builds the hamburger menu button for the navigation pane.
  ///
  /// If the [pane] has a [menuButton] set, it will be returned instead.
  static Widget buildMenuButton(
    BuildContext context,
    Widget itemTitle,
    NavigationPane pane, {
    required VoidCallback onPressed,
    EdgeInsetsGeometry padding = EdgeInsetsDirectional.zero,
  }) {
    if (pane.menuButton != null) return pane.menuButton!;
    return Container(
      width: pane.size?.compactWidth ?? kCompactNavigationPaneWidth,
      padding: padding,
      child:
          PaneItem(
            title: itemTitle,
            icon: const WindowsIcon(WindowsIcons.global_nav_button),
            body: const SizedBox.shrink(),
          ).build(
            context: context,
            selected: false,
            onPressed: onPressed,
            displayMode: PaneDisplayMode.compact,
            itemIndex: -1,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationPane &&
        other.key == key &&
        other.displayMode == displayMode &&
        other.customPane == customPane &&
        other.menuButton == menuButton &&
        other.size == size &&
        other.header == header &&
        listEquals(other.items, items) &&
        listEquals(other.footerItems, footerItems) &&
        other.autoSuggestBox == autoSuggestBox &&
        other.autoSuggestBoxReplacement == autoSuggestBoxReplacement &&
        other.selected == selected &&
        other.onChanged == onChanged &&
        other.onItemPressed == onItemPressed &&
        other.scrollController == scrollController &&
        other.indicator == indicator &&
        other.acrylicDisabled == acrylicDisabled;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        displayMode.hashCode ^
        customPane.hashCode ^
        menuButton.hashCode ^
        size.hashCode ^
        header.hashCode ^
        items.hashCode ^
        footerItems.hashCode ^
        autoSuggestBox.hashCode ^
        autoSuggestBoxReplacement.hashCode ^
        selected.hashCode ^
        onChanged.hashCode ^
        onItemPressed.hashCode ^
        scrollController.hashCode ^
        indicator.hashCode ^
        acrylicDisabled.hashCode;
  }
}

/// Configure the size of the pane in its various mode.
///
/// ```dart
/// NavigationView(
///   pane: NavigationPane(
///     size: NavigationPaneSize(
///       openWidth: MediaQuery.sizeOf(context).width / 5,
///       openMinWidth: 250,
///       openMaxWidth: 320,
///     ),
///   ),
/// )
/// ```
///
/// See also:
///
///  * [NavigationPane], which this configures the size of
///  * [NavigationView], used to display [NavigationPane]s
@immutable
class NavigationPaneSize with Diagnosticable {
  /// The height of the pane when it's in top mode.
  ///
  /// If null, 40.0 is used.
  final double? topHeight;

  /// The width of the pane when it's in compact mode.
  ///
  /// If null, 50.0 is used.
  final double? compactWidth;

  /// The width of the pane when it's open.
  ///
  /// If null, 320.0 is used.
  ///
  /// See also:
  ///
  ///  * [openMinWidth]
  ///  * [openMaxWidth]
  final double? openWidth;

  /// The minimum width of the pane when it's open.
  ///
  /// If the width is smaller than [minWidth], minWidth is used as width.
  ///
  /// It must be smaller or equal to [maxWidth].
  final double? openMinWidth;

  /// The maximum width of the pane when it's open.
  ///
  /// If width is greater than maxWidth, maxWidth is used as width.
  ///
  /// It must be greater or equal to [minWidth].
  final double? openMaxWidth;

  /// The height of the header in NavigationPane.
  ///
  /// Only used when NavigationPane mode is open.
  ///
  /// If null, 40.0 is used.
  final double? headerHeight;

  /// Creates a navigation pane size.
  const NavigationPaneSize({
    this.topHeight,
    this.compactWidth,
    this.openWidth,
    this.openMinWidth,
    this.openMaxWidth,
    this.headerHeight,
  }) : assert(
         openMinWidth == null ||
             openMaxWidth == null ||
             openMinWidth <= openMaxWidth,
         'openMinWidth must be greater than openMaxWidth',
       ),
       assert(
         topHeight == null || topHeight >= 0,
         'topHeight must be greater than 0',
       ),
       assert(
         compactWidth == null || compactWidth >= 0,
         'compactWidth must be greater than 0',
       ),
       assert(
         headerHeight == null || headerHeight >= 0,
         'headerHeight must be greater than 0',
       );

  /// Gets the open pane width with constraints applied.
  double get openPaneWidth {
    var paneWidth = openWidth ?? kOpenNavigationPaneWidth;
    if (openMaxWidth != null && paneWidth > openMaxWidth!) {
      paneWidth = openMaxWidth!;
    }
    if (openMinWidth != null && paneWidth < openMinWidth!) {
      paneWidth = openMinWidth!;
    }
    return paneWidth;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationPaneSize &&
        other.topHeight == topHeight &&
        other.compactWidth == compactWidth &&
        other.openWidth == openWidth &&
        other.openMinWidth == openMinWidth &&
        other.openMaxWidth == openMaxWidth &&
        other.headerHeight == headerHeight;
  }

  @override
  int get hashCode {
    return topHeight.hashCode ^
        compactWidth.hashCode ^
        openWidth.hashCode ^
        openMinWidth.hashCode ^
        openMaxWidth.hashCode ^
        headerHeight.hashCode;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(
        DoubleProperty(
          'topHeight',
          topHeight,
          defaultValue: kOneLineTileHeight,
        ),
      )
      ..add(
        DoubleProperty(
          'compactWidth',
          compactWidth,
          defaultValue: kCompactNavigationPaneWidth,
        ),
      )
      ..add(
        DoubleProperty(
          'openWidth',
          openWidth,
          defaultValue: kOpenNavigationPaneWidth,
        ),
      )
      ..add(DoubleProperty('openMinWidth', openMinWidth))
      ..add(DoubleProperty('openMaxWidth', openMaxWidth))
      ..add(
        DoubleProperty(
          'headerHeight',
          headerHeight,
          defaultValue: kOneLineTileHeight,
        ),
      );
  }
}

/// Data passed to custom navigation pane widgets.
class NavigationPaneWidgetData {
  /// Creates navigation pane widget data.
  const NavigationPaneWidgetData({
    required this.content,
    required this.titleBar,
    required this.scrollController,
    required this.paneKey,
    required this.listKey,
    required this.pane,
  });

  /// The main content of the navigation view.
  final Widget content;

  /// The app bar widget.
  final Widget? titleBar;

  /// The scroll controller for the pane.
  final ScrollController scrollController;

  /// The key for the pane.
  final Key paneKey;

  /// The key for the list of items.
  final GlobalKey listKey;

  /// The navigation pane configuration.
  final NavigationPane pane;
}

/// Base class for creating custom navigation panes.
///
/// ```dart
/// class CustomNavigationPane extends NavigationPaneWidget {
///   CustomNavigationPane();
///
///   @override
///   Widget build(BuildContext context, NavigationPaneWidgetData data) {
///   }
/// }
/// ```
abstract class NavigationPaneWidget {
  /// Builds the custom navigation pane.
  Widget build(BuildContext context, NavigationPaneWidgetData data);
}

class _SelectedItemKeyWrapper extends StatelessWidget {
  const _SelectedItemKeyWrapper({
    required this.child,
    required this.isSelected,
  });

  final Widget child;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: isSelected ? NavigationView.of(context)._selectedItemKey : null,
      child: child,
    );
  }
}

// TODO(bdlukaa): Adjust pane traversal order

/// Creates a top navigation pane.
///
/// ![Top Pane Anatomy](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-horizontal.png)
class _TopNavigationPane extends StatefulWidget {
  _TopNavigationPane({required this.pane}) : super(key: pane.key);

  final NavigationPane pane;

  @override
  State<_TopNavigationPane> createState() => _TopNavigationPaneState();
}

class _TopNavigationPaneState extends State<_TopNavigationPane> {
  final overflowKey = GlobalKey(debugLabel: 'TopNavigationPane overflowKey');
  final overflowController = FlyoutController();

  List<int> hiddenPaneItems = [];
  late List<int> _localItemHold;
  void generateLocalItemHold() {
    _localItemHold = List.generate(widget.pane.items.length, (index) => index);
  }

  @override
  void initState() {
    super.initState();
    generateLocalItemHold();
  }

  void _onPressed(PaneItem item) {
    widget.pane.changeTo(item);
    if (overflowController.isOpen) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildItem(NavigationPaneItem item, double height) {
    return Builder(
      builder: (context) {
        if (item is PaneItemHeader) {
          final theme = NavigationPaneTheme.of(context);
          final style =
              item.header._getProperty<TextStyle>() ??
              theme.itemHeaderTextStyle ??
              DefaultTextStyle.of(context).style;

          return Padding(
            padding: EdgeInsetsDirectional.only(
              // This will center the item header
              top: (height - (style.fontSize ?? 14.0)) / 4,
            ),
            child: item.build(context),
          );
        } else if (item is PaneItemSeparator) {
          return item.build(context, Axis.vertical);
        } else if (item is PaneItemExpander) {
          final selected = widget.pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () => _onPressed(item),
              onItemPressed: _onPressed,
              itemIndex: widget.pane.effectiveIndexOf(item),
              displayMode: PaneDisplayMode.top,
              showTextOnTop: !widget.pane.footerItems.contains(item),
            ),
          );
        } else if (item is PaneItem) {
          final selected = widget.pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () => _onPressed(item),
              itemIndex: widget.pane.effectiveIndexOf(item),
              // only show the text if the item is not in the footer
              showTextOnTop: !widget.pane.footerItems.contains(item),
              displayMode: PaneDisplayMode.top,
            ),
          );
        } else if (item is PaneItemWidgetAdapter) {
          return item.build(context);
        } else {
          throw UnsupportedError(
            '${item.runtimeType} is not a supported navigation pane item type.',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    overflowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _TopNavigationPane oldWidget) {
    // update the items
    if (oldWidget.pane.items.length != widget.pane.items.length) {
      generateLocalItemHold();
    }

    // if the selected item changed
    if (widget.pane.selected != oldWidget.pane.selected) {
      final selectedItem = widget.pane.items.indexOf(widget.pane.selectedItem);

      // if the selected item is part of the middle items and
      // if there is a non-hidden item
      // and if the selected item is hidden
      if (!selectedItem.isNegative &&
          !hiddenPaneItems.contains(0) &&
          hiddenPaneItems.contains(_localItemHold.indexOf(selectedItem))) {
        generateLocalItemHold();

        var item = hiddenPaneItems.first - 1;
        while (widget.pane.items[item] is! PaneItem) {
          item--;
          if (item.isNegative) {
            item++;
            break;
          }
        }

        _localItemHold
          ..remove(selectedItem)
          ..insert(item, selectedItem);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationViewContext.of(context);
    final height = widget.pane.size?.topHeight ?? kOneLineTileHeight;
    return SizedBox(
      key: widget.pane.paneKey,
      height: height,
      child: Row(
        children: [
          if (widget.pane.leading != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: widget.pane.leading,
            ),
          if (widget.pane.header != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: widget.pane.header,
            ),
          Expanded(
            child: DynamicOverflow(
              overflowWidgetAlignment: MainAxisAlignment.start,
              overflowWidget: FlyoutTarget(
                key: overflowKey,
                controller: overflowController,
                child:
                    PaneItem(
                      icon: const WindowsIcon(WindowsIcons.more),
                      body: const SizedBox.shrink(),
                    ).build(
                      context: context,
                      selected: false,
                      onPressed: () {
                        overflowController.showFlyout<void>(
                          placementMode: FlyoutPlacementMode.bottomCenter,
                          forceAvailableSpace: true,
                          builder: (context) {
                            return NavigationViewContext(
                              displayMode: view.displayMode,
                              isMinimalPaneOpen: view.isMinimalPaneOpen,
                              isCompactOverlayOpen: view.isCompactOverlayOpen,
                              previousItemIndex: view.previousItemIndex,
                              pane: view.pane,
                              isTransitioning: view.isTransitioning,
                              isTogglePaneButtonVisible:
                                  view.isTogglePaneButtonVisible,
                              child: MenuFlyout(
                                items: _localItemHold
                                    .sublist(hiddenPaneItems.first)
                                    .map((i) {
                                      final item = widget.pane.items[i];
                                      return _buildMenuPaneItem(
                                        context,
                                        item,
                                        _onPressed,
                                      );
                                    })
                                    .toList(),
                              ),
                            );
                          },
                        );
                      },
                      showTextOnTop: false,
                      displayMode: PaneDisplayMode.top,
                      itemIndex: -1,
                    ),
              ),
              overflowChangedCallback: (hiddenItems) {
                setState(() {
                  // indexes should always be valid
                  assert(() {
                    for (var i = 0; i < hiddenItems.length; i++) {
                      if (hiddenItems[i] < 0 ||
                          hiddenItems[i] >= widget.pane.items.length) {
                        return false;
                      }
                    }
                    return true;
                  }());

                  hiddenPaneItems = hiddenItems;
                });
              },
              children: _localItemHold.map((index) {
                final item = widget.pane.items[index];
                return SizedBox(
                  height: height,
                  child: _buildItem(item, height),
                );
              }).toList(),
            ),
          ),
          if (widget.pane.autoSuggestBox != null)
            Container(
              margin: const EdgeInsetsDirectional.only(start: 30),
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 215),
              child: widget.pane.autoSuggestBox,
            ),
          ...widget.pane.footerItems.map((item) {
            return _buildItem(item, height);
          }),
        ],
      ),
    );
  }
}

MenuFlyoutItemBase _buildMenuPaneItem(
  BuildContext context,
  NavigationPaneItem item,
  ValueChanged<PaneItem> onPressed, {
  EdgeInsetsGeometry? paneItemPadding,
}) {
  if (item is PaneItemSeparator) {
    return const MenuFlyoutSeparator();
  } else if (item is PaneItemExpander) {
    return _MenuFlyoutPaneItemExpander(
      item: item,
      onPressed: () => onPressed(item),
      onItemPressed: onPressed,
    );
  } else if (item is PaneItem) {
    return _MenuFlyoutPaneItem(
      item: item,
      onPressed: () => onPressed(item),
      padding: paneItemPadding,
    );
  } else if (item is PaneItemHeader) {
    return _MenuFlyoutHeader(header: item);
  } else if (item is PaneItemWidgetAdapter) {
    return MenuFlyoutItemBuilder(builder: item.build);
  } else {
    throw UnsupportedError(
      '${item.runtimeType} is not a supported navigation pane item type',
    );
  }
}

class _MenuFlyoutHeader extends MenuFlyoutItemBase {
  final PaneItemHeader header;

  const _MenuFlyoutHeader({required this.header});

  @override
  Widget build(BuildContext context) {
    final theme = NavigationPaneTheme.of(context);
    return Padding(
      padding: theme.headerPadding ?? EdgeInsetsDirectional.zero,
      child: header.build(context),
    );
  }
}

class _MenuFlyoutPaneItem extends MenuFlyoutItemBase {
  _MenuFlyoutPaneItem({
    required this.item,
    required this.onPressed,
    this.trailing = const SizedBox.shrink(),
    this.padding,
  });

  final PaneItem item;
  final VoidCallback? onPressed;
  final Widget trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final fluentTheme = FluentTheme.of(context);
    final view = NavigationViewContext.of(context);

    final selected = view.pane?.isSelected(item) ?? false;
    final titleText = item.title?._getProperty<String>() ?? '';
    final baseStyle =
        item.title?._getProperty<TextStyle>() ?? const TextStyle();

    return HoverButton(
      onPressed: () {
        item.onTap?.call();
        onPressed?.call();
      },
      builder: (context, states) {
        final textStyle = () {
          final style = theme.unselectedTextStyle?.resolve(states);
          if (style == null) return baseStyle;
          return style.merge(baseStyle);
        }();

        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsetsDirectional.zero,
                child: RichText(
                  text: item.title!._getProperty<InlineSpan>(textStyle)!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign:
                      item.title?._getProperty<TextAlign>() ?? TextAlign.start,
                  textHeightBehavior: item.title
                      ?._getProperty<TextHeightBehavior>(),
                  textWidthBasis:
                      item.title?._getProperty<TextWidthBasis>() ??
                      TextWidthBasis.parent,
                ),
              )
            : const SizedBox.shrink();

        return Container(
          padding: const EdgeInsetsDirectional.only(
            end: 4,
          ).add(padding ?? EdgeInsetsDirectional.zero),
          height: 36,
          color: ButtonThemeData.uncheckedInputColor(
            fluentTheme,
            states,
            transparentWhenNone: true,
            transparentWhenDisabled: true,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: kDefaultListTilePadding.vertical,
                  ),
                  child: Container(
                    height: 30 * 0.7,
                    width: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: selected
                          ? fluentTheme.accentColor.defaultBrushFor(
                              fluentTheme.brightness,
                            )
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: theme.iconPadding ?? EdgeInsetsDirectional.zero,
                child: IconTheme.merge(
                  data: IconThemeData(
                    color:
                        theme.unselectedIconColor?.resolve(states) ??
                        baseStyle.color,
                    size: 16,
                  ),
                  child: Center(child: item.icon),
                ),
              ),
              Expanded(child: textResult),
              if (item.infoBadge != null) item.infoBadge!,
              trailing,
            ],
          ),
        );
      },
    );
  }
}

class _MenuFlyoutPaneItemExpander extends MenuFlyoutItemBase {
  _MenuFlyoutPaneItemExpander({
    required this.item,
    required this.onPressed,
    required this.onItemPressed,
  });

  final PaneItemExpander item;
  final VoidCallback? onPressed;
  final ValueChanged<PaneItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return _MenuFlyoutPaneItemExpanderWidget(
      item: item,
      onPressed: onPressed,
      onItemPressed: onItemPressed,
    );
  }
}

class _MenuFlyoutPaneItemExpanderWidget extends StatefulWidget {
  const _MenuFlyoutPaneItemExpanderWidget({
    required this.item,
    required this.onPressed,
    required this.onItemPressed,
  });

  final PaneItemExpander item;
  final VoidCallback? onPressed;
  final ValueChanged<PaneItem> onItemPressed;

  @override
  State<_MenuFlyoutPaneItemExpanderWidget> createState() =>
      _MenuFlyoutPaneItemExpanderState();
}

class _MenuFlyoutPaneItemExpanderState
    extends State<_MenuFlyoutPaneItemExpanderWidget>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  void toggleOpen() {
    if (!mounted) return;
    setState(() => _open = !_open);
    if (_open) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = FluentTheme.of(context);
    controller.duration = theme.fastAnimationDuration;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuFlyoutPaneItem(
            item: widget.item,
            onPressed: () {
              toggleOpen();
              widget.onPressed?.call();
            },
            trailing: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => RotationTransition(
                turns: controller.drive(
                  Tween<double>(begin: _open ? 0 : 1.0, end: _open ? 0.5 : 0.5),
                ),
                child: child,
              ),
              child: const WindowsIcon(WindowsIcons.chevron_down, size: 10),
            ),
          ).build(context),
          AnimatedSize(
            duration: theme.fastAnimationDuration,
            curve: Curves.easeIn,
            child: !_open
                ? const SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.item.items.map((item) {
                      return _buildMenuPaneItem(
                        context,
                        item,
                        widget.onItemPressed,
                        paneItemPadding: const EdgeInsetsDirectional.only(
                          start: 24,
                        ),
                      ).build(context);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({
    required this.pane,
    required this.onToggle,
    required this.onOpenSearch,
    required this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final VoidCallback? onToggle;
  final VoidCallback? onOpenSearch;
  final VoidCallback onAnimationEnd;

  static Widget _buildItem(NavigationPaneItem item) {
    return Builder(
      builder: (context) {
        assert(debugCheckHasFluentTheme(context));
        final pane = NavigationViewContext.of(context).pane!;
        if (item is PaneItemHeader) {
          // Item Header is not visible on compact pane
          return const SizedBox();
        } else if (item is PaneItemSeparator) {
          return item.build(context, Axis.horizontal);
        } else if (item is PaneItemExpander) {
          final selected = pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () {
                pane.changeTo(item);
              },
              onItemPressed: pane.changeTo,
              displayMode: PaneDisplayMode.compact,
              itemIndex: pane.effectiveIndexOf(item),
            ),
          );
        } else if (item is PaneItem) {
          final selected = pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () {
                pane.changeTo(item);
              },
              displayMode: PaneDisplayMode.compact,
              itemIndex: pane.effectiveIndexOf(item),
            ),
          );
        } else if (item is PaneItemWidgetAdapter) {
          return item.build(context);
        } else {
          throw UnsupportedError(
            '${item.runtimeType} is not a supported pane item type.',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationView.of(context);
    final theme = NavigationPaneTheme.of(context);
    const EdgeInsetsGeometry topPadding = EdgeInsetsDirectional.only(bottom: 8);
    final showReplacement =
        pane.autoSuggestBox != null && pane.autoSuggestBoxReplacement != null;
    return AnimatedContainer(
      key: view._panelKey,
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      width: pane.size?.compactWidth ?? kCompactNavigationPaneWidth,
      onEnd: onAnimationEnd,
      child: Align(
        key: pane.paneKey,
        alignment: AlignmentDirectional.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            () {
              if (pane.menuButton != null) return pane.menuButton!;
              if (onToggle != null) {
                return NavigationPane.buildMenuButton(
                  context,
                  Text(FluentLocalizations.of(context).openNavigationTooltip),
                  pane,
                  onPressed: () {
                    onToggle?.call();
                  },
                  padding: showReplacement
                      ? EdgeInsetsDirectional.zero
                      : topPadding,
                );
              }
              return const SizedBox.shrink();
            }(),
            if (showReplacement)
              Padding(
                padding: topPadding,
                child:
                    PaneItem(
                      title: Text(
                        FluentLocalizations.of(context).clickToSearch,
                      ),
                      icon: pane.autoSuggestBoxReplacement,
                      body: const SizedBox.shrink(),
                    ).build(
                      context: context,
                      selected: false,
                      onPressed: () {
                        onToggle?.call();
                        onOpenSearch?.call();
                      },
                      displayMode: PaneDisplayMode.compact,
                      itemIndex: -1,
                    ),
              ),
            Expanded(
              // Use ListView.builder for lazy item building to handle
              // large lists efficiently. See: https://github.com/bdlukaa/fluent_ui/issues/742
              child: ListView.builder(
                key: view._listKey,
                primary: true,
                itemCount: pane.items.length,
                itemBuilder: (context, index) => _buildItem(pane.items[index]),
              ),
            ),
            ListView(
              key: view._secondaryListKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              children: pane.footerItems.map(_buildItem).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenNavigationPane extends StatefulWidget {
  _OpenNavigationPane({
    required this.pane,
    required this.theme,
    this.onToggle,
    this.onItemSelected,
    this.initiallyOpen = false,
    this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final VoidCallback? onToggle;
  final VoidCallback? onItemSelected;
  final NavigationPaneThemeData theme;
  final bool initiallyOpen;
  final VoidCallback? onAnimationEnd;

  static Widget buildItem(
    NavigationPane pane,
    NavigationPaneItem item, [
    VoidCallback? onChanged,
    double? width,
  ]) {
    return Builder(
      builder: (context) {
        if (width != null && width < kOpenNavigationPaneWidth / 1.5) {
          return _CompactNavigationPane._buildItem(item);
        }
        if (item is PaneItemHeader) {
          return item.build(context);
        } else if (item is PaneItemSeparator) {
          return item.build(context, Axis.horizontal);
        } else if (item is PaneItemExpander) {
          final selected = pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () {
                onChanged?.call();
                pane.changeTo(item);
              },
              onItemPressed: (item) {
                onChanged?.call();
                pane.changeTo(item);
              },
              displayMode: PaneDisplayMode.expanded,
              itemIndex: pane.effectiveIndexOf(item),
            ),
          );
        } else if (item is PaneItem) {
          final selected = pane.isSelected(item);
          return _SelectedItemKeyWrapper(
            isSelected: selected,
            child: item.build(
              context: context,
              selected: selected,
              onPressed: () {
                pane.changeTo(item);
                onChanged?.call();
              },
              displayMode: PaneDisplayMode.expanded,
              itemIndex: pane.effectiveIndexOf(item),
            ),
          );
        } else if (item is PaneItemWidgetAdapter) {
          return item.build(context);
        } else {
          throw UnsupportedError(
            '${item.runtimeType} is not a supported pane item type.',
          );
        }
      },
    );
  }

  @override
  State<_OpenNavigationPane> createState() => _OpenNavigationPaneState();
}

class _OpenNavigationPaneState extends State<_OpenNavigationPane> {
  NavigationPaneThemeData get theme => widget.theme;

  @override
  void initState() {
    super.initState();
    PageStorage.of(
      context,
    ).writeState(context, true, identifier: 'openModeOpen');
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationView.of(context);
    const EdgeInsetsGeometry topPadding = EdgeInsetsDirectional.only(bottom: 6);
    final menuButton = () {
      if (widget.pane.menuButton != null) return widget.pane.menuButton;
      if (widget.onToggle != null) {
        return NavigationPane.buildMenuButton(
          context,
          Text(FluentLocalizations.of(context).closeNavigationTooltip),
          widget.pane,
          onPressed: () {
            widget.onToggle?.call();
          },
        );
      }
      return null;
    }();
    final paneWidth =
        widget.pane.size?.openPaneWidth ?? kOpenNavigationPaneWidth;

    var paneHeaderHeight = widget.pane.size?.headerHeight;
    if (widget.pane.header == null && menuButton == null) {
      paneHeaderHeight = -1.0;
    }

    return AnimatedContainer(
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      key: view._panelKey,
      width: paneWidth,
      onEnd: widget.onAnimationEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (paneHeaderHeight == null || paneHeaderHeight >= 0)
                Container(
                  margin: widget.pane.autoSuggestBox != null
                      ? (menuButton == null ? theme.iconPadding : null)
                      : topPadding,
                  height: paneHeaderHeight,
                  child: () {
                    if (widget.pane.header != null) {
                      return Row(
                        children: [
                          menuButton ?? const SizedBox.shrink(),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 8,
                                ),
                                child: DefaultTextStyle.merge(
                                  style: theme.itemHeaderTextStyle,
                                  maxLines: 1,
                                  child: widget.pane.header!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return menuButton ?? const SizedBox.shrink();
                    }
                  }(),
                ),
              if (widget.pane.autoSuggestBox != null)
                if (width > kOpenNavigationPaneWidth / 1.5)
                  Container(
                    padding: theme.iconPadding ?? EdgeInsetsDirectional.zero,
                    height: 41,
                    alignment: AlignmentDirectional.center,
                    margin: topPadding,
                    child: widget.pane.autoSuggestBox,
                  )
                else
                  Padding(
                    padding: topPadding,
                    child:
                        PaneItem(
                          title: Text(
                            FluentLocalizations.of(context).clickToSearch,
                          ),
                          icon: widget.pane.autoSuggestBoxReplacement,
                          body: const SizedBox.shrink(),
                        ).build(
                          context: context,
                          selected: false,
                          onPressed: () {},
                          displayMode: PaneDisplayMode.compact,
                          itemIndex: -1,
                        ),
                  ),
              Expanded(
                child: ListView.builder(
                  key: view._listKey,
                  primary: true,
                  itemCount: widget.pane.items.length,
                  itemBuilder: (context, index) {
                    return _OpenNavigationPane.buildItem(
                      widget.pane,
                      widget.pane.items[index],
                      widget.onItemSelected,
                      width,
                    );
                  },
                ),
              ),
              ListView.builder(
                key: view._secondaryListKey,
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.pane.footerItems.length,
                itemBuilder: (context, index) {
                  return _OpenNavigationPane.buildItem(
                    widget.pane,
                    widget.pane.footerItems[index],
                    widget.onItemSelected,
                    width,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
