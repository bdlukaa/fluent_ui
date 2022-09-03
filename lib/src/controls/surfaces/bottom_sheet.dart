import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalBottomSheetCurve = Curves.decelerate;
const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

/// A callback for when the user begins dragging the bottom sheet.
///
/// Used by [_BottomSheet.onDragStart].
typedef _BottomSheetDragStartHandler = void Function(DragStartDetails details);

/// A callback for when the user stops dragging the bottom sheet.
///
/// Used by [_BottomSheet.onDragEnd].
typedef _BottomSheetDragEndHandler = void Function(
  DragEndDetails details, {
  required bool isClosing,
});

/// A fluent design bottom sheet.
///
/// A bottom sheet is an alternative to a menu or a dialog and
/// prevents the user from interacting with the rest of the app. Modal bottom
/// sheets can be created and displayed with the [showBottomSheet]
/// .
///
/// The [_BottomSheet] widget itself is rarely used directly. Instead, prefer to
/// create a bottom sheet with [showBottomSheet].
///
/// See also:
///
///  * [showBottomSheet], which can be used to display a modal bottom
///    sheet.
class _BottomSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  ///
  /// Typically, bottom sheets are created implicitly by [showBottomSheet],
  /// for modal bottom sheets.
  const _BottomSheet({
    Key? key,
    this.animationController,
    this.enableDrag = true,
    this.onDragStart,
    this.onDragEnd,
    this.backgroundColor,
    this.elevation,
    this.shape,
    required this.onClosing,
    required this.builder,
  })  : assert(elevation == null || elevation >= 0.0),
        super(key: key);

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController? animationController;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// A builder for the contents of the sheet.
  final WidgetBuilder builder;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  /// Called when the user begins dragging the bottom sheet vertically, if
  /// [enableDrag] is true.
  ///
  /// Would typically be used to change the bottom sheet animation curve so
  /// that it tracks the user's finger accurately.
  final _BottomSheetDragStartHandler? onDragStart;

  /// Called when the user stops dragging the bottom sheet, if [enableDrag]
  /// is true.
  ///
  /// Would typically be used to reset the bottom sheet animation curve, so
  /// that it animates non-linearly. Called before [onClosing] if the bottom
  /// sheet is closing.
  final _BottomSheetDragEndHandler? onDragEnd;

  /// The bottom sheet's background color.
  final Color? backgroundColor;

  /// This controls the size of the shadow.
  ///
  /// Defaults to 0. The value is non-negative.
  final double? elevation;

  /// The shape of the bottom sheet.
  final ShapeBorder? shape;

  @override
  _BottomSheetState createState() => _BottomSheetState();

  /// Creates an [AnimationController] suitable for a
  /// [_BottomSheet.animationController].
  ///
  /// This API available as a convenience for a Material compliant bottom sheet
  /// animation. If alternative animation durations are required, a different
  /// animation controller could be provided.
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _bottomSheetEnterDuration,
      reverseDuration: _bottomSheetExitDuration,
      debugLabel: '_BottomSheet',
      vsync: vsync,
    );
  }
}

