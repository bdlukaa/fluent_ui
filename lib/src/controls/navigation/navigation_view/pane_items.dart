part of 'view.dart';

/// Base class for items that can be displayed in a [NavigationPane].
///
/// Subclasses include [PaneItem], [PaneItemSeparator], [PaneItemHeader],
/// [PaneItemAction], [PaneItemExpander], and [PaneItemWidgetAdapter].
abstract class NavigationPaneItem with Diagnosticable {
  /// The key used for the item itself.
  ///
  /// See also:
  ///
  ///   * [PaneItem.build], which assigns this to its children
  final Key? key;

  /// The parent item of this item.
  ///
  /// If null, this is a root item.
  ///
  /// See also:
  ///
  ///   * [PaneItemExpander], which creates hierarchical navigation
  NavigationPaneItem? parent;

  /// Creates a navigation pane item.
  NavigationPaneItem({this.key});

  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]);
}

/// A widget that provides information about a specific [NavigationPaneItem]
/// to its descendants via an [InheritedWidget].
///
/// Use this for context-aware styling, focus management, or interacting with
/// the current item deeper in the widget tree (e.g., for badges, secondary actions, etc).
class _PaneItemContext extends InheritedWidget {
  const _PaneItemContext({
    required this.item,
    required super.child,
    required this.index,
    required this.isSelected,
    required this.depth,
  });

  /// The navigation pane item being provided.
  final PaneItem item;

  /// The index of the current item.
  final int index;

  /// Whether the current item is selected.
  final bool isSelected;

  /// The depth of this item in the hierarchy.
  final int depth;

  /// Retrieve the [_PaneItemContext], throws if not found.
  static _PaneItemContext of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PaneItemContext>()!;
  }

  @override
  bool updateShouldNotify(_PaneItemContext oldWidget) {
    // Update children if item or depth changes.
    return item != oldWidget.item || depth != oldWidget.depth;
  }
}

/// The item used by [NavigationView] to display the tiles.
///
/// On [PaneDisplayMode.compact], only [icon] is displayed, and [title] is
/// used as a tooltip. On the other display modes, [icon] and [title] are
/// displayed in a [Row].
///
/// This is the only [NavigationPaneItem] that is affected by [NavigationIndicator]s
///
/// See also:
///
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemHeader], used to label groups of items.
///   * [PaneItemAction], the item used for execute an action on click
///   * [PaneItemExpander], which creates hierarchical navigation
class PaneItem extends NavigationPaneItem {
  /// Creates a pane item.
  PaneItem({
    this.icon,
    this.body,
    super.key,
    this.title,
    this.trailing,
    this.infoBadge,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.tileColor,
    this.selectedTileColor,
    this.onTap,
    this.enabled = true,
  });

  /// The title used by this item. If the display mode is top
  /// or compact, this is shown as a tooltip. If it's open, this
  /// is shown by the side of the [icon].
  ///
  /// The text style is fetched from the closest [NavigationPaneThemeData]
  ///
  /// If this is a [Text] or [RichText], its text data is used to display the
  /// tooltip. The tooltip is only displayed only on compact mode and when the
  /// item is not disabled. It is also used by [Semantics] to allow screen
  /// readers to read the screen.
  ///
  /// Usually a [Text] or [RichText] widget.
  final Widget? title;

  /// The icon used by this item.
  ///
  /// Usually an [Icon] widget
  final Widget? icon;

  /// The info badge used by this item.
  ///
  /// Usually an [InfoBadge] widget.
  final Widget? infoBadge;

  /// The trailing widget used by this item. If the current display mode is
  /// compact, this is not disaplayed
  ///
  /// Usually an [Icon] widget
  final Widget? trailing;

