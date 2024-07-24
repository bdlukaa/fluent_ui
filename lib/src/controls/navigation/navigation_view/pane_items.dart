part of 'view.dart';

class NavigationPaneItem with Diagnosticable {
  /// The key used for the item itself. Useful to find the position and size of
  /// the pane item within the screen
  ///
  /// See also:
  ///
  ///   * [PaneItem.build], which assigns this to its children
  late final GlobalKey itemKey = GlobalKey(
    debugLabel: 'NavigationPaneItem key; $runtimeType',
  );

  final Key? key;

  NavigationPaneItem({this.key});
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
///   * [PaneItemExpander], which creates hierhical navigation
class PaneItem extends NavigationPaneItem {
  /// Creates a pane item.
  PaneItem({
    super.key,
    required this.icon,
    required this.body,
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
  /// If this is a [Text], its [Text.data] is used to display the tooltip. The
  /// tooltip is only displayed only on compact mode and when the item is not
  /// disabled.
  /// It is also used by [Semantics] to allow screen readers to
  /// read the screen.
  ///
  /// Usually a [Text] widget.
  final Widget? title;

  /// The icon used by this item.
  ///
  /// Usually an [Icon] widget
  final Widget icon;

  /// The info badge used by this item
  final Widget? infoBadge;

  /// The trailing widget used by this item. If the current display mode is
  /// compact, this is not disaplayed
  ///
  /// Usually an [Icon] widget
  final Widget? trailing;

  /// The body of the view attached to this tab
  final Widget body;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro fluent_ui.controls.inputs.HoverButton.mouseCursor}
  final MouseCursor? mouseCursor;

  /// The color of the tile when unselected.
  /// If null, [NavigationPaneThemeData.tileColor] is used
  final WidgetStateProperty<Color?>? tileColor;

  /// The color of the tile when unselected.
  /// If null, [NavigationPaneThemeData.tileColor]/hovering is used
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

  /// Used to construct the pane items all around [NavigationView]. You can
  /// customize how the pane items should look like by overriding this method
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    int? itemIndex,
    bool? autofocus,
  }) {
    final maybeBody = InheritedNavigationView.maybeOf(context);
    final mode = displayMode ??
        maybeBody?.displayMode ??
        maybeBody?.pane?.displayMode ??
        PaneDisplayMode.minimal;
    assert(mode != PaneDisplayMode.auto);
    assert(debugCheckHasFluentTheme(context));

    final isTransitioning = maybeBody?.isTransitioning ?? false;

    final theme = NavigationPaneTheme.of(context);
    final titleText = title?.getProperty<String>() ?? '';

    final baseStyle = title?.getProperty<TextStyle>() ?? const TextStyle();

    final isTop = mode == PaneDisplayMode.top;
    final isMinimal = mode == PaneDisplayMode.minimal;
    final isCompact = mode == PaneDisplayMode.compact;

    final onItemTapped =
        (onPressed == null && onTap == null) || !enabled || isTransitioning
            ? null
            : () {
                onPressed?.call();
                onTap?.call();
              };

    final button = HoverButton(
      autofocus: autofocus ?? this.autofocus,
      focusNode: focusNode,
      onPressed: onItemTapped,
      cursor: mouseCursor,
      focusEnabled: isMinimal ? (maybeBody?.minimalPaneOpen ?? false) : true,
      forceEnabled: enabled,
      builder: (context, states) {
        var textStyle = () {
          var style = !isTop
              ? (selected
                  ? theme.selectedTextStyle?.resolve(states)
                  : theme.unselectedTextStyle?.resolve(states))
              : (selected
                  ? theme.selectedTopTextStyle?.resolve(states)
                  : theme.unselectedTopTextStyle?.resolve(states));
          if (style == null) return baseStyle;
          return style.merge(baseStyle);
        }();

        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsets.zero,
                child: RichText(
                  text: title!.getProperty<InlineSpan>(textStyle)!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: title?.getProperty<TextAlign>() ?? TextAlign.start,
                  textHeightBehavior: title?.getProperty<TextHeightBehavior>(),
                  textWidthBasis: title?.getProperty<TextWidthBasis>() ??
                      TextWidthBasis.parent,
                ),
              )
            : const SizedBox.shrink();
        Widget result() {
          final iconThemeData = IconThemeData(
            color: textStyle.color ??
                (selected
                    ? theme.selectedIconColor?.resolve(states)
                    : theme.unselectedIconColor?.resolve(states)),
            size: textStyle.fontSize ?? 16.0,
          );
          switch (mode) {
            case PaneDisplayMode.compact:
              return Container(
                key: itemKey,
                constraints: const BoxConstraints(
                  minHeight: kPaneItemMinHeight,
                ),
                alignment: AlignmentDirectional.center,
                child: Padding(
                  padding: theme.iconPadding ?? EdgeInsets.zero,
                  child: IconTheme.merge(
                    data: iconThemeData,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: () {
                        if (infoBadge != null) {
                          return Stack(
                            alignment: AlignmentDirectional.center,
                            clipBehavior: Clip.none,
                            children: [
                              icon,
                              PositionedDirectional(
                                end: -8,
                                top: -8,
                                child: infoBadge!,
                              ),
                            ],
                          );
                        }
                        return icon;
                      }(),
                    ),
                  ),
                ),
              );
            case PaneDisplayMode.minimal:
            case PaneDisplayMode.open:
              final shouldShowTrailing = !isTransitioning;

              return ConstrainedBox(
                key: itemKey,
                constraints: const BoxConstraints(
                  minHeight: kPaneItemMinHeight,
                ),
                child: Row(children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: iconThemeData,
                      child: Center(child: icon),
                    ),
                  ),
                  Expanded(child: textResult),
                  if (shouldShowTrailing) ...[
                    if (infoBadge != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: infoBadge!,
                      ),
                    if (trailing != null)
                      IconTheme.merge(
                        data: const IconThemeData(size: 16.0),
                        child: trailing!,
                      ),
                  ],
                ]),
              );
            case PaneDisplayMode.top:
              Widget result = Row(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: theme.iconPadding ?? EdgeInsets.zero,
                  child: IconTheme.merge(
                    data: iconThemeData,
                    child: Center(child: icon),
                  ),
                ),
                if (showTextOnTop) textResult,
                if (trailing != null)
                  IconTheme.merge(
                    data: const IconThemeData(size: 16.0),
                    child: trailing!,
                  ),
              ]);
              if (infoBadge != null) {
                return Stack(key: itemKey, clipBehavior: Clip.none, children: [
                  result,
                  if (infoBadge != null)
                    PositionedDirectional(
                      end: -3,
                      top: 3,
                      child: infoBadge!,
                    ),
                ]);
              }
              return KeyedSubtree(key: itemKey, child: result);
            default:
              throw '$mode is not a supported type';
          }
        }

        return Semantics(
          label: titleText.isEmpty ? null : titleText,
          selected: selected,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              color: () {
                final tileColor = this.tileColor ??
                    theme.tileColor ??
                    kDefaultPaneItemColor(context, isTop);
                final newStates = states.toSet()..remove(WidgetState.disabled);
                if (selected && selectedTileColor != null) {
                  return selectedTileColor!.resolve(newStates);
                }
                return tileColor.resolve(
                  selected
                      ? {
                          states.isHovered
                              ? WidgetState.pressed
                              : WidgetState.hovered,
                        }
                      : newStates,
                );
              }(),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: FocusBorder(
              focused: states.isFocused,
              renderOutside: false,
              child: () {
                final showTooltip = ((isTop && !showTextOnTop) || isCompact) &&
                    titleText.isNotEmpty &&
                    !states.isDisabled;

                if (showTooltip) {
                  return Tooltip(
                    richMessage: title?.getProperty<InlineSpan>(),
                    style: TooltipThemeData(textStyle: baseStyle),
                    child: result(),
                  );
                }

                return result();
              }(),
            ),
          ),
        );
      },
    );

    final index = () {
      if (itemIndex != null) return itemIndex;
      if (maybeBody?.pane?.indicator != null) {
        return maybeBody!.pane!.effectiveIndexOf(this);
      }
    }();

    return Padding(
      key: key,
      padding: const EdgeInsetsDirectional.only(bottom: 4.0),
      child: () {
        // If there is an indicator and the item is an effective item
        if (maybeBody?.pane?.indicator != null &&
            index != null &&
            !index.isNegative) {
          final key = PaneItemKeys.of(index, context);

          return Stack(children: [
            button,
            Positioned.fill(
              child: InheritedNavigationView.merge(
                currentItemIndex: index,
                currentItemSelected: selected,
                child: KeyedSubtree(
                  key: key,
                  child: maybeBody!.pane!.indicator!,
                ),
              ),
            ),
          ]);
        }

        return button;
      }(),
    );
  }

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
///   * [PaneItemExpander], which creates hierhical navigation
class PaneItemSeparator extends NavigationPaneItem {
  /// Creates an item separator.
  PaneItemSeparator({
    super.key,
    this.color,
    this.thickness,
  });

