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
///
///   * [NavigationView], used alongside this to navigate through pages
///   * [PaneDisplayMode], that defines how this pane is rendered
///   * [TitleBar], used to display the title of the pane
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
    this.toggleButton = const PaneToggleButton(),
    this.toggleButtonPosition = PaneToggleButtonPreferredPosition.auto,
    this.scrollController,
    this.scrollBehavior,
    this.leading,
    this.indicator = const StickyNavigationIndicator(),
    this.acrylicDisabled,
    this.buildTopOverflowButton = defaultBuildTopOverflowButton,
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
  /// This is used when the current display mod is [PaneDisplayMode.compact].
  /// If `false`, the pane will always be closed.
  final bool toggleable;

  /// Creates a Custom pane that will be used
  final NavigationPaneWidget? customPane;

  /// The menu button used by this pane.
  ///
  /// If null, no toggle button will be displayed. [PaneToggleButton] is used by
  /// default.
  ///
  /// See also:
  ///
  ///   * [toggleButtonPosition], which defines the preferred position of the toggle button.
  final Widget? toggleButton;

  /// The position of the toggle button.
  ///
  /// See also:
  ///
  ///   * [toggleButton], which defines the toggle button to use.
  final PaneToggleButtonPreferredPosition toggleButtonPosition;

  /// The size of the pane in its various mode.
  final NavigationPaneSize? size;

  /// The header of the pane.
  ///
  /// If null, the space it should have taken will be removed from
  /// the pane ([PaneDisplayMode.minimal] and [PaneDisplayMode.expanded] only).
  ///
  /// Usually a [Text], [Image] or [Icon].
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

  /// The leading Widget for the Pane.
  final Widget? leading;

  /// The navigation indicator.
  ///
  /// See also:
  ///
  ///  * [StickyNavigationIndicator], the default navigation indicator.
  ///  * [EndNavigationIndicator], the Windows 10 indicator.
  final Widget? indicator;

  /// Whether the acrylic effect is disabled for the pane.
  ///
  /// See also:
  ///
  ///   * [DisableAcrylic], which disables all the acrylic effects down the
  ///      widget tree
  final bool? acrylicDisabled;

  /// Builds the top overflow button.
  ///
  /// [defaultBuildTopOverflowButton] is used by default.
  final Widget Function(VoidCallback openFlyout) buildTopOverflowButton;

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

  static Widget defaultBuildTopOverflowButton(VoidCallback openFlyout) {
    return Builder(
      builder: (context) {
        return PaneItem(icon: const WindowsIcon(WindowsIcons.more)).build(
          context: context,
          selected: false,
          onPressed: openFlyout,
          showTextOnTop: false,
          displayMode: PaneDisplayMode.top,
          itemIndex: -1,
        );
      },
    );
  }

  bool canChangeTo(NavigationPaneItem item) {
    final index = effectiveIndexOf(item);
    if (index.isNegative) return false;

    return index != selected;
  }

  /// Changes the selected item to [item].
  void changeTo(NavigationPaneItem item) {
    if (!canChangeTo(item)) return;
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

  int indexOf(NavigationPaneItem item) {
    return allItems.indexOf(item);
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

  Widget _buildItem(NavigationPaneItem item, {int depth = 0}) {
    return Builder(
      builder: (context) {
        if (item is PaneItemHeader) {
          // Item Header is not visible on compact pane
          return const SizedBox();
        } else if (item is PaneItemSeparator) {
          return item.build(context, Axis.horizontal);
        } else if (item is PaneItem) {
          final view = NavigationView.dataOf(context);
          final index = effectiveIndexOf(item);
          final selected = index == view.pane?.selected;
          return FocusTraversalOrder(
            order: NumericFocusOrder(index.toDouble()),
            child: _SelectedItemKeyWrapper(
              isSelected: item is! PaneItemExpander && selected,
              child: item.build(
                context: context,
                selected: selected,
                onPressed: () => changeTo(item),
                displayMode: view.displayMode,
                itemIndex: index,
                showTextOnTop: !footerItems.contains(item),
                depth: depth,
              ),
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationPane &&
        other.key == key &&
        other.displayMode == displayMode &&
        other.customPane == customPane &&
        other.toggleButton == toggleButton &&
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
        toggleButton.hashCode ^
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
  final double topHeight;

  /// The width of the pane when it's in compact mode.
  ///
  /// If null, 50.0 is used.
  final double compactWidth;

  /// The width of the pane when it's open.
  ///
  /// If null, 320.0 is used.
  ///
  /// See also:
  ///
  ///  * [openMinWidth]
  ///  * [openMaxWidth]
  final double openWidth;

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
  final double headerHeight;

  /// Creates a navigation pane size.
  const NavigationPaneSize({
    this.topHeight = kOneLineTileHeight,
    this.compactWidth = kCompactNavigationPaneWidth,
    this.openWidth = kOpenNavigationPaneWidth,
    this.openMinWidth,
    this.openMaxWidth,
    this.headerHeight = kOneLineTileHeight,
  }) : assert(
         openMinWidth == null ||
             openMaxWidth == null ||
             openMinWidth <= openMaxWidth,
         'openMinWidth must be greater than openMaxWidth',
       ),
       assert(topHeight >= 0, 'topHeight must be greater than 0'),
       assert(compactWidth >= 0, 'compactWidth must be greater than 0'),
       assert(headerHeight >= 0, 'headerHeight must be greater than 0');

  /// Gets the width of the open pane with the constraints applied.
  double get openPaneWidth {
    return openWidth.clamp(openMinWidth ?? 0, openMaxWidth ?? double.infinity);
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

/// Wraps the child in a KeyedSubtree with the selected item key, if the item is
/// selected.
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
    if (widget.pane.canChangeTo(item)) {
      widget.pane.changeTo(item);
      if (overflowController.isOpen) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildItem(NavigationPaneItem item, double height) {
    if (item is PaneItemHeader) {
      return Builder(
        builder: (context) {
          final theme = NavigationPaneTheme.of(context);
          final style =
              item.header._getProperty<TextStyle>() ??
              theme.itemHeaderTextStyle ??
              DefaultTextStyle.of(context).style;

          return Padding(
            padding: EdgeInsetsDirectional.only(
              // TODO(bdlukaa): Remove this
              // This is needed because we use [DynamicOverflow] to render the
              // items
              // This will center the item header
              top: (height - (style.fontSize ?? 14.0)) / 4,
            ),
            child: item.build(context),
          );
        },
      );
    } else {
      return widget.pane._buildItem(item);
    }
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

  void openOverflowFlyout() {
    final view = NavigationViewContext.of(context);
    overflowController.showFlyout<void>(
      placementMode: FlyoutPlacementMode.bottomCenter,
      forceAvailableSpace: true,
      builder: (context) {
        return NavigationViewContext.copy(
          parent: view,
          child: Builder(
            builder: (context) {
              return MenuFlyout(
                items: _localItemHold.sublist(hiddenPaneItems.first).map((i) {
                  final item = widget.pane.items[i];
                  return item.buildMenuFlyoutItem(context, _onPressed);
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final height = widget.pane.size?.topHeight ?? kOneLineTileHeight;
    return SizedBox(
      key: widget.pane.paneKey,
      height: height,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
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
                  child: widget.pane.buildTopOverflowButton(openOverflowFlyout),
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
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (context) {
            return widget.item
                .copyWith(
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggleOpen,
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) => RotationTransition(
                        turns: controller.drive(
                          Tween<double>(
                            begin: _open ? 0 : 1.0,
                            end: _open ? 0.5 : 0.5,
                          ),
                        ),
                        child: child,
                      ),
                      child: const WindowsIcon(
                        WindowsIcons.chevron_down,
                        size: 10,
                      ),
                    ),
                  ),
                )
                .buildMenuFlyoutItem(context, (item) {
                  toggleOpen();
                  widget.onPressed?.call();
                })
                .build(context);
          },
        ),
        AnimatedSize(
          duration: theme.fastAnimationDuration,
          curve: Curves.easeIn,
          alignment: AlignmentDirectional.topStart,
          child: !_open
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: widget.item.items.map((item) {
                    return NavigationPaneTheme.merge(
                      data: const NavigationPaneThemeData(
                        labelPadding: EdgeInsetsDirectional.only(start: 6),
                      ),
                      child: Builder(
                        builder: (context) {
                          return item
                              .buildMenuFlyoutItem(
                                context,
                                widget.onItemPressed,
                              )
                              .build(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({
    required this.pane,
    required this.onOpenSearch,
    required this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final VoidCallback? onOpenSearch;
  final VoidCallback onAnimationEnd;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = NavigationView.of(context);
    final theme = NavigationPaneTheme.of(context);
    const EdgeInsetsGeometry topPadding = EdgeInsetsDirectional.only(bottom: 6);
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
            if (view.toggleButtonPosition == PaneToggleButtonPosition.pane)
              Padding(padding: topPadding, child: pane.toggleButton),
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
                        onOpenSearch?.call();
                      },
                      displayMode: PaneDisplayMode.compact,
                      itemIndex: -1,
                    ),
              ),
            Expanded(
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: ListView.builder(
                  key: view._listKey,
                  primary: true,
                  itemCount: pane.items.length,
                  itemBuilder: (context, index) =>
                      pane._buildItem(pane.items[index]),
                ),
              ),
            ),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: ListView(
                key: view._secondaryListKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                children: pane.footerItems.map(pane._buildItem).toList(),
              ),
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
    this.onItemSelected,
    this.initiallyOpen = false,
    this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final VoidCallback? onItemSelected;
  final NavigationPaneThemeData theme;
  final bool initiallyOpen;
  final VoidCallback? onAnimationEnd;

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
    final menuButton =
        view.toggleButtonPosition == PaneToggleButtonPosition.pane
        ? Padding(padding: topPadding, child: widget.pane.toggleButton)
        : null;

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
              Container(
                margin: widget.pane.autoSuggestBox != null
                    ? (menuButton == null ? theme.iconPadding : null)
                    : topPadding,
                height: paneHeaderHeight,
                child: widget.pane.header != null
                    ? Row(
                        children: [
                          ?menuButton,
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
                      )
                    : menuButton,
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
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: ListView.builder(
                    key: view._listKey,
                    primary: true,
                    itemCount: widget.pane.items.length,
                    itemBuilder: (context, index) {
                      return widget.pane._buildItem(widget.pane.items[index]);
                    },
                  ),
                ),
              ),
              FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: ListView.builder(
                  key: view._secondaryListKey,
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.pane.footerItems.length,
                  itemBuilder: (context, index) {
                    return widget.pane._buildItem(
                      widget.pane.footerItems[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