  /// The body of the view attached to this tab.
  ///
  /// If null, the item will not be navigable and will only serve as a container
  /// (useful for [PaneItemExpander] that should only expand/collapse).
  final Widget? body;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.mouseCursor}
  final MouseCursor? mouseCursor;

  /// The color of the tile when unselected.
  ///
  /// If null, [NavigationPaneThemeData.tileColor] is used.
  final WidgetStateProperty<Color?>? tileColor;

  /// The color of the tile when selected.
  ///
  /// If null, [NavigationPaneThemeData.tileColor] with the resolved button state.
  final WidgetStateProperty<Color?>? selectedTileColor;

  /// Called when the item is tapped, regardless of selected or not
  final VoidCallback? onTap;

  /// Whether this pane item is disabled.
  ///
  /// A pane item can be disabled for many reasons, such as a page not being
  /// available in the current moment.
  ///
  /// If false, [onTap] is ignored.
  ///
  /// See also:
  ///
  ///  * [HoverButton.forceEnabled]
  final bool enabled;

  /// Builds the pane item widget for display in the navigation pane.
  ///
  /// This method handles all display modes ([PaneDisplayMode.compact],
  /// [PaneDisplayMode.expanded], [PaneDisplayMode.minimal], and [PaneDisplayMode.top])
  /// and adapts the layout accordingly:
  ///
  /// - **Compact mode**: Shows only the icon with tooltip on hover
  /// - **Open/Minimal mode**: Shows icon and title in a row with optional trailing
  /// - **Top mode**: Shows icon and title horizontally with different styling
  ///
  /// The method also handles:
  /// - Selection state and visual feedback
  /// - Info badge positioning
  /// - Navigation indicator integration
  /// - Focus management and accessibility
  ///
  /// You can customize the appearance by overriding this method.
  Widget build({
    required BuildContext context,
    required bool selected,
    required VoidCallback? onPressed,
    required PaneDisplayMode? displayMode,
    required int itemIndex,
    bool? autofocus,
    bool showTextOnTop = true,
    int depth = 0,
  }) {
    final maybeView = NavigationView.dataOf(context);
    final mode = displayMode ?? maybeView.displayMode;
    assert(mode != PaneDisplayMode.auto);
    assert(debugCheckHasFluentTheme(context));

    final theme = NavigationPaneTheme.of(context);

    final titleText = title?._getProperty<String>() ?? '';
    final baseStyle = title?._getProperty<TextStyle>() ?? const TextStyle();

    final isTop = mode == PaneDisplayMode.top;
    final isMinimal = mode == PaneDisplayMode.minimal;
    final isCompact = mode == PaneDisplayMode.compact;

    final onItemTapped =
        (onPressed == null && onTap == null) ||
            !enabled ||
            // Do not allow tapping if the panes are animating
            maybeView.isTransitioning
        ? null
        : () {
            onPressed?.call();
            onTap?.call();
          };

    final button = HoverButton(
      autofocus: autofocus ?? this.autofocus,
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      },
      onPressed: onItemTapped,
      cursor: mouseCursor,
      focusEnabled: !isMinimal || maybeView.isMinimalPaneOpen,
      forceEnabled: enabled,
      builder: (context, states) {
        final shouldShowTooltip =
            ((isTop && !showTextOnTop) || isCompact) &&
            titleText.isNotEmpty &&
            !states.isDisabled;
        final textStyle = () {
          final style = !isTop
              ? (selected
                    ? theme.selectedTextStyle?.resolve(states)
                    : theme.unselectedTextStyle?.resolve(states))
              : (selected
                    ? theme.selectedTopTextStyle?.resolve(states)
                    : theme.unselectedTopTextStyle?.resolve(states));
          return style?.merge(baseStyle) ?? baseStyle;
        }();

        final textResult = title != null
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsetsDirectional.zero,
                child: DefaultTextStyle(
                  style: textStyle,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  child: title!,
                ),
              )
            : null;

        Widget result() {
          switch (mode) {
            case PaneDisplayMode.compact:
              return Container(
                key: key,
                constraints: const BoxConstraints(
                  minHeight: kPaneItemMinHeight,
                ),
                alignment: AlignmentDirectional.centerStart,
                padding: theme.iconPadding ?? EdgeInsetsDirectional.zero,
                child: infoBadge != null
                    ? Stack(
                        alignment: AlignmentDirectional.center,
                        clipBehavior: Clip.none,
                        children: [
                          ?icon,
                          PositionedDirectional(
                            end: -10,
                            top: -10,
                            child: infoBadge!,
                          ),
                        ],
                      )
                    : icon,
              );
            case PaneDisplayMode.minimal:
            case PaneDisplayMode.expanded:
              final shouldShowTrailing = !maybeView.isTransitioning;

              return ConstrainedBox(
                key: key,
                constraints: const BoxConstraints(
                  minHeight: kPaneItemMinHeight,
                ),
                child: ClipRect(
                  child: Row(
                    children: [
                      SizedBox(width: depth * 28),
                      Padding(
                        padding:
                            theme.iconPadding ?? EdgeInsetsDirectional.zero,
                        child: Center(child: icon),
                      ),

                      Expanded(child: textResult ?? const SizedBox.shrink()),
                      if (shouldShowTrailing) ...[
                        if (infoBadge != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: infoBadge,
                          ),
                        if (trailing != null)
                          IconTheme.merge(
                            data: const IconThemeData(size: 16),
                            child: trailing!,
                          ),
                      ],
                    ],
                  ),
                ),
              );
            case PaneDisplayMode.top:
              final Widget result = ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: kPaneItemTopMinWidth,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: theme.iconPadding ?? EdgeInsetsDirectional.zero,
                      child: Center(child: icon),
                    ),
                    if (showTextOnTop) ?textResult,
                    if (trailing != null)
                      IconTheme.merge(
                        data: const IconThemeData(size: 16),
                        child: trailing!,
                      ),
                  ],
                ),
              );
              if (infoBadge != null) {
                return Stack(
                  key: key,
                  clipBehavior: Clip.none,
                  children: [
                    result,
                    PositionedDirectional(end: -3, child: infoBadge!),
                  ],
                );
              }
              return KeyedSubtree(key: key, child: result);
            default:
              throw UnsupportedError('$mode is not a supported type');
          }
        }

        return Semantics(
          label: titleText.isEmpty ? null : titleText,
          selected: selected,
          child: Container(
            // TODO(bdlukaa): Put this into the theme
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: () {
                final tileColor =
                    this.tileColor ??
                    theme.tileColor ??
                    kDefaultPaneItemColor(context, isTop);
                final newStates = states.toSet()..remove(WidgetState.disabled);
                if (selected && selectedTileColor != null) {
                  return selectedTileColor!.resolve(newStates);
                }
                return tileColor.resolve(
                  selected
                      ? {
                          if (states.isHovered)
                            WidgetState.pressed
                          else
                            WidgetState.hovered,
                        }
                      : newStates,
                );
              }(),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color:
                    textStyle.color ??
                    (selected
                        ? theme.selectedIconColor?.resolve(states)
                        : theme.unselectedIconColor?.resolve(states)),
                size: textStyle.fontSize ?? 16.0,
              ),
              child: FocusBorder(
                focused: states.isFocused,
                renderOutside: false,
                child: shouldShowTooltip
                    ? Tooltip(
                        richMessage: title?._getProperty<InlineSpan>(),
                        style: TooltipThemeData(textStyle: baseStyle),
                        child: result(),
                      )
                    : result(),
              ),
            ),
          ),
        );
      },
    );

    return _PaneItemContext(
      item: this,
      index: itemIndex,
      isSelected: selected,
      depth: depth,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 4),
        child: () {
          if (maybeView.pane?.indicator != null) {
            return Stack(
              children: [
                button,
                Positioned.fill(child: maybeView.pane!.indicator!),
              ],
            );
          }

          return button;
        }(),
      ),
    );
  }

  /// Creates a copy of this [PaneItem] with the given fields replaced.
  PaneItem copyWith({
    Widget? title,
    Widget? icon,
    Widget? infoBadge,
    Widget? trailing,
    Widget? body,
    FocusNode? focusNode,
    bool? autofocus,
    MouseCursor? mouseCursor,
    WidgetStateProperty<Color?>? tileColor,
    WidgetStateProperty<Color?>? selectedTileColor,
    VoidCallback? onTap,
    bool? enabled,
  }) {
    return PaneItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      infoBadge: infoBadge ?? this.infoBadge,
      trailing: trailing ?? this.trailing,
      body: body ?? this.body,
      focusNode: focusNode ?? this.focusNode,
      autofocus: autofocus ?? this.autofocus,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      onTap: onTap ?? this.onTap,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = NavigationViewContext.of(context);

    final selected = view.pane?.isSelected(this) ?? false;
    final baseStyle = title?._getProperty<TextStyle>() ?? const TextStyle();

    return MenuFlyoutItem(
      selected: selected,
      closeAfterClick: false,
      text: title != null
          ? Padding(
              padding: theme.labelPadding ?? EdgeInsetsDirectional.zero,
              child: DefaultTextStyle(
                style: baseStyle,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.start,
                maxLines: 1,
                child: title!,
              ),
            )
          : const SizedBox.shrink(),
      onPressed: () => onItemPressed?.call(this),
      trailing: () {
        if (infoBadge != null && trailing == null) {
          return infoBadge;
        } else if (trailing != null && infoBadge == null) {
          return trailing;
        } else if (trailing != null && infoBadge != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [trailing!, infoBadge!],
          );
        } else {
          return null;
        }
      }(),
      // padding: padding,
    );
  }
}

