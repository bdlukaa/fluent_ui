import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A callback that receives a notification that the selection state of
/// a TreeView has changed.
///
/// Used by [TreeView.onSelectionChanged]
typedef TreeViewSelectionChangedCallback = Future<void> Function(
  Iterable<TreeViewItem> selectedItems,
);

/// A callback that receives a notification that an item has been invoked.
///
/// Used by [TreeView.onItemInvoked]
typedef TreeViewItemInvoked = Future<void> Function(
  TreeViewItem item,
  TreeViewItemInvokeReason reason,
);

/// A callback that receives a notification that an item
/// received a secondary tap.
///
/// Used by [TreeView.onSecondaryTap]
typedef TreeViewItemOnSecondaryTap = void Function(
  TreeViewItem item,
  TapDownDetails details,
);

/// A callback that receives a notification that the expansion state of an
/// item has been toggled.
///
/// Used by [TreeView.onItemExpandToggle]
typedef TreeViewItemOnExpandToggle = Future<void> Function(
  TreeViewItem item,
  bool getsExpanded,
);

typedef TreeViewItemGesturesCallback = Map<Type, GestureRecognizerFactory>
    Function(TreeViewItem item);

const double _whiteSpace = 8.0;

/// Default loading indicator used by [TreeView]
const Widget kTreeViewLoadingIndicator = Padding(
  // Padding to make it the same width as the expand icon
  padding: EdgeInsetsDirectional.only(start: 6.0, end: 6.0),
  child: SizedBox(
    height: 12.0,
    width: 12.0,
    child: ProgressRing(
      strokeWidth: 3.0,
    ),
  ),
);

enum TreeViewSelectionMode {
  /// Selection is disabled
  none,

  /// When single selection is enabled, only a single item can be selected by
  /// once.
  single,

  /// When multiple selection is enabled, a checkbox is shown next to each tree
  /// view item, and selected items are highlighted. A user can select or
  /// de-select an item by using the checkbox; clicking the item still causes
  /// it to be invoked.
  ///
  /// Selecting or de-selecting a parent item will select or de-select all
  /// children under that item. If some, but not all, of the children under a
  /// parent item are selected, the checkbox for the parent node is shown in
  /// the indeterminate state
  ///
  /// ![TreeView with multiple selection enabled](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/treeview-selection.png)
  multiple,
}

/// The reason that a [TreeViewItem] was invoked
enum TreeViewItemInvokeReason {
  /// The item was expanded/collapsed
  expandToggle,

  /// The item selection state was toggled
  selectionToggle,

  /// The item was pressed
  pressed,
}

/// The item used by [TreeView] to render tiles
///
/// See also:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/tree-view>
///  * [TreeView], which render [TreeViewItem]s as tiles
///  * [Checkbox], used on multiple selection mode
class TreeViewItem with Diagnosticable {
  final Key? key;

  /// The item leading
  ///
  /// Usually an [Icon]
  final Widget? leading;

  /// The item content
  ///
  /// Usually a [Text]
  final Widget content;

  /// An optional/arbitrary value associated with the item.
  ///
  /// For example, a primary key of the row of data that this
  /// item is associated with.
  final dynamic value;

  /// The children of this item.
  final List<TreeViewItem> children;

  /// Whether the item can be collapsable by user-input or not.
  ///
  /// Defaults to `true`
  final bool collapsable;

  TreeViewItem? _parent;

  /// Whether the item has any siblings (including itself) that are expandable
  bool _anyExpandableSiblings;

  /// [TreeViewItem] that owns the [children] collection that this node is part
  /// of.
  ///
  /// If null, this is the root node
  TreeViewItem? get parent => _parent;

  /// Whether the current item is expanded.
  ///
  /// It has no effect if [children] is empty.
  bool expanded;

