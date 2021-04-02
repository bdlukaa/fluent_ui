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
    this.contentWidth,
  }) : super(key: key);

  final Widget child;
  final WidgetBuilder content;
  final double contentHeight;
  final double? contentWidth;

  final Color? backgroundColor;

  @override
  PopUpState<T> createState() => PopUpState<T>();
}

class PopUpState<T> extends State<PopUp> {
  _PopUpRoute<T>? _dropdownRoute;

  Future<void> openPopup() {
    final NavigatorState navigator = Navigator.of(context);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Offset target = itemBox.localToGlobal(
      itemBox.size.center(Offset.zero),
      ancestor: navigator.context.findRenderObject(),
    );
    final Rect itemRect = target & itemBox.size;
    assert(_dropdownRoute == null, 'You can NOT open it twice');
    _dropdownRoute = _PopUpRoute<T>(
      width: widget.contentWidth,
      target: target,
      contentHeight: widget.contentHeight,
      content: widget.content(context),
      buttonRect: itemRect,
      elevation: 4,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
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
        child: m.Material(
          type: m.MaterialType.transparency,
          child: ScrollConfiguration(
            behavior: const _PopUpScrollBehavior(),
            child: widget.route.content,
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
    required this.target,
    required this.verticalOffset,
    this.width,
  });

  final Rect buttonRect;
  final _PopUpRoute<T> route;
  final TextDirection? textDirection;
  final Offset target;
  final double verticalOffset;
  final double? width;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxHeight = constraints.maxHeight;
    final double width =
        this.width ?? math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      preferBelow: false,
      verticalOffset: 24,
    );
  }

  @override
  bool shouldRelayout(_PopUpMenuRouteLayout<T> oldDelegate) {
    return target != oldDelegate.target || buttonRect != oldDelegate.buttonRect;
  }
}

class _PopUpRoute<T> extends PopupRoute<T> {
  _PopUpRoute({
    required this.content,
    required this.contentHeight,
    required this.buttonRect,
    required this.target,
    this.elevation = 8,
    required this.capturedThemes,
    required this.transitionAnimationDuration,
    this.barrierLabel,
    this.width,
  });

  final Widget content;
  final double contentHeight;
  final Rect buttonRect;
  final int elevation;
  final CapturedThemes capturedThemes;
  final Offset target;
  final double? width;

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
  Widget buildPage(context, animation, secondaryAnimation) {
    return LayoutBuilder(builder: (context, constraints) {
      return _PopUpRoutePage<T>(
        target: target,
        route: this,
        constraints: constraints,
        content: content,
        buttonRect: buttonRect,
        elevation: elevation,
        width: width,
        capturedThemes: capturedThemes,
      );
    });
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }
}

class _PopUpRoutePage<T> extends StatelessWidget {
  const _PopUpRoutePage({
    Key? key,
    required this.route,
    required this.constraints,
    required this.content,
    required this.buttonRect,
    required this.target,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    this.width,
  }) : super(key: key);

  final _PopUpRoute<T> route;
  final BoxConstraints constraints;
  final Widget content;
  final Rect buttonRect;
  final Offset target;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final double? width;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _PopUpMenu<T>(
      route: route,
      buttonRect: buttonRect,
      constraints: constraints,
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
              target: target,
              buttonRect: buttonRect,
              route: route,
              textDirection: textDirection,
              verticalOffset: 0.0,
              width: width,
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }
}
