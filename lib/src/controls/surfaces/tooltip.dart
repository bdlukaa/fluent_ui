import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:fluent_ui/fluent_ui.dart';

/// A tooltip is a short description that is linked to another
/// control or object. Tooltips help users understand unfamiliar
/// objects that aren't described directly in the UI. They display
/// automatically when the user moves focus to, presses and holds,
/// or hovers the mouse pointer over a control. The tooltip disappears
/// after a few seconds, or when the user moves the finger, pointer
/// or keyboard/gamepad focus.
///
/// ![Tooltip Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/controls/tool-tip.png)
class Tooltip extends StatefulWidget {
  /// Creates a tooltip.
  ///
  /// Wrap any widget in a [Tooltip] to show a message on mouse hover
  const Tooltip({
    Key? key,
    required this.message,
    this.child,
    this.style,
    this.excludeFromSemantics = false,
    this.useMousePosition = true,
  }) : super(key: key);

  /// The text to display in the tooltip.
  final String message;

  /// The widget the tooltip will be displayed, either above or below,
  /// when the mouse is hovering or whenever it gets long pressed.
  final Widget? child;

  /// The style of the tooltip. If non-null, it's mescled with
  /// [ThemeData.tooltipThemeData]
  final TooltipThemeData? style;

  /// Whether the tooltip's [message] should be excluded from the
  /// semantics tree.
  ///
  /// Defaults to false. A tooltip will add a [Semantics] label that
  /// is set to [Tooltip.message]. Set this property to true if the
  /// app is going to provide its own custom semantics label.
  final bool excludeFromSemantics;

  /// Whether the current mouse position should be used to render the
  /// tooltip on the screen. If no mouse is connected, this value is
  /// ignored.
  ///
  /// Defaults to true. A tooltip will show the tooltip on the current
  /// mouse position and the tooltip will be removed as soon as the
  /// pointer exit the [child].
  final bool useMousePosition;

  @override
  _TooltipState createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> with SingleTickerProviderStateMixin {
  static const double _defaultVerticalOffset = 24.0;
  static const bool _defaultPreferBelow = false;
  static const EdgeInsetsGeometry _defaultMargin = EdgeInsets.all(0.0);
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);
  static const Duration _defaultShowDuration = Duration(milliseconds: 1500);
  static const Duration _defaultWaitDuration = Duration.zero;

  late double height;
  late EdgeInsetsGeometry padding;
  late EdgeInsetsGeometry margin;
  late Decoration decoration;
  late TextStyle textStyle;
  late double verticalOffset;
  late bool preferBelow;
  late bool excludeFromSemantics;
  late AnimationController _controller;
  OverlayEntry? _entry;
  Timer? _hideTimer;
  Timer? _showTimer;
  late Duration showDuration;
  late Duration waitDuration;
  late bool _mouseIsConnected;
  bool _longPressActivated = false;
  Offset? mousePosition;