  /// Whether the current item is selected.
  ///
  /// If [TreeView.selectionMode] is [TreeViewSelectionMode.none], this has no
  /// effect. If it's [TreeViewSelectionMode.single], this item is going to be
  /// the only selected item. If it's [TreeViewSelectionMode.multiple], this
  /// item is going to be one of the selected items
  bool? selected;

  /// Called when this item is invoked
  ///
  /// This item is passed to the callback.
  ///
  /// This callback is executed __after__ the global
  /// [TreeView.onItemInvoked]-callback.
  final TreeViewItemInvoked? onInvoked;

  /// Called when this item's expansion state is toggled.
  ///
  /// This item and its future expand state are passed to the callback.
  ///
  /// This callback is executed __after__ the global
  /// [TreeView.onItemExpandToggle]-callback.
  final TreeViewItemOnExpandToggle? onExpandToggle;

  /// The gestures that this item will respond to.
  ///
  /// See also:
  ///
  ///   * [TreeView.gesturesBuilder], which builds gestures for each item
  final Map<Type, GestureRecognizerFactory> gestures;

  /// The background color of this item.
  ///
  /// See also:
  ///
  ///   * [ButtonThemeData.uncheckedInputColor], which is used by default
  final ButtonState<Color>? backgroundColor;

  /// Whether this item is visible or not. Used to not lose the item state while
  /// it's not on the screen
  bool _visible = true;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// Whether the tree view item is loading
  bool loading = false;

  /// Widget to show when [loading]
  ///
  /// If null, [TreeView.loadingWidget] is used instead
  final Widget? loadingWidget;

  /// Whether this item children is loaded lazily
  final bool lazy;

  /// Creates a tree view item.
  TreeViewItem({
    this.key,
    this.leading,
    required this.content,
    this.value,
    this.children = const [],
    this.collapsable = true,
    bool? expanded,
    this.selected = false,
    this.onInvoked,
    this.onExpandToggle,
    this.gestures = const {},
    this.backgroundColor,
    this.autofocus = false,
    FocusNode? focusNode,
    this.semanticLabel,
    this.loadingWidget,
    this.lazy = false,
  })  : expanded = expanded ?? children.isNotEmpty,
        _anyExpandableSiblings = false,
        focusNode = focusNode ?? FocusNode();

  /// Deep copy constructor that can be used to copy an item and all of
  /// its child items. Useful if you want to have multiple trees with the
  /// same items, but with different UX states (e.g., selection, visibility,
  /// etc.).
  factory TreeViewItem.from(TreeViewItem source) {
    final newItem = TreeViewItem(
      key: source.key,
      leading: source.leading,
      content: source.content,
      value: source.value,
      children: source.children.map(TreeViewItem.from).toList(),
      collapsable: source.collapsable,
      expanded: source.expanded,
      selected: source.selected,
      onInvoked: source.onInvoked,
      onExpandToggle: source.onExpandToggle,
      backgroundColor: source.backgroundColor,
      autofocus: source.autofocus,
      focusNode: source.focusNode,
      semanticLabel: source.semanticLabel,
      loadingWidget: source.loadingWidget,
      lazy: source.lazy,
    );
    for (final c in newItem.children) {
      c._parent = newItem;
    }
    return newItem;
  }

  /// Whether this node is expandable
  bool get isExpandable {
    return lazy || children.isNotEmpty;
  }

  /// Indicates how far from the root node this child node is.
  ///
  /// If this is the root node, the depth is 0
  int get depth {
    if (parent != null) {
      var count = 1;
      TreeViewItem? currentParent = parent!;
      while (currentParent?.parent != null) {
        count++;
        currentParent = currentParent?.parent;
      }

      return count;
    }

    return 0;
  }

  /// Gets the last parent in the tree, in decrescent order.
  ///
  /// If this is the root parent, [this] is returned
  TreeViewItem get lastParent {
    if (parent != null) {
      var currentParent = parent!;
      while (currentParent.parent != null) {
        if (currentParent.parent != null) currentParent = currentParent.parent!;
      }
      return currentParent;
    }
    return this;
  }

