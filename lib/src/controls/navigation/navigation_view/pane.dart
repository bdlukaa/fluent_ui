part of 'view.dart';

/// The width of the Compact Navigation Pane
const double kCompactNavigationPaneWidth = 50.0;

/// The width of the Open Navigation Pane
const double kOpenNavigationPaneWidth = 320.0;

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
  /// ![Open Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-left.png)
  open,

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
  /// [compact], and then [open] as the window gets wider.
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
  }) : assert(
          selected == null || !selected.isNegative,
          'The selected index must not be negative',
        );

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
  /// the pane ([PaneDisplayMode.minimal] and [PaneDisplayMode.open] only).
  ///
  /// Usually a [Text] or an [Image].
  ///
  /// ![Top Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-top.png)
  /// ![Left Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-left.png)
  final Widget? header;

  /// The items used by this panel. These items are displayed before
  /// [autoSuggestBox] and [footerItems].
  ///
  /// Only [PaneItem], [PaneItemSeparator] and [PaneItemHeader] are
  /// accepted types. If other type is detected, an [UnsupportedError]
  /// is thrown.
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
  /// [PaneDisplayMode.compact] and [PaneDisplayMode.open].
  ///
  /// If null, a local scroll controller is created to control the scrolling and
  /// keep the state of the scroll when the display mode is toggled.
  final ScrollController? scrollController;

  /// The scroll behavior used by the pane when [displayMode] is
  /// [PaneDisplayMode.compact] and [PaneDisplayMode.open].
  ///
  /// If null, [NavigationViewScrollBehavior] is used.
  final ScrollBehavior? scrollBehavior;

  /// The leading Widget for the Pane
  final Widget? leading;

  /// A function called when building the navigation indicator
  final Widget? indicator;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<PaneDisplayMode>(
        'displayMode',
        displayMode,
        defaultValue: PaneDisplayMode.auto,
      ))
      ..add(IterableProperty<NavigationPaneItem>(
        'items',
        items,
        defaultValue: [],
      ))
      ..add(IterableProperty<NavigationPaneItem>(
        'footerItems',
        footerItems,
        defaultValue: [],
      ))
      ..add(IntProperty('selected', selected, ifNull: 'none'))
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(ObjectFlagProperty('onItemPressed', onItemPressed,
          ifNull: 'disabled'))
      ..add(DiagnosticsProperty<ScrollController>(
          'scrollController', scrollController))
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
  List<NavigationPaneItem> get allItems {
    final all = items + footerItems;

    {
      final expandItems = LinkedList<_PaneItemExpanderItem>();
      for (final parent in all) {
        // We get all the [PaneItemExpander]s inside [all] items
        if (parent is PaneItemExpander) {
          // Them, we add them and their parent and siblings info to the
          // [expandItems]
          expandItems.addAll(parent.items.map(
            (expandItem) => _PaneItemExpanderItem(
              parent,
              expandItem,
              parent.items,
            ),
          ));
        }
      }

      // Now, we add them, in their respective position
      for (final entry in expandItems) {
        final parentIndex = all.indexOf(entry.parent);
        all.insert(
          parentIndex + 1 + entry.siblings.indexOf(entry.expanderItem),
          entry.expanderItem,
        );
      }
    }

    return all;
  }

  /// All the [PaneItem]s inside [allItems]
  List<PaneItem> get effectiveItems {
    return (allItems..removeWhere((i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();
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

  static Widget buildMenuButton(
    BuildContext context,
    Widget itemTitle,
    NavigationPane pane, {
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required VoidCallback onPressed,
  }) {
    if (pane.menuButton != null) return pane.menuButton!;
    return Container(
      width: pane.size?.compactWidth ?? kCompactNavigationPaneWidth,
      margin: padding,
      child: PaneItem(
        title: itemTitle,
        icon: const Icon(FluentIcons.global_nav_button),
        body: const SizedBox.shrink(),
      ).build(
        context,
        false,
        onPressed,
        displayMode: PaneDisplayMode.compact,
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
        other.indicator == indicator;
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
        indicator.hashCode;
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

  const NavigationPaneSize({
    this.topHeight,
    this.compactWidth,
    this.openWidth,
    this.openMinWidth,
    this.openMaxWidth,
    this.headerHeight,
  })  : assert(
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
      ..add(DoubleProperty(
        'topHeight',
        topHeight,
        defaultValue: kOneLineTileHeight,
      ))
      ..add(DoubleProperty(
        'compactWidth',
        compactWidth,
        defaultValue: kCompactNavigationPaneWidth,
      ))
      ..add(DoubleProperty(
        'openWidth',
        openWidth,
        defaultValue: kOpenNavigationPaneWidth,
      ))
      ..add(DoubleProperty('openMinWidth', openMinWidth))
      ..add(DoubleProperty('openMaxWidth', openMaxWidth))
      ..add(DoubleProperty(
        'headerHeight',
        headerHeight,
        defaultValue: kOneLineTileHeight,
      ));
  }
}

class NavigationPaneWidgetData {
  const NavigationPaneWidgetData({
    required this.content,
    required this.appBar,
    required this.scrollController,
    required this.paneKey,
    required this.listKey,
    required this.pane,
  });

  final Widget content;
  final Widget appBar;
  final ScrollController scrollController;
  final Key paneKey;
  final GlobalKey listKey;
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
  Widget build(BuildContext context, NavigationPaneWidgetData data);
}

/// Creates a top navigation pane.
///
/// ![Top Pane Anatomy](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-horizontal.png)
class _TopNavigationPane extends StatefulWidget {
  _TopNavigationPane({
    required this.pane,
    this.listKey,
    this.appBar,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final GlobalKey? listKey;
  final NavigationAppBar? appBar;

  @override
  State<_TopNavigationPane> createState() => _TopNavigationPaneState();
}

class _TopNavigationPaneState extends State<_TopNavigationPane> {
  final overflowKey = GlobalKey(debugLabel: 'TopNavigationPane overflowKey');
  final overflowController = FlyoutController();

  List<int> hiddenPaneItems = [];
  late List<int> _localItemHold;
  void generateLocalItemHold() {
    _localItemHold = List.generate(
      widget.pane.items.length,
      (index) => index,
    );
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

  Widget _buildItem(
    NavigationPaneItem item,
    double height,
  ) {
    return Builder(builder: (context) {
      if (item is PaneItemHeader) {
        final theme = NavigationPaneTheme.of(context);
        final style = item.header.getProperty<TextStyle>() ??
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
        return item.build(
          context,
          selected,
          () => _onPressed(item),
          onItemPressed: _onPressed,
          // only show the text if the item is not in the footer
          showTextOnTop: !widget.pane.footerItems.contains(item),
          displayMode: PaneDisplayMode.top,
        );
      } else if (item is PaneItem) {
        final selected = widget.pane.isSelected(item);
        return item.build(
          context,
          selected,
          () => _onPressed(item),
          // only show the text if the item is not in the footer
          showTextOnTop: !widget.pane.footerItems.contains(item),
          displayMode: PaneDisplayMode.top,
        );
      } else if (item is PaneItemWidgetAdapter) {
        return item.build(context);
      } else {
        throw UnsupportedError(
          '${item.runtimeType} is not a supported navigation pane item type.',
        );
      }
    });
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
      final selectedItem = widget.pane.items.indexOf(
        widget.pane.selectedItem,
      );

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
        // debugPrint(
        //   's$selectedItem to$item - i$_localItemHold - h$hiddenPaneItems',
        // );
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final view = InheritedNavigationView.of(context);
    final height = widget.pane.size?.topHeight ?? kOneLineTileHeight;
    return SizedBox(
      key: widget.pane.paneKey,
      height: height,
      child: Row(children: [
        if (widget.pane.leading != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: widget.pane.leading!,
          ),
        if (widget.pane.header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: widget.pane.header!,
          ),
        Expanded(
          child: DynamicOverflow(
            overflowWidgetAlignment: MainAxisAlignment.start,
            overflowWidget: FlyoutTarget(
              key: overflowKey,
              controller: overflowController,
              child: PaneItem(
                icon: const Icon(FluentIcons.more),
                body: const SizedBox.shrink(),
              ).build(
                context,
                false,
                () {
                  overflowController.showFlyout(
                    placementMode: FlyoutPlacementMode.bottomCenter,
                    forceAvailableSpace: true,
                    builder: (context) {
                      return InheritedNavigationView(
                        displayMode: view.displayMode,
                        currentItemIndex: view.currentItemIndex,
                        minimalPaneOpen: view.minimalPaneOpen,
                        previousItemIndex: view.previousItemIndex,
                        pane: view.pane,
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
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
                showTextOnTop: false,
                displayMode: PaneDisplayMode.top,
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
            margin: const EdgeInsetsDirectional.only(start: 30.0),
            constraints: const BoxConstraints(minWidth: 100.0, maxWidth: 215.0),
            child: widget.pane.autoSuggestBox!,
          ),
        ...widget.pane.footerItems.map((item) {
          return _buildItem(item, height);
        }),
      ]),
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
      padding: theme.headerPadding ?? EdgeInsets.zero,
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
    final size = Flyout.of(context).size;
    final theme = NavigationPaneTheme.of(context);
    final fluentTheme = FluentTheme.of(context);
    final view = InheritedNavigationView.of(context);

    final selected = view.pane?.isSelected(item) ?? false;
    final titleText = item.title?.getProperty<String>() ?? '';
    final baseStyle = item.title?.getProperty<TextStyle>() ?? const TextStyle();

    return HoverButton(
      onPressed: () {
        item.onTap?.call();
        onPressed?.call();
      },
      builder: (context, states) {
        var textStyle = () {
          var style = theme.unselectedTextStyle?.resolve(states);
          if (style == null) return baseStyle;
          return style.merge(baseStyle);
        }();

        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsets.zero,
                child: RichText(
                  text: item.title!.getProperty<InlineSpan>(textStyle)!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign:
                      item.title?.getProperty<TextAlign>() ?? TextAlign.start,
                  textHeightBehavior:
                      item.title?.getProperty<TextHeightBehavior>(),
                  textWidthBasis: item.title?.getProperty<TextWidthBasis>() ??
                      TextWidthBasis.parent,
                ),
              )
            : const SizedBox.shrink();

        return Container(
          width: size.isEmpty ? null : size.width,
          padding: MenuFlyout.itemsPadding
              // the scrollbar padding
              .add(const EdgeInsetsDirectional.only(end: 4.0))
              .add(padding ?? EdgeInsets.zero),
          height: 36.0,
          color: ButtonThemeData.uncheckedInputColor(
            FluentTheme.of(context),
            states,
            transparentWhenNone: true,
            transparentWhenDisabled: true,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: kDefaultListTilePadding.vertical,
                ),
                child: Container(
                  height: 30 * 0.7,
                  width: 3.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color: selected
                        ? fluentTheme.accentColor
                            .defaultBrushFor(fluentTheme.brightness)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: theme.iconPadding ?? EdgeInsets.zero,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: theme.unselectedIconColor?.resolve(states) ??
                      baseStyle.color,
                  size: 16.0,
                ),
                child: Center(child: item.icon),
              ),
            ),
            Flexible(
              fit: size.isEmpty ? FlexFit.loose : FlexFit.tight,
              child: textResult,
            ),
            if (item.infoBadge != null) item.infoBadge!,
            trailing,
          ]),
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
    setState(() => _open = !_open);
    if (_open) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Flyout.of(context).size;
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return SizedBox(
      width: size.isEmpty ? null : size.width,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _MenuFlyoutPaneItem(
          item: widget.item,
          onPressed: () {
            toggleOpen();
            widget.onPressed?.call();
          },
          trailing: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => RotationTransition(
              turns: controller.drive(Tween<double>(
                begin: _open ? 0 : 1.0,
                end: _open ? 0.5 : 0.5,
              )),
              child: child,
            ),
            child: const Icon(FluentIcons.chevron_down, size: 10.0),
          ),
        ).build(context),
        if (!size.isEmpty)
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
                        paneItemPadding:
                            const EdgeInsetsDirectional.only(start: 24.0),
                      ).build(context);
                    }).toList(),
                  ),
          ),
      ]),
    );
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({
    required this.pane,
    this.paneKey,
    this.listKey,
    this.onToggle,
    this.onOpenSearch,
    this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final GlobalKey? listKey;
  final VoidCallback? onToggle;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onAnimationEnd;

  static Widget _buildItem(NavigationPaneItem item) {
    return Builder(builder: (context) {
      assert(debugCheckHasFluentTheme(context));
      final pane = InheritedNavigationView.of(context).pane!;
      if (item is PaneItemHeader) {
        // Item Header is not visible on compact pane
        return const SizedBox();
      } else if (item is PaneItemSeparator) {
        return item.build(context, Axis.horizontal);
      } else if (item is PaneItemExpander) {
        final selected = pane.isSelected(item);
        return item.build(
          context,
          selected,
          () {
            pane.changeTo(item);
          },
          onItemPressed: pane.changeTo,
        );
      } else if (item is PaneItem) {
        final selected = pane.isSelected(item);
        return item.build(
          context,
          selected,
          () {
            pane.changeTo(item);
          },
        );
      } else if (item is PaneItemWidgetAdapter) {
        return item.build(context);
      } else {
        throw UnsupportedError(
          '${item.runtimeType} is not a supported pane item type.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    const EdgeInsetsGeometry topPadding =
        EdgeInsetsDirectional.only(bottom: 8.0);
    final showReplacement =
        pane.autoSuggestBox != null && pane.autoSuggestBoxReplacement != null;
    return AnimatedContainer(
      key: paneKey,
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      width: pane.size?.compactWidth ?? kCompactNavigationPaneWidth,
      onEnd: onAnimationEnd,
      child: Align(
        key: pane.paneKey,
        alignment: AlignmentDirectional.topCenter,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                padding: showReplacement ? EdgeInsets.zero : topPadding,
              );
            }
            return const SizedBox.shrink();
          }(),
          if (showReplacement)
            Padding(
              padding: topPadding,
              child: PaneItem(
                title: Text(FluentLocalizations.of(context).clickToSearch),
                icon: pane.autoSuggestBoxReplacement!,
                body: const SizedBox.shrink(),
              ).build(
                context,
                false,
                () {
                  onToggle?.call();
                  onOpenSearch?.call();
                },
              ),
            ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              key: listKey,
              primary: true,
              children: pane.items.map((item) {
                return _buildItem(item);
              }).toList(),
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            children: pane.footerItems.map((item) {
              return _buildItem(item);
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

class _OpenNavigationPane extends StatefulWidget {
  _OpenNavigationPane({
    required this.pane,
    required this.theme,
    this.paneKey,
    this.listKey,
    this.onToggle,
    this.onItemSelected,
    this.initiallyOpen = false,
    this.onAnimationEnd,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final GlobalKey? listKey;
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
    return Builder(builder: (context) {
      if (width != null && width < kOpenNavigationPaneWidth / 1.5) {
        return _CompactNavigationPane._buildItem(item);
      }
      if (item is PaneItemHeader) {
        return item.build(context);
      } else if (item is PaneItemSeparator) {
        return item.build(context, Axis.horizontal);
      } else if (item is PaneItemExpander) {
        final selected = pane.isSelected(item);
        return item.build(
          context,
          selected,
          () {
            pane.changeTo(item);
            onChanged?.call();
          },
          onItemPressed: (item) {
            pane.changeTo(item);
            onChanged?.call();
          },
        );
      } else if (item is PaneItem) {
        final selected = pane.isSelected(item);
        return item.build(
          context,
          selected,
          () {
            pane.changeTo(item);
            onChanged?.call();
          },
        );
      } else if (item is PaneItemWidgetAdapter) {
        return item.build(context);
      } else {
        throw UnsupportedError(
          '${item.runtimeType} is not a supported pane item type.',
        );
      }
    });
  }

  @override
  State<_OpenNavigationPane> createState() => _OpenNavigationPaneState();
}

class _OpenNavigationPaneState extends State<_OpenNavigationPane> {
  NavigationPaneThemeData get theme => widget.theme;

  @override
  void initState() {
    super.initState();
    PageStorage.of(context).writeState(
      context,
      true,
      identifier: 'openModeOpen',
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    const EdgeInsetsGeometry topPadding =
        EdgeInsetsDirectional.only(bottom: 6.0);
    final menuButton = () {
      if (widget.pane.menuButton != null) return widget.pane.menuButton!;
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
    var paneWidth = widget.pane.size?.openPaneWidth ?? kOpenNavigationPaneWidth;

    var paneHeaderHeight = widget.pane.size?.headerHeight;
    if (widget.pane.header == null && menuButton == null) {
      paneHeaderHeight = -1.0;
    }

    return AnimatedContainer(
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      key: widget.paneKey,
      width: paneWidth,
      onEnd: widget.onAnimationEnd,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          key: widget.pane.paneKey,
          children: [
            if (paneHeaderHeight == null || paneHeaderHeight >= 0)
              Container(
                margin: widget.pane.autoSuggestBox != null
                    ? (menuButton == null ? theme.iconPadding : null)
                    : topPadding,
                height: paneHeaderHeight,
                child: () {
                  if (widget.pane.header != null) {
                    return Row(children: [
                      menuButton ?? const SizedBox.shrink(),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 8.0,
                            ),
                            child: DefaultTextStyle.merge(
                              style: theme.itemHeaderTextStyle,
                              maxLines: 1,
                              child: widget.pane.header!,
                            ),
                          ),
                        ),
                      ),
                    ]);
                  } else {
                    return menuButton ?? const SizedBox.shrink();
                  }
                }(),
              ),
            if (widget.pane.autoSuggestBox != null)
              if (width > kOpenNavigationPaneWidth / 1.5)
                Container(
                  padding: theme.iconPadding ?? EdgeInsets.zero,
                  height: 41.0,
                  alignment: AlignmentDirectional.center,
                  margin: topPadding,
                  child: widget.pane.autoSuggestBox!,
                )
              else
                Padding(
                  padding: topPadding,
                  child: PaneItem(
                    title: Text(FluentLocalizations.of(context).clickToSearch),
                    icon: widget.pane.autoSuggestBoxReplacement!,
                    body: const SizedBox.shrink(),
                  ).build(
                    context,
                    false,
                    () {},
                    displayMode: PaneDisplayMode.compact,
                  ),
                ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                key: widget.listKey,
                primary: true,
                addAutomaticKeepAlives: false,
                children: widget.pane.items.map((item) {
                  return _OpenNavigationPane.buildItem(
                    widget.pane,
                    item,
                    widget.onItemSelected,
                    width,
                  );
                }).toList(),
              ),
            ),
            ListView(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.pane.footerItems.map((item) {
                return _OpenNavigationPane.buildItem(
                  widget.pane,
                  item,
                  widget.onItemSelected,
                  width,
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }
}
