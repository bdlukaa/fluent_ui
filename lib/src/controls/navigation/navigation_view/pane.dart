part of 'view.dart';

const double _kCompactNavigationPanelWidth = 50.0;
const double _kOpenNavigationPanelWidth = 320.0;

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

  /// Let the [NavigationPane] decide what display mode should be used
  /// based on the width. This is used by default on [NavigationPanel].
  /// In Auto mode, the [NavigationPane] adapts between [minimal] when
  /// the window is narrow, to [compact], and then [open] as the window
  /// gets wider.
  ///
  /// ![Automatic Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
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
    this.size,
    this.header,
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.autoSuggestBoxReplacement,
    this.displayMode = PaneDisplayMode.auto,
    this.customPane,
    this.menuButton,
    this.scrollController,
    this.indicatorBuilder = defaultNavigationIndicator,
  }) : assert(selected == null || selected >= 0);

  final Key? key;

  final GlobalKey paneKey = GlobalKey();

  /// Use this property to customize how the pane will be displayed.
  /// [PaneDisplayMode.auto] is used by default.
  final PaneDisplayMode displayMode;

  final NavigationPaneWidget? customPane;

  /// The menu button used by this pane. If null and [onDisplayModeRequested]
  /// is null
  final Widget? menuButton;

  /// The size of the pane in its various mode.
  final NavigationPaneSize? size;

  /// The header of the pane.
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

  /// The scroll controller used by the pane when [displayMode]
  /// is [PaneDisplayMode.compact] and [PaneDisplayMode.open].
  ///
  /// If null, a local scroll controller is created to control
  /// the scrolling and keep the state of the scroll when the
  /// display mode is toggled.
  final ScrollController? scrollController;

  /// A function called when building the navigation indicator
  final NavigationIndicatorBuilder indicatorBuilder;

  static Widget defaultNavigationIndicator({
    required BuildContext context,
    required NavigationPane pane,
    Axis? axis,
    required Widget child,
  }) {
    if (pane.selected == null) return child;
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    axis ??= Axis.horizontal;

    final left = theme.iconPadding?.left ?? theme.labelPadding?.left ?? 0;
    final right = theme.labelPadding?.right ?? theme.iconPadding?.right ?? 0;

    return StickyNavigationIndicator(
      index: pane.selected!,
      offsets: () => pane.effectiveItems.getPaneItemsOffsets(pane.paneKey),
      sizes: pane.effectiveItems.getPaneItemsSizes,
      child: child,
      color: theme.highlightColor,
      curve: theme.animationCurve ?? Curves.linear,
      axis: axis,
      topPadding: EdgeInsets.only(left: left, right: right),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('displayMode', displayMode));
    properties.add(IterableProperty('items', items));
    properties.add(IterableProperty('footerItems', footerItems));
    properties.add(IntProperty('selected', selected));
    properties
        .add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'));
    properties.add(DiagnosticsProperty<ScrollController>(
      'scrollController',
      scrollController,
    ));
  }

  /// A list of all of the items displayed on this pane.
  List<NavigationPaneItem> get allItems {
    return items + footerItems;
  }

  List<NavigationPaneItem> get effectiveItems {
    return (allItems
      ..removeWhere((i) => i is! PaneItem || i is PaneItemAction));
  }

  /// Check if the provided [item] is selected on not.
  bool isSelected(NavigationPaneItem item) {
    return effectiveIndexOf(item) == selected;
  }

  /// Get the effective index of the navigation pane.
  int effectiveIndexOf(NavigationPaneItem item) {
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
      width: pane.size?.compactWidth ?? _kCompactNavigationPanelWidth,
      margin: padding,
      child: PaneItem(
        title: itemTitle,
        icon: const Icon(FluentIcons.global_nav_button),
      ).build(
        context,
        false,
        onPressed,
        displayMode: PaneDisplayMode.compact,
      ),
    );
  }
}

/// Configure the size of the pane in its various mode.
class NavigationPaneSize {
  /// The height of the pane when he is in top mode.
  ///
  /// If the value is null, [kOneLineTileHeight] is used.
  final double? topHeight;

  /// The width of the pane when he is in compact mode.
  ///
  /// If the value is null, [_kCompactNavigationPanelWidth] is used.
  final double? compactWidth;

  /// The width of the pane when he is open.
  ///
  /// If the value is null, [_kOpenNavigationPanelWidth] is used.
  /// The width can be based on MediaQuery and used
  /// with [minWidth] and [maxWidth].
  final double? openWidth;

  /// The minimum width of the pane when he is open.
  ///
  /// If width is smaller than minWidth, minWidth is used as width.
  /// minWidth must be smaller or equal to maxWidth.
  final double? openMinWidth;

  /// The maximum width of the pane when he is open.
  ///
  /// If width is greater than maxWidth, maxWidth is used as width.
  /// maxWidth must be greater or equal than minWidth.
  final double? openMaxWidth;

