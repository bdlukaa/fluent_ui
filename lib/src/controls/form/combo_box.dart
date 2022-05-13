import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'pickers/pickers.dart';

const Duration _kComboboxMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemHeight = kPickerHeight;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 12.0);
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsets.only(
  top: 4.0,
  bottom: 4.0,
  right: 8.0,
  left: 12.0,
);
const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;
const EdgeInsets _kListPadding = EdgeInsets.symmetric(vertical: 8.0);
const double kMinInteractiveDimension = 48.0;

/// A builder to customize combobox buttons.
///
/// Used by [Combobox.selectedItemBuilder].
typedef ComboboxBuilder = List<Widget> Function(BuildContext context);

class _ComboboxMenuPainter extends CustomPainter {
  _ComboboxMenuPainter({
    this.selectedIndex,
    required this.resize,
    required this.getSelectedItemOffset,
    required Color backgroundColor,
    required double elevation,
  })  : _painter = BoxDecoration(
          // If you add an image here, you must provide a real
          // configuration in the paint() function and you must provide some sort
          // of onChanged callback here.
          // color: color,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(width: 0.25),
          color: backgroundColor,
          boxShadow: kElevationToShadow[elevation],
        ).createBoxPainter(),
        super(repaint: resize);

  final int? selectedIndex;
  final Animation<double> resize;
  final ValueGetter<double> getSelectedItemOffset;
  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset = getSelectedItemOffset();
    final Tween<double> top = Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - _kMenuItemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = Tween<double>(
      begin:
          (top.begin! + _kMenuItemHeight).clamp(_kMenuItemHeight, size.height),
      end: size.height,
    );

    final Rect rect = Rect.fromLTRB(
        0.0, top.evaluate(resize), size.width, bottom.evaluate(resize));

