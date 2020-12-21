import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class Pivot extends StatelessWidget {
  const Pivot({
    Key key,
    @required this.currentIndex,
    @required this.onChanged,
    @required this.pivots,
    this.scrollPhysics,
  })  : assert(pivots != null),
        assert(currentIndex != null),
        assert(currentIndex >= 0 && currentIndex < pivots.length),
        super(key: key);

  /// The current index of the pivot. This can NOT be null
  final int currentIndex;

  /// The callback whenever the index changes
  final ValueChanged<int> onChanged;

  /// The list of pivots. This can't be null
  final List<PivotItem> pivots;

  final ScrollPhysics scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: scrollPhysics,
      child: Row(
        children: List.generate(pivots.length, (index) {
          final pivot = pivots[index];
          final style = context.theme.pivotItemStyle.copyWith(pivot.style);
          final bool selected = currentIndex == index;
          style.padding.flipped;
          return HoverButton(
            cursor: (_, state) => style.cursor(state),
            onPressed: () => onChanged?.call(index),
            builder: (context, state) => Stack(
              children: [
                Container(
                  padding: style.padding,
                  margin: style.margin,
                  color: style.color(state),
                  child: Row(
                    children: [
                      if (pivot.leading != null) pivot.leading,
                      if (pivot.text != null)
                        AnimatedDefaultTextStyle(
                          child: pivot.text,
                          style: selected
                              ? style.selectedTextStyle
                              : style.unselectedTextStyle,
                          duration: style.animationDuration,
                        ),
                      if (pivot.trailing != null) pivot.trailing,
                    ],
                  ),
                ),
                if (currentIndex == index)
                  AnimatedPositioned(
                    duration: style.animationDuration,
                    curve: style.animationCurve,
                    bottom: 0,
                    left: state.isHovering || state.isPressing
                        ? 0
                        : style?.padding?.left ?? 0,
                    right: state.isHovering || state.isPressing
                        ? 0
                        : style?.padding?.right ?? 0,
                    child: pivot.indicator?.call(state) ??
                        AnimatedContainer(
                          duration: style.animationDuration,
                          curve: style.animationCurve,
                          height: style.indicatorHeight,
                          decoration: style.indicatorDecoration,
                        ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class PivotItem {
  const PivotItem({
    this.leading,
    this.text,
    this.trailing,
    this.style,
    this.indicator,
  });

  /// The leading widget. Usually an [Icon] Widget
  final Widget leading;

  /// The center widget. Usually a [Text] Widget
  final Widget text;

  /// The trailing widget. Usually an [Icon] Widget
  final Widget trailing;

  /// The indicator. Can be any custom widget
  final ButtonState<Widget> indicator;

  /// The style of the pivot. Defaults to [PivotItemStyle.defaultTheme()]
  final PivotItemStyle style;
}

class PivotItemStyle {
  /// The mouse cursor of the pivot. If the pivot is disabled, defaults
  /// to [SystemMouseCursors.forbidden], otherwise defaults to
  /// [SystemMouseCursors.click]
  final ButtonState<MouseCursor> cursor;

  /// The background color of the pivot. If it's dark, defaults to
  /// [darkButtonBackgroundColor], otherwise defaults to [lightButtonBackgroundColor]
  final ButtonState<Color> color;

  /// The padding of the pivot. Defaults to [EdgeInsets.all(8)]
  ///
  /// This can't be [EdgeInsetsGeometry] because the Pivot needs
  /// to calculate the how much space it needs to take from the border.
  /// If this is null or zero, there will not be any animation since
  /// the min size is the leading + text + trailing size
  final EdgeInsets padding;

  /// The margin of the pivot. Defaults to [EdgeInsets.zero]
  final EdgeInsetsGeometry margin;

  /// The text style of the selected text
  final TextStyle selectedTextStyle;

  /// The text style of the unselected text
  final TextStyle unselectedTextStyle;

  /// The duration of the animations. Default to [Duration(milliseconds: 200)]
  final Duration animationDuration;

  /// The curve of the animations. Default to [Curves.linear]
  final Curve animationCurve;

  /// The height of the indicator. Defaults to 1.5
  final double indicatorHeight;

  /// The decoratino of the indicator. Defaults to [Decoration(color: Colors.white)]
  final Decoration indicatorDecoration;

  PivotItemStyle({
    this.cursor,
    this.margin,
    this.padding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.color,
    this.animationDuration,
    this.animationCurve,
    this.indicatorHeight,
    this.indicatorDecoration,
  });

  /// The default theme for a [Pivot]
  static PivotItemStyle defaultTheme([Brightness brightness]) {
    final def = PivotItemStyle(
      cursor: (state) => state.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(8),
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
      unselectedTextStyle: TextStyle(color: Colors.white),
      selectedTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      indicatorHeight: 1.5,
      indicatorDecoration: BoxDecoration(color: Colors.white),
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(PivotItemStyle(color: lightButtonBackgroundColor));
    else
      return def.copyWith(PivotItemStyle(color: darkButtonBackgroundColor));
  }

  PivotItemStyle copyWith(PivotItemStyle style) {
    if (style == null) return this;
    return PivotItemStyle(
      cursor: style?.cursor ?? cursor,
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      color: style?.color ?? color,
      selectedTextStyle: style?.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: style?.unselectedTextStyle ?? unselectedTextStyle,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      indicatorDecoration: style?.indicatorDecoration ?? indicatorDecoration,
      indicatorHeight: style?.indicatorHeight ?? indicatorHeight,
    );
  }
}

class PivotView extends StatelessWidget {
  const PivotView({
    Key key,
    @required this.currentIndex,
    @required this.pages,
    this.transitionDuration,
    this.transitionCurve,
    this.transitionBuilder,
  })  : assert(pages != null),
        assert(currentIndex != null),
        assert(currentIndex >= 0 && currentIndex < pages.length),
        super(key: key);

  /// The pages. This can NOT be null
  final List<Widget> pages;

  /// The current index. This can NOT be null
  final int currentIndex;

  /// The duration of the transition. Defaults to [Duration(milliseconds: 200)]
  final Duration transitionDuration;

  /// The curve of the transition. Defaults to [Curves.linear]
  final Curve transitionCurve;

  /// The transition. Defaults to a [FadeTransition]
  final Widget Function(Widget child, Animation<double> animation)
      transitionBuilder;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.pivotItemStyle;
    return AnimatedSwitcher(
      duration: transitionDuration ?? style?.animationDuration,
      switchInCurve: transitionCurve ?? style?.animationCurve,
      child: Container(
        key: ValueKey<int>(currentIndex),
        child: pages[currentIndex],
      ),
      transitionBuilder:
          transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
    );
  }
}