class _BottomSheetState extends State<_BottomSheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: '_BottomSheet child');

  double get _childHeight {
    final RenderBox renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController!.status == AnimationStatus.reverse;

  void _handleDragStart(DragStartDetails details) {
    widget.onDragStart?.call(details);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    widget.animationController!.value -= details.primaryDelta! / _childHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    bool isClosing = false;
    if (details.velocity.pixelsPerSecond.dy > _minFlingVelocity) {
      final double flingVelocity =
          -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (widget.animationController!.value < _closeProgressThreshold) {
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: -1.0);
      }
      isClosing = true;
    } else {
      widget.animationController!.forward();
    }

    widget.onDragEnd?.call(
      details,
      isClosing: isClosing,
    );

    if (isClosing) {
      widget.onClosing();
    }
  }

  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent) {
      widget.onClosing();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final BottomSheetThemeData bottomSheetTheme = BottomSheetTheme.of(context);
    final Color? color =
        widget.backgroundColor ?? bottomSheetTheme.backgroundColor;
    final double elevation =
        widget.elevation ?? bottomSheetTheme.elevation ?? 0;
    final ShapeBorder? shape = widget.shape ?? bottomSheetTheme.shape;

    final Widget bottomSheet = PhysicalModel(
      color: Colors.black,
      elevation: elevation,
      borderRadius: shape is RoundedRectangleBorder
          ? shape.borderRadius is BorderRadius
              ? shape.borderRadius as BorderRadius
              : BorderRadius.zero
          : BorderRadius.zero,
      child: Container(
        key: _childKey,
        decoration: ShapeDecoration(
          shape: shape ?? const RoundedRectangleBorder(),
          color: color,
        ),
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: extentChanged,
          child: widget.builder(context),
        ),
      ),
    );
    return !widget.enableDrag
        ? bottomSheet
        : GestureDetector(
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            excludeFromSemantics: true,
            child: bottomSheet,
          );
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: isScrollControlled
          ? constraints.maxHeight
          : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key? key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.isScrollControlled = false,
    this.enableDrag = true,
  }) : super(key: key);

  final _ModalBottomSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool enableDrag;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;

  String _getRouteLabel(FluentLocalizations localizations) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = _BottomSheetSuspendedCurve(
      widget.route!.animation!.value,
      curve: _modalBottomSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasFluentLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final FluentLocalizations localizations = FluentLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      child: _BottomSheet(
        animationController: widget.route!._animationController,
        onClosing: () {
          if (widget.route!.isCurrent) {
            Navigator.pop(context);
          }
        },
        builder: widget.route!.builder!,
        backgroundColor: widget.backgroundColor,
        elevation: widget.elevation,
        shape: widget.shape,
        enableDrag: widget.enableDrag,
        onDragStart: handleDragStart,
        onDragEnd: handleDragEnd,
      ),
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = animationCurve.transform(
          mediaQuery.accessibleNavigation
              ? 1.0
              : widget.route!.animation!.value,
        );
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(
                animationValue,
                widget.isScrollControlled,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    required this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    RouteSettings? settings,
    this.transitionAnimationController,
  }) : super(settings: settings);

  final WidgetBuilder? builder;
  final CapturedThemes capturedThemes;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final AnimationController? transitionAnimationController;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black.withOpacity(0.54);

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = transitionAnimationController ??
        _BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Builder(
        builder: (BuildContext context) {
          final BottomSheetThemeData sheetTheme = BottomSheetTheme.of(context);
          return _ModalBottomSheet<T>(
            route: this,
            backgroundColor: backgroundColor ?? sheetTheme.backgroundColor,
            elevation: elevation ?? sheetTheme.elevation,
            shape: shape,
            isScrollControlled: isScrollControlled,
            enableDrag: enableDrag,
          );
        },
      ),
    );
    return capturedThemes.wrap(bottomSheet);
  }
}

/// A curve that progresses linearly until a specified [startingPoint], at which
/// point [curve] will begin. Unlike [Interval], [curve] will not start at zero,
/// but will use [startingPoint] as the Y position.
///
/// For example, if [startingPoint] is set to `0.5`, and [curve] is set to
/// [Curves.easeOut], then the bottom-left quarter of the curve will be a
/// straight line, and the top-right quarter will contain the entire contents of
/// [Curves.easeOut].
///
/// This is useful in situations where a widget must track the user's finger
/// (which requires a linear animation), and afterwards can be flung using a
/// curve specified with the [curve] argument, after the finger is released. In
/// such a case, the value of [startingPoint] would be the progress of the
/// animation at the time when the finger was released.
///
/// The [startingPoint] and [curve] arguments must not be null.
class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _BottomSheetSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  });

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}

