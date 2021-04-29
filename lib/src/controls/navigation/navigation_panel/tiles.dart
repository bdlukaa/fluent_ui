part of 'navigation_panel.dart';

class NavigationPanelItem {
  /// The icon of the item. Usually an [Icon] widget
  final Widget? icon;

  /// The label of the item. Usually a [Text] widget
  final Widget? label;

  final NavigationPanelThemeData? style;

  final bool header;

  final void Function()? onTapped;

  const NavigationPanelItem({
    this.icon,
    this.label,
    this.style,
    this.header = false,
    this.onTapped,
  });
}

class NavigationPanelSectionHeader extends NavigationPanelItem {
  const NavigationPanelSectionHeader({
    required Widget header,
  }) : super(header: true, label: header);
}

class NavigationPanelTileSeparator extends NavigationPanelItem {
  const NavigationPanelTileSeparator() : super();
}

class NavigationPanelMenuItem {
  final Widget icon;
  final Widget? label;

  const NavigationPanelMenuItem({required this.icon, this.label});
}

class NavigationPanelMenu extends StatelessWidget {
  const NavigationPanelMenu({
    Key? key,
    required this.item,
    this.compact = false,
    this.onTap,
  }) : super(key: key);

  final NavigationPanelMenuItem item;
  final bool compact;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return NavigationPanelItemTile(
      onTap: onTap,
      compact: compact,
      selected: false,
      item: NavigationPanelItem(
        icon: item.icon,
        label: item.label,
        header: false,
      ),
    );
  }
}

class NavigationPanelItemTile extends StatelessWidget {
  const NavigationPanelItemTile({
    Key? key,
    required this.item,
    this.onTap,
    this.selected = false,
    this.compact = false,
  }) : super(key: key);

  final NavigationPanelItem item;
  final bool selected;
  final void Function()? onTap;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = NavigationPanelThemeData.standard(context.theme).copyWith(
      context.theme.navigationPanelTheme.copyWith(item.style),
    );
    return SizedBox(
      height: 41.0,
      child: HoverButton(
        onPressed: onTap,
        builder: (context, state) {
          final child = AnimatedContainer(
            duration: style.animationDuration ?? Duration.zero,
            curve: style.animationCurve ?? standartCurve,
            color: uncheckedInputColor(context.theme, state),
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
              if (item.label != null && !compact)
                () {
                  final textStyle = selected
                      ? style.selectedTextStyle!(state)
                      : style.unselectedTextStyle!(state);
                  return Expanded(
                    child: Padding(
                      padding: style.labelPadding ?? EdgeInsets.zero,
                      child: AnimatedDefaultTextStyle(
                        duration: style.animationDuration ??
                            context.theme.mediumAnimationDuration,
                        curve: style.animationCurve ?? standartCurve,
                        style: textStyle,
                        child: item.label!,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  );
                }(),
            ]),
          );
          return Semantics(
            selected: selected,
            child: FocusBorder(
              child: child,
              focused: state.isFocused,
            ),
          );
        },
      ),
    );
  }
}