  /// Executes [callback] for every parent found in the tree
  void executeForAllParents(ValueChanged<TreeViewItem?> callback) {
    if (parent == null) return;
    TreeViewItem? currentParent = parent!;
    callback(currentParent);
    while (currentParent?.parent != null) {
      currentParent = currentParent?.parent;
      callback(currentParent);
    }
  }

  /// Changes the selection state for this item and all of its children
  /// to either all selected or all deselected. Also appropriately updates
  /// the selection state of this item's parents as required. This should not
  /// be used for an item that belongs to a [TreeView] in single selection
  /// mode. See also [TreeView.deselectParentWhenChildrenDeselected].
  void setSelectionStateForMultiSelectionMode(
      bool newSelectionState, bool deselectParentWhenChildrenDeselected) {
    selected = newSelectionState;
    children.executeForAll((item) {
      item.selected = newSelectionState;
    });
    executeForAllParents(
        (p) => p?.updateSelected(deselectParentWhenChildrenDeselected));
  }

  /// Updates [selected] based on the direct [children]s' state.
  /// [selected] will not be forced to false if
  /// `deselectParentWhenChildrenDeselected` is false and
  /// either there are no children or all children are deselected.
  ///
  /// Since this only updates the state based on direct children,
  /// you would normally only call this in a depth-first manner on
  /// all parents, for example:
  ///
  /// ```dart
  /// item.executeForAllParents((parent) => parent
  ///   ?.updateSelected(widget.deselectParentWhenChildrenDeselected))
  /// ```
  void updateSelected(bool deselectParentWhenChildrenDeselected) {
    var hasNull = false;
    var hasFalse = false;
    var hasTrue = false;

    for (final child in children) {
      if (child.selected == null) {
        hasNull = true;
      } else if (child.selected == false) {
        hasFalse = true;
      } else if (child.selected == true) {
        hasTrue = true;
      }
    }

    if (!deselectParentWhenChildrenDeselected &&
        (children.isEmpty || (!hasNull && hasFalse && !hasTrue))) {
      if (selected == null && children.isEmpty) {
        // should not be possible unless children were removed after the
        // selected was updated previously...
        selected = true;
      } else if (selected == true) {
        // we're now only in a partially selected state
        selected = null;
      }
    } else {
      selected = hasNull || (hasTrue && hasFalse) ? null : hasTrue;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('hasLeading',
          value: leading != null, ifFalse: 'no leading'))
      ..add(FlagProperty('hasChildren',
          value: children.isNotEmpty, ifFalse: 'has children'))
      ..add(FlagProperty('collapsable',
          value: collapsable, defaultValue: true, ifFalse: 'uncollapsable'))
      ..add(FlagProperty('isRootNode',
          value: parent == null, ifFalse: 'has parent'))
      ..add(FlagProperty('expanded',
          value: expanded, defaultValue: true, ifFalse: 'collapsed'))
      ..add(FlagProperty('selected',
          value: selected, defaultValue: false, ifFalse: 'unselected'))
      ..add(FlagProperty('loading',
          value: loading, defaultValue: false, ifFalse: 'not loading'));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TreeViewItem &&
        other.key == key &&
        other.leading == leading &&
        other.content == content &&
        other.value == value &&
        listEquals(other.children, children) &&
        other.collapsable == collapsable &&
        other._anyExpandableSiblings == _anyExpandableSiblings &&
        other.selected == selected &&
        other.onInvoked == onInvoked &&
        other.onExpandToggle == onExpandToggle &&
        other.backgroundColor == backgroundColor &&
        other._visible == _visible &&
        other.autofocus == autofocus &&
        other.focusNode == focusNode &&
        other.semanticLabel == semanticLabel &&
        other.loading == loading &&
        other.loadingWidget == loadingWidget &&
        other.lazy == lazy;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        leading.hashCode ^
        content.hashCode ^
        value.hashCode ^
        children.hashCode ^
        collapsable.hashCode ^
        _anyExpandableSiblings.hashCode ^
        selected.hashCode ^
        onInvoked.hashCode ^
        onExpandToggle.hashCode ^
        backgroundColor.hashCode ^
        _visible.hashCode ^
        autofocus.hashCode ^
        focusNode.hashCode ^
        semanticLabel.hashCode ^
        loading.hashCode ^
        loadingWidget.hashCode ^
        lazy.hashCode;
  }
}

