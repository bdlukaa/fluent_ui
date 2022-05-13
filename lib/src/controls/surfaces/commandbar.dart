import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

/// A card with appropriate margins, padding, and elevation for it to
/// contain one or more [CommandBar]s.
class CommandBarCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsets padding;

  const CommandBarCard({
    Key? key,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Card(
        padding: padding,
        elevation: elevation,
        child: child,
      ),
    );
  }
}

/// How horizontal overflow is handled for the items on the primary area
/// of a CommandBar.
enum CommandBarOverflowBehavior {
  /// Will cause items to scroll horizontally.
  scrolling,

  /// Will expand the size of the CommandBar based on the size of the contained items.
  noWrap,

  /// Will wrap items onto additional lines as needed.
  wrap,

  /// Will keep items on one line and clip as needed.
  clip,

  /// Will dynamically move overflowing items into the "secondary area"
  /// (shown as a flyout menu when the overflow item is activated).
  dynamicOverflow,
}

/// Signature of function that will build a [CommandBarItem] with some
/// functionality to trigger an action (e.g., a clickable button), and
/// it will call the given callback when the action is triggered.
typedef CommandBarActionItemBuilder = CommandBarItem Function(
    VoidCallback onPressed);

/// Command bars provide quick access to common tasks. This could be
/// application-level or page-level commands.
///
/// A command bar is composed of a series of [CommandBarItem]s, which each could
/// be a [CommandBarButton] or a custom [CommandBarItem].
///
/// If there is not enough horizontal space to display all items, the overflow
/// behavior is determined by [overflowBehavior].
///
/// ![CommandBar example](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-appbar-icons.png)
///
/// See also:
///
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/command-bar>
class CommandBar extends StatefulWidget {
  /// The [CommandBarItem]s that should appear on the primary area.
  final List<CommandBarItem> primaryItems;

  /// If non-empty, a "overflow item" will appear on the primary area
  /// (as built by [overflowItemBuilder], or it will be a "more" button
  /// if [overflowItemBuilder] is null), and when activated, will show a
  /// flyout containing this list of secondary items.
  final List<CommandBarItem> secondaryItems;

  /// Allows customization of the "overflow item" that will appear on the
  /// primary area of the command bar if there are any items in the
  /// [secondaryItems] (including any items that are dynamically considered
  /// to be there if [overflowBehavior] is
  /// [CommandBarOverflowBehavior.dynamicOverflow].)
  final CommandBarActionItemBuilder? overflowItemBuilder;

  /// Determines what should happen when the items are too wide for the
  /// primary command bar area. See [CommandBarOverflowBehavior].
  final CommandBarOverflowBehavior overflowBehavior;

  /// If the width of this widget is less then the indicated amount,
  /// items in the primary area will be rendered using
  /// [CommandBarItemDisplayMode.inPrimaryCompact]. If this is `null`
  /// or the width of this widget is wider, then the items will be rendered
  /// using [CommandBarItemDisplayMode.inPrimary].
  final double? compactBreakpointWidth;

  /// If [compactBreakpointWidth] is `null`, then specifies whether or not
  /// primary items should be displayed in compact mode
  /// ([CommandBarItemDisplayMode.inPrimaryCompact]) or normal mode
  /// [CommandBarItemDisplayMode.inPrimary].
  ///
  /// This can be useful if the CommandBar is used in a setting where
  /// [compactBreakpointWidth] cannot be used (i.e. because using
  /// [LayoutBuilder] cannot be used in a context where the intrinsic
  /// height is also calculated), and you want to specify whether or not
  /// the primary items should be compact or not.
  ///
  /// If [compactBreakpointWidth] is not `null` this field is ignored.
  final bool? isCompact;

  /// The alignment of the items within the command bar across the main axis
  final MainAxisAlignment mainAxisAlignment;

  /// The alignment of the items within the command bar across the cross axis
  final CrossAxisAlignment crossAxisAlignment;

  /// The alignment of the overflow item (if displayed) between the end of
  /// the visible primary items and the end of the boundaries of this widget.
  /// Only relevant if [overflowBehavior] is
  /// [CommandBarOverflowBehavior.dynamicOverflow].
  final MainAxisAlignment overflowItemAlignment;

  final bool _isExpanded;

  const CommandBar({
    Key? key,
    required this.primaryItems,
    this.secondaryItems = const [],
    this.overflowItemBuilder,
    this.overflowBehavior = CommandBarOverflowBehavior.dynamicOverflow,
    this.compactBreakpointWidth,
    this.isCompact,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.overflowItemAlignment = MainAxisAlignment.end,
  })  : _isExpanded = overflowBehavior != CommandBarOverflowBehavior.noWrap,
        super(key: key);

  @override
  _CommandBarState createState() => _CommandBarState();
}

class _CommandBarState extends State<CommandBar> {
  final FlyoutController secondaryFlyoutController = FlyoutController();
  List<int> dynamicallyHiddenPrimaryItems = [];

  @override
  void dispose() {
    secondaryFlyoutController.dispose();
    super.dispose();
  }

