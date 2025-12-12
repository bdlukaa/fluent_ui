import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/src/controls/pickers/pickers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'editable_combo_box.dart';

const Duration _kComboBoxMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemBottomPadding = 6;

/// The default height of a combo box item.
const double kComboBoxItemHeight = kPickerHeight + _kMenuItemBottomPadding;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 12);
const EdgeInsetsGeometry _kAlignedButtonPadding = EdgeInsetsDirectional.only(
  start: 11,
  end: 15,
);
const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;
const EdgeInsetsDirectional _kListPadding = EdgeInsetsDirectional.only(
  top: _kMenuItemBottomPadding,
);

/// The default corner radius for combo box elements.
const kComboBoxRadius = Radius.circular(4);

/// A builder to customize combo box buttons.
///
/// Used by [ComboBox.selectedItemBuilder].
typedef ComboBoxBuilder = List<Widget> Function(BuildContext context);

class _ComboBoxMenuPainter extends CustomPainter {
  _ComboBoxMenuPainter({
    required this.resize,
    required this.getSelectedItemOffset,
    this.selectedIndex,
    Color borderColor = Colors.black,
    Color? backgroundColor,
    int elevation = 0,
  }) : _painter = BoxDecoration(
         // If you add an image here, you must provide a real
         // configuration in the paint() function and you must provide some sort
         // of onChanged callback here.
         // color: color,
         borderRadius: const BorderRadius.all(kComboBoxRadius),
         border: Border.all(color: borderColor),
         boxShadow: kElevationToShadow[elevation],
         color: backgroundColor,
       ).createBoxPainter(),
       super(repaint: resize);