/// Separators for grouping navigation items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemHeader], used to label groups of items.
///   * [PaneItemAction], the item used for execute an action on click
///   * [PaneItemExpander], which creates hierarchical navigation
class PaneItemSeparator extends NavigationPaneItem {
  /// Creates an item separator.
  PaneItemSeparator({super.key, this.color, this.thickness});

  /// The color used by the [Divider].
  final Color? color;

  /// The separator thickness. Defaults to 1.0
  final double? thickness;

  /// Builds the separator widget.
  Widget build(BuildContext context, Axis direction, {int depth = 0}) {
    return Divider(
      key: key,
      direction: direction,
      style: DividerThemeData(
        thickness: thickness,
        decoration: color != null ? BoxDecoration(color: color) : null,
        verticalMargin: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        horizontalMargin: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
      ),
    );
  }

  @override
  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]) {
    return const MenuFlyoutSeparator();
  }
}

/// Headers for labeling groups of items. This is not displayed if the display
/// mode is [PaneDisplayMode.compact]
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemAction], the item used for execute an action on click
///   * [PaneItemExpander], which creates hierarchical navigation
class PaneItemHeader extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemHeader({required this.header, super.key});

  /// The header. The default style is [NavigationPaneThemeData.itemHeaderTextStyle],
  /// but can be overriten by [Text.style].
  ///
  /// Usually a [Text] widget.
  final Widget header;

  /// Builds the header widget.
  Widget build(BuildContext context, {int depth = 0}) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = NavigationViewContext.of(context);

    return Container(
      key: key,
      constraints: const BoxConstraints(minHeight: kPaneItemHeaderMinHeight),
      padding: (theme.iconPadding ?? EdgeInsetsDirectional.zero)
          .add(
            view.displayMode == PaneDisplayMode.top
                ? EdgeInsetsDirectional.zero
                : theme.headerPadding ?? EdgeInsetsDirectional.zero,
          )
          .add(EdgeInsetsDirectional.only(start: depth * 28)),
      child: DefaultTextStyle.merge(
        style: theme.itemHeaderTextStyle,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
        textAlign: view.displayMode == PaneDisplayMode.top
            ? TextAlign.center
            : TextAlign.left,
        child: header,
      ),
    );
  }

  @override
  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]) {
    return MenuFlyoutItemBuilder(
      builder: (context) {
        final theme = NavigationPaneTheme.of(context);
        return Padding(
          padding: theme.headerPadding ?? EdgeInsetsDirectional.zero,
          child: build(context),
        );
      },
    );
  }
}

