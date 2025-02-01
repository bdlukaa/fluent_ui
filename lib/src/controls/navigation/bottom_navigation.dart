import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const double _kBottomNavigationHeight = 48.0;

/// The navigation item used by [BottomNavigation]
class BottomNavigationItem {
  /// The label of the item. If not provided, only [icon] is shown
  ///
  /// Usually a [Text] widget
  final Widget? title;

  /// The icon that represents this item.
  ///
  /// Usually an [Icon] or an [AnimatedIcon]
  final Widget icon;

  /// The icon that represents this item when selected. If null, [icon]
  /// is displayed.
  ///
  /// Usually an [Icon]
  final Widget? selectedIcon;

  /// Creates a new bottom navigation item.
  const BottomNavigationItem({
    required this.icon,
    this.selectedIcon,
    this.title,
  });
}

/// The bottom navigation displays icons and optional text at the
/// bottom of the screen for switching between different primary
/// destinations in an app.
///
/// It's usually used on [ScaffoldPage.bottomBar]
///
/// ![BottomNavigation Preview](https://static2.sharepointonline.com/files/fabric/fabric-website/images/controls/android/updated/img_bottomnavigation_01_dark.png?text=DarkMode)
///
/// See also:
///
///   * [BottomNavigationItem], the items used by this widget
///   * [BottomNavigationThemeData], used to style this widget
///   * [ScaffoldPage], used to layout pages
class BottomNavigation extends StatelessWidget {
  /// Creates a bottom navigation
  ///
  /// [items] must have at least 2 items
  ///
  /// [index] must be in the range of 0 to [items.length]
  const BottomNavigation({
    super.key,
    required this.items,
    required this.index,
    this.onChanged,
    this.style,
  })  : assert(items.length >= 2),
        assert(index >= 0 && index < items.length);

  /// The items displayed by this widget. There must be at least 2
  /// items in the list.
  ///
  /// See also:
  ///
  ///   * [BottomNavigationItem], the items used on this bottom navigation
  final List<BottomNavigationItem> items;

  /// The current selected index. This must be in the range of 0 to [items.length]
  final int index;

  /// Called when the current index should be changed. If null, the bottom
  /// navigation items are considered disabled.
  ///
  /// {@tool snippet}
  /// ```dart
  ///
  /// int index = 0;
  ///
  /// BottomNavigation(
  ///   index: index,
  ///   onChanged: (i) => setState(() => index = i),
  /// )
  /// ```
  /// {@end-tool}
  final ValueChanged<int>? onChanged;

  /// Used to style this bottom navigation bar. If non-null,
  /// it's mescled with [FluentThemeData.bottomNavigationTheme]
  final BottomNavigationThemeData? style;

  bool get _disabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = BottomNavigationTheme.of(context).merge(this.style);
    return PhysicalModel(
      color: Colors.black,
      elevation: 8.0,
      shadowColor: FluentTheme.of(context).shadowColor,
      child: Container(
        constraints: const BoxConstraints(minHeight: _kBottomNavigationHeight),
        color: style.backgroundColor,
        child: Row(
          children: items.map((item) {
            final itemIndex = items.indexOf(item);
            return _BottomNavigationItem(
              key: ValueKey<BottomNavigationItem>(item),
              item: item,
              style: style,
              selected: index == itemIndex,
              onPressed: _disabled ? null : () => onChanged!(itemIndex),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    super.key,
    required this.item,
    required this.selected,
    required this.style,
    this.onPressed,
  });

  final BottomNavigationItem item;
  final bool selected;
  final VoidCallback? onPressed;
  final BottomNavigationThemeData style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HoverButton(
        onPressed: onPressed,
        builder: (context, state) {
          final content =
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconTheme.merge(
              data: IconThemeData(
                color: selected ? style.selectedColor : style.inactiveColor,
              ),
              child: selected ? item.selectedIcon ?? item.icon : item.icon,
            ),
            if (item.title != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 1.0),
                child: DefaultTextStyle.merge(
                  style: FluentTheme.of(context).typography.caption!.copyWith(
                        color: selected
                            ? style.selectedColor
                            : style.inactiveColor,
                      ),
                  child: item.title!,
                ),
              ),
          ]);
          return FocusBorder(
            focused: state.isFocused,
            renderOutside: false,
            child: ColoredBox(
              color: ButtonThemeData.uncheckedInputColor(
                FluentTheme.of(context),
                state,
              ),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [BottomNavigation]s in this widget's subtree.
///
/// Values specified here are used for [BottomNavigation] properties that are not
/// given an explicit non-null value.
class BottomNavigationTheme extends InheritedTheme {
  /// Creates a button theme that controls the configurations for
  /// [BottomNavigation].
  const BottomNavigationTheme({
    super.key,
    required super.child,
    required this.data,
  });

  /// The properties for descendant [BottomNavigation] widgets.
  final BottomNavigationThemeData data;

  /// Creates a button theme that controls how descendant [BottomNavigation]s should
  /// look like, and merges in the current button theme, if any.
  static Widget merge({
    Key? key,
    required BottomNavigationThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return BottomNavigationTheme(
        key: key,
        data: _getInheritedBottomNavigationThemeData(context).merge(data),
        child: child,
      );
    });
  }

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Defaults to [FluentThemeData.bottomNavigationTheme]
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// BottomNavigationThemeData theme = BottomNavigationTheme.of(context);
  /// ```
  static BottomNavigationThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return BottomNavigationThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedBottomNavigationThemeData(context),
    );
  }

  static BottomNavigationThemeData _getInheritedBottomNavigationThemeData(
      BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<BottomNavigationTheme>();
    return theme?.data ?? FluentTheme.of(context).bottomNavigationTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return BottomNavigationTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(BottomNavigationTheme oldWidget) {
    return oldWidget.data != data;
  }
}

/// See also:
///
///   * [BottomNavigation], the widget styled by this theme data
///   * [BottomNavigationTheme], an inherited theme that required this
///     theme data
@immutable
class BottomNavigationThemeData with Diagnosticable {
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? inactiveColor;

  const BottomNavigationThemeData({
    this.backgroundColor,
    this.selectedColor,
    this.inactiveColor,
  });

  factory BottomNavigationThemeData.standard(FluentThemeData theme) {
    final isLight = theme.brightness.isLight;
    return BottomNavigationThemeData(
      backgroundColor:
          isLight ? const Color(0xFFf8f8f8) : const Color(0xFF0c0c0c),
      selectedColor: theme.accentColor,
      inactiveColor: theme.resources.controlFillColorDisabled,
    );
  }

  static BottomNavigationThemeData lerp(
    BottomNavigationThemeData? a,
    BottomNavigationThemeData? b,
    double t,
  ) {
    return BottomNavigationThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      inactiveColor: Color.lerp(a?.inactiveColor, b?.inactiveColor, t),
    );
  }

  BottomNavigationThemeData merge(BottomNavigationThemeData? other) {
    if (other == null) return this;
    return BottomNavigationThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedColor: other.selectedColor ?? selectedColor,
      inactiveColor: other.inactiveColor ?? inactiveColor,
    );
  }
}
