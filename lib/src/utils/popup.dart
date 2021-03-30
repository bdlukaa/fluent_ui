import 'dart:ui';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

class PopUp<T> extends StatefulWidget {
  const PopUp({
    Key? key,
    required this.child,
    required this.content,
    required this.contentHeight,
    this.backgroundColor,
  }) : super(key: key);

  final Widget child;
  final WidgetBuilder content;
  final double contentHeight;

  final Color? backgroundColor;

  @override
  PopUpState<T> createState() => PopUpState<T>();
}

class PopUpState<T> extends State<PopUp> {
  _PopUpRoute<T>? _dropdownRoute;

  Future<void> openPopup() {
    final NavigatorState navigator = Navigator.of(context);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
            ancestor: navigator.context.findRenderObject()) &
        itemBox.size;
    assert(_dropdownRoute == null, 'You can NOT open it twice');
    _dropdownRoute = _PopUpRoute<T>(
      contentHeight: widget.contentHeight,
      content: widget.content(context),
      buttonRect: EdgeInsets.zero
          .resolve(Directionality.of(context))
          .inflateRect(itemRect),
      elevation: 4,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      dropdownColor: widget.backgroundColor ??
          context.theme.navigationPanelBackgroundColor,
      transitionAnimationDuration:
          context.theme.mediumAnimationDuration ?? Duration.zero,
    );

    return navigator.push(_dropdownRoute!).then((T? newValue) {
      removePopUpRoute();
      if (!mounted || newValue == null) return;
    });
  }

  bool get isOpen => _dropdownRoute != null;

  void removePopUpRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
    // _lastOrientation = null;
  }

  @override
  void dispose() {
    removePopUpRoute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Backend below

class _PopUpScrollBehavior extends ScrollBehavior {
  const _PopUpScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => defaultTargetPlatform;

  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _PopUpMenu<T> extends StatefulWidget {
  const _PopUpMenu({
    Key? key,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    this.dropdownColor,
  }) : super(key: key);

  final _PopUpRoute<T> route;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? dropdownColor;

  @override
  _PopUpMenuState<T> createState() => _PopUpMenuState<T>();
}

class _PopUpMenuState<T> extends State<_PopUpMenu<T>> {
  late CurvedAnimation _fadeOpacity;

  @override
  void initState() {
    super.initState();
    _fadeOpacity = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.0, 0.50),
      reverseCurve: const Interval(0.75, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOpacity,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        child: Acrylic(
          opacity: 0.1,
          decoration: BoxDecoration(
            color: widget.dropdownColor ??
                context.theme.navigationPanelBackgroundColor,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: context.theme.scaffoldBackgroundColor!,
              width: 0.8,
            ),
          ),
          child: m.Material(
            type: m.MaterialType.transparency,
            child: ScrollConfiguration(
              behavior: const _PopUpScrollBehavior(),
              child: widget.route.content,
            ),
          ),
        ),
      ),
    );
  }
}

class _PopUpMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _PopUpMenuRouteLayout({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
  });

  final Rect buttonRect;
  final _PopUpRoute<T> route;
  final TextDirection? textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxHeight = constraints.maxHeight;
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
    final menuLimits = route.getMenuLimits(buttonRect, size.height);
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

    return Offset(
      left,
      menuLimits.top - (childSize.height / 2) + kOneLineTileHeight * 1.25,
    );
  }

  @override
  bool shouldRelayout(_PopUpMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}

class _MenuLimits {
  const _MenuLimits(this.top, this.bottom, this.height);
  final double top;
  final double bottom;
  final double height;

  @override
  String toString() {
    return '$top $bottom $height';
  }
}

class _PopUpRoute<T> extends PopupRoute<T> {
  _PopUpRoute({
    required this.content,
    required this.contentHeight,
    required this.buttonRect,
    this.elevation = 8,
    required this.capturedThemes,
    required this.transitionAnimationDuration,
    this.barrierLabel,
    this.dropdownColor,
  });

  final Widget content;
  final double contentHeight;
  final Rect buttonRect;
  final int elevation;
  final CapturedThemes capturedThemes;
  final Color? dropdownColor;

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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return _PopUpRoutePage<T>(
        route: this,
        constraints: constraints,
        content: content,
        buttonRect: buttonRect,
        elevation: elevation,
        capturedThemes: capturedThemes,
        dropdownColor: dropdownColor,
      );
    });
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  _MenuLimits getMenuLimits(Rect buttonRect, double availableHeight) {
    final double maxMenuHeight = availableHeight - contentHeight;
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);

    final double topLimit = math.min(kOneLineTileHeight, buttonTop);
    final double bottomLimit = math.max(availableHeight, buttonBottom);

    double menuTop = (buttonTop) - (buttonRect.height) / 2.0;

    double preferredMenuHeight = EdgeInsets.symmetric(vertical: 8.0).vertical;
    preferredMenuHeight += contentHeight - availableHeight;

    final double menuHeight = math.min(preferredMenuHeight, maxMenuHeight);
    double menuBottom = menuTop + menuHeight;

    if (menuTop < topLimit) menuTop = math.min(buttonTop, topLimit);

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    return _MenuLimits(menuTop, menuBottom, menuHeight);
  }
}

class _PopUpRoutePage<T> extends StatelessWidget {
  const _PopUpRoutePage({
    Key? key,
    required this.route,
    required this.constraints,
    required this.content,
    required this.buttonRect,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    required this.dropdownColor,
  }) : super(key: key);

  final _PopUpRoute<T> route;
  final BoxConstraints constraints;
  final Widget content;
  final Rect buttonRect;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _PopUpMenu<T>(
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
            delegate: _PopUpMenuRouteLayout<T>(
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