  /// The color used by the [Divider].
  final Color? color;

  /// The separator thickness. Defaults to 1.0
  final double? thickness;

  Widget build(BuildContext context, Axis direction) {
    return KeyedSubtree(
      key: key,
      child: Divider(
        key: itemKey,
        direction: direction,
        style: DividerThemeData(
          thickness: thickness,
          decoration: color != null ? BoxDecoration(color: color) : null,
          verticalMargin: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          ),
          horizontalMargin: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0,
          ),
        ),
      ),
    );
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
///   * [PaneItemExpander], which creates hierhical navigation
class PaneItemHeader extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemHeader({super.key, required this.header});

  /// The header. The default style is [NavigationPaneThemeData.itemHeaderTextStyle],
  /// but can be overriten by [Text.style].
  ///
  /// Usually a [Text] widget.
  final Widget header;

  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = InheritedNavigationView.of(context);

    return KeyedSubtree(
      key: key,
      child: Container(
        // key: itemKey,
        constraints: const BoxConstraints(minHeight: kPaneItemHeaderMinHeight),
        padding: (theme.iconPadding ?? EdgeInsets.zero).add(
          view.displayMode == PaneDisplayMode.top
              ? EdgeInsets.zero
              : theme.headerPadding ?? EdgeInsets.zero,
        ),
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
      ),
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
///   * [PaneItemExpander], which creates hierhical navigation
class PaneItemAction extends PaneItem {
  PaneItemAction({
    super.key,
    required super.icon,
    super.body = const SizedBox.shrink(),
    required VoidCallback super.onTap,
    super.title,
    super.infoBadge,
    super.focusNode,
    super.autofocus = false,
    super.mouseCursor,
    super.selectedTileColor,
    super.tileColor,
    super.trailing,
  });

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int? itemIndex,
  }) {
    return super.build(
      context,
      selected,
      onPressed,
      displayMode: displayMode,
      showTextOnTop: showTextOnTop,
      autofocus: autofocus,
      itemIndex: itemIndex,
    );
  }
}

