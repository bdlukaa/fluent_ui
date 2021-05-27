import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';

const double _kMinHeight = 28.0;

const double _kMinButtonsSpacing = 8.0;
const double _kMaxButtonsSpacing = 10.0;

const double _kMinButtonWidth = 56.0;
const double _kMaxButtonHeight = _kMinHeight;

class PillButtonBarItem {
  final Widget text;

  const PillButtonBarItem({
    required this.text,
  });
}

/// Pill button bar is a horizontal scrollable list of
/// pill-shaped text buttons in which only one button
/// can be selected at a given time.
class PillButtonBar extends StatelessWidget {
  /// Creates a pill button bar.
  const PillButtonBar({
    Key? key,
    required this.items,
    required this.selected,
    this.onChanged,
  })  : assert(items.length > 2),
        super(key: key);

  /// The items used on this
  final List<PillButtonBarItem> items;

  final int selected;

  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = PillButtonBarTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: _kMinHeight),
      color: theme.backgroundColor ?? FluentTheme.of(context).accentColor,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ...List.generate(items.length, (index) {
          final item = items[index];
          return _PillButtonBarItem(
            item: item,
            selected: selected == index,
            onPressed: onChanged == null ? null : () => onChanged!(index),
          );
        }),
      ]),
    );
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

    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        final Color selectedColor =
            theme.selectedColor?.resolve(states) ?? Colors.transparent;
        final Color unselectedColor = theme.unselectedColor?.resolve(states) ??
            FluentTheme.of(context).accentColor.dark;
        return Container(
          decoration: BoxDecoration(
            color: selected ? selectedColor : unselectedColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          constraints: const BoxConstraints(
            minWidth: _kMinButtonWidth,
            maxHeight: _kMaxButtonHeight,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
          margin: const EdgeInsets.all(_kMinButtonsSpacing),
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
            : states.isHovering
                ? 0.85
                : 1.0,
      );
    }

    final isLight = style.brightness.isLight;
    final unselectedColor =
        isLight ? style.accentColor.dark : Color(0xFF141414);

    return PillButtonBarThemeData(
      backgroundColor: isLight ? style.accentColor : Color(0xFF212121),
      selectedColor: ButtonState.resolveWith((states) {
        return _applyOpacity(
            isLight ? Colors.white : Color(0xFF404040), states);
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
      selectedTextStyle: TextStyle.lerp(a?.selectedTextStyle, b?.selectedTextStyle, t),
      unselectedTextStyle: TextStyle.lerp(a?.unselectedTextStyle, b?.unselectedTextStyle, t),
      selectedColor: ButtonState.lerp(a?.selectedColor, b?.selectedColor, t, Color.lerp),
      unselectedColor: ButtonState.lerp(a?.unselectedColor, b?.unselectedColor, t, Color.lerp),
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