/// The item used by [NavigationView] to display the tiles.
///
/// On [PaneDisplayMode.compact], only [icon] is displayed, and [title] is used
/// as a tooltip. On the other display modes, [icon] and [title] are displayed
/// in a [Row].
///
/// The difference with [PaneItem] is that the item is not linked to a page but
/// to an action passed in parameter (callback)
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemHeader], used to label groups of items.
///   * [PaneItemExpander], which creates hierarchical navigation
class PaneItemAction extends PaneItem {
  /// Creates a pane item action.
  PaneItemAction({
    required super.icon,
    required VoidCallback super.onTap,
    super.key,
    super.body = const SizedBox.shrink(),
    super.title,
    super.infoBadge,
    super.focusNode,
    super.autofocus = false,
    super.mouseCursor,
    super.selectedTileColor,
    super.tileColor,
    super.trailing,
    super.enabled = true,
  });
}

/// hierarchical navigation item used on [NavigationView]
///
/// Some apps may have a more complex hierarchical structure that requires more
/// than just a flat list of navigation items. You may want to use top-level
/// navigation items to display categories of pages, with children items
/// displaying specific pages. It is also useful if you have hub-style pages
/// that only link to other pages. For these kinds of cases, you should create a
/// hierarchical [NavigationView].
///
/// ![Navigation View Hierarchy Labeled](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/navigation-view-hierarchy-labeled.png)
///
/// See also:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/navigationview#hierarchical-navigation>
///  * [PaneItem], the item used by [NavigationView] to render tiles
///  * [PaneItemSeparator], used to group navigation items
///  * [PaneItemHeader], used to label groups of items.
class PaneItemExpander extends PaneItem {
  /// Creates a pane item expander.
  ///
  /// If [body] is null, clicking the expander will only toggle expand/collapse
  /// without navigating to a page. This is useful when the expander serves only
  /// as a container for child items.
  ///
  /// Supports nested hierarchies with any number of nesting levels, though
  /// keeping the navigation hierarchy shallow is recommended for better UX.
  PaneItemExpander({
    required super.icon,
    required this.items,
    super.body,
    super.key,
    super.title,
    super.infoBadge,
    super.trailing = kDefaultTrailing,
    super.focusNode,
    super.autofocus = false,
    super.mouseCursor,
    super.tileColor,
    super.selectedTileColor,
    super.onTap,
    this.initiallyExpanded = false,
  });

