part of 'view.dart';

const kCompactNavigationPanelWidth = 50.0;
const kOpenNavigationPanelWidth = 320.0;

/// You can use the PaneDisplayMode property to configure different
/// navigation styles, or display modes, for the NavigationView
///
/// ![Display Modes](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
enum PaneDisplayMode {
  top,

  /// The pane is expanded and positioned to the left of the content.
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

  /// Let the [NavigationPanel] decide what display mode should be used
  /// based on the width. This is used by default on [NavigationPanel].
  /// In Auto mode, the [NavigationPanel] adapts between [minimal] when
  /// the window is narrow, to [compact], and then [open] as the window
  /// gets wider.
  ///
  /// ![Automatic Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
  auto,
}

class NavigationPaneItem with Diagnosticable {
  final Key? key;

  const NavigationPaneItem({this.key});
}

class PaneItem extends NavigationPaneItem {
  const PaneItem({
    Key? key,
    required this.title,
    this.icon,
  }) : super(key: key);

  /// The title used by this item. If the display mode is top
  /// or compact, this is shown as a tooltip. If it's open, this
  /// is shown by the side of the [icon].
  ///
  /// This is also used by [Semantics] to allow screen readers to
  /// read the screen.
  final String title;

  /// The icon used by this item.
  final Widget? icon;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }

  static Widget buildPaneItemButton(
    BuildContext context,
    PaneItem item,
    PaneDisplayMode displayMode,
    bool selected,
    VoidCallback onPressed, {
    bool showTextOnTop = true,
  }) {
    assert(displayMode != PaneDisplayMode.auto);
    final bool isTop = displayMode == PaneDisplayMode.top;
    final bool isCompact = displayMode == PaneDisplayMode.compact;
    final bool isOpen = displayMode == PaneDisplayMode.open;
    final style = NavigationPanelThemeData.standard(context.theme).copyWith(
      context.theme.navigationPanelTheme,
    );

    final Widget result = SizedBox(
      key: item.key,
      height: !isTop ? 41.0 : null,
      child: HoverButton(
        onPressed: onPressed,
        builder: (context, state) {
          final textStyle = selected
              ? style.selectedTextStyle!(state)
              : style.unselectedTextStyle!(state);
          final textResult = Padding(
            padding: style.labelPadding ?? EdgeInsets.zero,
            child: Text(item.title, style: textStyle),
          );
          Widget child = Flex(
            direction: isTop ? Axis.vertical : Axis.horizontal,
            textDirection: isTop ? ui.TextDirection.ltr : ui.TextDirection.rtl,
            children: [
              if (isOpen) Expanded(child: textResult),
              if (item.icon != null)
                () {
                  final icon = Padding(
                    padding: style.iconPadding ?? EdgeInsets.zero,
                    child: FluentTheme(
                      data: context.theme.copyWith(
                        iconTheme: IconThemeData(
                          color: selected
                              ? style.selectedIconColor!(state)
                              : style.unselectedIconColor!(state),
                        ),
                      ),
                      child: item.icon!,
                    ),
                  );
                  if (isOpen) return icon;
                  return Expanded(child: icon);
                }(),
            ],
          );
          if (isTop && showTextOnTop)
            child = Row(mainAxisSize: MainAxisSize.min, children: [
              child,
              Padding(
                child: textResult,
                padding: EdgeInsets.only(right: 8.0),
              ),
            ]);
          child = AnimatedContainer(
            duration: style.animationDuration ?? Duration.zero,
            curve: style.animationCurve ?? standartCurve,
            color: ButtonThemeData.uncheckedInputColor(context.theme, state),
            child: child,
          );
          child = Stack(fit: StackFit.passthrough, children: [
            child,
            Align(
              alignment: isTop ? Alignment.bottomCenter : Alignment.centerLeft,
              child: AnimatedSwitcher(
                duration: style.animationDuration ?? Duration.zero,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(!isTop ? -1 : 0, isTop ? 1 : 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: style.animationCurve ?? standartCurve,
                    )),
                    child: child,
                  );
                },
                child: Container(
                  key: ValueKey<bool>(selected),
                  height: isTop ? 4 : double.infinity,
                  width: !isTop ? 4 : null,
                  margin: EdgeInsets.symmetric(
                    horizontal: isTop ? 10 : 0,
                    vertical: !isTop ? 10 : 0,
                  ),
                  color: selected ? style.highlightColor : Colors.transparent,
                ),
              ),
            ),
          ]);
          return Semantics(
            label: item.title,
            selected: selected,
            child: FocusBorder(
              child: child,
              focused: state.isFocused,
              renderOutside: false,
            ),
          );
        },
      ),
    );
    if (((isTop && !showTextOnTop) || isCompact) && item.title.isNotEmpty)
      return Tooltip(message: item.title, child: result);
    return result;
  }
}