  NavigationPaneSize({
    this.topHeight,
    this.compactWidth,
    this.openWidth,
    this.openMinWidth,
    this.openMaxWidth,
  }) : assert(openMinWidth == null ||
            openMaxWidth == null ||
            openMinWidth <= openMaxWidth);
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
  final Key? paneKey;
  final GlobalKey? listKey;
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
class _TopNavigationPane extends StatelessWidget {
  _TopNavigationPane({
    required this.pane,
    this.listKey,
    this.appBar,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final GlobalKey? listKey;
  final NavigationAppBar? appBar;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    if (item is PaneItemHeader) {
      return item.build(context);
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.vertical);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return item.build(
        context,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
        },
        showTextOnTop: !pane.footerItems.contains(item),
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Widget topBar = SizedBox(
      height: pane.size?.topHeight ?? kOneLineTileHeight,
      child: pane.indicatorBuilder(
        context: context,
        pane: pane,
        axis: Axis.vertical,
        child: Row(key: pane.paneKey, children: [
          Expanded(
            child: Row(children: [
              if (appBar != null)
                NavigationAppBar.buildLeading(context, appBar!),
              if (pane.header != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  child: pane.header!,
                ),
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: false,
                  // A single child scroll view is used instead of a ListView
                  // because the Row implies the cross axis alignment to center,
                  // but ListView implies to top
                  child: SingleChildScrollView(
                    key: listKey,
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: pane.items.map((item) {
                        return _buildItem(context, item);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          if (pane.autoSuggestBox != null)
            Container(
              margin: const EdgeInsets.only(left: 50.0),
              constraints: const BoxConstraints(
                minWidth: 215.0,
                maxWidth: _kOpenNavigationPanelWidth,
              ),
              child: pane.autoSuggestBox!,
            ),
          ...pane.footerItems.map((item) {
            return _buildItem(context, item);
          }),
        ]),
      ),
    );
    return topBar;
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({
    required this.pane,
    this.paneKey,
    this.listKey,
    this.onToggle,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final GlobalKey? listKey;
  final VoidCallback? onToggle;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    assert(debugCheckHasFluentTheme(context));
    if (item is PaneItemHeader) {
      /// Item Header is not visible on compact pane
      return const SizedBox();
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.horizontal);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return item.build(
        context,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
        },
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    const EdgeInsetsGeometry topPadding = EdgeInsets.only(bottom: 6.0);
    final bool showReplacement =
        pane.autoSuggestBox != null && pane.autoSuggestBoxReplacement != null;
    return AnimatedContainer(
      key: paneKey,
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      width: pane.size?.compactWidth ?? _kCompactNavigationPanelWidth,
      child: pane.indicatorBuilder(
        context: context,
        pane: pane,
        child: Align(
          key: pane.paneKey,
          alignment: Alignment.topCenter,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                ).build(
                  context,
                  false,
                  () {
                    onToggle?.call();
                  },
                ),
              ),
            Expanded(
              child: Scrollbar(
                isAlwaysShown: false,
                child: ListView(key: listKey, primary: true, children: [
                  ...pane.items.map((item) {
                    return _buildItem(context, item);
                  }),
                ]),
              ),
            ),
            ...pane.footerItems.map((item) {
              return _buildItem(context, item);
            }),
          ]),
        ),
      ),
    );
  }
}

class _OpenNavigationPane extends StatelessWidget {
  _OpenNavigationPane({
    required this.pane,
    this.paneKey,
    this.listKey,
    this.onToggle,
    this.onItemSelected,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final GlobalKey? listKey;
  final VoidCallback? onToggle;
  final VoidCallback? onItemSelected;

  static Widget buildItem(
    BuildContext context,
    NavigationPane pane,
    NavigationPaneItem item, [
    VoidCallback? onChanged,
    bool autofocus = false,
  ]) {
    if (item is PaneItemHeader) {
      return item.build(context);
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.horizontal);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return item.build(
        context,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
          onChanged?.call();
        },
        autofocus: autofocus,
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    const EdgeInsetsGeometry topPadding = EdgeInsets.only(bottom: 6.0);
    final menuButton = () {
      if (pane.menuButton != null) return pane.menuButton!;
      if (onToggle != null) {
        return NavigationPane.buildMenuButton(
          context,
          Text(FluentLocalizations.of(context).closeNavigationTooltip),
          pane,
          onPressed: () {
            onToggle?.call();
          },
        );
      }
      return const SizedBox.shrink();
    }();
    var paneWidth = pane.size?.openWidth ?? _kOpenNavigationPanelWidth;
    if (pane.size?.openMaxWidth != null &&
        paneWidth > pane.size!.openMaxWidth!) {
      paneWidth = pane.size!.openMaxWidth!;
    }
    if (pane.size?.openMinWidth != null &&
        paneWidth < pane.size!.openMinWidth!) {
      paneWidth = pane.size!.openMinWidth!;
    }

    return AnimatedContainer(
      key: paneKey,
      duration: theme.animationDuration ?? Duration.zero,
      curve: theme.animationCurve ?? Curves.linear,
      width: paneWidth,
      child: pane.indicatorBuilder(
        context: context,
        pane: pane,
        child: Column(key: pane.paneKey, children: [
          Container(
            margin: pane.autoSuggestBox != null ? EdgeInsets.zero : topPadding,
            height: kOneLineTileHeight,
            child: () {
              if (pane.header != null) {
                return Row(children: [
                  menuButton,
                  Expanded(
                    child: Align(
                      child: pane.header!,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ]);
              } else {
                return menuButton;
              }
            }(),
          ),
          if (pane.autoSuggestBox != null)
            Container(
              padding: theme.iconPadding ?? EdgeInsets.zero,
              height: 41.0,
              alignment: Alignment.center,
              margin: topPadding,
              child: pane.autoSuggestBox!,
            ),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: false,
              child: ListView(key: listKey, primary: true, children: [
                ...pane.items.map((item) {
                  return buildItem(context, pane, item, onItemSelected);
                }),
              ]),
            ),
          ),
          ...pane.footerItems.map((item) {
            return buildItem(context, pane, item, onItemSelected);
          }),
        ]),
      ),
    );
  }
}