  /// The child items contained within this expander.
  final List<NavigationPaneItem> items;

  /// Whether the item is initially expanded. Defaults to false
  final bool initiallyExpanded;

  /// The default trailing icon for expanders.
  static const kDefaultTrailing = WindowsIcon(
    WindowsIcons.chevron_down,
    size: 8,
  );

  @override
  Widget build({
    required BuildContext context,
    required bool selected,
    required VoidCallback? onPressed,
    required PaneDisplayMode? displayMode,
    required int itemIndex,
    ValueChanged<PaneItem>? onItemPressed,
    bool? autofocus,
    bool showTextOnTop = true,
    int depth = 0,
  }) {
    final maybeBody = NavigationView.dataOf(context);
    final mode = displayMode ?? maybeBody.displayMode;

    return RepaintBoundary(
      child: _PaneItemExpander(
        key: key,
        item: this,
        items: items,
        displayMode: mode,
        showTextOnTop: showTextOnTop,
        selected: selected,
        onPressed: onPressed,
        onItemPressed: onItemPressed,
        initiallyExpanded: initiallyExpanded,
        depth: depth,
      ),
    );
  }

  @override
  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]) {
    return _MenuFlyoutPaneItemExpander(
      item: this,
      onPressed: () => onItemPressed?.call(this),
      onItemPressed: onItemPressed ?? (_) {},
    );
  }
}

class _PaneItemExpander extends StatefulWidget {
  const _PaneItemExpander({
    required this.item,
    required this.items,
    required this.displayMode,
    required this.showTextOnTop,
    required this.selected,
    required this.onPressed,
    required this.onItemPressed,
    required this.initiallyExpanded,
    this.depth = 0,
    super.key,
  });

