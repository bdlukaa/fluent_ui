import 'package:fluent_ui/fluent_ui.dart';

/// A card with appropriate margins, padding, and elevation for it to
/// contain one or more [CommandBar]s.
class CommandBarCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final EdgeInsets padding;

  const CommandBarCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        padding: padding,
        elevation: elevation,
        child: child,
      ),
    );
  }
}

/// The type of wrapping used for the items inside of the CommandBar.
///
///   * [CommandBarOverflowBehavior.scrolling] will cause items to scroll horizontally.
///   * [CommandBarOverflowBehavior.noWrap] will expand the size of the CommandBar based
///      on the size of the contained items.
///   * [CommandBarOverflowBehavior.wrap] will wrap items onto additional lines as needed.
///   * [CommandBarOverflowBehavior.clip] will keep items on one line and clip as needed.
enum CommandBarOverflowBehavior {
  scrolling,
  noWrap,
  wrap,
  clip,
  // TODO: Implement support for an overflow button and dynamically overflowing items into the "SecondaryCommands" flyout
}

/// Command bars provide quick access to common tasks. This could be
/// application-level or page-level commands.
///
/// A command bar is composed of a series of [CommandBarItem]s, which each could
/// be a [CommandBarButton] or a custom [CommandBarItem].
///
/// If there is not enough horizontal space to display all items, the wrapping
/// behavior is determined by [wrapType].
///
/// ![CommandBar example](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-appbar-icons.png)
///
/// See also:
///
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/command-bar>
class CommandBar extends StatelessWidget {
  final List<Widget> children;
  final CommandBarOverflowBehavior wrapType;
  final bool _isExpanded;
  final ScrollController? parentVerticalScrollController;

  const CommandBar(
      {Key? key,
      required this.children,
      this.wrapType = CommandBarOverflowBehavior.scrolling,
      this.parentVerticalScrollController})
      : _isExpanded = !(wrapType == CommandBarOverflowBehavior.noWrap),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget w;
    switch (wrapType) {
      case CommandBarOverflowBehavior.scrolling:
        w = HorizontalScrollView(
          child: Row(children: children),
          parentVerticalScrollController: parentVerticalScrollController,
        );
        break;
      case CommandBarOverflowBehavior.noWrap:
        w = Row(children: children);
        break;
      case CommandBarOverflowBehavior.wrap:
        w = Wrap(
          children: children,
        );
        break;
      case CommandBarOverflowBehavior.clip:
        w = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(children: children),
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
/// They are composed of an (optional) icon and an optional
class CommandBarButton extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? iconSemanticLabel;
  final TextDirection? iconTextDirection;
  final Widget? label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;

  const CommandBarButton(
      {Key? key,
      this.icon,
      this.iconColor,
      this.iconSemanticLabel,
      this.iconTextDirection,
      required this.onPressed,
      this.onLongPress,
      this.focusNode,
      this.autofocus = false,
      this.label})
      : super(key: key);

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
              Icon(
                icon,
                size: 16,
                color: iconColor,
                semanticLabel: iconSemanticLabel,
                textDirection: iconTextDirection,
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