typedef PaneItemExpanderKey = GlobalKey<__PaneItemExpanderState>;

/// Hierhical navigation item used on [NavigationView]
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
  final PaneItemExpanderKey expanderKey = PaneItemExpanderKey();

  PaneItemExpander({
    super.key,
    required super.icon,
    required this.items,
    required super.body,
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
  }) : assert(
          items.any((item) => item is PaneItemExpander) == false,
          'There can not be nested PaneItemExpanders',
        );

  final List<NavigationPaneItem> items;

  /// Whether the item is initially expanded. Defaults to false
  final bool initiallyExpanded;

  static const kDefaultTrailing = Icon(FluentIcons.chevron_down, size: 8.0);

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    ValueChanged<PaneItem>? onItemPressed,
    bool? autofocus,
    int? itemIndex,
  }) {
    final maybeBody = InheritedNavigationView.maybeOf(context);
    final mode = displayMode ??
        maybeBody?.displayMode ??
        maybeBody?.pane?.displayMode ??
        PaneDisplayMode.minimal;

    return KeyedSubtree(
      key: key,
      child: _PaneItemExpander(
        key: expanderKey,
        item: this,
        items: items,
        displayMode: mode,
        showTextOnTop: showTextOnTop,
        selected: selected,
        onPressed: onPressed,
        onItemPressed: onItemPressed,
        initiallyExpanded: initiallyExpanded,
      ),
    );
  }
}