  final PaneItem item;
  final List<NavigationPaneItem> items;
  final PaneDisplayMode displayMode;
  final bool showTextOnTop;
  final bool selected;
  final VoidCallback? onPressed;
  final ValueChanged<PaneItem>? onItemPressed;
  final bool initiallyExpanded;

  /// The depth level of this expander in the hierarchy (0 = root level)
  final int depth;

  @override
  State<_PaneItemExpander> createState() => __PaneItemExpanderState();
}

/// State for managing expandable navigation items.
///
/// This state handles:
/// - Expand/collapse animations
/// - State persistence using [PageStorage]
/// - Flyout menu display for compact/minimal modes
/// - Nested expander support with depth tracking
class __PaneItemExpanderState extends State<_PaneItemExpander>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final flyoutController = FlyoutController();

  /// Whether to use a flyout menu instead of inline expansion.
  ///
  /// Flyouts are used in compact and top modes where there isn't
  /// enough space to show expanded children inline.
  bool get useFlyout =>
      widget.displayMode == PaneDisplayMode.compact ||
      widget.displayMode == PaneDisplayMode.top;

  late bool _open;

  /// Whether the expander is currently expanded.
  bool get isExpanded => _open;
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  @override
  void initState() {
    super.initState();
    flyoutController.addListener(_controllerListener);
    _open = widget.initiallyExpanded;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = FluentTheme.of(context);
    controller.duration = theme.fastAnimationDuration;
  }

  void _controllerListener() {
    if (!useFlyout) return;

    if (isExpanded && !flyoutController.isOpen ||
        !isExpanded && flyoutController.isOpen) {
      toggleOpen(doFlyout: false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    flyoutController.dispose();
    super.dispose();
  }

  int get index {
    final body = NavigationViewContext.of(context);
    return body.pane?.effectiveIndexOf(widget.item) ?? 0;
  }

  /// Checks if any child of this expander is currently selected
  bool get hasSelectedChild {
    final body = NavigationView.dataOf(context);
    if (body.pane == null) return false;

    bool checkSelected(NavigationPaneItem item) {
      if (item is PaneItemExpander) {
        if (body.pane!.isSelected(item)) return true;
        if (item.items.any(checkSelected)) return true;
      } else if (item is PaneItem) {
        return body.pane!.isSelected(item);
      }
      return false;
    }

    return widget.items.any(checkSelected);
  }

  void toggleOpen({bool doFlyout = true}) {
    if (!mounted) return;
    setState(() => _open = !_open);
    final view = NavigationView.of(context);
    final viewData = NavigationView.dataOf(context);

    if (hasSelectedChild) {
      // If the expander has a selected child, update the previous item index
      // to -1 to prevent the sticky indicator from animating undulately.
      view._updatePreviousItemIndex(-1);
    }

    if (isExpanded) {
      if (useFlyout && doFlyout && flyoutController.isAttached) {
        final body = NavigationViewContext.of(context);
        final displayMode = body.displayMode;
        final navigationTheme = NavigationPaneTheme.of(context);

        flyoutController.showFlyout<void>(
          placementMode: displayMode == PaneDisplayMode.compact
              ? FlyoutPlacementMode.rightTop
              : FlyoutPlacementMode.bottomCenter,
          forceAvailableSpace: true,
          barrierColor: Colors.transparent,
          builder: (context) {
            return NavigationViewContext.copy(
              parent: body,
              child: MenuFlyout(
                items: widget.items.map<MenuFlyoutItemBase>((item) {
                  if (item is PaneItemExpander) {
                    return _MenuFlyoutPaneItemExpander(
                      item: item,
                      onPressed: () {
                        if (viewData.pane?.canChangeTo(item) ?? false) {
                          Navigator.pop(context);
                          widget.onPressed?.call();
                          item.onTap?.call();
                          viewData.pane?.changeTo(item);
                        }
                      },
                      onItemPressed:
                          widget.onItemPressed ??
                          (item) {
                            if (viewData.pane?.canChangeTo(item) ?? false) {
                              Navigator.pop(context);
                              item.onTap?.call();
                              viewData.pane?.changeTo(item);
                            }
                          },
                    );
                  } else if (item is PaneItem) {
                    return _PaneItemExpanderMenuItem(
                      item: item,
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onItemPressed?.call(item);
                        item.onTap?.call();
                        viewData.pane?.changeTo(item);
                      },
                      isSelected: body.pane!.isSelected(item),
                    );
                  } else if (item is PaneItemSeparator) {
                    return const MenuFlyoutSeparator();
                  } else if (item is PaneItemHeader) {
                    return MenuFlyoutItemBuilder(
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          margin: const EdgeInsetsDirectional.only(bottom: 4),
                          child: DefaultTextStyle.merge(
                            style: navigationTheme.itemHeaderTextStyle,
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            child: item.header,
                          ),
                        );
                      },
                    );
                  } else {
                    throw UnsupportedError(
                      '${item.runtimeType} is not a supported item type',
                    );
                  }
                }).toList(),
              ),
            );
          },
        );
      }

      controller.forward();
    } else {
      if (useFlyout && doFlyout && flyoutController.isOpen) {
        Navigator.of(context).pop();
      }
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final view = NavigationViewContext.of(context);

    final expanderIndex = view.pane!.effectiveIndexOf(widget.item);
    final isExpanderSelected = widget.selected;

    final expanderWidget = _ForceShowIndicator(
      forceShow: !isExpanded && hasSelectedChild,
      child: widget.item
          .copyWith(
            trailing: GestureDetector(
              onTap: toggleOpen,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => RotationTransition(
                    turns: controller.drive(
                      Tween<double>(
                        begin: isExpanded ? 0 : 1.0,
                        end: isExpanded ? 0.5 : 0.5,
                      ),
                    ),
                    child: child,
                  ),
                  child: widget.item.trailing,
                ),
              ),
            ),
          )
          .build(
            context: context,
            selected: isExpanderSelected,
            onPressed: () {
              if (widget.item.body != null) {
                widget.onPressed?.call();
              }
              toggleOpen();
            },
            displayMode: widget.displayMode,
            showTextOnTop: widget.showTextOnTop,
            itemIndex: expanderIndex,
            depth: widget.depth,
          ),
    );

    if (widget.items.isEmpty) {
      return expanderWidget;
    }

    final displayMode = view.displayMode;
    switch (displayMode) {
      case PaneDisplayMode.expanded:
      case PaneDisplayMode.minimal:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            expanderWidget,
            AnimatedSize(
              duration: theme.fastAnimationDuration,
              curve: Curves.easeIn,
              child: !isExpanded
                  ? const SizedBox(width: double.infinity)
                  : ClipRect(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.items.map((childItem) {
                          final childDepth = widget.depth + 1;
                          return view.pane!._buildItem(
                            childItem,
                            depth: childDepth,
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        );
      case PaneDisplayMode.top:
      case PaneDisplayMode.compact:
        return FlyoutTarget(
          controller: flyoutController,
          child: expanderWidget,
        );
      case PaneDisplayMode.auto:
        return expanderWidget;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _PaneItemExpanderMenuItem extends MenuFlyoutItemBase {
  const _PaneItemExpanderMenuItem({
    required this.item,
    required this.onPressed,
    required this.isSelected,
  });

  final PaneItem item;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final navigationTheme = NavigationPaneTheme.of(context);
    return HoverButton(
      onPressed: item.enabled ? onPressed : null,
      forceEnabled: item.enabled,
      builder: (context, states) {
        final textStyle =
            (isSelected
                ? navigationTheme.selectedTextStyle?.resolve(states)
                : navigationTheme.unselectedTextStyle?.resolve(states)) ??
            const TextStyle();
        final iconTheme = IconThemeData(
          color:
              textStyle.color ??
              (isSelected
                  ? navigationTheme.selectedIconColor?.resolve(states)
                  : navigationTheme.unselectedIconColor?.resolve(states)),
          size: textStyle.fontSize ?? 16.0,
        );
        return MenuFlyoutItem(
          selected: isSelected,
          onPressed: onPressed,
          leading: item.icon != null
              ? IconTheme.merge(data: iconTheme, child: item.icon!)
              : null,
          text: DefaultTextStyle(
            style: textStyle,
            child: item.title ?? const SizedBox.shrink(),
          ),
          trailing: () {
            if (item.infoBadge != null) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: item.infoBadge,
              );
            }
          }(),
        ).build(context);
      },
    );
  }
}

/// Display a widget as a PaneItem without addressing an index to it.
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemAction], the item used for execute an action on click
///   * [PaneItemExpander], which creates hierarchical navigation
class PaneItemWidgetAdapter extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemWidgetAdapter({
    required this.child,
    super.key,
    this.applyPadding = true,
  });

  /// The child.
  final Widget child;

  /// Whether to apply default padding around the child.
  final bool applyPadding;

  /// Builds the widget adapter.
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = NavigationViewContext.of(context);

    return Padding(
      key: key,
      padding: applyPadding
          ? (theme.iconPadding ?? EdgeInsetsDirectional.zero).add(
              view.displayMode == PaneDisplayMode.top
                  ? EdgeInsetsDirectional.zero
                  : theme.headerPadding ?? EdgeInsetsDirectional.zero,
            )
          : EdgeInsetsDirectional.zero,
      child: child,
    );
  }

  @override
  MenuFlyoutItemBase buildMenuFlyoutItem(
    BuildContext context, [
    ValueChanged<PaneItem>? onItemPressed,
  ]) {
    return MenuFlyoutItemBuilder(builder: build);
  }
}