  @override
  void initState() {
    super.initState();
    _mouseIsConnected = RendererBinding.instance!.mouseTracker.mouseIsConnected;
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
    // Listen to see when a mouse is added.
    RendererBinding.instance!.mouseTracker
        .addListener(_handleMouseTrackerChange);
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance!.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  // https://material.io/components/tooltips#specs
  double _getDefaultTooltipHeight() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 24.0;
      default:
        return 32.0;
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const EdgeInsets.symmetric(horizontal: 8.0);
      default:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  double _getDefaultFontSize() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 10.0;
      default:
        return 14.0;
    }
  }

  // Forces a rebuild if a mouse has been added or removed.
  void _handleMouseTrackerChange() {
    if (!mounted) {
      return;
    }
    final bool mouseIsConnected =
        RendererBinding.instance!.mouseTracker.mouseIsConnected;
    if (mouseIsConnected != _mouseIsConnected) {
      setState(() {
        _mouseIsConnected = mouseIsConnected;
      });
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _hideTooltip(immediately: true);
    }
  }

  void _hideTooltip({bool immediately = false}) {
    _showTimer?.cancel();
    _showTimer = null;
    if (immediately) {
      _removeEntry();
      return;
    }
    if (_longPressActivated) {
      // Tool tips activated by long press should stay around for the showDuration.
      _hideTimer ??= Timer(showDuration, _controller.reverse);
    } else {
      // Tool tips activated by hover should disappear as soon as the mouse
      // leaves the control.
      _controller.reverse();
    }
    _longPressActivated = false;
  }

  void _showTooltip({bool immediately = false}) {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (immediately) {
      ensureTooltipVisible();
      return;
    }
    _showTimer ??= Timer(waitDuration, ensureTooltipVisible);
  }

  /// Shows the tooltip if it is not already visible.
  ///
  /// Returns `false` when the tooltip was already visible or if the context has
  /// become null.
  bool ensureTooltipVisible() {
    _showTimer?.cancel();
    _showTimer = null;
    if (_entry != null) {
      // Stop trying to hide, if we were.
      _hideTimer?.cancel();
      _hideTimer = null;
      _controller.forward();
      return false; // Already visible.
    }
    _createNewEntry();
    _controller.forward();
    return true;
  }

  void _createNewEntry() {
    final OverlayState overlayState = Overlay.of(
      context,
      debugRequiredFor: widget,
    )!;

    final RenderBox box = context.findRenderObject()! as RenderBox;
    Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );
    if (_mouseIsConnected && widget.useMousePosition && mousePosition != null) {
      target = mousePosition!;
    }

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _TooltipOverlay(
        message: widget.message,
        height: height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        textStyle: textStyle,
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
      ),
    );
    _entry = OverlayEntry(builder: (BuildContext context) => overlay);
    overlayState.insert(_entry!);
    SemanticsService.tooltip(widget.message);
  }

  void _removeEntry() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    _entry?.remove();
    _entry = null;
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_entry == null) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _hideTooltip();
    } else if (event is PointerDownEvent) {
      _hideTooltip(immediately: true);
    }
  }

  @override
  void deactivate() {
    if (_entry != null) {
      _hideTooltip(immediately: true);
    }
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    GestureBinding.instance!.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    RendererBinding.instance!.mouseTracker
        .removeListener(_handleMouseTrackerChange);
    if (_entry != null) _removeEntry();
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    _longPressActivated = true;
    final bool tooltipCreated = ensureTooltipVisible();
    if (tooltipCreated) Feedback.forLongPress(context);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    final ThemeData theme = FluentTheme.of(context);
    final TooltipThemeData tooltipTheme =
        TooltipTheme.of(context).merge(widget.style);
    final TextStyle defaultTextStyle;
    final BoxDecoration defaultDecoration;
    if (theme.brightness == Brightness.dark) {
      defaultTextStyle = theme.typography.body!.copyWith(
        color: Colors.black,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    } else {
      defaultTextStyle = theme.typography.body!.copyWith(
        color: Colors.white,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: Colors.grey[150].withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    }

    height = tooltipTheme.height ?? _getDefaultTooltipHeight();
    padding = tooltipTheme.padding ?? _getDefaultPadding();
    margin = tooltipTheme.margin ?? _defaultMargin;
    verticalOffset = tooltipTheme.verticalOffset ?? _defaultVerticalOffset;
    preferBelow = tooltipTheme.preferBelow ?? _defaultPreferBelow;
    excludeFromSemantics = widget.excludeFromSemantics;
    decoration = tooltipTheme.decoration ?? defaultDecoration;
    textStyle = tooltipTheme.textStyle ?? defaultTextStyle;
    waitDuration = tooltipTheme.waitDuration ?? _defaultWaitDuration;
    showDuration = tooltipTheme.showDuration ?? _defaultShowDuration;

    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _handleLongPress,
      excludeFromSemantics: true,
      child: Semantics(
        label: excludeFromSemantics ? null : widget.message,
        child: widget.child,
      ),
    );

    // Only check for hovering if there is a mouse connected.
    if (_mouseIsConnected) {
      result = MouseRegion(
        onEnter: (PointerEnterEvent event) => _showTooltip(),
        onExit: (PointerExitEvent event) => _hideTooltip(),
        onHover: (PointerHoverEvent event) {
          mousePosition = event.position;
        },
        child: result,
      );
    }

    return result;
  }
}