/// Shows a bottom sheet.
///
/// A bottom sheet is an alternative to a menu or a dialog and prevents
/// the user from interacting with the rest of the app.
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the bottom sheet. It is only used when the method is called. Its
/// corresponding widget can be safely removed from the tree before the bottom
/// sheet is closed.
///
/// The `isScrollControlled` parameter specifies whether this is a route for
/// a bottom sheet that will utilize [DraggableScrollableSheet]. If you wish
/// to have a bottom sheet that has a scrollable child such as a [ListView] or
/// a [GridView] and have the bottom sheet be draggable, you should set this
/// parameter to true.
///
/// The `useRootNavigator` parameter ensures that the root navigator is used to
/// display the [BottomSheet] when set to `true`. This is useful in the case
/// that a modal [BottomSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
///
/// The [isDismissible] parameter specifies whether the bottom sheet will be
/// dismissed when user taps on the scrim.
///
/// The [enableDrag] parameter specifies whether the bottom sheet can be
/// dragged up and down and dismissed by swiping downwards.
///
/// The optional [backgroundColor], [elevation], [shape], [clipBehavior] and
/// [transitionAnimationController] parameters can be passed in to customize the
/// appearance and behavior of modal bottom sheets.
///
/// The [transitionAnimationController] controls the bottom sheet's entrance and
/// exit animations if provided.
///
/// The optional `routeSettings` parameter sets the [RouteSettings] of the modal bottom sheet
/// sheet. This is particularly useful in the case that a user wants to observe
/// [PopupRoute]s within a [NavigatorObserver].
///
/// Returns a `Future` that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal bottom sheet was closed.
///
/// {@tool dartpad --template=stateless_widget_scaffold}
///
/// This example demonstrates how to use `showBottomSheet` to display a
/// bottom sheet that obscures the content behind it when a user taps a button.
/// It also demonstrates how to close the bottom sheet using the [Navigator]
/// when a user taps on a button inside the bottom sheet.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Center(
///     child: ElevatedButton(
///       child: const Text('showBottomSheet'),
///       onPressed: () {
///         showBottomSheet<void>(
///           context: context,
///           builder: (BuildContext context) {
///             return Container(
///               height: 200,
///               color: Colors.amber,
///               child: Center(
///                 child: Column(
///                   mainAxisAlignment: MainAxisAlignment.center,
///                   mainAxisSize: MainAxisSize.min,
///                   children: <Widget>[
///                     const Text('Modal BottomSheet'),
///                     ElevatedButton(
///                       child: const Text('Close BottomSheet'),
///                       onPressed: () => Navigator.pop(context),
///                     )
///                   ],
///                 ),
///               ),
///             );
///           },
///         );
///       },
///     ),
///   );
/// }
/// ```
/// {@end-tool}
/// See also:
///
///  * [BottomSheet], a helper widget that implements the fluent ui bottom and top
///    sheet
///  * [DraggableScrollableSheet], which allows you to create a bottom sheet
///    that grows and then becomes scrollable once it reaches its maximum size.
Future<T?> showBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Color? barrierColor,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasFluentLocalizations(context));

  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_ModalBottomSheetRoute<T>(
    builder: builder,
    capturedThemes:
        InheritedTheme.capture(from: context, to: navigator.context),
    isScrollControlled: isScrollControlled,
    barrierLabel: FluentLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    settings: routeSettings,
    transitionAnimationController: transitionAnimationController,
  ));
}

class _BottomSheetScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(context, child, details) {
    return child;
  }
}

class BottomSheet extends StatelessWidget {
  /// Creates a bottom sheet.
  const BottomSheet({
    Key? key,
    this.header,
    this.showHandle = true,
    this.showDivider,
    this.description,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.85,
    this.children,
  })  : assert(
          header == null || description == null,
          'You can NOT provide both header and description',
        ),
        assert(minChildSize >= 0.0),
        assert(maxChildSize <= 1.0),
        assert(minChildSize <= initialChildSize),
        assert(initialChildSize <= maxChildSize),
        super(key: key);

  /// Whether the handle should be displayed by the bottom sheet.
  /// Defaults to true
  final bool showHandle;