extension TreeViewItemCollection on List<TreeViewItem> {
  /// Adds the [TreeViewItem.parent] property to the [TreeViewItem]s
  /// and calculates other internal properties.
  List<TreeViewItem> build({TreeViewItem? parent}) {
    if (isNotEmpty) {
      final list = <TreeViewItem>[];
      final anyExpandableSiblings = any((i) => i.isExpandable);
      for (final item in this) {
        item
          .._parent = parent
          .._anyExpandableSiblings = anyExpandableSiblings;
        if (parent != null) {
          item._visible = parent._visible;
        }
        if (item._visible) {
          list.add(item);
        }
        final itemAnyExpandableSiblings =
            item.children.any((i) => i.isExpandable);
        for (final child in item.children) {
          // only add the children when it's expanded and visible
          child
            .._visible = item.expanded && item._visible
            .._parent = item
            .._anyExpandableSiblings = itemAnyExpandableSiblings;
          if (child._visible) {
            list.add(child);
          }
          if (child.expanded) {
            list.addAll(child.children.build(parent: child));
          }
        }
      }
      return list;
    }

    return this;
  }

  void executeForAll(ValueChanged<TreeViewItem> callback) {
    for (final child in this) {
      callback(child);
      child.children.executeForAll(callback);
    }
  }

  Iterable<TreeViewItem> whereForAll(bool Function(TreeViewItem element) t) {
    var result = where(t);
    for (final child in this) {
      result = result.followedBy(child.children.whereForAll(t));
    }
    return result;
  }

  /// Returns an iteration of all selected items (optionally including items
  /// that are only partially selected).
  Iterable<TreeViewItem> selectedItems(bool includePartiallySelectedItems) {
    return whereForAll((item) =>
        (item.selected ?? false) ||
        (includePartiallySelectedItems && item.selected == null));
  }
}

/// The `TreeView` control enables a hierarchical list with expanding and
/// collapsing nodes that contain nested items. It can be used to illustrate a
/// folder structure or nested relationships in your UI.
///
/// The tree view uses a combination of indentation and icons to represent the
/// nested relationship between parent nodes and child nodes. Collapsed items
/// use a chevron pointing to the right, and expanded nodes use a chevron
/// pointing down.
///
/// ![TreeView Simple](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/treeview-simple.png)
///
/// You can include an icon in the [TreeViewItem] template to represent items.
/// For example, if you show a file system hierarchy, you could use folder
/// icons for the parent items and file icons for the leaf items.
///
/// ![TreeView with Icons](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/treeview-icons.png)
///
/// See also:
///
///  * <https://docs.microsoft.com/en-us/windows/apps/design/controls/tree-view>
///  * [TreeViewItem], used to render the tiles
///  * [Checkbox], used on multiple selection mode
class TreeView extends StatefulWidget {
  /// Creates a tree view.
  ///
  /// [items] must not be empty
  const TreeView({
    super.key,
    required this.items,
    this.selectionMode = TreeViewSelectionMode.none,
    this.onSelectionChanged,
    this.onItemInvoked,
    this.onItemExpandToggle,
    this.onSecondaryTap,
    this.gesturesBuilder,
    this.loadingWidget = kTreeViewLoadingIndicator,
    this.shrinkWrap = true,
    this.scrollPrimary,
    this.scrollController,
    this.cacheExtent,
    this.itemExtent,
    this.addRepaintBoundaries = true,
    this.usePrototypeItem = false,
    this.narrowSpacing = false,
    this.includePartiallySelectedItems = false,
    this.deselectParentWhenChildrenDeselected = true,
  });

