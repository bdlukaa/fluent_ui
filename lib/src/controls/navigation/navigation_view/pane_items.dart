part of 'view.dart';

class NavigationPaneItem with Diagnosticable {
  final GlobalKey itemKey = GlobalKey();

  NavigationPaneItem();
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
class PaneItem extends NavigationPaneItem {
  /// Creates a pane item.
  PaneItem({
    required this.icon,
    this.title,
    this.infoBadge,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
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
  final InfoBadge? infoBadge;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  final MouseCursor? mouseCursor;

  /// Used to construct the pane items all around [NavigationView]. You can
  /// customize how the pane items should look like by overriding this method
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    final PaneDisplayMode mode = displayMode ??
        _NavigationBody.maybeOf(context)?.displayMode ??
        PaneDisplayMode.minimal;
    assert(mode != PaneDisplayMode.auto);

    final NavigationPaneThemeData theme = NavigationPaneTheme.of(context);
    final String titleText =
        title != null && title is Text ? (title! as Text).data ?? '' : '';

    return HoverButton(
      autofocus: autofocus ?? this.autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      cursor: mouseCursor,
      builder: (context, states) {
        final textStyle = selected
            ? theme.selectedTextStyle?.resolve(states)
            : theme.unselectedTextStyle?.resolve(states);
        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsets.zero,
                child: Text(
                  titleText,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )
            : const SizedBox.shrink();
        Widget result() {
          switch (mode) {
            case PaneDisplayMode.compact:
              return Container(
                key: itemKey,
                height: 36.0,
                alignment: Alignment.center,
                child: Padding(
                  padding: theme.iconPadding ?? EdgeInsets.zero,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: (selected
                              ? theme.selectedIconColor?.resolve(states)
                              : theme.unselectedIconColor?.resolve(states)) ??
                          textStyle?.color,
                      size: 16.0,
                    ),
                    child: Center(child: () {
                      if (infoBadge != null) {
                        return Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            icon,
                            Positioned(
                              right: -8,
                              top: -8,
                              child: infoBadge!,
                            ),
                          ],
                        );
                      }
                      return icon;
                    }()),
                  ),
                ),
              );
            case PaneDisplayMode.minimal:
            case PaneDisplayMode.open:
              return SizedBox(
                key: itemKey,
                height: 36.0,
                child: Row(children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: (selected
                                ? theme.selectedIconColor?.resolve(states)
                                : theme.unselectedIconColor?.resolve(states)) ??
                            textStyle?.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  Expanded(child: textResult),
                  if (infoBadge != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: infoBadge!,
                    ),
                ]),
              );
            case PaneDisplayMode.top:
              final result = Row(
                children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: (selected
                                ? theme.selectedIconColor?.resolve(states)
                                : theme.unselectedIconColor?.resolve(states)) ??
                            textStyle?.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  textResult,
                ],
              );
              if (infoBadge != null) {
                return Stack(clipBehavior: Clip.none, children: [
                  result,
                  if (infoBadge != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: infoBadge!,
                    ),
                ]);
              }
              return Center(child: result);
            default:
              throw '$mode is not a supported type';
          }
        }

        final bool isTop = mode == PaneDisplayMode.top;
        final bool isCompact = mode == PaneDisplayMode.compact;

        return Semantics(
          label: title == null ? null : titleText,
          selected: selected,
          child: AnimatedContainer(
            duration: theme.animationDuration ?? Duration.zero,
            curve: theme.animationCurve ?? standartCurve,
            margin: const EdgeInsets.only(right: 6.0, left: 6.0, bottom: 4.0),
            decoration: BoxDecoration(
              color: () {
                final ButtonState<Color?> tileColor = theme.tileColor ??
                    ButtonState.resolveWith((states) {
                      // By default, if it's top, do not show any color
                      if (isTop) return Colors.transparent;
                      return ButtonThemeData.uncheckedInputColor(
                        FluentTheme.of(context),
                        states,
                      );
                    });
                final newStates = states.toSet()..remove(ButtonStates.disabled);
                return tileColor.resolve(
                  selected ? {ButtonStates.hovering} : newStates,
                );
              }(),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: FocusBorder(
              child: () {
                final showTooltip = ((isTop && !showTextOnTop) || isCompact) &&
                    titleText.isNotEmpty &&
                    !states.isDisabled;

                if (showTooltip) {
                  return Tooltip(
                    message: titleText,
                    style: TooltipThemeData(
                      textStyle: title is Text ? (title as Text).style : null,
                    ),
                    child: result(),
                  );
                }

                return result();
              }(),
              focused: states.isFocused,
              renderOutside: false,
            ),
          ),
        );
      },
    );
  }
}