  WrapAlignment _getWrapAlignment() {
    switch (widget.mainAxisAlignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment _getWrapCrossAlignment() {
    switch (widget.crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        throw UnsupportedError(
          'CommandBar does not support ${widget.crossAxisAlignment}',
        );
    }
  }

  Widget _buildForPrimaryMode(
      BuildContext context, CommandBarItemDisplayMode primaryMode) {
    final builtItems =
        widget.primaryItems.map((item) => item.build(context, primaryMode));
    Widget? overflowWidget;
    if (widget.secondaryItems.isNotEmpty ||
        widget.overflowBehavior == CommandBarOverflowBehavior.dynamicOverflow) {
      void showSecondaryMenu() {
        secondaryFlyoutController.open();
      }

      late CommandBarItem overflowItem;
      if (widget.overflowItemBuilder != null) {
        overflowItem = widget.overflowItemBuilder!(showSecondaryMenu);
      } else {
        overflowItem = CommandBarButton(
          onPressed: showSecondaryMenu,
          icon: const Icon(FluentIcons.more),
        );
      }

      var allSecondaryItems = [
        ...dynamicallyHiddenPrimaryItems
            .map((index) => widget.primaryItems[index]),
        ...widget.secondaryItems,
      ];
      // It's useless if the first item is a separator
      if (allSecondaryItems.isNotEmpty &&
          allSecondaryItems.first is CommandBarSeparator) {
        allSecondaryItems.removeAt(0);
      }
      overflowWidget = Flyout(
        content: (context) => FlyoutContent(
          constraints: const BoxConstraints(maxWidth: 250.0),
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView(
            shrinkWrap: true,
            children: allSecondaryItems
                .map((item) => item.build(
                      context,
                      CommandBarItemDisplayMode.inSecondary,
                    ))
                .toList(),
          ),
        ),
        controller: secondaryFlyoutController,
        child: overflowItem.build(context, primaryMode),
      );
    }

    late Widget w;
    switch (widget.overflowBehavior) {
      case CommandBarOverflowBehavior.scrolling:
        w = HorizontalScrollView(
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: [
              ...builtItems,
              if (overflowWidget != null) overflowWidget,
            ],
          ),
        );
        break;
      case CommandBarOverflowBehavior.noWrap:
        w = Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            ...builtItems,
            if (overflowWidget != null) overflowWidget,
          ],
        );
        break;
      case CommandBarOverflowBehavior.wrap:
        w = Wrap(
          alignment: _getWrapAlignment(),
          crossAxisAlignment: _getWrapCrossAlignment(),
          children: [
            ...builtItems,
            if (overflowWidget != null) overflowWidget,
          ],
        );
        break;
      case CommandBarOverflowBehavior.dynamicOverflow:
        assert(overflowWidget != null);
        w = DynamicOverflow(
          alignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          alwaysDisplayOverflowWidget: widget.secondaryItems.isNotEmpty,
          overflowWidget: overflowWidget!,
          overflowWidgetAlignment: widget.overflowItemAlignment,
          overflowChangedCallback: (hiddenItems) {
            setState(() {
              // indexes should always be valid
              assert(() {
                for (var i = 0; i < hiddenItems.length; i++) {
                  if (hiddenItems[i] < 0 ||
                      hiddenItems[i] >= widget.primaryItems.length) {
                    return false;
                  }
                }
                return true;
              }());
              dynamicallyHiddenPrimaryItems = hiddenItems;
            });
          },
          children: builtItems.toList(),
        );
        break;
      case CommandBarOverflowBehavior.clip:
        w = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: [
              ...builtItems,
              if (overflowWidget != null) overflowWidget,
            ],
          ),
        );
        break;
    }
    if (widget._isExpanded) {
      w = Row(children: [Expanded(child: w)]);
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactBreakpointWidth == null) {
      final displayMode = (widget.isCompact ?? false)
          ? CommandBarItemDisplayMode.inPrimaryCompact
          : CommandBarItemDisplayMode.inPrimary;
      return _buildForPrimaryMode(context, displayMode);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > widget.compactBreakpointWidth!) {
            return _buildForPrimaryMode(
                context, CommandBarItemDisplayMode.inPrimary);
          } else {
            return _buildForPrimaryMode(
                context, CommandBarItemDisplayMode.inPrimaryCompact);
          }
        },
      );
    }
  }
}

/// When a [CommandBarItem] is being built, indicates the visual context
/// in which the item is being built.
enum CommandBarItemDisplayMode {
  /// The item is displayed in the horizontal area (primary command area)
  /// of the command bar.
  ///
  /// The item should be rendered by wrapping content in a
  /// [CommandBarItemInPrimary] widget.
  inPrimary,

  /// The item is displayed in the horizontal area (primary command area)
  /// of the command bar, but it is requested that the item take up less
  /// horizontal space so that more items may fit without overflow.
  ///
  /// The item should be rendered by wrapping content in a
  /// [CommandBarItemInPrimary] widget.
  inPrimaryCompact,