  /// The items of the tree view.
  ///
  /// Must not be empty
  final List<TreeViewItem> items;

  /// The current selection mode.
  ///
  /// [TreeViewSelectionMode.none] is used by default
  final TreeViewSelectionMode selectionMode;

  /// If [selectionMode] is [TreeViewSelectionMode.multiple], indicates if
  /// a parent will automatically be deselected when all of its children
  /// are deselected. If you disable this behavior, also consider if you
  /// want to set [includePartiallySelectedItems] to true.
  final bool deselectParentWhenChildrenDeselected;

  /// Called when an item is invoked
  ///
  /// The item invoked is passed to the callback.
  ///
  /// This callback is executed __before__ the item's own
  /// [TreeViewItem.onInvoked]-callback.
  final TreeViewItemInvoked? onItemInvoked;

  /// Called when an item's expand state is toggled.
  ///
  /// The item and its future expand state are passed to the callback.
  /// The callback is executed before the item's expand state actually changes.
  ///
  /// This callback is executed __before__ the item's own
  /// [TreeViewItem.onExpandToggle]-callback.
  final TreeViewItemOnExpandToggle? onItemExpandToggle;

  /// A tap with a secondary button has occurred.
  ///
  /// The item tapped and [TapDownDetails] are passed to the callback.
  final TreeViewItemOnSecondaryTap? onSecondaryTap;

  /// A callback that receives a notification that the gestures for an item
  ///
  /// This is called alongside [TreeViewItem.gestures]
  final TreeViewItemGesturesCallback? gesturesBuilder;

  /// Called when the selection changes. The items that are currently
  /// selected will be passed to the callback. This could be empty
  /// if nothing is now selected. If [TreeView.selectionMode] is
  /// [TreeViewSelectionMode.single] then it will contain exactly
  /// zero or one items.
  final TreeViewSelectionChangedCallback? onSelectionChanged;

  /// If true, will include items that are in an indeterminute (partially
  /// selected) state in the list of selected items in the
  /// [onSelectionChanged] callback.
  final bool includePartiallySelectedItems;

  /// A widget to be shown when a node is loading. Only used if
  /// [TreeViewItem.loadingWidget] is null.
  ///
  /// [kTreeViewLoadingIndicator] is used by default
  final Widget loadingWidget;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? scrollPrimary;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and simply repaint the children during scrolling.
  ///
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether or not to give the internal [ListView] a prototype item based on
  /// the first item in the tree view. Set this to true to allow the ListView to
  /// more efficiently calculate the maximum scrolling extent, and it will force
  /// the vertical size of each item to be the same size as the first item in
  /// the tree view.
  ///
  /// {@macro flutter.widgets.list_view.prototypeItem}
  ///
  /// Defaults to false.
  ///
  /// See also:
  ///
  ///  * [ListView.prototypeItem]
  final bool usePrototypeItem;

  /// Whether or not to have narrow spacing between the contents of each item.
  ///
  /// Defaults to `false`.
  final bool narrowSpacing;

  @override
  State<TreeView> createState() => TreeViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty(
        'selectionMode',
        selectionMode,
        defaultValue: TreeViewSelectionMode.none,
      ))
      ..add(IterableProperty<TreeViewItem>('items', items))
      ..add(FlagProperty(
        'includePartiallySelectedItems',
        value: includePartiallySelectedItems,
        defaultValue: false,
        ifFalse: 'only fully selected items',
      ))
      ..add(FlagProperty(
        'narrowSpacing',
        value: narrowSpacing,
        defaultValue: false,
        ifTrue: 'narrow spacing',
      ));
  }
}

class TreeViewState extends State<TreeView> with AutomaticKeepAliveClientMixin {
  late List<TreeViewItem> _items;

  /// Performs a build of all the items in the tree view.
  ///
  /// This is useful when an item needs to be updated outside of the built-in
  /// callbacks.
  ///
  /// This operation is expensive and should be used with caution.
  void buildItems() => _buildItems();