/// Separators for grouping navigation items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemHeader], used to label groups of items.
///   * [PaneItemAction], the item used for execute an action on click
class PaneItemSeparator extends NavigationPaneItem {
  /// Creates an item separator.
  PaneItemSeparator({this.color, this.thickness});

  /// The color used by the [Divider].
  final Color? color;

  /// The separator thickness. Defaults to 1.0
  final double? thickness;

  Widget build(BuildContext context, Axis direction) {
    return Divider(
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
    );
  }
}

/// Headers for labeling groups of items. This is not displayed if the display
/// mode is [PaneDisplayMode.compact]
///
/// See also:
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemAction], the item used for execute an action on click
class PaneItemHeader extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemHeader({required this.header});

  /// The header. The default style is [NavigationPaneThemeData.itemHeaderTextStyle],
  /// but can be overriten by [Text.style].
  ///
  /// Usually a [Text] widget.
  final Widget header;

  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneTheme.of(context);
    return Padding(
      key: itemKey,
      padding: theme.iconPadding ?? EdgeInsets.zero,
      child: DefaultTextStyle(
        style: theme.itemHeaderTextStyle ?? const TextStyle(),
        child: header,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.left,
      ),
    );
  }
}

/// The item used by [NavigationView] to display the tiles.
///
/// On [PaneDisplayMode.compact], only [icon] is displayed, and [title] is
/// used as a tooltip. On the other display modes, [icon] and [title] are
/// displayed in a [Row].
///
/// The difference with [PaneItem] is that the item is not linked
/// to a page but to an action passed in parameter (callback)
///
/// See also:
///
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemHeader], used to label groups of items.
class PaneItemAction extends PaneItem implements NavigationPaneItem {
  PaneItemAction({
    required icon,
    required this.onTap,
    title,
    infoBadge,
    focusNode,
    autofocus = false,
  }) : super(
          icon: icon,
          title: title,
          infoBadge: infoBadge,
          focusNode: focusNode,
          autofocus: autofocus,
        );

  /// The function who will be executed when the item is clicked
  final Function() onTap;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    return super.build(
      context,
      selected,
      onTap,
      displayMode: displayMode,
      showTextOnTop: showTextOnTop,
      autofocus: autofocus,
    );
  }
}

extension ItemsExtension on List<NavigationPaneItem> {
  /// Get the all the item offets in this list
  List<Offset> getPaneItemsOffsets(GlobalKey<State<StatefulWidget>> paneKey) {
    return map((e) {
      // Gets the item global position
      final itemContext = e.itemKey.currentContext;
      if (itemContext == null) return Offset.zero;
      final box = itemContext.findRenderObject()! as RenderBox;
      final globalPosition = box.localToGlobal(Offset.zero);
      // And then convert it to the local position
      final paneContext = paneKey.currentContext;
      if (paneContext == null) return Offset.zero;
      final paneBox = paneKey.currentContext!.findRenderObject() as RenderBox;
      final position = paneBox.globalToLocal(globalPosition);
      return position;
    }).toList();
  }

  /// Get all the item sizes in this list
  List<Size> getPaneItemsSizes() {
    return map((e) {
      final context = e.itemKey.currentContext;
      if (context == null) return Size.zero;
      final box = context.findRenderObject()! as RenderBox;
      return box.size;
    }).toList();
  }
}