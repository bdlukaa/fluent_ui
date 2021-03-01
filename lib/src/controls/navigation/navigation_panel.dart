import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

// TODO: NavigationPanelHeader
// TODO: NavigationPanelTileSeparator

enum NavigationPanelDisplayMode {
  open,
  compact,
  minimal,
}

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({
    Key key,
    @required this.currentIndex,
    @required this.items,
    @required this.onChanged,
    this.top,
    this.bottom,
    this.displayMode,
  })  : assert(items != null && items.length >= 2),
        assert(currentIndex != null &&
            currentIndex >= 0 &&
            currentIndex < items.length),
        super(key: key);

  final int currentIndex;
  final ValueChanged<int> onChanged;

  // TODO: rename top to menu
  final Widget top;
  final List<NavigationPanelItem> items;
  final NavigationPanelItem bottom;

  final NavigationPanelDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    return LayoutBuilder(builder: (context, consts) {
      NavigationPanelDisplayMode displayMode = this.displayMode;
      if (displayMode == null) {
        double width = consts.biggest.width;
        if (width.isInfinite) width = MediaQuery.of(context).size.width;
        if (width >= 680) {
          displayMode = NavigationPanelDisplayMode.open;
        } else if (width >= 400) {
          displayMode = NavigationPanelDisplayMode.compact;
        } else
          displayMode = NavigationPanelDisplayMode.minimal;
      }
      switch (displayMode) {
        case NavigationPanelDisplayMode.compact:
        case NavigationPanelDisplayMode.open:
          final width =
              displayMode == NavigationPanelDisplayMode.compact ? 50.0 : 320.0;
          return AnimatedContainer(
            duration: context.theme.animationDuration,
            curve: context.theme.animationCurve,
            width: width,
            color: context.theme.navigationPanelBackgroundColor,
            child: ListView(
              children: [
                if (top != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 22, top: 22, left: 14),
                    child: top,
                  ),
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  // Use this to avoid overflow when animation is happening
                  return SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: NavigationPanelItemTile(
                        item: item,
                        selected: currentIndex == index,
                        onTap:
                            onChanged == null ? null : () => onChanged(index),
                        compact:
                            displayMode == NavigationPanelDisplayMode.compact,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        case NavigationPanelDisplayMode.minimal:
        default:
          return SizedBox();
      }
    });
  }
}

class NavigationPanelItemTile extends StatelessWidget {
  const NavigationPanelItemTile({
    Key key,
    @required this.item,
    this.onTap,
    this.selected = false,
    this.compact = false,
  })  : assert(item != null),
        assert(compact != null),
        assert(selected != null),
        super(key: key);

  final NavigationPanelItem item;
  final bool selected;
  final Function onTap;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.navigationPanelStyle.copyWith(item.style);
    return SizedBox(
      height: 44,
      child: HoverButton(
        onPressed: onTap,
        builder: (context, state) {
          return AnimatedContainer(
            duration: style.animationDuration ?? Duration.zero,
            curve: style.animationCurve ?? Curves.linear,
            color: uncheckedInputColor(context.theme, state),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: style.animationDuration ?? Duration.zero,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: style.animationCurve ?? Curves.linear,
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
                    child: item.icon,
                  ),
                if (item.label != null && !compact)
                  Padding(
                    padding: style.labelPadding ?? EdgeInsets.zero,
                    child: item.label,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NavigationPanelItem {
  /// The icon of the item. Usually an [Icon] widget
  final Widget icon;

  /// The label of the item. Usually a [Text] widget
  final Widget label;

  final NavigationPanelStyle style;

  NavigationPanelItem({this.icon, this.label, this.style});
}

class NavigationPanelStyle {
  final ButtonState<Color> color;
  final Color highlightColor;

  final EdgeInsetsGeometry labelPadding;
  final EdgeInsetsGeometry iconPadding;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<TextStyle> selectedTextStyle;
  final ButtonState<TextStyle> unselectedTextStyle;

  final Duration animationDuration;
  final Curve animationCurve;

  const NavigationPanelStyle({
    this.color,
    this.highlightColor,
    this.labelPadding,
    this.iconPadding,
    this.cursor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.animationDuration,
    this.animationCurve,
  });

  static NavigationPanelStyle defaultTheme(Style style,
      [Brightness brightness]) {
    final disabledTextStyle = TextStyle(
      color: style.disabledColor,
      fontWeight: FontWeight.bold,
    );
    return NavigationPanelStyle(
      animationDuration: style.animationDuration,
      animationCurve: style.animationCurve,
      color: (state) => uncheckedInputColor(style, state),
      highlightColor: style.accentColor,
      selectedTextStyle: (state) => state.isDisabled
          ? disabledTextStyle
          : TextStyle(color: style.accentColor, fontSize: 16),
      unselectedTextStyle: (state) => state.isDisabled
          ? disabledTextStyle
          : TextStyle(color: style.inactiveColor, fontWeight: FontWeight.w500),
      cursor: buttonCursor,
      labelPadding: EdgeInsets.zero,
      iconPadding: EdgeInsets.only(right: 10, left: 8),
    );
  }

  NavigationPanelStyle copyWith(NavigationPanelStyle style) {
    if (style == null) return this;
    return NavigationPanelStyle(
      cursor: style?.cursor ?? cursor,
      iconPadding: style?.iconPadding ?? iconPadding,
      labelPadding: style?.labelPadding ?? labelPadding,
      color: style?.color ?? color,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      highlightColor: style?.highlightColor ?? highlightColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
    );
  }
}
