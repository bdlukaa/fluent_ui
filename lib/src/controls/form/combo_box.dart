import 'dart:ui';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

import 'pickers/pickers.dart';

const double _kMenuItemHeight = kOneLineTileHeight;
const EdgeInsets _kListPadding = EdgeInsets.symmetric(vertical: 4.0);

typedef ComboBoxBuilder = List<Widget> Function(BuildContext context);

class _ComboboxMenuPainter extends CustomPainter {
  _ComboboxMenuPainter({
    this.color,
    this.elevation,
    this.selectedIndex,
    required this.resize,
    required this.getSelectedItemOffset,
  })   : _painter = BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2.0),
          boxShadow: kElevationToShadow[elevation],
        ).createBoxPainter(),
        super(repaint: resize);

  final Color? color;
  final int? elevation;
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
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

class _ComboboxScrollBehavior extends ScrollBehavior {
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

class _ComboboxMenuItemButton<T> extends StatefulWidget {
  const _ComboboxMenuItemButton({
    Key? key,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;

  @override
  _ComboboxMenuItemButtonState<T> createState() =>
      _ComboboxMenuItemButtonState<T>();
}

class _ComboboxMenuItemButtonState<T>
    extends State<_ComboboxMenuItemButton<T>> {
  void _handleOnTap() {
    final ComboboxMenuItem<T> dropdownMenuItem =
        widget.route.items[widget.itemIndex].item!;

    if (dropdownMenuItem.onTap != null) {
      dropdownMenuItem.onTap!();
    }

    Navigator.pop(
      context,
      _ComboboxRouteResult<T>(dropdownMenuItem.value),
    );
  }

  static final Map<LogicalKeySet, Intent> _webShortcuts =
      <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final CurvedAnimation opacity;
    final double unit = 0.5 / (widget.route.items.length + 1.5);
    if (widget.itemIndex == widget.route.selectedIndex) {
      opacity = CurvedAnimation(
        parent: widget.route.animation!,
        curve: const Threshold(0.0),
      );
    } else {
      final double start =
          (0.5 + (widget.itemIndex + 1) * unit).clamp(0.0, 1.0);
      final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
      opacity = CurvedAnimation(
        parent: widget.route.animation!,
        curve: Interval(start, end),
      );
    }
    final selected = widget.itemIndex == widget.route.selectedIndex;
    Widget child = FadeTransition(
      opacity: opacity,
      child: TappableListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        onTap: _handleOnTap,
        title: DefaultTextStyle(
          maxLines: 1,
          style: (selected
                  ? context.theme.typography.base
                  : context.theme.typography.body) ??
              TextStyle(),
          child: widget.route.items[widget.itemIndex],
        ),
        tileColor: (state) {
          if (selected) {
            return HSVColor.fromColor(context.theme.accentColor)
                .withSaturation(0.6)
                .withValue(0.8)
                .toColor();
          }
          return uncheckedInputColor(context.theme, state);
        },
      ),
    );
    if (kIsWeb) {
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
    required this.route,
    required this.buttonRect,
    required this.constraints,
    this.dropdownColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? dropdownColor;

  @override
  _ComboboxMenuState<T> createState() => _ComboboxMenuState<T>();
}

class _ComboboxMenuState<T> extends State<_ComboboxMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  late CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
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
    final _ComboboxRoute<T> route = widget.route;
    final List<Widget> children = <Widget>[
      for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex)
        _ComboboxMenuItemButton<T>(
          route: widget.route,
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          itemIndex: itemIndex,
        ),
    ];