    _painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_ComboboxMenuPainter oldPainter) {
    return oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

// Do not use the platform-specific default scroll configuration.
// Combobox menus should never overscroll or display an overscroll indicator.
class _ComboboxScrollBehavior extends FluentScrollBehavior {
  const _ComboboxScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

// The widget that is the button wrapping the menu items.
class _ComboboxItemButton<T> extends StatefulWidget {
  const _ComboboxItemButton({
    Key? key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;

  @override
  _ComboboxItemButtonState<T> createState() => _ComboboxItemButtonState<T>();
}

class _ComboboxItemButtonState<T> extends State<_ComboboxItemButton<T>> {
  void _handleFocusChange(bool focused) {
    final bool inTraditionalMode;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        inTraditionalMode = false;
        break;
      case FocusHighlightMode.traditional:
        inTraditionalMode = true;
        break;
    }

    if (focused && inTraditionalMode) {
      final _MenuLimits menuLimits = widget.route.getMenuLimits(
          widget.buttonRect, widget.constraints.maxHeight, widget.itemIndex);
      widget.route.scrollController!.animateTo(
        menuLimits.scrollOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  void _handleOnTap() {
    final ComboboxItem<T> comboboxMenuItem =
        widget.route.items[widget.itemIndex].item!;

    if (comboboxMenuItem.onTap != null) {
      comboboxMenuItem.onTap!();
    }

    Navigator.pop(
      context,
      _ComboboxRouteResult<T>(comboboxMenuItem.value),
    );
  }

  static final Map<LogicalKeySet, Intent> _webShortcuts =
      <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Widget child = HoverButton(
      autofocus: widget.itemIndex == widget.route.selectedIndex,
      builder: (context, states) {
        final theme = FluentTheme.of(context);
        return Padding(
          padding: const EdgeInsets.only(right: 6.0, left: 6.0, bottom: 4.0),
          child: Stack(fit: StackFit.loose, children: [
            Container(
              decoration: BoxDecoration(
                color: () {
                  if (states.isFocused) {
                    return ButtonThemeData.uncheckedInputColor(
                      theme,
                      {ButtonStates.hovering},
                    );
                  }
                  return ButtonThemeData.uncheckedInputColor(theme, states);
                }(),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: widget.padding,
              child: widget.route.items[widget.itemIndex],
            ),
            if (states.isFocused)
              AnimatedPositioned(
                duration: theme.fastAnimationDuration,
                curve: theme.animationCurve,
                top: states.isPressing ? 10.0 : 8.0,
                bottom: states.isPressing ? 10.0 : 8.0,
                child: Container(
                  width: 3.0,
                  decoration: BoxDecoration(
                    color: theme.accentColor
                        .resolveFromReverseBrightness(theme.brightness),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
          ]),
        );
      },
      onPressed: _handleOnTap,
      onFocusChange: _handleFocusChange,
    );
    if (kIsWeb) {
      // On the web, enter doesn't select things, *except* in a <select>
      // element, which is what a combobox emulates.
      child = Shortcuts(
        shortcuts: _webShortcuts,
        child: child,
      );
    }
    return child;
  }
}

class _ComboboxMenu<T> extends StatefulWidget {
  const _ComboboxMenu({
    Key? key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    this.comboboxColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? comboboxColor;

  @override
  _ComboboxMenuState<T> createState() => _ComboboxMenuState<T>();
}

class _ComboboxMenuState<T> extends State<_ComboboxMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  late CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
    // We need to hold these animations as state because of their curve
    // direction. When the route's animation reverses, if we were to recreate
    // the CurvedAnimation objects in build, we'd lose
    // CurvedAnimation._curveDirection.
    _fadeOpacity = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _resize = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The menu is shown in three stages (unit timing in brackets):
    // [0s - 0.25s] - Fade in a rect-sized menu container with the selected item.
    // [0.25s - 0.5s] - Grow the otherwise empty menu container from the center
    //   until it's big enough for as many items as we're going to show.
    // [0.5s - 1.0s] Fade in the remaining visible items from top to bottom.
    //
    // When the menu is dismissed we just fade the entire thing out
    // in the first 0.25s.
    final _ComboboxRoute<T> route = widget.route;
    final List<Widget> children = <Widget>[
      for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex)
        _ComboboxItemButton<T>(
          route: widget.route,
          padding: widget.padding,
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          itemIndex: itemIndex,
        ),
    ];

    return FadeTransition(
      opacity: _fadeOpacity,
      child: CustomPaint(
        painter: _ComboboxMenuPainter(
          selectedIndex: route.selectedIndex,
          resize: _resize,
          // This offset is passed as a callback, not a value, because it must
          // be retrieved at paint time (after layout), not at build time.
          getSelectedItemOffset: () => route.getItemOffset(route.selectedIndex),
          backgroundColor: FluentTheme.of(context).menuColor,
          elevation: route.elevation.toDouble(),
        ),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          // label: localizations.popupMenuLabel,
          child: DefaultTextStyle(
            style: route.style,
            child: ScrollConfiguration(
              behavior: const _ComboboxScrollBehavior(),
              child: PrimaryScrollController(
                controller: widget.route.scrollController!,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // final double menuTotalHeight = widget.route.itemHeights
                    //     .reduce(
                    //         (double total, double height) => total + height);
                    // final bool isScrollable =
                    //     _kListPadding.vertical + menuTotalHeight >
                    //         constraints.maxHeight;
                    return ListView(
                      padding: _kListPadding,
                      shrinkWrap: true,
                      children: children,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboboxMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _ComboboxMenuRouteLayout({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
  });

  final Rect buttonRect;
  final _ComboboxRoute<T> route;
  final TextDirection? textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The maximum height of a simple menu should be one or more rows less than
    // the view height. This ensures a tappable area outside of the simple menu
    // with which to dismiss the menu.
    //   -- https://material.io/design/components/menus.html#usage
    final double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    // The width of a menu should be at most the view width. This ensures that
    // the menu does not extend past the left and right edges of the screen.
    final double width = math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final _MenuLimits menuLimits =
        route.getMenuLimits(buttonRect, size.height, route.selectedIndex);

    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
        // If the button was entirely on-screen, then verify
        // that the menu is also on-screen.
        // If the button was a bit off-screen, then, oh well.
        assert(menuLimits.top >= 0.0);
        assert(menuLimits.top + menuLimits.height <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    final double left;
    switch (textDirection!) {
      case TextDirection.rtl:
        left = buttonRect.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
        break;
    }

    return Offset(left, menuLimits.top);
  }

  @override
  bool shouldRelayout(_ComboboxMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}

// We box the return value so that the return value can be null. Otherwise,
// canceling the route (which returns null) would get confused with actually
// returning a real null value.
@immutable
class _ComboboxRouteResult<T> {
  const _ComboboxRouteResult(this.result);

  final T? result;

  @override
  bool operator ==(Object other) {
    return other is _ComboboxRouteResult<T> && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _MenuLimits {
  const _MenuLimits(this.top, this.bottom, this.height, this.scrollOffset);
  final double top;
  final double bottom;
  final double height;
  final double scrollOffset;
}

class _ComboboxRoute<T> extends PopupRoute<_ComboboxRouteResult<T>> {
  _ComboboxRoute({
    required this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 16,
    required this.capturedThemes,
    required this.style,
    required this.acrylicEnabled,
    this.barrierLabel,
    this.itemHeight,
    this.comboboxColor,
  }) : itemHeights = List<double>.filled(
            items.length, itemHeight ?? kMinInteractiveDimension);

  final List<_MenuItem<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final double? itemHeight;
  final Color? comboboxColor;
  final bool acrylicEnabled;

  final List<double> itemHeights;
  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kComboboxMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(context, animation, secondaryAnimation) {
    return LayoutBuilder(builder: (context, constraints) {
      final page = _ComboboxRoutePage<T>(
        route: this,
        constraints: constraints,
        items: items,
        padding: padding,
        buttonRect: buttonRect,
        selectedIndex: selectedIndex,
        elevation: elevation,
        capturedThemes: capturedThemes,
        style: style,
        comboboxColor: comboboxColor,
      );
      if (acrylicEnabled) return page;
      return DisableAcrylic(child: page);
    });
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  double getItemOffset(int index) {
    double offset = _kListPadding.top;
    if (items.isNotEmpty && index > 0) {
      assert(items.length == itemHeights.length);
      offset += itemHeights
          .sublist(0, index)
          .reduce((double total, double height) => total + height);
    }
    return offset;
  }

  // Returns the vertical extent of the menu and the initial scrollOffset
  // for the ListView that contains the menu items. The vertical center of the
  // selected item is aligned with the button's vertical center, as far as
  // that's possible given availableHeight.
  _MenuLimits getMenuLimits(
      Rect buttonRect, double availableHeight, int index) {
    final double maxMenuHeight = availableHeight - 2.0 * _kMenuItemHeight;
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final double selectedItemOffset = getItemOffset(index);

    // If the button is placed on the bottom or top of the screen, its top or
    // bottom may be less than [_kMenuItemHeight] from the edge of the screen.
    // In this case, we want to change the menu limits to align with the top
    // or bottom edge of the button.
    final double topLimit = math.min(_kMenuItemHeight, buttonTop);
    final double bottomLimit =
        math.max(availableHeight - _kMenuItemHeight, buttonBottom);

    double menuTop = (buttonTop - selectedItemOffset) -
        (itemHeights[selectedIndex] - buttonRect.height) / 2.0;
    double preferredMenuHeight = _kListPadding.vertical;
    if (items.isNotEmpty) {
      preferredMenuHeight +=
          itemHeights.reduce((double total, double height) => total + height);
    }

    // If there are too many elements in the menu, we need to shrink it down
    // so it is at most the maxMenuHeight.
    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);
    double menuBottom = menuTop + menuHeight;

    // If the computed top or bottom of the menu are outside of the range
    // specified, we need to bring them into range. If the item height is larger
    // than the button height and the button is at the very bottom or top of the
    // screen, the menu will be aligned with the bottom or top of the button
    // respectively.
    if (menuTop < topLimit) menuTop = math.min(buttonTop, topLimit);

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    double scrollOffset = 0;
    // If all of the menu items will not fit within availableHeight then
    // compute the scroll offset that will line the selected menu item up
    // with the select item. This is only done when the menu is first
    // shown - subsequently we leave the scroll offset where the user left
    // it. This scroll offset is only accurate for fixed height menu items
    // (the default).
    if (preferredMenuHeight > maxMenuHeight) {
      // The offset should be zero if the selected item is in view at the beginning
      // of the menu. Otherwise, the scroll offset should center the item if possible.
      scrollOffset = math.max(0.0, selectedItemOffset - (buttonTop - menuTop));
      // If the selected item's scroll offset is greater than the maximum scroll offset,
      // set it instead to the maximum allowed scroll offset.
      scrollOffset = math.min(scrollOffset, preferredMenuHeight - menuHeight);
    }

    return _MenuLimits(menuTop, menuBottom, menuHeight, scrollOffset);
  }
}

class _ComboboxRoutePage<T> extends StatelessWidget {
  const _ComboboxRoutePage({
    Key? key,
    required this.route,
    required this.constraints,
    this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    required this.comboboxColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final BoxConstraints constraints;
  final List<_MenuItem<T>>? items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? comboboxColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    // Computing the initialScrollOffset now, before the items have been laid
    // out. This only works if the item heights are effectively fixed, i.e. either
    // Combobox.itemHeight is specified or Combobox.itemHeight is null
    // and all of the items' intrinsic heights are less than kMinInteractiveDimension.
    // Otherwise the initialScrollOffset is just a rough approximation based on
    // treating the items as if their heights were all equal to kMinInteractveDimension.
    if (route.scrollController == null) {
      final _MenuLimits menuLimits =
          route.getMenuLimits(buttonRect, constraints.maxHeight, selectedIndex);
      route.scrollController =
          ScrollController(initialScrollOffset: menuLimits.scrollOffset);
    }

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _ComboboxMenu<T>(
      route: route,
      padding: padding.resolve(textDirection),
      buttonRect: buttonRect,
      constraints: constraints,
      comboboxColor: comboboxColor,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _ComboboxMenuRouteLayout<T>(
              buttonRect: buttonRect,
              route: route,
              textDirection: textDirection,
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }
}

// This widget enables _ComboboxRoute to look up the sizes of
// each menu item. These sizes are used to compute the offset of the selected
// item so that _ComboboxRoutePage can align the vertical center of the
// selected item lines up with the vertical center of the combobox button,
// as closely as possible.
class _MenuItem<T> extends SingleChildRenderObjectWidget {
  const _MenuItem({
    Key? key,
    required this.onLayout,
    required this.item,
  }) : super(key: key, child: item);

  final ValueChanged<Size> onLayout;
  final ComboboxItem<T>? item;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem extends RenderProxyBox {
  _RenderMenuItem(this.onLayout, [RenderBox? child]) : super(child);

  ValueChanged<Size> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size);
  }
}

// The container widget for a menu item created by a [Combobox]. It
// provides the default configuration for [ComboboxItem]s, as well as a
// [Combobox]'s placeholder and disabledHint widgets.
class _ComboboxItemContainer extends StatelessWidget {
  /// Creates an item for a combobox menu.
  ///
  /// The [child] argument is required.
  const _ComboboxItemContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _kMenuItemHeight),
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }
}

/// An item in a menu created by a [Combobox].
///
/// The type `T` is the type of the value the entry represents. All the entries
/// in a given menu must represent values with consistent types.
class ComboboxItem<T> extends _ComboboxItemContainer {
  /// Creates an item for a combobox menu.
  ///
  /// The [child] argument is required.
  const ComboboxItem({
    Key? key,
    this.onTap,
    this.value,
    required Widget child,
  }) : super(key: key, child: child);

  /// Called when the combobox menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [Combobox.onChanged].
  final T? value;
}

/// A fluent design button for selecting from a list of items.
///
/// A combobox button lets the user select from a number of items. The button
/// shows the currently selected item as well as an arrow that opens a menu for
/// selecting another item.
///
/// The type `T` is the type of the [value] that each combobox item represents.
/// All the entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [ComboboxItem] in [items] must be
/// specialized with that same type argument.
///
/// The [onChanged] callback should update a state variable that defines the
/// combobox's value. It should also call [State.setState] to rebuild the
/// combobox with the new value.
///
/// If the [onChanged] callback is null or the list of [items] is null
/// then the combobox button will be disabled, i.e. its arrow will be
/// displayed in grey and it will not respond to input. A disabled button
/// will display the [disabledHint] widget if it is non-null. However, if
/// [disabledHint] is null and [placeholder] is non-null, the [placeholder]
/// widget will instead be displayed.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [ComboboxItem], the class used to represent the [items].
class Combobox<T> extends StatefulWidget {
  /// Creates a combobox button.
  ///
  /// The [items] must have distinct values. If [value] isn't null then it
  /// must be equal to one of the [ComboboxItem] values. If [items] or
  /// [onChanged] is null, the button will be disabled, the down arrow
  /// will be greyed out.
  ///
  /// If [value] is null and the button is enabled, [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// The [elevation] and [iconSize] arguments must not be null (they both have
  /// defaults, so do not need to be specified). The [isExpanded] arguments must
  /// not be null.
  ///
  /// The [autofocus] argument must not be null.
  ///
  /// The [comboboxColor] argument specifies the background color of the
  /// combobox when it is open. If it is null, the current theme's
  /// [ThemeData.canvasColor] will be used instead.
  Combobox({
    Key? key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.placeholder,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 10.0,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.comboboxColor,
    // When adding new arguments, consider adding similar arguments to
    // ComboboxFormField.
  })  : assert(
          items == null ||
              items.isEmpty ||
              value == null ||
              items.where((ComboboxItem<T> item) {
                    return item.value == value;
                  }).length ==
                  1,
          "There should be exactly one item with [Combobox]'s value: "
          '$value. \n'
          'Either zero or 2 or more [ComboboxItem]s were detected '
          'with the same value',
        ),
        assert(itemHeight == null || itemHeight >= kMinInteractiveDimension),
        super(key: key);

  /// The list of items the user can select.
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the combobox button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input.
  final List<ComboboxItem<T>>? items;

  /// The value of the currently selected [ComboboxItem].
  ///
  /// If [value] is null and the button is enabled, [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [placeholder] will be displayed
  /// if it is non-null.
  final T? value;

  /// A placeholder widget that is displayed by the combobox button.
  ///
  /// If [value] is null and the combobox is enabled ([items] and [onChanged] are non-null),
  /// this widget is displayed as a placeholder for the combobox button's value.
  ///
  /// If [value] is null and the combobox is disabled and [disabledHint] is null,
  /// this widget is used as the placeholder.
  final Widget? placeholder;

  /// A preferred placeholder widget that is displayed when the combobox is disabled.
  ///
  /// If [value] is null, the combobox is disabled ([items] or [onChanged] is null),
  /// this widget is displayed as a placeholder for the combobox button's value.
  final Widget? disabledHint;

  /// {@template flutter.material.comboboxButton.onChanged}
  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [Combobox.items]
  /// is null then the combobox button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input. A disabled button
  /// will display the [Combobox.disabledHint] widget if it is non-null.
  /// If [Combobox.disabledHint] is also null but [Combobox.placeholder] is
  /// non-null, [Combobox.placeholder] will instead be displayed.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

  /// Called when the combobox button is tapped.
  ///
  /// This is distinct from [onChanged], which is called when the user
  /// selects an item from the combobox.
  ///
  /// The callback will not be invoked if the combobox button is disabled.
  final VoidCallback? onTap;

  /// A builder to customize the combobox buttons corresponding to the
  /// [ComboboxItem]s in [items].
  ///
  /// When a [ComboboxItem] is selected, the widget that will be displayed
  /// from the list corresponds to the [ComboboxItem] of the same index
  /// in [items].
  ///
  /// {@tool dartpad --template=stateful_widget_scaffold}
  ///
  /// This sample shows a `Combobox` with a button with [Text] that
  /// corresponds to but is unique from [ComboboxItem].
  ///
  /// ```dart
  /// final List<String> items = <String>['1','2','3'];
  /// String selectedItem = '1';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Padding(
  ///     padding: const EdgeInsets.symmetric(horizontal: 12.0),
  ///     child: Combobox<String>(
  ///       value: selectedItem,
  ///       onChanged: (String? string) => setState(() => selectedItem = string!),
  ///       selectedItemBuilder: (BuildContext context) {
  ///         return items.map<Widget>((String item) {
  ///           return Text(item);
  ///         }).toList();
  ///       },
  ///       items: items.map((String item) {
  ///         return ComboboxItem<String>(
  ///           child: Text('Log $item'),
  ///           value: item,
  ///         );
  ///       }).toList(),
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// If this callback is null, the [ComboboxItem] from [items]
  /// that matches [value] will be displayed.
  final ComboboxBuilder? selectedItemBuilder;

  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12,
  /// 16, and 24. See [kElevationToShadow].
  ///
  /// Defaults to 8, the appropriate elevation for combobox buttons.
  final int elevation;

  /// The text style to use for text in the combobox button and the combobox
  /// menu that appears when you tap the button.
  ///
  /// To use a separate text style for selected item when it's displayed within
  /// the combobox button, consider using [selectedItemBuilder].
  ///
  /// {@tool dartpad --template=stateful_widget_scaffold}
  ///
  /// This sample shows a `Combobox` with a combobox button text style
  /// that is different than its menu items.
  ///
  /// ```dart
  /// List<String> options = <String>['One', 'Two', 'Free', 'Four'];
  /// String comboboxValue = 'One';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Container(
  ///     alignment: Alignment.center,
  ///     color: Colors.blue,
  ///     child: Combobox<String>(
  ///       value: comboboxValue,
  ///       onChanged: (String? newValue) {
  ///         setState(() {
  ///           comboboxValue = newValue!;
  ///         });
  ///       },
  ///       style: TextStyle(color: Colors.blue),
  ///       selectedItemBuilder: (BuildContext context) {
  ///         return options.map((String value) {
  ///           return Text(
  ///             comboboxValue,
  ///             style: TextStyle(color: Colors.white),
  ///           );
  ///         }).toList();
  ///       },
  ///       items: options.map<ComboboxItem<String>>((String value) {
  ///         return ComboboxItem<String>(
  ///           value: value,
  ///           child: Text(value),
  ///         );
  ///       }).toList(),
  ///     ),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// Defaults to the [TextTheme.subtitle1] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle? style;

  /// The widget to use for the drop-down button's icon.
  ///
  /// Defaults to an [Icon] with the [FluentIcons.chevron_down] glyph.
  final Widget? icon;

  /// The color of any [Icon] descendant of [icon] if this button is disabled,
  /// i.e. if [onChanged] is null.
  ///
  /// Defaults to [MaterialColor.shade400] of [Colors.grey] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white10] when it is [Brightness.dark]
  final Color? iconDisabledColor;

  /// The color of any [Icon] descendant of [icon] if this button is enabled,
  /// i.e. if [onChanged] is defined.
  ///
  /// Defaults to [MaterialColor.shade700] of [Colors.grey] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white70] when it is [Brightness.dark]
  final Color? iconEnabledColor;

  /// The size to use for the drop-down button's down arrow icon button.
  ///
  /// Defaults to 24.0.
  final double iconSize;

  /// Set the combobox's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// If null, then the menu item heights will vary according to each menu item's
  /// intrinsic height.
  ///
  /// The default value is [kMinInteractiveDimension], which is also the minimum
  /// height for menu items.
  ///
  /// If this value is null and there isn't enough vertical room for the menu,
  /// then the menu's initial scroll offset may not align the selected item with
  /// the combobox button. That's because, in this case, the initial scroll
  /// offset is computed as if all of the menu item heights were
  /// [kMinInteractiveDimension].
  final double? itemHeight;

  /// The color for the button's [Material] when it has the input focus.
  final Color? focusColor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The background color of the combobox.
  ///
  /// If it is not provided, the theme's [ThemeData.canvasColor] will be used
  /// instead.
  final Color? comboboxColor;

  @override
  _ComboboxState<T> createState() => _ComboboxState<T>();
}

class _ComboboxState<T> extends State<Combobox<T>> with WidgetsBindingObserver {
  int? _selectedIndex;
  _ComboboxRoute<T>? _comboboxRoute;
  Orientation? _lastOrientation;
  FocusNode? _internalNode;
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;
  late FocusHighlightMode _focusHighlightMode;

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
    final FocusManager focusManager = WidgetsBinding.instance.focusManager;
    _focusHighlightMode = focusManager.highlightMode;
    focusManager.addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeComboboxRoute();
    WidgetsBinding.instance.focusManager
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  void _removeComboboxRoute() {
    _comboboxRoute?._dismiss();
    _comboboxRoute = null;
    _lastOrientation = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _focusHighlightMode = mode;
    });
  }

  @override
  void didUpdateWidget(Combobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (widget.value == null || widget.items == null || widget.items!.isEmpty) {
      _selectedIndex = null;
      return;
    }

    assert(widget.items!
            .where((ComboboxItem<T> item) => item.value == widget.value)
            .length ==
        1);
    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle? get _textStyle =>
      widget.style ?? FluentTheme.of(context).typography.body;

  void _handleTap() {
    final TextDirection? textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = _kAlignedMenuMargin;

    final List<_MenuItem<T>> menuItems = <_MenuItem<T>>[
      for (int index = 0; index < widget.items!.length; index += 1)
        _MenuItem<T>(
          item: widget.items![index],
          onLayout: (Size size) {
            // If [_comboboxRoute] is null and onLayout is called, this means
            // that performLayout was called on a _ComboboxRoute that has not
            // left the widget tree but is already on its way out.
            //
            // Since onLayout is used primarily to collect the desired heights
            // of each menu item before laying them out, not having the _ComboboxRoute
            // collect each item's height to lay out is fine since the route is
            // already on its way out.
            if (_comboboxRoute == null) return;

            _comboboxRoute!.itemHeights[index] = size.height;
          },
        )
    ];

    final NavigatorState navigator = Navigator.of(context);
    assert(_comboboxRoute == null);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
            ancestor: navigator.context.findRenderObject()) &
        itemBox.size;
    _comboboxRoute = _ComboboxRoute<T>(
      acrylicEnabled: DisableAcrylic.of(context) != null,
      items: menuItems,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: _selectedIndex ?? 0,
      elevation: widget.elevation,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
      itemHeight: widget.itemHeight,
      comboboxColor: widget.comboboxColor,
    );

    navigator
        .push(_comboboxRoute!)
        .then<void>((_ComboboxRouteResult<T>? newValue) {
      _removeComboboxRoute();
      if (!mounted || newValue == null) return;
      if (widget.onChanged != null) widget.onChanged!(newValue.result);
    });

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  Color get _iconColor {
    // These colors are not defined in the Material Design spec.
    if (_enabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;

      switch (FluentTheme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey[190];
        case Brightness.dark:
          return Colors.white.withOpacity(0.7);
      }
    } else {
      if (widget.iconDisabledColor != null) return widget.iconDisabledColor!;

      switch (FluentTheme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey[150];
        case Brightness.dark:
          return Colors.white.withOpacity(0.10);
      }
    }
  }

  bool get _enabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  Orientation _getOrientation(BuildContext context) {
    Orientation? result = MediaQuery.maybeOf(context)?.orientation;
    if (result == null) {
      // If there's no MediaQuery, then use the window aspect to determine
      // orientation.
      final Size size = window.physicalSize;
      result = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }
    return result;
  }

  bool get _showHighlight {
    switch (_focusHighlightMode) {
      case FocusHighlightMode.touch:
        return false;
      case FocusHighlightMode.traditional:
        return _hasPrimaryFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeComboboxRoute();
      _lastOrientation = newOrientation;
    }

    // The width of the button and the menu are defined by the widest
    // item and the width of the placeholder.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when placeholder and selectedItemBuilder are provided.
    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? placeholderIndex;
    if (widget.placeholder != null ||
        (!_enabled && widget.disabledHint != null)) {
      Widget displayedHint = _enabled
          ? widget.placeholder!
          : widget.disabledHint ?? widget.placeholder!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _ComboboxItemContainer(child: displayedHint);
      }

      placeholderIndex = items.length;
      items.add(DefaultTextStyle(
        style:
            _textStyle!.copyWith(color: FluentTheme.of(context).disabledColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      ));
    }

    const EdgeInsetsGeometry padding = _kAlignedButtonPadding;

    // If value is null (then _selectedIndex is null) then we
    // display the placeholder or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = IndexedStack(
        index: _selectedIndex ?? placeholderIndex,
        alignment: AlignmentDirectional.centerStart,
        children: items.map((Widget item) {
          return widget.itemHeight != null
              ? SizedBox(height: widget.itemHeight, child: item)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[item],
                );
        }).toList(),
      );
    }

    const Icon defaultIcon = Icon(FluentIcons.chevron_down);

    Widget result = DefaultTextStyle(
      style: _enabled
          ? _textStyle!
          : _textStyle!.copyWith(color: FluentTheme.of(context).disabledColor),
      child: Container(
        padding: padding.resolve(Directionality.of(context)),
        height: kPickerHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.isExpanded)
              Expanded(child: innerItemsWidget)
            else
              innerItemsWidget,
            IconTheme.merge(
              data: IconThemeData(color: _iconColor, size: widget.iconSize),
              child: widget.icon ?? defaultIcon,
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: HoverButton(
          focusNode: focusNode,
          autofocus: widget.autofocus,
          onPressed: _enabled ? _handleTap : null,
          builder: (context, states) {
            return Container(
              decoration: kPickerDecorationBuilder(context, () {
                if (_showHighlight) {
                  return {ButtonStates.focused};
                } else if (states.isFocused) {
                  return <ButtonStates>{};
                }
                return states;
              }()),
              child: result,
            );
          },
        ),
      ),
    );
  }
}