  /// The item is displayed within the secondary command area (within a
  /// Flyout as a drop down of the "more" button).
  ///
  /// Normally you would want to render an item in this visual context as a
  /// [TappableListTile].
  inSecondary,
}

/// An individual control displayed within a [CommandBar]. Sub-class this
/// to build a new type of widget that appears inside of a command bar.
/// It knows how to build an appropriate widget for the given
/// [CommandBarItemDisplayMode] during build time.
abstract class CommandBarItem with Diagnosticable {
  final Key? key;

  const CommandBarItem({required this.key});

  /// Builds the final widget for this display mode for this item.
  /// Sub-classes implement this to build the widget that is appropriate
  /// for the given display mode.
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode);
}

/// Signature of function that can customize the widget returned by
/// a CommandBarItem built in the given display mode. Can be useful to
/// wrap the widget in a [Tooltip] etc.
typedef CommandBarItemWidgetBuilder = Widget Function(
    BuildContext context, CommandBarItemDisplayMode displayMode, Widget w);

class CommandBarBuilderItem extends CommandBarItem {
  /// Function that is called with the built widget of the wrappedItem for
  /// a given display mode before it is returned. For example, to wrap a
  /// widget in a [Tooltip].
  final CommandBarItemWidgetBuilder builder;
  final CommandBarItem wrappedItem;

  CommandBarBuilderItem({
    Key? key,
    required this.builder,
    required this.wrappedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {
    // First, build the widget for the wrappedItem in the given displayMode,
    // as it is always passed to the callback
    Widget w = wrappedItem.build(context, displayMode);
    return builder(context, displayMode, w);
  }
}

/// A widget to help render items that will appear on the primary
/// (horizontal) area of a command bar. This widget ensures that
/// the child widget has the proper margin so the item has the proper
/// minimum height and width expected of a control within the
/// primary command area of a [CommandBar].
class CommandBarItemInPrimary extends StatelessWidget {
  final Widget child;

  const CommandBarItemInPrimary({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 3.0),
      child: child,
    );
  }
}

/// Buttons are the most common control to put within a [CommandBar].
/// They are composed of an (optional) icon and an (optional) label.
class CommandBarButton extends CommandBarItem {
  /// The icon to show in the button (primary area) or menu (secondary area)
  final Widget? icon;

  /// The label to show in the button (primary area) or menu (secondary area)
  final Widget? label;

  /// The sub-title to use if this item is shown in the secondary menu
  final Widget? subtitle;

  /// The trailing widget to use if this item is shown in the secondary menu
  final Widget? trailing;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;

  const CommandBarButton({
    Key? key,
    this.icon,
    this.label,
    this.subtitle,
    this.trailing,
    required this.onPressed,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {
    switch (displayMode) {
      case CommandBarItemDisplayMode.inPrimary:
      case CommandBarItemDisplayMode.inPrimaryCompact:
        final showIcon = (icon != null);
        final showLabel = (label != null &&
            (displayMode == CommandBarItemDisplayMode.inPrimary || !showIcon));
        return IconButton(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          focusNode: focusNode,
          autofocus: autofocus,
          icon: CommandBarItemInPrimary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon)
                  IconTheme(
                    data: IconTheme.of(context).copyWith(size: 16),
                    child: icon!,
                  ),
                if (showIcon && showLabel) const SizedBox(width: 10),
                if (showLabel) label!,
              ],
            ),
          ),
        );
      case CommandBarItemDisplayMode.inSecondary:
        return Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: FlyoutListTile(
            key: key,
            onPressed: onPressed,
            focusNode: focusNode,
            autofocus: autofocus,
            icon: icon,
            text: label ?? const SizedBox.shrink(),
          ),
        );
    }
  }
}

/// Separators for grouping command bar items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///   * [CommandBar], which is a collection of [CommandBarItem]s.
///   * [CommandBarButton], an item for a button with an icon and/or label.
class CommandBarSeparator extends CommandBarItem {
  /// Creates a command bar item separator.
  const CommandBarSeparator({
    Key? key,
    this.color,
    this.thickness,
  }) : super(key: key);

  /// Override the color used by the [Divider].
  final Color? color;

  /// Override the separator thickness.
  final double? thickness;

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {
    switch (displayMode) {
      case CommandBarItemDisplayMode.inPrimary:
      case CommandBarItemDisplayMode.inPrimaryCompact:
        return CommandBarItemInPrimary(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 28),
            child: Divider(
              direction: Axis.vertical,
              style: DividerThemeData(
                thickness: thickness,
                decoration: color != null ? BoxDecoration(color: color) : null,
                verticalMargin: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 0.0,
                ),
              ),
            ),
          ),
        );
      case CommandBarItemDisplayMode.inSecondary:
        return Divider(
          direction: Axis.horizontal,
          style: DividerThemeData(
            thickness: thickness,
            decoration: color != null ? BoxDecoration(color: color) : null,
            horizontalMargin: const EdgeInsets.only(bottom: 5.0),
          ),
        );
    }
  }
}