  final int? selectedIndex;
  final Animation<double> resize;
  final ValueGetter<double> getSelectedItemOffset;
  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final selectedItemOffset = getSelectedItemOffset();
    final top = Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - kComboBoxItemHeight),
      end: 0,
    );

    final bottom = Tween<double>(
      begin: (top.begin! + kComboBoxItemHeight).clamp(
        kComboBoxItemHeight,
        size.height,
      ),
      end: size.height,
    );

    final rect = Rect.fromLTRB(
      0,
      top.evaluate(resize),
      size.width,
      bottom.evaluate(resize),
    );

    _painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_ComboBoxMenuPainter oldPainter) {
    return oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

// Do not use the platform-specific default scroll configuration.
// ComboBox menus should never overscroll or display an overscroll indicator.
class _ComboBoxScrollBehavior extends FluentScrollBehavior {
  const _ComboBoxScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

// The widget that is the button wrapping the menu items.
class _ComboBoxItemButton<T> extends StatefulWidget {
  const _ComboBoxItemButton({
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
    super.key,
    this.padding,
  });

  final _ComboBoxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;

  @override
  State<_ComboBoxItemButton<T>> createState() => _ComboBoxItemButtonState<T>();
}

class _ComboBoxItemButtonState<T> extends State<_ComboBoxItemButton<T>> {
  void _handleFocusChange(bool focused) {
    final bool inTraditionalMode;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        inTraditionalMode = false;
      case FocusHighlightMode.traditional:
        inTraditionalMode = true;
    }

    final scrollable = widget.route.scrollController!.hasClients;

    if (focused && inTraditionalMode && scrollable) {
      final menuLimits = widget.route.getMenuLimits(
        widget.buttonRect,
        widget.constraints.maxHeight,
        widget.itemIndex,
      );
      widget.route.scrollController!.animateTo(
        menuLimits.scrollOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  ComboBoxItem<T> get comboboxMenuItem => widget.route.items[widget.itemIndex];

  void _handleOnTap() {
    comboboxMenuItem.onTap?.call();

    Navigator.pop(context, _ComboBoxRouteResult<T>(comboboxMenuItem.value));
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
          padding: const EdgeInsetsDirectional.only(
            end: 6,
            start: 6,
            // bottom: 4.0,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ButtonThemeData.uncheckedInputColor(
                    theme,
                    states.isFocused ? {WidgetState.hovered} : states,
                    transparentWhenNone: true,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: widget.padding,
                child: widget.route.items[widget.itemIndex],
              ),
              if (states.isFocused)
                AnimatedPositionedDirectional(
                  duration: theme.fastAnimationDuration,
                  curve: theme.animationCurve,
                  top: states.isPressed ? 10.0 : 8.0,
                  bottom: states.isPressed ? 10.0 : 8.0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: theme.accentColor.defaultBrushFor(
                        theme.brightness,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      onPressed: comboboxMenuItem.enabled ? _handleOnTap : null,
      onFocusChange: _handleFocusChange,
    );
    if (kIsWeb) {
      // On the web, enter doesn't select things, *except* in a <select>
      // element, which is what a combo box emulates.
      child = Shortcuts(shortcuts: _webShortcuts, child: child);
    }

    if (kIsWeb) {
      child = Focus(
        onKeyEvent: (node, event) {
          if (!(event is KeyDownEvent || event is KeyRepeatEvent)) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // if nothing is selected, select the first
            FocusScope.of(context).nextFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // if nothing is selected, select the last
            FocusScope.of(context).previousFocus();
            return KeyEventResult.handled;
          } else {
            return KeyEventResult.ignored;
          }
        },
        canRequestFocus: false,
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: _kMenuItemBottomPadding,
      ),
      child: child,
    );
  }
}

class _ComboBoxMenu<T> extends StatefulWidget {
  const _ComboBoxMenu({
    required this.route,
    required this.buttonRect,
    required this.constraints,
    super.key,
    this.padding,
    this.popupColor,
  });

  final _ComboBoxRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? popupColor;

  @override
  State<_ComboBoxMenu<T>> createState() => _ComboBoxMenuState<T>();
}

class _ComboBoxMenuState<T> extends State<_ComboBoxMenu<T>> {
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
      curve: const Interval(0, 0.25),
      reverseCurve: const Interval(0.75, 1),
    );
    _resize = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    // The menu is shown in three stages (unit timing in brackets):
    // [0s - 0.25s] - Fade in a rect-sized menu container with the selected item.
    // [0.25s - 0.5s] - Grow the otherwise empty menu container from the center
    //   until it's big enough for as many items as we're going to show.
    // [0.5s - 1.0s] Fade in the remaining visible items from top to bottom.
    //
    // When the menu is dismissed we just fade the entire thing out
    // in the first 0.25s.
    final route = widget.route;

    final theme = FluentTheme.of(context);

    return AnimatedBuilder(
      animation: widget.route.animation!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeOpacity,
          child: CustomPaint(
            painter: _ComboBoxMenuPainter(
              selectedIndex: route.selectedIndex,
              resize: _resize,
              // This offset is passed as a callback, not a value, because it must
              // be retrieved at paint time (after layout), not at build time.
              getSelectedItemOffset: () =>
                  route.getItemOffset(route.selectedIndex ?? 0),
              // elevation: route.elevation.toDouble(),
              borderColor: theme.resources.surfaceStrokeColorFlyout,
              backgroundColor: widget.popupColor,
              elevation: route.elevation,
            ),
            child: ClipRRect(
              clipper: _ComboBoxResizeClipper(
                resizeAnimation: _resize,
                getSelectedItemOffset: () =>
                    route.getItemOffset(route.selectedIndex ?? 0),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Acrylic(
        tintAlpha: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(kComboBoxRadius),
        ),
        child: ColoredBox(
          color: theme.menuColor.withValues(alpha: kMenuColorOpacity),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: FluentLocalizations.of(context).dialogLabel,
            child: DefaultTextStyle.merge(
              style: route.style,
              child: ScrollConfiguration(
                behavior: const _ComboBoxScrollBehavior(),
                child: PrimaryScrollController(
                  controller: widget.route.scrollController!,
                  child: ListView.builder(
                    primary: true,
                    itemCount: route.items.length,
                    padding: _kListPadding,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final Widget container = _ComboBoxItemContainer(
                        child: _ComboBoxItemButton<T>(
                          route: widget.route,
                          padding: widget.padding,
                          buttonRect: widget.buttonRect,
                          constraints: widget.constraints,
                          itemIndex: index,
                        ),
                      );
                      return container;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboBoxResizeClipper extends CustomClipper<RRect> {
  final Animation<double> resizeAnimation;
  final ValueGetter<double> getSelectedItemOffset;

  const _ComboBoxResizeClipper({
    required this.resizeAnimation,
    required this.getSelectedItemOffset,
  });

  @override
  RRect getClip(Size size) {
    final selectedItemOffset = getSelectedItemOffset();
    final top = Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - kComboBoxItemHeight),
      end: 0,
    );

    final bottom = Tween<double>(
      begin: (top.begin! + kComboBoxItemHeight).clamp(
        kComboBoxItemHeight,
        size.height,
      ),
      end: size.height,
    );

    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -10,
        top.evaluate(resizeAnimation),
        size.width + 10,
        bottom.evaluate(resizeAnimation),
      ),
      kComboBoxRadius,
    );
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) => true;
}

class _ComboBoxMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _ComboBoxMenuRouteLayout({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
  });

  final Rect buttonRect;
  final _ComboBoxRoute<T> route;
  final TextDirection? textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The maximum height of a simple menu should be one or more rows less than
    // the view height. This ensures a tappable area outside of the simple menu
    // with which to dismiss the menu.
    //   -- https://material.io/design/components/menus.html#usage
    final double maxHeight = math.max(
      0,
      constraints.maxHeight - 2 * kComboBoxItemHeight,
    );
    // The width of a menu should be at most the view width. This ensures that
    // the menu does not extend past the left and right edges of the screen.
    final double width = math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final menuLimits = route.getMenuLimits(
      buttonRect,
      size.height,
      route.selectedIndex ?? 0,
    );

    assert(() {
      final container = Offset.zero & size;
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
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
    }

    return Offset(left, menuLimits.top);
  }

  @override
  bool shouldRelayout(_ComboBoxMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}

// We box the return value so that the return value can be null. Otherwise,
// canceling the route (which returns null) would get confused with actually
// returning a real null value.
@immutable
class _ComboBoxRouteResult<T> {
  const _ComboBoxRouteResult(this.result);

  final T? result;

  @override
  bool operator ==(Object other) {
    return other is _ComboBoxRouteResult<T> && other.result == result;
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

class _ComboBoxRoute<T> extends PopupRoute<_ComboBoxRouteResult<T>> {
  _ComboBoxRoute({
    required this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    required this.capturedThemes,
    required this.style,
    required this.acrylicEnabled,
    this.elevation = 16,
    this.barrierLabel,
    this.popupColor,
  }) : itemHeights = List<double>.filled(items.length, kComboBoxItemHeight);

  final List<ComboBoxItem<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int? selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final Color? popupColor;
  final bool acrylicEnabled;

  final List<double> itemHeights;
  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kComboBoxMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final page = _ComboBoxRoutePage<T>(
          route: this,
          constraints: constraints,
          padding: padding,
          buttonRect: buttonRect,
          selectedIndex: selectedIndex,
          elevation: elevation,
          capturedThemes: capturedThemes,
          style: style,
          popupColor: popupColor,
        );
        if (acrylicEnabled) return page;
        return DisableAcrylic(child: page);
      },
    );
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  double getItemOffset(int index) {
    var offset = _kListPadding.top;
    if (items.isNotEmpty && index > 0) {
      assert(items.length == itemHeights.length);
      offset += itemHeights
          .sublist(0, index)
          .reduce((total, height) => total + height);
    }
    return offset;
  }

  // Returns the vertical extent of the menu and the initial scrollOffset
  // for the ListView that contains the menu items. The vertical center of the
  // selected item is aligned with the button's vertical center, as far as
  // that's possible given availableHeight.
  _MenuLimits getMenuLimits(
    Rect buttonRect,
    double availableHeight,
    int index,
  ) {
    final computedMaxHeight = availableHeight - 2.0 * kComboBoxItemHeight;
    // if (menuMaxHeight != null) {
    //   computedMaxHeight = math.min(computedMaxHeight, menuMaxHeight!);
    // }
    final buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final selectedItemOffset = getItemOffset(index);

    // If the button is placed on the bottom or top of the screen, its top or
    // bottom may be less than [kComboBoxItemHeightWithPadding] from the edge of the screen.
    // In this case, we want to change the menu limits to align with the top
    // or bottom edge of the button.
    const topLimit = _kMenuItemBottomPadding;
    final double bottomLimit = math.max(
      availableHeight - kComboBoxItemHeight,
      buttonBottom,
    );

    var menuTop =
        (buttonTop - selectedItemOffset) -
        (itemHeights[selectedIndex ?? 0] - buttonRect.height) / 2.0;

    var preferredMenuHeight = _kListPadding.vertical;
    if (items.isNotEmpty) {
      preferredMenuHeight += itemHeights.reduce(
        (total, height) => total + height,
      );
    }
    // If there are too many elements in the menu, we need to shrink it down
    // so it is at most the computedMaxHeight.
    final double menuHeight = math.min(computedMaxHeight, preferredMenuHeight);
    var menuBottom = menuTop + menuHeight;

    // If the computed top or bottom of the menu are outside of the range
    // specified, we need to bring them into range. If the item height is larger
    // than the button height and the button is at the very bottom or top of the
    // screen, the menu will be aligned with the bottom or top of the button
    // respectively.
    if (menuTop < topLimit) {
      menuTop = math.min(buttonTop, topLimit);
      menuBottom = menuTop + menuHeight;
    }

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    if (menuBottom - itemHeights[selectedIndex ?? 0] / 2.0 <
        buttonBottom - buttonRect.height / 2.0) {
      menuBottom =
          buttonBottom -
          buttonRect.height / 2.0 +
          itemHeights[selectedIndex ?? 0] / 2.0;
      menuTop = menuBottom - menuHeight;
    }

    var scrollOffset = 0.0;
    // If all of the menu items will not fit within availableHeight then
    // compute the scroll offset that will line the selected menu item up
    // with the select item. This is only done when the menu is first
    // shown - subsequently we leave the scroll offset where the user left
    // it. This scroll offset is only accurate for fixed height menu items
    // (the default).
    if (preferredMenuHeight > computedMaxHeight) {
      // The offset should be zero if the selected item is in view at the beginning
      // of the menu. Otherwise, the scroll offset should center the item if possible.
      scrollOffset = math.max(0, selectedItemOffset - (buttonTop - menuTop));
      // If the selected item's scroll offset is greater than the maximum scroll offset,
      // set it instead to the maximum allowed scroll offset.
      scrollOffset = math.min(scrollOffset, preferredMenuHeight - menuHeight);
    }

    assert((menuBottom - menuTop - menuHeight).abs() < precisionErrorTolerance);
    return _MenuLimits(menuTop, menuBottom, menuHeight, scrollOffset);
  }
}

class _ComboBoxRoutePage<T> extends StatelessWidget {
  const _ComboBoxRoutePage({
    required this.route,
    required this.constraints,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    required this.capturedThemes,
    required this.popupColor,
    super.key,
    this.elevation = 8,
    this.style,
  });

  final _ComboBoxRoute<T> route;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int? selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? popupColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    // Computing the initialScrollOffset now, before the items have been laid
    // out. This only works if the item heights are effectively fixed, i.e. either
    // ComboBox.itemHeight is specified or ComboBox.itemHeight is null
    // and all of the items' intrinsic heights are less than kItemHeight.
    // Otherwise the initialScrollOffset is just a rough approximation based on
    // treating the items as if their heights were all equal to kComboBoxItemHeight.
    if (route.scrollController == null) {
      final menuLimits = route.getMenuLimits(
        buttonRect,
        constraints.maxHeight,
        selectedIndex ?? 0,
      );
      route.scrollController = ScrollController(
        initialScrollOffset: menuLimits.scrollOffset,
        keepScrollOffset: false,
      );
    }

    final textDirection = Directionality.maybeOf(context);
    final Widget menu = _ComboBoxMenu<T>(
      route: route,
      padding: padding.resolve(textDirection),
      buttonRect: buttonRect,
      constraints: constraints,
      popupColor: popupColor,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: CustomSingleChildLayout(
        delegate: _ComboBoxMenuRouteLayout<T>(
          buttonRect: buttonRect,
          route: route,
          textDirection: textDirection,
        ),
        child: capturedThemes.wrap(menu),
      ),
    );
  }
}

// The container widget for a menu item created by a [ComboBox]. It
// provides the default configuration for [ComboBoxItem]s, as well as a
// [ComboBox]'s placeholder and disabledPlaceholder widgets.
class _ComboBoxItemContainer extends StatelessWidget {
  /// Creates an item for a combo box menu.
  ///
  /// The [child] argument is required.
  const _ComboBoxItemContainer({required this.child, super.key});

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final hasPadding = _ContainerWithoutPadding.of(context) == null;
    final state = HoverButton.maybeOf(context)?.states ?? <WidgetState>{};

    final foregroundColor = state.isDisabled
        ? theme.resources.textFillColorDisabled
        : state.isPressed
        ? theme.resources.textFillColorTertiary
        : state.isHovered
        ? theme.resources.textFillColorSecondary
        : theme.resources.textFillColorPrimary;

    return Container(
      height: hasPadding
          ? kComboBoxItemHeight
          : kComboBoxItemHeight - _kMenuItemBottomPadding,
      alignment: AlignmentDirectional.centerStart,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foregroundColor),
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: child,
        ),
      ),
    );
  }
}

class _ContainerWithoutPadding extends InheritedWidget {
  const _ContainerWithoutPadding({required super.child});

  static _ContainerWithoutPadding? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ContainerWithoutPadding>();
  }

  @override
  bool updateShouldNotify(_ContainerWithoutPadding oldWidget) {
    return true;
  }
}

/// An item in a menu created by a [ComboBox].
///
/// The type `T` is the type of the value the entry represents. All the entries
/// in a given menu must represent values with consistent types.
class ComboBoxItem<T> extends _ComboBoxItemContainer {
  /// Creates an item for a combo box menu.
  ///
  /// The [child] argument is required.
  const ComboBoxItem({
    required super.child,
    super.key,
    this.onTap,
    this.value,
    this.enabled = true,
  });

  /// Called when the combo box menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [ComboBox.onChanged].
  final T? value;

  /// Whether this item is enabled.
  final bool enabled;
}

/// A combo box (also known as a drop-down list) lets the user select from a
/// list of items.
///
/// The combo box displays the currently selected item and shows an arrow that,
/// when clicked, opens a dropdown menu for selecting another item. This is useful
/// when you have a large set of options or when screen space is limited.
///
/// ![ComboBox Popup preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/combo-box-list-item-state.png)
///
/// {@tool snippet}
/// This example shows a basic combo box with a list of colors:
///
/// ```dart
/// String? selectedColor;
///
/// ComboBox<String>(
///   value: selectedColor,
///   items: ['Red', 'Green', 'Blue'].map((color) {
///     return ComboBoxItem<String>(
///       value: color,
///       child: Text(color),
///     );
///   }).toList(),
///   onChanged: (value) => setState(() => selectedColor = value),
///   placeholder: Text('Select a color'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a combo box with an enum:
///
/// ```dart
/// enum Priority { low, medium, high }
///
/// Priority? selectedPriority;
///
/// ComboBox<Priority>(
///   value: selectedPriority,
///   items: Priority.values.map((priority) {
///     return ComboBoxItem<Priority>(
///       value: priority,
///       child: Text(priority.name),
///     );
///   }).toList(),
///   onChanged: (value) => setState(() => selectedPriority = value),
/// )
/// ```
/// {@end-tool}
///
/// The type `T` is the type of the [value] that each combo box item represents.
/// All the entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [ComboBoxItem] in [items] must be
/// specialized with that same type argument.
///
/// The [onChanged] callback should update a state variable that defines the
/// combo box's value. It should also call [State.setState] to rebuild the
/// combo box with the new value.
///
/// If the [onChanged] callback is null or the list of [items] is null
/// then the combo box button will be disabled—its arrow will be displayed in
/// grey and it will not respond to input.
///
/// See also:
///
///  * [ComboBoxItem], the class used to represent the [items]
///  * [EditableComboBox], a combo box that allows text input
///  * [AutoSuggestBox], a text box with suggestion dropdown
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/combo-box>
class ComboBox<T> extends StatefulWidget {
  /// Creates a combo box button.
  ///
  /// The [items] must have distinct values. If [value] isn't null then it
  /// must be equal to one of the [ComboBoxItem] values. If [items] or
  /// [onChanged] is null, the button will be disabled, the down arrow
  /// will be greyed out.
  ///
  /// If [value] is null and the button is enabled, [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledPlaceholder] will be displayed
  /// if it is non-null. If [disabledPlaceholder] is null, then [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// The [elevation] and [iconSize] arguments must not be null (they both have
  /// defaults, so do not need to be specified). The [isExpanded] arguments must
  /// not be null.
  ///
  /// The [autofocus] argument must not be null.
  ///
  /// The [popupColor] argument specifies the background color of the
  /// combo box when it is open. If it is null, the default [Acrylic] color is used.
  const ComboBox({
    required this.items,
    super.key,
    this.selectedItemBuilder,
    this.value,
    this.placeholder,
    this.disabledPlaceholder,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon = const WindowsIcon(WindowsIcons.chevron_down),
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 8.0,
    this.isExpanded = false,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.popupColor,
    // When adding new arguments, consider adding similar arguments to
    // ComboBoxFormField.
  });

  /// The list of items the user can select.
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the combo box button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input.
  final List<ComboBoxItem<T>>? items;

  /// The value of the currently selected [ComboBoxItem].
  ///
  /// If [value] is null and the button is enabled, [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledPlaceholder] will be displayed
  /// if it is non-null. If [disabledPlaceholder] is null, then [placeholder] will be displayed
  /// if it is non-null.
  final T? value;

  /// A placeholder widget that is displayed by the combo box button.
  ///
  /// If [value] is null and the combo box is enabled ([items] and [onChanged] are non-null),
  /// this widget is displayed as a placeholder for the combo box button's value.
  ///
  /// If [value] is null and the combo box is disabled and [disabledPlaceholder] is null,
  /// this widget is used as the placeholder.
  final Widget? placeholder;

  /// A preferred placeholder widget that is displayed when the combo box is disabled.
  ///
  /// If [value] is null, the combo box is disabled ([items] or [onChanged] is null),
  /// this widget is displayed as a placeholder for the combo box button's value.
  final Widget? disabledPlaceholder;

  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [ComboBox.items]
  /// is null then the combo box button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input. A disabled button
  /// will display the [ComboBox.disabledPlaceholder] widget if it is non-null.
  /// If [ComboBox.disabledPlaceholder] is also null but [ComboBox.placeholder] is
  /// non-null, [ComboBox.placeholder] will instead be displayed.
  final ValueChanged<T?>? onChanged;

  /// Called when the combo box button is tapped.
  ///
  /// This is distinct from [onChanged], which is called when the user
  /// selects an item from the combo box.
  ///
  /// The callback will not be invoked if the combo box button is disabled.
  final VoidCallback? onTap;

  /// A builder to customize the combo box buttons corresponding to the
  /// [ComboBoxItem]s in [items].
  ///
  /// When a [ComboBoxItem] is selected, the widget that will be displayed
  /// from the list corresponds to the [ComboBoxItem] of the same index
  /// in [items].
  ///
  /// This sample shows a `ComboBox` with a button with [Text] that
  /// corresponds to but is unique from [ComboBoxItem].
  ///
  /// ```dart
  /// final List<String> items = <String>['1','2','3'];
  /// String selectedItem = '1';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Padding(
  ///     padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
  ///     child: ComboBox<String>(
  ///       value: selectedItem,
  ///       onChanged: (String? string) => setState(() => selectedItem = string!),
  ///       selectedItemBuilder: (BuildContext context) {
  ///         return items.map<Widget>((String item) {
  ///           return Text(item);
  ///         }).toList();
  ///       },
  ///       items: items.map((String item) {
  ///         return ComboBoxItem<String>(
  ///           child: Text('Log $item'),
  ///           value: item,
  ///         );
  ///       }).toList(),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// If this callback is null, the [ComboBoxItem] from [items]
  /// that matches [value] will be displayed.
  final ComboBoxBuilder? selectedItemBuilder;

  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12,
  /// 16, and 24. See [kElevationToShadow].
  ///
  /// Defaults to 8, the appropriate elevation for combo box buttons.
  final int elevation;

  /// The text style to use for text in the combo box button and the combo box
  /// menu that appears when you tap the button.
  ///
  /// To use a separate text style for selected item when it's displayed within
  /// the combo box button, consider using [selectedItemBuilder].
  ///
  /// This sample shows a `ComboBox` with a combo box button text style
  /// that is different than its menu items.
  ///
  /// ```dart
  /// List<String> options = <String>['One', 'Two', 'Free', 'Four'];
  /// String comboboxValue = 'One';
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Container(
  ///     alignment: AlignmentDirectional.center,
  ///     color: Colors.blue,
  ///     child: ComboBox<String>(
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
  ///       items: options.map<ComboBoxItem<String>>((String value) {
  ///         return ComboBoxItem<String>(
  ///           value: value,
  ///           child: Text(value),
  ///         );
  ///       }).toList(),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// Defaults to the [Typography.body] value of the closest [FluentThemeData]
  final TextStyle? style;

  /// The widget to use for the comobo box button's icon.
  ///
  /// Defaults to an [Icon] with the [FluentIcons.chevron_down] glyph.
  final Widget icon;

  /// The color of any [Icon] descendant of [icon] if this button is disabled,
  /// i.e. if [onChanged] is null.
  final Color? iconDisabledColor;

  /// The color of any [Icon] descendant of [icon] if this button is enabled,
  /// i.e. if [onChanged] is defined.
  final Color? iconEnabledColor;

  /// The size to use for the checkbox button's down arrow icon button.
  ///
  /// Defaults to 12.0
  final double iconSize;

  /// Set the combo box's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// The color for the button's [Material] when it has the input focus.
  final Color? focusColor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The background color of the combo box menu.
  ///
  /// If it is not provided, the default [Acrylic] color is used.
  final Color? popupColor;

  @override
  State<ComboBox<T>> createState() => ComboBoxState<T>();
}

class ComboBoxState<T> extends State<ComboBox<T>> {
  int? _selectedIndex;

  /// The index of the selected item.
  int? get selectedIndex => _selectedIndex;

  _ComboBoxRoute<T>? _comboboxRoute;
  FocusNode? _internalNode;

  /// The focus node for the combo box.
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;

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
        onInvoke: (intent) => openPopup(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (intent) => openPopup(),
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    closePopup();
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  /// Closes the combo box popup.
  ///
  /// If the combo box popup is not open, this method does nothing.
  void closePopup() {
    _comboboxRoute?._dismiss();
    _comboboxRoute = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });
    }
  }

  @override
  void didUpdateWidget(ComboBox<T> oldWidget) {
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

    // only update the selected value if it exists
    if (widget.items!.any((item) => item.value == widget.value)) {
      for (var itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
        if (widget.items![itemIndex].value == widget.value) {
          _selectedIndex = itemIndex;
          break;
        }
      }
    } else {
      _selectedIndex = null;
    }
  }

  TextStyle? _textStyle(BuildContext context) =>
      widget.style ?? FluentTheme.of(context).typography.body;

  /// Opens the combo box popup.
  ///
  /// If the combo box is not enabled, this method does nothing.
  ///
  /// If the combo box popup is already open, this method does nothing.
  void openPopup() {
    assert(isEnabled, 'The ComboBox must be enabled to open a popup');
    final textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = _kAlignedMenuMargin;

    final navigator = Navigator.of(context);
    assert(_comboboxRoute == null);
    final itemBox = context.findRenderObject()! as RenderBox;
    final itemRect =
        itemBox.localToGlobal(
          Offset.zero,
          ancestor: navigator.context.findRenderObject(),
        ) &
        itemBox.size;
    _comboboxRoute = _ComboBoxRoute<T>(
      acrylicEnabled: DisableAcrylic.of(context) == null,
      items: widget.items!,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: _selectedIndex,
      elevation: widget.elevation,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      style: _textStyle(context)!,
      barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
      popupColor: widget.popupColor,
    );

    navigator.push(_comboboxRoute!).then<void>((newValue) {
      closePopup();
      if (!mounted || newValue == null) return;
      _onChanged(newValue.result);
    });

    widget.onTap?.call();
  }

  void _onChanged(T? newValue) {
    widget.onChanged?.call(newValue);
  }

  Color _iconColor(BuildContext context) {
    final res = FluentTheme.of(context).resources;
    if (isEnabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;

      final state = HoverButton.of(context).states;

      if (state.isPressed) {
        return res.textFillColorTertiary;
      }

      return widget.iconEnabledColor ?? res.textFillColorSecondary;
    } else {
      return widget.iconDisabledColor ?? res.textFillColorDisabled;
    }
  }

  /// Whether the combo box is enabled.
  bool get isEnabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));
    assert(debugCheckHasDirectionality(context));

    final theme = FluentTheme.of(context);
    final textStyle = _textStyle(context)!;

    // The width of the button and the menu are defined by the widest
    // item and the width of the placeholder.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when placeholder and selectedItemBuilder are provided.
    final items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? placeholderIndex;
    if (widget.placeholder != null ||
        (!isEnabled && widget.disabledPlaceholder != null)) {
      var displayedHint = isEnabled
          ? widget.placeholder!
          : widget.disabledPlaceholder ?? widget.placeholder!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _ComboBoxItemContainer(child: displayedHint);
      }

      placeholderIndex = items.length;
      items.add(
        DefaultTextStyle.merge(
          style: textStyle.copyWith(
            color: theme.resources.textFillColorDisabled,
          ),
          child: IgnorePointer(child: displayedHint),
        ),
      );
    }

    const padding = _kAlignedButtonPadding;

    // If value is null (then _selectedIndex is null) then we
    // display the placeholder or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = _ContainerWithoutPadding(
        child: IndexedStack(
          sizing: StackFit.passthrough,
          index: _selectedIndex ?? placeholderIndex,
          alignment: AlignmentDirectional.centerStart,
          children: items.map((item) {
            return Column(mainAxisSize: MainAxisSize.min, children: [item]);
          }).toList(),
        ),
      );
    }

    final Widget result = Builder(
      builder: (context) {
        return DefaultTextStyle.merge(
          style: isEnabled
              ? textStyle
              : textStyle.copyWith(
                  color: theme.resources.textFillColorDisabled,
                ),
          child: Container(
            padding: padding.resolve(Directionality.of(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.isExpanded)
                  Expanded(child: innerItemsWidget)
                else
                  innerItemsWidget,
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: _iconColor(context),
                      size: widget.iconSize,
                    ),
                    child: widget.icon,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: Button(
          onPressed: isEnabled ? openPopup : null,
          autofocus: widget.autofocus,
          focusNode: focusNode,
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
          ),
          child: result,
        ),
      ),
    );
  }
}
