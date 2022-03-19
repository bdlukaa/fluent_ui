import 'package:fluent_ui/fluent_ui.dart';

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

/// How horizontal overflow is handled for the items inside of a CommandBar.
enum CommandBarOverflowBehavior {
  /// Will cause items to scroll horizontally.
  scrolling,

  /// Will expand the size of the CommandBar based on the size of the contained items.
  noWrap,

  /// Will wrap items onto additional lines as needed.
  wrap,

  /// Will keep items on one line and clip as needed.
  clip,
  // TODO: Implement support for an overflow button and dynamically overflowing items into the "SecondaryCommands" flyout
}

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
class CommandBar extends StatelessWidget {
  final List<Widget> children;
  final CommandBarOverflowBehavior overflowBehavior;
  final bool _isExpanded;

  const CommandBar({
    Key? key,
    required this.children,
    this.overflowBehavior = CommandBarOverflowBehavior.scrolling,
  })  : _isExpanded = overflowBehavior != CommandBarOverflowBehavior.noWrap,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget w;
    switch (overflowBehavior) {
      case CommandBarOverflowBehavior.scrolling:
        w = HorizontalScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
        break;
      case CommandBarOverflowBehavior.noWrap:
        w = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );
        break;
      case CommandBarOverflowBehavior.wrap:
        w = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        );
        break;
      case CommandBarOverflowBehavior.clip:
        w = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
        break;
    }
    if (_isExpanded) {
      w = Row(children: [Expanded(child: w)]);
    }
    return w;
  }
}

/// An individual control displayed within a [CommandBar]. This widget ensures
/// that the child widget has the proper margin so the item has the proper
/// minimum height and width expected of a control within a [CommandBar].
class CommandBarItem extends StatelessWidget {
  final Widget child;

  const CommandBarItem({Key? key, required this.child}) : super(key: key);

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
class CommandBarButton extends StatelessWidget {
  final Widget? icon;
  final Widget? label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;

  const CommandBarButton({
    Key? key,
    this.icon,
    required this.onPressed,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: CommandBarItem(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconTheme.of(context).copyWith(size: 16),
                child: icon!,
              ),
              if (label != null) const SizedBox(width: 10),
            ],
            if (label != null) label!,
          ],
        ),
      ),
    );
  }
}

/// Separators for grouping command bar items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///   * [CommandBar], which is a collection of [CommandBarItem]s.
///   * [CommandBarButton], an item for a button with an icon and/or label.
class CommandBarSeparator extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CommandBarItem(
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
  }
}