class PaneItemSeparator extends NavigationPaneItem {
  const PaneItemSeparator({Key? key}) : super(key: key);
}

class PaneItemHeader extends NavigationPaneItem {
  const PaneItemHeader({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;
}

class NavigationPane with Diagnosticable {
  const NavigationPane({
    this.key,
    this.selected,
    this.onChanged,
    this.header,
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.autoSuggestBoxReplacement,
    this.displayMode = PaneDisplayMode.auto,
    this.appBar,
  });

  final Key? key;

  /// Use this property to customize how the pane will be displayed.
  /// [PaneDisplayMode.auto] is used by default.
  final PaneDisplayMode displayMode;

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
  /// It's usually an [Icon] with [Icons.search] as the icon.
  final Widget? autoSuggestBoxReplacement;

  /// Usualy an [AppWindowBar]
  final Widget? appBar;

  /// The current selected index.
  final int? selected;

  /// Called when the current index changes.
  final ValueChanged<int>? onChanged;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('displayMode', displayMode));
    properties.add(IterableProperty('items', items));
    properties.add(IterableProperty('footerItems', footerItems));
    properties.add(IntProperty('selected', selected));
  }

  /// A all of the items displayed on this pane.
  List<NavigationPaneItem> get allItems {
    return items + footerItems;
  }

  /// Check if the provided [item] is selected on not.
  bool isSelected(NavigationPaneItem item) {
    return effectiveIndexOf(item) == selected;
  }

  /// Get the effective index of the navigation pane.
  int effectiveIndexOf(NavigationPaneItem item) {
    return (allItems..removeWhere((i) => i is! PaneItem)).indexOf(item);
  }
}

/// Creates a top navigation pane.
///
/// ![Top Pane Anatomy](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-horizontal.png)
class _TopNavigationPane extends StatelessWidget {
  _TopNavigationPane({required this.pane}) : super(key: pane.key);

  final NavigationPane pane;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    if (item is PaneItemHeader) {
      return Padding(
        key: item.key,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: theme.typography.base ?? TextStyle(),
          child: item.header,
        ),
      );
    } else if (item is PaneItemSeparator) {
      return Divider(
        key: item.key,
        direction: Axis.vertical,
        style: DividerThemeData(margin: (axis) {
          return EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          );
        }),
      );
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
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
    Widget topBar = Acrylic(
      height: kOneLineTileHeight,
      child: Row(children: [
        if (pane.header != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: pane.header!,
          ),
        ...pane.items.map((item) {
          return _buildItem(context, item);
        }),
        Spacer(),
        if (pane.autoSuggestBox != null) Flexible(child: pane.autoSuggestBox!),
        ...pane.footerItems.map((item) {
          return _buildItem(context, item);
        }),
      ]),
    );
    if (pane.appBar != null) {
      return Column(children: [
        pane.appBar!,
        topBar,
      ]);
    }
    return topBar;
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({required this.pane}) : super(key: pane.key);

  final NavigationPane pane;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    assert(debugCheckHasFluentTheme(context));
    if (item is PaneItemHeader) {
      /// Item Header is not visible on compact pane
      return SizedBox();
    } else if (item is PaneItemSeparator) {
      return Divider(
        key: item.key,
        direction: Axis.horizontal,
        style: DividerThemeData(margin: (axis) {
          return EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          );
        }),
      );
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
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
    const EdgeInsetsGeometry topPadding = const EdgeInsets.only(bottom: 6.0);
    final bool showReplacement =
        pane.autoSuggestBox != null && pane.autoSuggestBoxReplacement != null;
    return Acrylic(
      width: kCompactNavigationPanelWidth,
      child: Column(children: [
        Padding(
          padding: showReplacement ? EdgeInsets.zero : topPadding,
          child: PaneItem.buildPaneItemButton(
            context,
            PaneItem(title: 'Open Navigation', icon: Icon(Icons.menu)),
            pane.displayMode,
            false,
            () {},
          ),
        ),
        if (showReplacement)
          Padding(
            padding: topPadding,
            child: PaneItem.buildPaneItemButton(
              context,
              PaneItem(
                title: 'Click to search',
                icon: pane.autoSuggestBoxReplacement,
              ),
              pane.displayMode,
              false,
              () {},
            ),
          ),
        Expanded(
          child: ListView(children: [
            ...pane.items.map((item) {
              return _buildItem(context, item);
            }),
          ]),
        ),
        ...pane.footerItems.map((item) {
          return _buildItem(context, item);
        }),
      ]),
    );
  }
}

