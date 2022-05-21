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
    this.tileColor,
    this.selectedTileColor,
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

  /// {@macro fluent_ui.controls.inputs.HoverButton.mouseCursor}
  final MouseCursor? mouseCursor;

  /// The color of the tile when unselected.
  /// If null, [NavigationPaneThemeData.tileColor] is used
  final ButtonState<Color?>? tileColor;

  /// The color of the tile when unselected.
  /// If null, [NavigationPaneThemeData.tileColor]/hovering is used
  final ButtonState<Color?>? selectedTileColor;

  T? _getPropertyFromTitle<T>([dynamic def]) {
    if (title is Text) {
      final title = this.title as Text;
      switch (T) {
        case String:
          return (title.data ?? title.textSpan?.toPlainText()) as T?;
        case InlineSpan:
          return (title.textSpan ??
              TextSpan(
                text: title.data ?? '',
                style: _getPropertyFromTitle<TextStyle>()
                        ?.merge(def as TextStyle?) ??
                    def as TextStyle?,
              )) as T?;
        case TextStyle:
          return title.style as T?;
        case TextAlign:
          return title.textAlign as T?;
        case TextHeightBehavior:
          return title.textHeightBehavior as T?;
        case TextWidthBasis:
          return title.textWidthBasis as T?;
      }
    } else if (title is RichText) {
      final title = this.title as RichText;
      switch (T) {
        case String:
          return title.text.toPlainText() as T?;
        case InlineSpan:
          if (T is InlineSpan) {
            final span = title.text;
            span.style?.merge(def as TextStyle?);
            return span as T;
          }
          return title.text as T;
        case TextStyle:
          return (title.text.style as T?) ?? def as T?;
        case TextAlign:
          return title.textAlign as T?;
        case TextHeightBehavior:
          return title.textHeightBehavior as T?;
        case TextWidthBasis:
          return title.textWidthBasis as T?;
      }
    } else if (title is Icon) {
      final title = this.title as Icon;
      switch (T) {
        case String:
          if (title.icon?.codePoint == null) return null;
          return String.fromCharCode(title.icon!.codePoint) as T?;
        case InlineSpan:
          return TextSpan(
            text: String.fromCharCode(title.icon!.codePoint),
            style: _getPropertyFromTitle<TextStyle>(),
          ) as T?;
        case TextStyle:
          return TextStyle(
            color: title.color,
            fontSize: title.size,
            fontFamily: title.icon?.fontFamily,
            package: title.icon?.fontPackage,
          ) as T?;
        case TextAlign:
          return null;
        case TextHeightBehavior:
          return null;
        case TextWidthBasis:
          return null;
      }
    }
    return null;
  }

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
    final maybeBody = InheritedNavigationView.maybeOf(context);
    final PaneDisplayMode mode = displayMode ??
        maybeBody?.displayMode ??
        maybeBody?.pane?.displayMode ??
        PaneDisplayMode.minimal;
    assert(mode != PaneDisplayMode.auto);

    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final direction = Directionality.of(context);

    final NavigationPaneThemeData theme = NavigationPaneTheme.of(context);
    final String titleText = _getPropertyFromTitle<String>() ?? '';

    final TextStyle baseStyle =
        _getPropertyFromTitle<TextStyle>() ?? const TextStyle();

    final bool isTop = mode == PaneDisplayMode.top;
    final bool isCompact = mode == PaneDisplayMode.compact;

    final button = HoverButton(
      autofocus: autofocus ?? this.autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      cursor: mouseCursor,
      builder: (context, states) {
        TextStyle textStyle = baseStyle.merge(
          selected
              ? theme.selectedTextStyle?.resolve(states)
              : theme.unselectedTextStyle?.resolve(states),
        );
        if (isTop && states.isPressing) {
          textStyle = textStyle.copyWith(
            color: textStyle.color?.withOpacity(0.75),
          );
        }
        final textResult = titleText.isNotEmpty
            ? Padding(
                padding: theme.labelPadding ?? EdgeInsets.zero,
                child: RichText(
                  text: _getPropertyFromTitle<InlineSpan>(textStyle)!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign:
                      _getPropertyFromTitle<TextAlign>() ?? TextAlign.start,
                  textHeightBehavior:
                      _getPropertyFromTitle<TextHeightBehavior>(),
                  textWidthBasis: _getPropertyFromTitle<TextWidthBasis>() ??
                      TextWidthBasis.parent,
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
                          textStyle.color,
                      size: 16.0,
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: () {
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
                            textStyle.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  Expanded(child: textResult),
                  if (infoBadge != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: infoBadge!,
                    ),
                ]),
              );
            case PaneDisplayMode.top:
              Widget result = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: theme.iconPadding ?? EdgeInsets.zero,
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: (selected
                                ? theme.selectedIconColor?.resolve(states)
                                : theme.unselectedIconColor?.resolve(states)) ??
                            textStyle.color,
                        size: 16.0,
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  if (showTextOnTop) textResult,
                ],
              );
              if (infoBadge != null) {
                return Stack(
                  key: itemKey,
                  clipBehavior: Clip.none,
                  children: [
                    result,
                    if (infoBadge != null)
                      Positioned.directional(
                        textDirection: direction,
                        end: -3,
                        top: 3,
                        child: infoBadge!,
                      ),
                  ],
                );
              }
              return KeyedSubtree(key: itemKey, child: result);
            default:
              throw '$mode is not a supported type';
          }
        }

        return Semantics(
          label: titleText.isEmpty ? null : titleText,
          selected: selected,
          child: AnimatedContainer(
            duration: theme.animationDuration ?? Duration.zero,
            curve: theme.animationCurve ?? standardCurve,
            margin: const EdgeInsets.only(right: 6.0, left: 6.0),
            decoration: BoxDecoration(
              color: () {
                final ButtonState<Color?> tileColor = this.tileColor ??
                    theme.tileColor ??
                    kDefaultTileColor(
                      context,
                      isTop,
                    );
                final newStates = states.toSet()..remove(ButtonStates.disabled);
                if (selected && selectedTileColor != null) {
                  return selectedTileColor!.resolve(newStates);
                }
                return tileColor.resolve(
                  selected
                      ? {
                          states.isHovering
                              ? ButtonStates.pressing
                              : ButtonStates.hovering,
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
                    richMessage: _getPropertyFromTitle<InlineSpan>(),
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

    final int? index = () {
      if (maybeBody?.pane?.indicator != null) {
        return maybeBody!.pane!.effectiveIndexOf(this);
      }
    }();

    final GlobalKey? key = () {
      if (index != null && !index.isNegative) {
        return _PaneItemKeys.of(index, context);
      }
    }();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: () {
        // If there is an indicator and the item is an effective item
        if (maybeBody?.pane?.indicator != null && index != -1) {
          return Stack(children: [
            button,
            Positioned.fill(
              child: InheritedNavigationView.merge(
                currentItemIndex: index,
                child: KeyedSubtree(
                  key: index != null ? key : null,
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
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.left,
        child: header,
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
class PaneItemAction extends PaneItem {
  PaneItemAction({
    required Widget icon,
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

  /// The function that will be executed when the item is clicked
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int index = -1,
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

extension _ItemsExtension on List<NavigationPaneItem> {
  /// Get the all the item offets in this list
  List<Offset> _getPaneItemsOffsets(GlobalKey<State<StatefulWidget>> paneKey) {
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
}