  /// Builds all the items based on the items provided by the [widget]
  void _buildItems() {
    if (widget.selectionMode != TreeViewSelectionMode.single) {
      _items = widget.items.build();
      widget.items.executeForAll(
        (item) => item.executeForAllParents((parent) => parent
            ?.updateSelected(widget.deselectParentWhenChildrenDeselected)),
      );
    } else {
      // make sure that at most only a single item is selected
      var foundSelected = 0;
      for (final item in widget.items) {
        final selected = item.selected;
        // the null "indeterminute" state is not allowed in single select mode
        if (selected == null) {
          item.selected = false;
        } else if (selected) {
          foundSelected++;
          if (foundSelected >= 2) {
            item.selected = false;
          }
        }
      }
      _items = widget.items.build();
    }
  }

  @override
  void initState() {
    super.initState();
    _buildItems();
  }

  @override
  void didUpdateWidget(TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) _buildItems();
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));

    return FocusScope(
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28.0),
          child: ListView.builder(
            // If shrinkWrap is true, then we default to not using the primary
            // scroll controller (should not normally need any controller in
            // this case).
            primary: widget.scrollPrimary ?? (widget.shrinkWrap ? false : null),
            controller: widget.scrollController,
            shrinkWrap: widget.shrinkWrap,
            cacheExtent: widget.cacheExtent,
            itemExtent: widget.itemExtent,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            prototypeItem: widget.usePrototypeItem && _items.isNotEmpty
                ? _TreeViewItem(
                    item: _items.first,
                    selectionMode: widget.selectionMode,
                    narrowSpacing: widget.narrowSpacing,
                    gestures: const {},
                    onInvoked: (_) {},
                    onSelect: () {},
                    onSecondaryTap: (details) {},
                    onExpandToggle: () {},
                    loadingWidgetFallback: widget.loadingWidget,
                  )
                : null,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];

              return _TreeViewItem(
                key: item.key ?? ValueKey<TreeViewItem>(item),
                item: item,
                selectionMode: widget.selectionMode,
                narrowSpacing: widget.narrowSpacing,
                onSecondaryTap: (details) {
                  widget.onSecondaryTap?.call(item, details);
                },
                gestures: {
                  ...item.gestures,
                  if (widget.gesturesBuilder != null)
                    ...widget.gesturesBuilder!(item),
                },
                onSelect: () async {
                  final onSelectionChanged = widget.onSelectionChanged;
                  switch (widget.selectionMode) {
                    case TreeViewSelectionMode.single:
                      setState(() {
                        _items.executeForAll((item) {
                          item.selected = false;
                        });
                        item.selected = true;
                      });
                      if (onSelectionChanged != null) {
                        await onSelectionChanged([item]);
                      }
                      break;
                    case TreeViewSelectionMode.multiple:
                      setState(() {
                        final newSelectionState =
                            item.selected == null || item.selected == false;
                        item.setSelectionStateForMultiSelectionMode(
                            newSelectionState,
                            widget.deselectParentWhenChildrenDeselected);
                      });
                      if (onSelectionChanged != null) {
                        final selectedItems = widget.items.selectedItems(
                            widget.includePartiallySelectedItems);
                        await onSelectionChanged(selectedItems);
                      }
                      break;
                    default:
                      break;
                  }
                },
                onExpandToggle: () async {
                  await _invokeItem(
                    item,
                    TreeViewItemInvokeReason.expandToggle,
                  );

                  if (item.collapsable) {
                    if (item.lazy) {
                      // Triggers a loading indicator.
                      setState(() => item.loading = true);
                    }

                    await Future.wait([
                      if (widget.onItemExpandToggle != null)
                        widget.onItemExpandToggle!(item, !item.expanded),
                      if (item.onExpandToggle != null)
                        item.onExpandToggle!(item, !item.expanded),
                    ]);

                    // Remove the loading indicator.
                    // Toggle the expand icon.
                    setState(() {
                      item
                        ..loading = false
                        ..expanded = !item.expanded;
                      _buildItems();
                    });
                  }
                },
                onInvoked: (reason) => _invokeItem(item, reason),
                loadingWidgetFallback: widget.loadingWidget,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _invokeItem(
    TreeViewItem item,
    TreeViewItemInvokeReason reason,
  ) async {
    if (widget.onItemInvoked == null && item.onInvoked == null) return;

    await Future.wait([
      if (widget.onItemInvoked != null) widget.onItemInvoked!(item, reason),
      if (item.onInvoked != null) item.onInvoked!(item, reason),
    ]);

    _buildItems();
  }

  /// Toggles the [item] expanded state
  void toggleItem(TreeViewItem item) {
    setState(() {
      item.expanded = !item.expanded;
      _buildItems();
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class _TreeViewItem extends StatelessWidget {
  const _TreeViewItem({
    super.key,
    required this.item,
    required this.selectionMode,
    required this.onSelect,
    required this.onSecondaryTap,
    required this.gestures,
    required this.onExpandToggle,
    required this.onInvoked,
    required this.loadingWidgetFallback,
    required this.narrowSpacing,
  });

  final TreeViewItem item;
  final TreeViewSelectionMode selectionMode;
  final VoidCallback onSelect;
  final GestureTapDownCallback onSecondaryTap;
  final Map<Type, GestureRecognizerFactory> gestures;
  final VoidCallback onExpandToggle;
  final void Function(TreeViewItemInvokeReason reason) onInvoked;
  final Widget loadingWidgetFallback;
  final bool narrowSpacing;

  void _onCheckboxInvoked() {
    onSelect();
    onInvoked(TreeViewItemInvokeReason.selectionToggle);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    if (!item._visible) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);
    final selected = item.selected ?? false;
    final direction = Directionality.of(context);

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTap,
      child: HoverButton(
        hitTestBehavior: HitTestBehavior.translucent,
        gestures: gestures,
        shortcuts: item.isExpandable
            ? {
                const SingleActivator(LogicalKeyboardKey.arrowLeft):
                    VoidCallbackIntent(() {
                  if (item.expanded) {
                    // if the item is expanded, close it
                    onExpandToggle();
                  } else if (item.parent != null) {
                    // if the item is already closed and has a parent
                    // focus the parent
                    item.parent!.focusNode.requestFocus();
                  }
                }),
                const SingleActivator(LogicalKeyboardKey.arrowRight):
                    VoidCallbackIntent(() {
                  if (item.expanded) {
                    // if the item is already expanded, focus its first child
                    FocusScope.of(context).nextFocus();
                  } else {
                    // expand the item
                    onExpandToggle();
                  }
                }),
              }
            : {
                const SingleActivator(LogicalKeyboardKey.arrowLeft):
                    VoidCallbackIntent(() {
                  if (item.parent != null) {
                    // if the item has a parent, focus the parent
                    item.parent!.focusNode.requestFocus();
                  }
                }),
              },
        onPressed: selectionMode == TreeViewSelectionMode.single
            ? () {
                onSelect();
                onInvoked(TreeViewItemInvokeReason.pressed);
                FocusScope.of(context).unfocus(
                  disposition: UnfocusDisposition.previouslyFocusedChild,
                );
              }
            : () {
                onInvoked(TreeViewItemInvokeReason.pressed);
                FocusScope.of(context).unfocus(
                  disposition: UnfocusDisposition.previouslyFocusedChild,
                );
              },
        onFocusTap: _onCheckboxInvoked,
        onFocusChange: selectionMode == TreeViewSelectionMode.single
            ? (focused) {
                if (focused) onSelect();
              }
            : null,
        autofocus: item.autofocus,
        focusNode: item.focusNode,
        semanticLabel: item.semanticLabel,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        builder: (context, states) {
          final itemForegroundColor = ButtonState.forStates<Color>(
            states,
            disabled: theme.resources.textFillColorDisabled,
            pressed: theme.resources.textFillColorSecondary,
            none: theme.resources.textFillColorPrimary,
          );

          return FocusBorder(
            focused: states.isFocused,
            child: Stack(children: [
              // Indentation and selection indicator for single selection mode.
              Container(
                constraints: BoxConstraints(
                  minHeight: selectionMode == TreeViewSelectionMode.multiple
                      ? 28.0
                      : 26.0,
                ),
                padding: EdgeInsetsDirectional.only(
                  start: selectionMode == TreeViewSelectionMode.multiple
                      ? !narrowSpacing
                          ? item.depth * _whiteSpace * 3
                          // The extra 4 pixels are added as the checkbox's
                          // width is not a multiple of 8.
                          : item.depth * (_whiteSpace * 2 + 4)
                      : !narrowSpacing
                          ? item.depth * _whiteSpace * 2
                          : item.depth * _whiteSpace,
                ),
                decoration: BoxDecoration(
                  color: item.backgroundColor?.resolve(states) ??
                      ButtonThemeData.uncheckedInputColor(
                        theme,
                        [
                          TreeViewSelectionMode.multiple,
                          TreeViewSelectionMode.none
                        ].contains(selectionMode)
                            ? states
                            : selected && (states.isPressing || states.isNone)
                                ? {ButtonStates.hovering}
                                : selected && states.isHovering
                                    ? {ButtonStates.pressing}
                                    : states,
                        transparentWhenNone: true,
                      ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Row(children: [
                  // Checkbox for multi selection mode
                  if (selectionMode == TreeViewSelectionMode.multiple)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 8.0,
                        end: narrowSpacing ? 0.0 : _whiteSpace,
                      ),
                      child: ExcludeFocus(
                        child: Checkbox(
                          checked: item.selected,
                          onChanged: (value) => _onCheckboxInvoked(),
                        ),
                      ),
                    ),

                  // Expand icon with hitbox
                  if (item.isExpandable)
                    if (item.loading)
                      item.loadingWidget ?? loadingWidgetFallback
                    else
                      GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTap: onExpandToggle,
                        child: Container(
                          // The hitbox for the chevron is three times the
                          // chevron's (max) width.
                          width: 24,
                          // The hitbox fills the available height.
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Icon(
                            item.expanded
                                ? FluentIcons.chevron_down
                                : direction == TextDirection.ltr
                                    ? FluentIcons.chevron_right
                                    : FluentIcons.chevron_left,
                            size: 8.0,
                            color: itemForegroundColor,
                          ),
                        ),
                      )
                  else
                    // Add padding to make all items of the same depth level
                    // have the same indentation, regardless whether or not
                    // they are expandable.
                    const Padding(
                      padding: EdgeInsetsDirectional.only(start: 24.0),
                    ),

                  // Leading icon
                  if (item.leading != null)
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: narrowSpacing ? 0 : _whiteSpace,
                        end: narrowSpacing ? _whiteSpace : 2 * _whiteSpace,
                      ),
                      width: 20.0,
                      child: IconTheme.merge(
                        data: IconThemeData(
                          size: 20.0,
                          color: itemForegroundColor,
                        ),
                        child: item.leading!,
                      ),
                    )
                  else if (!narrowSpacing)
                    const SizedBox(width: _whiteSpace),

                  // Item content
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 12.0,
                        color: itemForegroundColor,
                      ),
                      child: item.content,
                    ),
                  ),
                ]),
              ),
              if (selected && selectionMode == TreeViewSelectionMode.single)
                PositionedDirectional(
                  top: 6.0,
                  bottom: 6.0,
                  start: 0.0,
                  child: Container(
                    width: 3.0,
                    decoration: BoxDecoration(
                      color:
                          theme.accentColor.defaultBrushFor(theme.brightness),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
            ]),
          );
        },
      ),
    );
  }
}