    return FadeTransition(
      opacity: _fadeOpacity,
      child: CustomPaint(
        painter: _ComboboxMenuPainter(
          color: widget.dropdownColor ??
              context.theme.navigationPanelBackgroundColor,
          elevation: route.elevation,
          selectedIndex: route.selectedIndex,
          resize: _resize,
          getSelectedItemOffset: () =>
              route.getItemOffset(route.selectedIndex ?? 0),
        ),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          child: m.Material(
            type: m.MaterialType.transparency,
            textStyle: route.style,
            child: ScrollConfiguration(
              behavior: const _ComboboxScrollBehavior(),
              child: PrimaryScrollController(
                controller: widget.route.scrollController!,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double menuTotalHeight = widget.route.itemHeights
                        .reduce(
                            (double total, double height) => total + height);
                    final bool isScrollable =
                        _kListPadding.vertical + menuTotalHeight >
                            constraints.maxHeight;
                    return Scrollbar(
                      isAlwaysShown: isScrollable,
                      child: ListView(
                        padding: _kListPadding,
                        shrinkWrap: true,
                        children: children,
                      ),
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
    final double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);

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
    final _MenuLimits menuLimits = route.getMenuLimits(
      buttonRect,
      size.height,
      route.selectedIndex ?? 0,
    );

    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
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
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 8,
    required this.capturedThemes,
    required this.style,
    required this.transitionAnimationDuration,
    this.barrierLabel,
    this.itemHeight,
    this.dropdownColor,
  }) : itemHeights = List<double>.filled(
          items.length,
          itemHeight ?? kOneLineTileHeight,
        );

  final List<_MenuItem<T>> items;
  final Rect buttonRect;
  final int? selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final double? itemHeight;
  final Color? dropdownColor;

  final List<double> itemHeights;
  ScrollController? scrollController;

  final Duration transitionAnimationDuration;

  @override
  Duration get transitionDuration => transitionAnimationDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return LayoutBuilder(builder: (context, constraints) {
      return _ComboboxRoutePage<T>(
        route: this,
        constraints: constraints,
        items: items,
        buttonRect: buttonRect,
        selectedIndex: selectedIndex,
        elevation: elevation,
        capturedThemes: capturedThemes,
        style: style,
        dropdownColor: dropdownColor,
      );
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

  _MenuLimits getMenuLimits(
      Rect buttonRect, double availableHeight, int index) {
    final double maxMenuHeight = availableHeight - 2.0 * _kMenuItemHeight;
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final double selectedItemOffset = getItemOffset(index);

    final double topLimit = math.min(_kMenuItemHeight, buttonTop);
    final double bottomLimit =
        math.max(availableHeight - _kMenuItemHeight, buttonBottom);

    double menuTop = (buttonTop - selectedItemOffset) -
        (itemHeights[selectedIndex ?? 0] - buttonRect.height) / 2.0;
    double preferredMenuHeight = _kListPadding.vertical;
    if (items.isNotEmpty)
      preferredMenuHeight +=
          itemHeights.reduce((double total, double height) => total + height);

    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);
    double menuBottom = menuTop + menuHeight;

    if (menuTop < topLimit) menuTop = math.min(buttonTop, topLimit);

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    double scrollOffset = 0;

    if (preferredMenuHeight > maxMenuHeight) {
      scrollOffset = math.max(0.0, selectedItemOffset - (buttonTop - menuTop));

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
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    required this.dropdownColor,
  }) : super(key: key);

  final _ComboboxRoute<T> route;
  final BoxConstraints constraints;
  final List<_MenuItem<T>>? items;
  final Rect buttonRect;
  final int? selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    if (route.scrollController == null) {
      final _MenuLimits menuLimits = route.getMenuLimits(
        buttonRect,
        constraints.maxHeight,
        selectedIndex ?? 0,
      );
      route.scrollController =
          ScrollController(initialScrollOffset: menuLimits.scrollOffset);
    }

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _ComboboxMenu<T>(
      route: route,
      buttonRect: buttonRect,
      constraints: constraints,
      dropdownColor: dropdownColor,
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

class _MenuItem<T> extends SingleChildRenderObjectWidget {
  const _MenuItem({
    Key? key,
    required this.onLayout,
    required this.item,
  }) : super(key: key, child: item);

  final ValueChanged<Size> onLayout;
  final ComboboxMenuItem<T>? item;

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

class _ComboboxMenuItemContainer extends StatelessWidget {
  const _ComboboxMenuItemContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }
}

class ComboboxMenuItem<T> extends _ComboboxMenuItemContainer {
  const ComboboxMenuItem({
    Key? key,
    this.onTap,
    this.value,
    required Widget child,
  }) : super(key: key, child: child);

  final VoidCallback? onTap;

  final T? value;
}

class ComboBox<T> extends StatefulWidget {
  ComboBox({
    Key? key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 4,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 20.0,
    this.isExpanded = false,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.placeholder,
    this.header,
    this.headerStyle,
    this.cursor = SystemMouseCursors.click,
  })  : assert(
          items == null ||
              items.isEmpty ||
              value == null ||
              items.where((ComboboxMenuItem<T> item) {
                    return item.value == value;
                  }).length ==
                  1,
          "There should be exactly one item with [ComboBox]'s value: "
          '$value. \n'
          'Either zero or 2 or more [ComboboxMenuItem]s were detected '
          'with the same value',
        ),
        super(key: key);

  final List<ComboboxMenuItem<T>>? items;

  final T? value;

  final Widget? hint;

  final Widget? disabledHint;

  final ValueChanged<T?>? onChanged;

  final VoidCallback? onTap;

  final ComboBoxBuilder? selectedItemBuilder;

  final int elevation;

  final TextStyle? style;

  final Widget? icon;

  final Color? iconDisabledColor;

  final Color? iconEnabledColor;

  final double iconSize;

  final bool isExpanded;

  final FocusNode? focusNode;

  final bool autofocus;

  final Color? dropdownColor;

  final String? placeholder;
  final String? header;
  final TextStyle? headerStyle;

  final MouseCursor cursor;

  @override
  _ComboBoxState<T> createState() => _ComboBoxState<T>();
}

class _ComboBoxState<T> extends State<ComboBox<T>> with WidgetsBindingObserver {
  int? _selectedIndex;
  _ComboboxRoute<T>? _dropdownRoute;
  Orientation? _lastOrientation;
  late Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _removeComboboxRoute();
    super.dispose();
  }

  void _removeComboboxRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
    _lastOrientation = null;
  }

  @override
  void didUpdateWidget(ComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (widget.value == null || widget.items == null || widget.items!.isEmpty) {
      _selectedIndex = null;
      return;
    }

    assert(widget.items!
            .where((ComboboxMenuItem<T> item) => item.value == widget.value)
            .length ==
        1);
    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle? get _textStyle => widget.style ?? context.theme.typography.body;

  void _handleTap() {
    final TextDirection? textDirection = Directionality.maybeOf(context);

    final List<_MenuItem<T>> menuItems = <_MenuItem<T>>[
      for (int index = 0; index < widget.items!.length; index += 1)
        _MenuItem<T>(
          item: widget.items![index],
          onLayout: (Size size) {
            if (_dropdownRoute == null) return;

            _dropdownRoute!.itemHeights[index] = size.height;
          },
        )
    ];

    final NavigatorState navigator = Navigator.of(context);
    assert(_dropdownRoute == null);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
            ancestor: navigator.context.findRenderObject()) &
        itemBox.size;
    _dropdownRoute = _ComboboxRoute<T>(
      items: menuItems,
      buttonRect: EdgeInsets.zero.resolve(textDirection).inflateRect(itemRect),
      selectedIndex: _selectedIndex ?? 0,
      elevation: widget.elevation,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      dropdownColor: widget.dropdownColor,
      transitionAnimationDuration: context.theme.mediumAnimationDuration,
    );

    navigator
        .push(_dropdownRoute!)
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
    if (_enabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;

      switch (context.theme.brightness) {
        case Brightness.light:
          return Colors.grey[180]!;
        case Brightness.dark:
          return Colors.white;
      }
    } else {
      if (widget.iconDisabledColor != null) return widget.iconDisabledColor!;

      switch (context.theme.brightness) {
        case Brightness.light:
          return Colors.grey[120]!;
        case Brightness.dark:
          return Colors.white;
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
      final Size size = window.physicalSize;
      result = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeComboboxRoute();
      _lastOrientation = newOrientation;
    }

    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? hintIndex;
    if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      Widget displayedHint =
          _enabled ? widget.hint! : widget.disabledHint ?? widget.hint!;
      if (widget.selectedItemBuilder == null)
        displayedHint = _ComboboxMenuItemContainer(child: displayedHint);

      hintIndex = items.length;
      items.add(DefaultTextStyle(
        maxLines: 1,
        style: _textStyle!.copyWith(color: context.theme.disabledColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      ));
    }

    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = IndexedStack(
        index: _selectedIndex ?? hintIndex,
        alignment: AlignmentDirectional.centerStart,
        children: items.map((Widget item) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[item],
          );
        }).toList(),
      );
    }

    const Icon defaultIcon = Icon(Icons.keyboard_arrow_down);

    Widget result = DefaultTextStyle(
      maxLines: 1,
      style: _enabled
          ? _textStyle!
          : _textStyle!.copyWith(color: context.theme.disabledColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.isExpanded)
            Expanded(child: innerItemsWidget)
          else
            innerItemsWidget,
          FluentTheme(
            data: context.theme.copyWith(
              iconTheme: context.theme.iconTheme.copyWith(
                IconThemeData(
                  color: _iconColor,
                  size: widget.iconSize,
                ),
              ),
            ),
            child: widget.icon ?? defaultIcon,
          ),
        ],
      ),
    );

    final child = Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: HoverButton(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          cursor: (_) => widget.cursor,
          onPressed: _enabled ? _handleTap : null,
          builder: (context, state) => Container(
            padding: kTextBoxPadding,
            decoration: kPickerDecorationBuilder(context, state),
            child: result,
          ),
        ),
      ),
    );
    if (widget.header != null)
      return InfoHeader(
        child: child,
        header: widget.header!,
        headerStyle: widget.headerStyle,
      );
    return child;
  }
}