class _PaneItemExpander extends StatefulWidget {
  const _PaneItemExpander({
    super.key,
    required this.item,
    required this.items,
    required this.displayMode,
    required this.showTextOnTop,
    required this.selected,
    required this.onPressed,
    required this.onItemPressed,
    required this.initiallyExpanded,
  });

  final PaneItem item;
  final List<NavigationPaneItem> items;
  final PaneDisplayMode displayMode;
  final bool showTextOnTop;
  final bool selected;
  final VoidCallback? onPressed;
  final ValueChanged<PaneItem>? onItemPressed;
  final bool initiallyExpanded;

  static const leadingPadding = EdgeInsetsDirectional.only(start: 28.0);

  @override
  State<_PaneItemExpander> createState() => __PaneItemExpanderState();
}

class __PaneItemExpanderState extends State<_PaneItemExpander>
    with SingleTickerProviderStateMixin {
  final flyoutController = FlyoutController();
  bool get useFlyout => widget.displayMode != PaneDisplayMode.open;

  late bool _open;
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _open = PageStorage.of(context).readState(
          context,
          identifier: 'paneItemExpanderOpen$index',
        ) as bool? ??
        widget.initiallyExpanded;

    if (_open) {
      controller.value = 1;
    }

    flyoutController.addListener(() {
      if (_open && !flyoutController.isOpen ||
          !_open && flyoutController.isOpen) {
        toggleOpen(doFlyout: false);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    flyoutController.dispose();
    super.dispose();
  }

  int get index {
    final body = InheritedNavigationView.of(context);

    return body.pane?.effectiveIndexOf(widget.item) ?? 0;
  }

  void toggleOpen({bool doFlyout = true}) {
    setState(() => _open = !_open);

    PageStorage.of(context).writeState(
      context,
      _open,
      identifier: 'paneItemExpanderOpen$index',
    );
    if (_open) {
      if (useFlyout && doFlyout && flyoutController.isAttached) {
        final body = InheritedNavigationView.of(context);
        final displayMode = body.displayMode;
        final navigationTheme = NavigationPaneTheme.of(context);

        flyoutController.showFlyout(
          placementMode: displayMode == PaneDisplayMode.compact
              ? FlyoutPlacementMode.right
              : FlyoutPlacementMode.bottomCenter,
          forceAvailableSpace: true,
          builder: (context) {
            return MenuFlyout(
              items: widget.items.map<MenuFlyoutItemBase>((item) {
                if (item is PaneItem) {
                  return _PaneItemExpanderMenuItem(
                    item: item,
                    onPressed: () {
                      widget.onItemPressed?.call(item);
                      item.onTap?.call();
                      Navigator.pop(context);
                    },
                    isSelected: body.pane!.isSelected(item),
                  );
                } else if (item is PaneItemSeparator) {
                  return const MenuFlyoutSeparator();
                } else if (item is PaneItemHeader) {
                  return MenuFlyoutItemBuilder(builder: (context) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ),
                      margin: const EdgeInsetsDirectional.only(bottom: 4.0),
                      child: DefaultTextStyle.merge(
                        style: navigationTheme.itemHeaderTextStyle,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        child: item.header,
                      ),
                    );
                  });
                } else {
                  throw UnsupportedError(
                    '${item.runtimeType} is not a supported item type',
                  );
                }
              }).toList(),
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
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final body = InheritedNavigationView.of(context);

    assert(body.pane!.selected != null,
        'The selected of NavigationPane can not be null!Try offer a value in NavigationPane!');

    _open = PageStorage.of(context).readState(
          context,
          identifier: 'paneItemExpanderOpen$index',
        ) as bool? ??
        _open;

    // Indexes
    // Ensure, if the child item is not visible, this is shown as the selected
    // item
    var realIndex = body.pane!.effectiveIndexOf(widget.item);
    final childrenIndexes = body.pane!.effectiveItems.where((item) {
      return widget.items.contains(item);
    }).map((item) => body.pane!.effectiveIndexOf(item));
    if (childrenIndexes.contains(body.pane!.selected!) && !_open) {
      realIndex = body.pane!.selected!;
    }

    // the item is this item with changes on the trailing widget: the padding
    // and rotation animation
    final item = widget.item
        .copyWith(
      trailing: GestureDetector(
        onTap: toggleOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 14.0),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => RotationTransition(
              turns: controller.drive(Tween<double>(
                begin: _open ? 0 : 1.0,
                end: _open ? 0.5 : 0.5,
              )),
              child: child,
            ),
            child: widget.item.trailing!,
          ),
        ),
      ),
    )
        .build(
      context,
      widget.selected,
      () {
        widget.onPressed?.call();
        toggleOpen();
      },
      displayMode: widget.displayMode,
      showTextOnTop: widget.showTextOnTop,
      itemIndex: realIndex,
    );
    if (widget.items.isEmpty) {
      return item;
    }
    final displayMode = body.displayMode;
    switch (displayMode) {
      case PaneDisplayMode.open:
      case PaneDisplayMode.minimal:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          item,
          AnimatedSize(
            duration: theme.fastAnimationDuration,
            curve: Curves.easeIn,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.items.map((item) {
                      if (item is PaneItem) {
                        final i = item.copyWith(
                          icon: Padding(
                            padding: _PaneItemExpander.leadingPadding,
                            child: item.icon,
                          ),
                        );
                        return i.build(
                          context,
                          body.pane!.isSelected(item),
                          () => widget.onItemPressed?.call(item),
                          displayMode: widget.displayMode,
                          showTextOnTop: widget.showTextOnTop,
                          itemIndex: body.pane!.effectiveIndexOf(item),
                        );
                      } else if (item is PaneItemHeader) {
                        return Padding(
                          padding: _PaneItemExpander.leadingPadding,
                          child: item.build(context),
                        );
                      } else if (item is PaneItemSeparator) {
                        return item.build(
                          context,
                          widget.displayMode == PaneDisplayMode.top
                              ? Axis.vertical
                              : Axis.horizontal,
                        );
                      } else {
                        throw UnsupportedError(
                          '${item.runtimeType} is not a supported item type',
                        );
                      }
                    }).toList(),
                  ),
          ),
        ]);
      case PaneDisplayMode.top:
      case PaneDisplayMode.compact:
        return FlyoutTarget(
          controller: flyoutController,
          child: item,
        );
      default:
        return item;
    }
  }
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
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final navigationTheme = NavigationPaneTheme.of(context);
    final size = Flyout.of(context).size;
    return Container(
      width: size.isEmpty ? null : size.width,
      padding: MenuFlyout.itemsPadding,
      child: HoverButton(
        onPressed: item.enabled ? onPressed : null,
        forceEnabled: item.enabled,
        builder: (context, states) {
          final textStyle = (isSelected
                  ? navigationTheme.selectedTextStyle?.resolve(states)
                  : navigationTheme.unselectedTextStyle?.resolve(states)) ??
              const TextStyle();
          final iconTheme = IconThemeData(
            color: textStyle.color ??
                (isSelected
                    ? navigationTheme.selectedIconColor?.resolve(states)
                    : navigationTheme.unselectedIconColor?.resolve(states)),
            size: textStyle.fontSize ?? 16.0,
          );
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            margin: const EdgeInsetsDirectional.only(bottom: 4.0),
            decoration: BoxDecoration(
              color: ButtonThemeData.uncheckedInputColor(
                theme,
                states,
                transparentWhenNone: true,
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: IconTheme.merge(
                  data: iconTheme,
                  child: item.icon,
                ),
              ),
              Flexible(
                fit: size.isEmpty ? FlexFit.loose : FlexFit.tight,
                child: DefaultTextStyle(
                  style: textStyle,
                  child: item.title ?? const SizedBox.shrink(),
                ),
              ),
              if (item.infoBadge != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: item.infoBadge!,
                ),
            ]),
          );
        },
      ),
    );
  }
}