/// An inherited widget that defines the configuration for
/// [Tooltip]s in this widget's subtree.
///
/// Values specified here are used for [Tooltip] properties that are not
/// given an explicit non-null value.
class TooltipTheme extends InheritedTheme {
  /// Creates a tooltip theme that controls the configurations for
  /// [Tooltip].
  const TooltipTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The properties for descendant [Tooltip] widgets.
  final TooltipThemeData data;

  /// Creates a button theme that controls how descendant [InfoBar]s should
  /// look like, and merges in the current toggle button theme, if any.
  static Widget merge({
    Key? key,
    required TooltipThemeData data,
    required Widget child,
  }) {
    return Builder(builder: (BuildContext context) {
      return TooltipTheme(
        key: key,
        data: _getInheritedThemeData(context).merge(data),
        child: child,
      );
    });
  }

  static TooltipThemeData _getInheritedThemeData(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<TooltipTheme>();
    return theme?.data ?? FluentTheme.of(context).tooltipTheme;
  }

  /// Returns the [data] from the closest [TooltipTheme] ancestor. If there is
  /// no ancestor, it returns [ThemeData.tooltipTheme]. Applications can assume
  /// that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TooltipThemeData theme = TooltipTheme.of(context);
  /// ```
  static TooltipThemeData of(BuildContext context) {
    return TooltipThemeData.standard(FluentTheme.of(context)).merge(
      _getInheritedThemeData(context),
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TooltipTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TooltipTheme oldWidget) => data != oldWidget.data;
}

class TooltipThemeData with Diagnosticable {
  /// The height of the tooltip's [child].
  ///
  /// If the [child] is null, then this is the tooltip's intrinsic height.
  final double? height;

  /// The vertical gap between the widget and the displayed tooltip.
  ///
  /// When [preferBelow] is set to true and tooltips have sufficient space
  /// to display themselves, this property defines how much vertical space
  /// tooltips will position themselves under their corresponding widgets.
  /// Otherwise, tooltips will position themselves above their corresponding
  /// widgets with the given offset.
  final double? verticalOffset;

  /// The amount of space by which to inset the tooltip's [child].
  ///
  /// Defaults to 10.0 logical pixels in each direction.
  final EdgeInsetsGeometry? padding;

  /// The empty space that surrounds the tooltip.
  ///
  /// Defines the tooltip's outer [Container.margin]. By default, a long
  /// tooltip will span the width of its window. If long enough, a tooltip
  /// might also span the window's height. This property allows one to define
  /// how much space the tooltip must be inset from the edges of their display
  /// window.
  final EdgeInsetsGeometry? margin;

  /// Whether the tooltip defaults to being displayed below the widget.
  ///
  /// Defaults to true. If there is insufficient space to display the tooltip
  /// in the preferred direction, the tooltip will be displayed in the opposite
  /// direction.
  final bool? preferBelow;

  /// Specifies the tooltip's shape and background color.
  ///
  /// The tooltip shape defaults to a rounded rectangle with a border radius of 4.0.
  /// Tooltips will also default to an opacity of 90% and with the color [Colors.grey]
  /// if [ThemeData.brightness] is [Brightness.dark], and [Colors.white] if it is
  /// [Brightness.light].
  final Decoration? decoration;

  /// The length of time that a pointer must hover over a tooltip's widget before
  /// the tooltip will be shown.
  ///
  /// Once the pointer leaves the widget, the tooltip will immediately disappear.
  ///
  /// Defaults to 0 milliseconds (tooltips are shown immediately upon hover).
  final Duration? waitDuration;

  /// The length of time that the tooltip will be shown after a long press is released.
  ///
  /// Defaults to 1.5 seconds.
  final Duration? showDuration;

