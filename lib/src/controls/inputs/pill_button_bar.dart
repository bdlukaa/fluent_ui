import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';

const double _kMinHeight = 28.0;
const double _kMaxHeight = 46.0;

const double _kButtonsSpacing = 8.0;

const double _kMinButtonWidth = 56.0;
const double _kMaxButtonHeight = _kMinHeight;

/// The item used by [PillButtonBar]
class PillButtonBarItem {
  /// The text
  final Widget text;

  /// Create a new pill button item
  const PillButtonBarItem({required this.text});
}

/// Pill button bar is a horizontal scrollable list of pill-shaped
/// text buttons in which only one button can be selected at a given
/// time.
///
/// ![Light PillButtonBar](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/ios/updated/img_pillbar_01_light.png?text=LightMode)
///
/// ![Dark PillButtonBar](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/ios/updated/img_pillbar_01_dark.png?text=DarkMode)
///
/// See also:
///
///   * [PillButtonBarItem], the item used by pill button bar
///   * [PillButtonTheme], used to style the pill button bar
class PillButtonBar extends StatelessWidget {
  /// Creates a pill button bar.
  ///
  /// [selected] must be in the range of 0 to [items.length]
  const PillButtonBar({
    Key? key,
    required this.items,
    required this.selected,
    this.onChanged,
    this.controller,
  })  : assert(items.length >= 2),
        assert(selected >= 0 && selected < items.length),
        super(key: key);

  /// The items of the bar. There must be at least 2 items in the list
  final List<PillButtonBarItem> items;

  /// The current selected item index. It must be in the range
  /// of 0 to [items.length]
  final int selected;

  /// Called when the items are changed. If null, the bar is
  /// considered disabled.
  final ValueChanged<int>? onChanged;

  /// The scroll controller used to control the current scroll
  /// position of the bar.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = PillButtonBarTheme.of(context);
    final visualDensity = FluentTheme.of(context).visualDensity;
    Widget bar = Container(
      constraints: BoxConstraints(
        minHeight: _kMinHeight + visualDensity.vertical,
        maxHeight: _kMaxHeight + visualDensity.vertical,
      ),
      color: theme.backgroundColor ?? FluentTheme.of(context).accentColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        controller: controller,
        semanticChildCount: items.length,
        children: List<Widget>.generate(items.length, (index) {
          final item = items[index];
          return _PillButtonBarItem(
            item: item,
            selected: selected == index,
            onPressed: onChanged == null ? null : () => onChanged!(index),
          );
        }),
      ),
    );
    return Align(alignment: Alignment.topLeft, child: bar);
  }
}

class _PillButtonBarItem extends StatelessWidget {
  const _PillButtonBarItem({
    Key? key,
    required this.item,
    this.selected = false,
    this.onPressed,
  }) : super(key: key);

  final PillButtonBarItem item;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = PillButtonBarTheme.of(context);
    final VisualDensity visualDensity = FluentTheme.of(context).visualDensity;
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        final Color selectedColor =
            theme.selectedColor?.resolve(states) ?? Colors.transparent;
        final Color unselectedColor = theme.unselectedColor?.resolve(states) ??
            FluentTheme.of(context).accentColor.dark;
        return Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? selectedColor : unselectedColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            constraints: BoxConstraints(
              minWidth: _kMinButtonWidth + visualDensity.horizontal,
              maxHeight: _kMaxButtonHeight + visualDensity.vertical,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 + visualDensity.horizontal,
              vertical: 3.0,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: _kButtonsSpacing + visualDensity.horizontal,
              vertical: _kButtonsSpacing + visualDensity.vertical,
            ),
            child: DefaultTextStyle(
              style: (selected
                      ? theme.selectedTextStyle
                      : theme.unselectedTextStyle) ??
                  TextStyle(
                    color: selected
                        ? selectedColor
                        : unselectedColor.basedOnLuminance(),
                  ),
              child: item.text,
            ),
          ),
        );
      },
    );
  }
}

/// An inherited widget that defines the configuration for
/// [PillButtonBar]s in this widget's subtree.
///
/// Values specified here are used for [PillButtonBar] properties that are not
/// given an explicit non-null value.
class PillButtonBarTheme extends InheritedTheme {
  /// Creates a button theme that controls the configurations for
  /// [PillButtonBar].
  const PillButtonBarTheme({
    Key? key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

  /// The properties for descendant [PillButtonBar] widgets.
  final PillButtonBarThemeData data;

  /// Creates a button theme that controls how descendant [PillButtonBar]s should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required PillButtonBarThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return PillButtonBarTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [ThemeData.pillButtonBarTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// PillButtonBarThemeData theme = PillButtonBarTheme.of(context);
  /// ```
  static PillButtonBarThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return PillButtonBarThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  static PillButtonBarThemeData _getInheritedThemeData(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<PillButtonBarTheme>();
    return theme?.data ?? FluentTheme.of(context).pillButtonBarTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return PillButtonBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(PillButtonBarTheme oldWidget) {
    return oldWidget.data != data;
  }
}

/// See also:
///
///   * [PillButtonBar], the widget styled by this theme data
///   * [PillButtonBarTheme], an inherited theme that required this
///     theme data
@immutable
class PillButtonBarThemeData with Diagnosticable {
  final Color? backgroundColor;
  final ButtonState<Color?>? selectedColor;
  final ButtonState<Color?>? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  const PillButtonBarThemeData({
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  factory PillButtonBarThemeData.standard(ThemeData style) {
    Color _applyOpacity(Color color, Set<ButtonStates> states) {
      return color.withOpacity(
        states.isPressing
            ? 0.925
            : states.isFocused
                ? 0.4
                : states.isHovering
                    ? 0.85
                    : 1.0,
      );
    }

    final isLight = style.brightness.isLight;
    final unselectedColor =
        isLight ? style.accentColor.dark : const Color(0xFF141414);

    return PillButtonBarThemeData(
      backgroundColor: isLight ? style.accentColor : const Color(0xFF212121),
      selectedColor: ButtonState.resolveWith((states) {
        return _applyOpacity(
            isLight ? Colors.white : const Color(0xFF404040), states);
      }),
      unselectedColor: ButtonState.resolveWith((states) {
        return _applyOpacity(unselectedColor, states);
      }),
      selectedTextStyle:
          TextStyle(color: isLight ? Colors.black : Colors.white),
      unselectedTextStyle: TextStyle(
          color: isLight ? unselectedColor.basedOnLuminance() : Colors.white),
    );
  }

  static PillButtonBarThemeData lerp(
    PillButtonBarThemeData? a,
    PillButtonBarThemeData? b,
    double t,
  ) {
    return PillButtonBarThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      selectedTextStyle:
          TextStyle.lerp(a?.selectedTextStyle, b?.selectedTextStyle, t),
      unselectedTextStyle:
          TextStyle.lerp(a?.unselectedTextStyle, b?.unselectedTextStyle, t),
      selectedColor:
          ButtonState.lerp(a?.selectedColor, b?.selectedColor, t, Color.lerp),
      unselectedColor: ButtonState.lerp(
          a?.unselectedColor, b?.unselectedColor, t, Color.lerp),
    );
  }

  PillButtonBarThemeData merge(PillButtonBarThemeData? other) {
    if (other == null) return this;
    return PillButtonBarThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedColor: other.selectedColor ?? selectedColor,
      unselectedColor: other.unselectedColor ?? unselectedColor,
      selectedTextStyle: other.selectedTextStyle ?? selectedTextStyle,
      unselectedTextStyle: other.unselectedTextStyle ?? unselectedTextStyle,
    );
  }
}