base class _PaneItemExpanderItem
    extends LinkedListEntry<_PaneItemExpanderItem> {
  final PaneItem parent;
  final NavigationPaneItem expanderItem;
  final List<NavigationPaneItem> siblings;

  _PaneItemExpanderItem(this.parent, this.expanderItem, this.siblings);

  @override
  String toString() {
    return '$parent : $expanderItem : $siblings';
  }
}

/// Display a widget as a PaneItem without addressing an index to it.
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemAction], the item used for execute an action on click
///   * [PaneItemExpander], which creates hierhical navigation
class PaneItemWidgetAdapter extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemWidgetAdapter({
    super.key,
    required this.child,
    this.applyPadding = true,
  });

  /// The child.
  final Widget child;

  final bool applyPadding;

  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    final view = InheritedNavigationView.of(context);

    return Padding(
      key: key,
      padding: applyPadding
          ? (theme.iconPadding ?? EdgeInsets.zero).add(
              view.displayMode == PaneDisplayMode.top
                  ? EdgeInsets.zero
                  : theme.headerPadding ?? EdgeInsets.zero,
            )
          : EdgeInsets.zero,
      child: child,
    );
  }
}

extension _ItemsExtension on List<NavigationPaneItem> {
  /// Get the all the item offets in this list
  Iterable<Offset> _getPaneItemsOffsets(
    GlobalKey<State<StatefulWidget>> paneKey,
  ) {
    return map((e) {
      // Gets the item global position
      final itemContext = e.itemKey.currentContext;
      if (itemContext == null || !itemContext.mounted) return Offset.zero;
      final box = itemContext.findRenderObject()! as RenderBox;
      final globalPosition = box.localToGlobal(Offset.zero);
      // And then convert it to the local position
      final paneContext = paneKey.currentContext;
      if (paneContext == null || !paneContext.mounted) return Offset.zero;
      final paneBox = paneKey.currentContext!.findRenderObject() as RenderBox;
      final position = paneBox.globalToLocal(globalPosition);
      return position;
    })
        // Calling .toList here ensures that all the pane items positions are
        // calculated. Without it, a lazy Iterable would be returned resulting
        // in RenderObject bugs due to the widget not being in the tree
        .toList();
  }
}

extension ItemExtension on Widget {
  T? getProperty<T>([dynamic def]) {
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
                    title.getProperty<TextStyle>()?.merge(def as TextStyle?) ??
                        def as TextStyle?,
              )) as T?;
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
            style: title.getProperty<TextStyle>(),
          ) as T?;
        case const (TextStyle):
          return TextStyle(
            color: title.color,
            fontSize: title.size,
            fontFamily: title.icon?.fontFamily,
            package: title.icon?.fontPackage,
          ) as T?;
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