  /// Whether the divider should be displayed to divide the [header]
  /// or [description] from [children].
  ///
  /// If null, the divider is automatically inserted if [header] or
  /// [description] are non-null.
  final bool? showDivider;

  /// The header of the bottom sheet. May be null.
  final Widget? header;

  /// The description of the bottom sheet. May be null.
  ///
  /// Typically a [Text]
  final Widget? description;

  /// The content of the bottom sheet
  final List<Widget>? children;

  /// The initial fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.5`.
  final double initialChildSize;

  /// The minimum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.25`.
  final double minChildSize;

  /// The maximum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `1.0`.
  final double maxChildSize;

  static Widget buildHandle(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = BottomSheetTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 4.0,
          decoration: BoxDecoration(
            color: theme.handleColor ?? Colors.grey[80],
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = BottomSheetTheme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, controller) {
        return IconTheme.merge(
          data: IconThemeData(color: theme.handleColor),
          child: ScrollConfiguration(
            behavior: _BottomSheetScrollBehavior(),
            child: ListView(controller: controller, children: [
              if (showHandle) buildHandle(context),
              if (header != null) header!,
              if (description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: DefaultTextStyle(
                    style: FluentTheme.of(context).typography.caption!,
                    textAlign: TextAlign.center,
                    child: description!,
                  ),
                ),
              if (showDivider != false &&
                  (header != null || description != null))
                const Divider(
                  style: DividerThemeData(
                    horizontalMargin: EdgeInsets.zero,
                  ),
                ),
              if (children != null) ...children!,
            ]),
          ),
        );
      },
    );
  }
}

/// An inherited widget that defines the configuration for
/// [BottomSheet]s in this widget's subtree.
///
/// Values specified here are used for [BottomSheet] properties that are not
/// given an explicit non-null value.
class BottomSheetTheme extends InheritedTheme {
  /// Creates a info bar theme that controls the configurations for
  /// [BottomSheet].
  const BottomSheetTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [BottomSheet] widgets.
  final BottomSheetThemeData data;

  /// Creates a button theme that controls how descendant [BottomSheet]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required BottomSheetThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return BottomSheetTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static BottomSheetThemeData _getInheritedThemeData(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<BottomSheetTheme>();
    return theme?.data ?? FluentTheme.of(context).bottomSheetTheme;
  }

  /// Returns the [data] from the closest [BottomSheetTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.bottomSheetTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// BottomSheetThemeData theme = BottomSheetTheme.of(context);
  /// ```
  static BottomSheetThemeData of(BuildContext context) {
    return BottomSheetThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return BottomSheetTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(BottomSheetTheme oldWidget) => data != oldWidget.data;
}

class BottomSheetThemeData with Diagnosticable {
  final Color? backgroundColor;
  final Color? handleColor;
  final ShapeBorder? shape;
  final double? elevation;

  const BottomSheetThemeData({
    this.handleColor,
    this.backgroundColor,
    this.shape,
    this.elevation,
  });

  factory BottomSheetThemeData.standard(ThemeData style) {
    final bool isLight = style.brightness.isLight;
    return BottomSheetThemeData(
      backgroundColor:
          isLight ? style.scaffoldBackgroundColor : const Color(0xFF212121),
      handleColor: isLight ? const Color(0xFF919191) : const Color(0xFF6e6e6e),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
    );
  }

  static BottomSheetThemeData lerp(
    BottomSheetThemeData? a,
    BottomSheetThemeData? b,
    double t,
  ) {
    return BottomSheetThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      handleColor: Color.lerp(a?.handleColor, b?.handleColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
  }

  BottomSheetThemeData merge(BottomSheetThemeData? style) {
    if (style == null) return this;
    return BottomSheetThemeData(
      backgroundColor: style.backgroundColor ?? backgroundColor,
      handleColor: style.handleColor ?? handleColor,
      shape: style.shape ?? shape,
      elevation: style.elevation ?? elevation,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('handleColor', handleColor));
    properties.add(DiagnosticsProperty('shape', shape));
    properties.add(DoubleProperty('elevation', elevation));
  }
}
