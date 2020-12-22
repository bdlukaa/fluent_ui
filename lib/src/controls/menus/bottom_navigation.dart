import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key key,
    @required this.currentIndex,
    @required this.items,
    @required this.onChanged,
    this.style,
  })  : assert(items != null && items.length >= 2),
        assert(currentIndex != null &&
            currentIndex >= 0 &&
            currentIndex < items.length),
        super(key: key);

  final int currentIndex;
  final List<BottomNavigationItem> items;
  final ValueChanged<int> onChanged;

  final BottomNavigationStyle style;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.bottomNavigationStyle.copyWith(this.style);
    return Container(
      height: 58,
      margin: style.margin,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: style.borderRadius,
        border: style.border,
        boxShadow: elevationShadow(
          factor: style.elevation,
          color: style.elevationColor,
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          bool selected = currentIndex == index;
          return Expanded(
            child: HoverButton(
              builder: (context, state) => Container(
                margin: style.padding,
                decoration: BoxDecoration(
                  color: style.color(state),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) item.icon,
                    if (item.label != null)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: style.labelVisibility(state) ==
                                    BottomNavigationItemLabelVisibility
                                        .always ||
                                (style.labelVisibility(state) ==
                                        BottomNavigationItemLabelVisibility
                                            .selected &&
                                    selected)
                            ? AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                child: item.label,
                                style: selected
                                    ? style.selectedTextStyle(state)
                                    : style.unselectedTextStyle(state),
                              )
                            : SizedBox(),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                      ),
                  ],
                ),
              ),
              onPressed: onChanged == null ? null : () => onChanged(index),
            ),
          );
        }),
      ),
    );
  }
}

enum BottomNavigationItemLabelVisibility { always, selected, never }

class BottomNavigationItem {
  /// The icon of the item. Usually an [Icon] widget
  final Widget icon;

  /// The label of the item. Usually a [Text] widget
  final Widget label;

  final BottomNavigationStyle style;

  BottomNavigationItem({this.icon, this.label, this.style});
}

class BottomNavigationStyle {
  final Color backgroundColor;
  final ButtonState<Color> color;

  final Border border;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final ButtonState<MouseCursor> cursor;

  final ButtonState<TextStyle> selectedTextStyle;
  final ButtonState<TextStyle> unselectedTextStyle;

  final double elevation;
  final Color elevationColor;

  final ButtonState<BottomNavigationItemLabelVisibility> labelVisibility;

  BottomNavigationStyle({
    this.color,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
    this.cursor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.elevation,
    this.elevationColor,
    this.backgroundColor,
    this.labelVisibility,
  });

  static BottomNavigationStyle defaultTheme([Brightness brightness]) {
    final defButton = BottomNavigationStyle(
      cursor: buttonCursor,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(2),
      elevation: 0,
      labelVisibility: (_) => BottomNavigationItemLabelVisibility.always,
    );
    final disabledTextStyle = TextStyle(
      color: Colors.grey[100],
      fontWeight: FontWeight.bold,
    );
    if (brightness == null || brightness == Brightness.light)
      return defButton.copyWith(BottomNavigationStyle(
        backgroundColor: Colors.white,
        border: Border.all(color: Colors.grey[100], width: 0.6),
        elevationColor: lightElevationColor,
        selectedTextStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.blue, fontSize: 16),
        unselectedTextStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        color: lightButtonBackgroundColor,
      ));
    else
      return defButton.copyWith(BottomNavigationStyle(
        backgroundColor: Colors.grey,
        border: Border.all(color: Colors.white, width: 0.6),
        elevationColor: darkElevationColor,
        selectedTextStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        unselectedTextStyle: (state) => state.isDisabled
            ? disabledTextStyle
            : TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        color: darkButtonBackgroundColor,
      ));
  }

  BottomNavigationStyle copyWith(BottomNavigationStyle style) {
    if (style == null) return this;
    return BottomNavigationStyle(
      border: style?.border ?? border,
      borderRadius: style?.borderRadius ?? borderRadius,
      cursor: style?.cursor ?? cursor,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      color: style?.color ?? color,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      backgroundColor: style?.backgroundColor ?? backgroundColor,
      labelVisibility: style?.labelVisibility ?? labelVisibility,
    );
  }
}