  /// The style to use for the message of the tooltip.
  ///
  /// If null, [Typography.caption] is used
  final TextStyle? textStyle;

  const TooltipThemeData({
    this.height,
    this.verticalOffset,
    this.padding,
    this.margin,
    this.preferBelow,
    this.decoration,
    this.showDuration,
    this.waitDuration,
    this.textStyle,
  });

  factory TooltipThemeData.standard(ThemeData style) {
    return TooltipThemeData(
      height: 32.0,
      verticalOffset: 24.0,
      preferBelow: false,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      showDuration: const Duration(milliseconds: 1500),
      waitDuration: const Duration(seconds: 1),
      textStyle: style.typography.caption,
      decoration: () {
        final radius = BorderRadius.circular(4.0);
        final shadow = [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 1),
            blurRadius: 10.0,
          ),
        ];
        if (style.brightness == Brightness.light) {
          return BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: shadow,
          );
        } else {
          return BoxDecoration(
            color: Colors.grey,
            borderRadius: radius,
            boxShadow: shadow,
          );
        }
      }(),
    );
  }

  static TooltipThemeData lerp(
    TooltipThemeData? a,
    TooltipThemeData? b,
    double t,
  ) {
    return TooltipThemeData(
      decoration: Decoration.lerp(a?.decoration, b?.decoration, t),
      height: lerpDouble(a?.height, b?.height, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      preferBelow: t < 0.5 ? a?.preferBelow : b?.preferBelow,
      showDuration: lerpDuration(a?.showDuration ?? Duration.zero,
          b?.showDuration ?? Duration.zero, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      verticalOffset: lerpDouble(a?.verticalOffset, b?.verticalOffset, t),
      waitDuration: lerpDuration(a?.waitDuration ?? Duration.zero,
          b?.waitDuration ?? Duration.zero, t),
    );
  }

  TooltipThemeData merge(TooltipThemeData? style) {
    if (style == null) return this;
    return TooltipThemeData(
      decoration: style.decoration ?? decoration,
      height: style.height ?? height,
      margin: style.margin ?? margin,
      padding: style.padding ?? padding,
      preferBelow: style.preferBelow ?? preferBelow,
      showDuration: style.showDuration ?? showDuration,
      textStyle: style.textStyle ?? textStyle,
      verticalOffset: style.verticalOffset ?? verticalOffset,
      waitDuration: style.waitDuration ?? waitDuration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('verticalOffset', verticalOffset));
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin),
    );
    properties.add(FlagProperty(
      'preferBelow',
      value: preferBelow,
      ifFalse: 'prefer above',
    ));
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<Duration>('waitDuration', waitDuration));
    properties.add(DiagnosticsProperty<Duration>('showDuration', showDuration));
    properties.add(DiagnosticsProperty<TextStyle>('textStyle', textStyle));
  }
}

/// A delegate for computing the layout of a tooltip to be displayed above or
/// bellow a target specified in the global coordinate system.
class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a tooltip.
  ///
  /// The arguments must not be null.
  const _TooltipPositionDelegate({
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  });

  /// The offset of the target the tooltip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tooltip.
  final double verticalOffset;

  /// Whether the tooltip is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the tooltip in the preferred
  /// direction, the tooltip will be displayed in the opposite direction.
  final bool preferBelow;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}

class _TooltipOverlay extends StatelessWidget {
  const _TooltipOverlay({
    Key? key,
    required this.message,
    required this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    required this.animation,
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  }) : super(key: key);

  final String message;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Animation<double> animation;
  final Offset target;
  final double verticalOffset;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomSingleChildLayout(
          delegate: _TooltipPositionDelegate(
            target: target,
            verticalOffset: verticalOffset,
            preferBelow: preferBelow,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: DefaultTextStyle(
                style: FluentTheme.of(context).typography.body!,
                child: Container(
                  decoration: decoration,
                  padding: padding,
                  margin: margin,
                  child: Center(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Text(
                      message,
                      style: textStyle,
                    ),
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