extension on Widget {
  /// Gets a property from this widget based on its type.
  ///
  /// The supported widget types are:
  /// - Text
  /// - RichText
  /// - Icon
  ///
  /// The supported property types are:
  /// - String
  /// - InlineSpan
  /// - TextStyle
  /// - TextAlign
  /// - TextHeightBehavior
  /// - TextWidthBasis
  T? _getProperty<T>([dynamic def]) {
    if (this is Text) {
      final title = this as Text;
      switch (T) {
        case const (String):
          return (title.data ?? title.textSpan?.toPlainText()) as T?;
        case const (InlineSpan):
          return (title.textSpan ??
                  TextSpan(
                    text: title.data ?? '',
                    style:
                        title._getProperty<TextStyle>()?.merge(
                          def as TextStyle?,
                        ) ??
                        def as TextStyle?,
                  ))
              as T?;
        case const (TextStyle):
          return title.style as T?;
        case const (TextAlign):
          return title.textAlign as T?;
        case const (TextHeightBehavior):
          return title.textHeightBehavior as T?;
        case const (TextWidthBasis):
          return title.textWidthBasis as T?;
      }
    } else if (this is RichText) {
      final title = this as RichText;
      switch (T) {
        case const (String):
          return title.text.toPlainText() as T?;
        case const (InlineSpan):
          if (T is InlineSpan) {
            final span = title.text;
            span.style?.merge(def as TextStyle?);
            return span as T;
          }
          return title.text as T;
        case const (TextStyle):
          return (title.text.style as T?) ?? def as T?;
        case const (TextAlign):
          return title.textAlign as T?;
        case const (TextHeightBehavior):
          return title.textHeightBehavior as T?;
        case const (TextWidthBasis):
          return title.textWidthBasis as T?;
      }
    } else if (this is Icon) {
      final title = this as Icon;
      switch (T) {
        case const (String):
          if (title.icon?.codePoint == null) return null;
          return String.fromCharCode(title.icon!.codePoint) as T?;
        case const (InlineSpan):
          return TextSpan(
                text: String.fromCharCode(title.icon!.codePoint),
                style: title._getProperty<TextStyle>(),
              )
              as T?;
        case const (TextStyle):
          return TextStyle(
                color: title.color,
                fontSize: title.size,
                fontFamily: title.icon?.fontFamily,
                package: title.icon?.fontPackage,
              )
              as T?;
        case const (TextAlign):
          return null;
        case const (TextHeightBehavior):
          return null;
        case const (TextWidthBasis):
          return null;
      }
    }
    return null;
  }
}