class _OpenNavigationPane extends StatelessWidget {
  _OpenNavigationPane({required this.pane}) : super(key: pane.key);

  final NavigationPane pane;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    if (item is PaneItemHeader) {
      return Padding(
        key: item.key,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: theme.typography.base ?? TextStyle(),
          child: item.header,
        ),
      );
    } else if (item is PaneItemSeparator) {
      return Divider(
        key: item.key,
        direction: Axis.horizontal,
        style: DividerThemeData(margin: (axis) {
          return EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          );
        }),
      );
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
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
    const EdgeInsetsGeometry topPadding = const EdgeInsets.only(bottom: 6.0);
    final menuButton = SizedBox(
      width: kCompactNavigationPanelWidth,
      child: PaneItem.buildPaneItemButton(
        context,
        PaneItem(title: 'Close navigation', icon: Icon(Icons.menu)),
        PaneDisplayMode.compact,
        false,
        () {},
      ),
    );
    return Acrylic(
      width: kOpenNavigationPanelWidth,
      child: Column(children: [
        Padding(
          padding: pane.autoSuggestBox != null ? EdgeInsets.zero : topPadding,
          child: () {
            if (pane.header != null)
              return Row(children: [
                menuButton,
                Expanded(
                  child: Align(
                    child: pane.header!,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ]);
            else
              return menuButton;
          }(),
        ),
        if (pane.autoSuggestBox != null)
          Container(
            height: 41.0,
            margin: topPadding,
            child: pane.autoSuggestBox!,
          ),
        Expanded(
          child: ListView(children: [
            ...pane.items.map((item) {
              return _buildItem(context, item);
            }),
          ]),
        ),
        ...pane.footerItems.map((item) {
          return _buildItem(context, item);
        }),
      ]),
    );
  }
}

class AppWindowBar extends StatelessWidget {
  const AppWindowBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.remainingSpace,
  }) : super(key: key);

  final Widget? leading;

  /// If [leading] is null and this property is true, the
  /// widget will decide if there's any leading widget that
  /// can be automatically implied, such as the back button,
  /// if the route can be poped.
  final bool automaticallyImplyLeading;

  final Widget? title;

  final Widget? remainingSpace;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    return Acrylic(
      enabled: false,
      child: Row(children: [
        if (leading != null)
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: leading,
          )
        else if (canPop && automaticallyImplyLeading)
          Container(
            width: 46.0,
            child: Tooltip(
              message: 'Back',
              child: IconButton(
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonThemeData(
                  margin: EdgeInsets.zero,
                  scaleFactor: 1.0,
                ),
              ),
            ),
          ),
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: DefaultTextStyle(
              style: FluentTheme.of(context).typography.caption!,
              child: title!,
            ),
          ),
        if (remainingSpace != null) Expanded(child: remainingSpace!),
      ]),
    );
  }
}
