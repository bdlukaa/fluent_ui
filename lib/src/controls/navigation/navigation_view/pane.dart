part of 'view.dart';

const kCompactNavigationPanelWidth = 50.0;

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

class NavigationPaneItem {
  final Key? key;

  const NavigationPaneItem({this.key});
}

class PaneItem extends NavigationPaneItem {
  const PaneItem({
    Key? key,
    required this.title,
    this.icon,
  }) : super(key: key);

  final Widget title;
  final Widget? icon;
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

class NavigationPane {
  const NavigationPane({
    this.key,
    this.selected,
    this.onChanged,
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.displayMode = PaneDisplayMode.auto,
    this.appBar,
  });

  final PaneDisplayMode displayMode;

  final Key? key;
  final List<NavigationPaneItem> items;

  final List<NavigationPaneItem> footerItems;

  /// An optional control to allow for app-level search. Usually
  /// an [AutoSuggestBox]
  final Widget? autoSuggestBox;

  /// Usualy an [AppWindowBar]
  final Widget? appBar;

  /// The current selected index.
  final int? selected;
  final ValueChanged<int>? onChanged;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: theme.typography.base ?? TextStyle(),
          child: item.header,
        ),
      );
    } else if (item is PaneItemSeparator) {
      return Divider(
        direction: Axis.vertical,
        style: DividerThemeData(margin: (axis) {
          return EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          );
        }),
      );
    } else if (item is PaneItem) {
      final style = NavigationPanelThemeData.standard(context.theme).copyWith(
        context.theme.navigationPanelTheme,
      );
      final selected = pane.isSelected(item);
      return SizedBox(
        width: 41.0,
        child: HoverButton(
          onPressed: () {
            pane.onChanged?.call(pane.effectiveIndexOf(item));
          },
          builder: (context, state) {
            final child = AnimatedContainer(
              duration: style.animationDuration ?? Duration.zero,
              curve: style.animationCurve ?? standartCurve,
              color: ButtonThemeData.uncheckedInputColor(context.theme, state),
              child: Column(children: [
                if (item.icon != null)
                  Expanded(
                    child: Padding(
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
                    ),
                  ),
                AnimatedSwitcher(
                  duration: style.animationDuration ?? Duration.zero,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 1),
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
                    height: 4,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    color: selected ? style.highlightColor : Colors.transparent,
                  ),
                ),
              ]),
            );
            return Semantics(
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
        ...pane.items.map((item) {
          return _buildItem(context, item);
        }),
        Spacer(),
        if (pane.autoSuggestBox != null) Flexible(child: pane.autoSuggestBox!),
        ...pane.footerItems.map((item) {
          if (item is PaneItem) {
            assert(item.icon != null, 'There must be an icon');
            assert(item.title is Text,
                'You can only provide a text widget for the title on footer items');
            return SizedBox(
              height: kOneLineTileHeight,
              child: IconButton(
                icon: item.icon!,
                style: ButtonThemeData(
                  margin: EdgeInsets.only(left: 8.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  scaleFactor: 1.0,
                ),
                onPressed: () {},
              ),
            );
          } else {
            throw UnsupportedError(
              '${item.runtimeType} is not a supported pane item type.',
            );
          }
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
        direction: Axis.vertical,
        style: DividerThemeData(margin: (axis) {
          return EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          );
        }),
      );
    } else if (item is PaneItem) {
      final style = NavigationPanelThemeData.standard(context.theme).copyWith(
        context.theme.navigationPanelTheme,
      );
      final selected = pane.isSelected(item);
      return SizedBox(
        height: 41.0,
        child: HoverButton(
          onPressed: () {
            pane.onChanged?.call(pane.effectiveIndexOf(item));
          },
          builder: (context, state) {
            final child = AnimatedContainer(
              duration: style.animationDuration ?? Duration.zero,
              curve: style.animationCurve ?? standartCurve,
              color: ButtonThemeData.uncheckedInputColor(context.theme, state),
              child: Row(children: [
                AnimatedSwitcher(
                  duration: style.animationDuration ?? Duration.zero,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1, 0),
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
                    height: double.infinity,
                    width: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    color: selected ? style.highlightColor : Colors.transparent,
                  ),
                ),
                if (item.icon != null)
                  Padding(
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
                  ),
              ]),
            );
            return Semantics(
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
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Acrylic(
      width: kCompactNavigationPanelWidth,
      child: Column(children: [
        // if (menu != null)
        //   Padding(
        //     padding: EdgeInsets.only(bottom: 22),
        //     child: NavigationPanelMenu(
        //       item: menu!,
        //       compact: true,
        //       onTap: onMenuTapped,
        //     ),
        //   ),
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
