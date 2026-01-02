import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// A tooltip is a popup that contains additional information about another
/// control or object.
///
/// Tooltips display automatically when the user moves focus to, presses and holds,
/// or hovers the pointer over the associated control. The tooltip disappears when
/// the user moves focus from, stops pressing on, or stops hovering the pointer
/// over the associated control.
///
/// ![Tooltip Preview](https://learn.microsoft.com/en-us/windows/apps/design/controls/images/controls/tool-tip.png)
///
/// {@tool snippet}
/// This example shows a basic tooltip with a text message:
///
/// ```dart
/// Tooltip(
///   message: 'This is a tooltip',
///   child: IconButton(
///     icon: Icon(WindowsIcons.info),
///     onPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows a tooltip with rich text content:
///
/// ```dart
/// Tooltip(
///   richMessage: TextSpan(
///     children: [
///       TextSpan(text: 'Bold text', style: TextStyle(fontWeight: FontWeight.bold)),
///       TextSpan(text: ' and normal text'),
///     ],
///   ),
///   child: Button(
///     child: Text('Hover me'),
///     onPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## Tooltip behavior
///
/// * On desktop: Tooltips appear after hovering for a short duration
/// * On touch devices: Tooltips appear on long press
/// * Tooltips automatically dismiss when the user interacts elsewhere
///
/// ## Accessibility
///
/// Tooltips are automatically announced by screen readers. The [message] or
/// [richMessage] content is used as the accessible description for the [child]
/// widget, unless [excludeFromSemantics] is set to true.
///
/// See also:
///
///  * [Flyout], which creates a popup with interactive content
///  * [TeachingTip], for onboarding experiences and feature discovery
///  * <https://learn.microsoft.com/en-us/windows/apps/design/controls/tooltips>
class Tooltip extends StatefulWidget {
  /// Creates a tooltip.
  ///
  /// Wrap any widget in a [Tooltip] to show a message on mouse hover
  const Tooltip({
    super.key,
    this.message,
    this.richMessage,
    this.child,
    this.style,
    this.excludeFromSemantics = false,
    this.useMousePosition = true,
    this.displayHorizontally = false,
    this.triggerMode,
    this.enableFeedback,
  }) : assert(
         (message == null) != (richMessage == null),
         'Either `message` or `richMessage` must be specified',
       );

  /// The text to display in the tooltip.
  ///
  /// Only one of [message] and [richMessage] may be non-null.
  final String? message;

  /// The rich text to display in the tooltip.
  ///
  /// Only one of [message] and [richMessage] may be non-null.
  final InlineSpan? richMessage;

  /// The widget the tooltip will be displayed, either above or below,
  /// when the mouse is hovering or whenever it gets long pressed.
  final Widget? child;

  /// The style of the tooltip. If non-null, it's mescled with
  /// [FluentThemeData.tooltipThemeData]
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

  /// Whether the tooltip should be displayed at the left or right of
  /// the [child]. If true, [TooltipThemeData.preferBelow] is used as
  /// "preferLeft"
  final bool displayHorizontally;

  /// The [TooltipTriggerMode] that will show the tooltip.
  ///
  /// If this property is null, then [TooltipTriggerMode.longPress] is used
  final TooltipTriggerMode? triggerMode;

  /// Whether the tooltip should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// When null, the default value is true.
  ///
  /// See also:
  ///
  ///  * [Feedback], for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  static final List<TooltipState> _openedTooltips = <TooltipState>[];

  // Causes any current tooltips to be concealed. Only called for mouse hover enter
  // detections. Won't conceal the supplied tooltip.
  static void _concealOtherTooltips(TooltipState current) {
    if (_openedTooltips.isNotEmpty) {
      // Avoid concurrent modification.
      final openedTooltips = _openedTooltips.toList();
      for (final state in openedTooltips) {
        if (state == current) {
          continue;
        }
        state._concealTooltip();
      }
    }
  }

  // Causes the most recently concealed tooltip to be revealed. Only called for mouse
  // hover exit detections.
  static void _revealLastTooltip() {
    if (_openedTooltips.isNotEmpty) {
      _openedTooltips.last._revealTooltip();
    }
  }

  /// Dismiss all of the tooltips that are currently shown on the screen.
  ///
  /// This method returns true if it successfully dismisses the tooltips. It
  /// returns false if there is no tooltip shown on the screen.
  static bool dismissAllToolTips() {
    if (_openedTooltips.isNotEmpty) {
      // Avoid concurrent modification.
      final openedTooltips = _openedTooltips.toList();
      for (final state in openedTooltips) {
        state._dismissTooltip(immediately: true);
      }
      return true;
    }
    return false;
  }

  @override
  State<Tooltip> createState() => TooltipState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<InlineSpan>('richMessage', richMessage))
      ..add(DiagnosticsProperty<TooltipThemeData>('style', style))
      ..add(
        FlagProperty(
          'excludeFromSemantics',
          value: excludeFromSemantics,
          ifTrue: 'excluded',
          defaultValue: false,
        ),
      )
      ..add(
        FlagProperty(
          'useMousePosition',
          value: useMousePosition,
          ifFalse: 'use child position',
          defaultValue: true,
        ),
      )
      ..add(
        FlagProperty(
          'displayHorizontally',
          value: displayHorizontally,
          ifTrue: 'display horizontally',
          defaultValue: false,
        ),
      )
      ..add(
        EnumProperty<TooltipTriggerMode>(
          'triggerMode',
          triggerMode,
          defaultValue: TooltipState._defaultTriggerMode,
        ),
      )
      ..add(
        FlagProperty(
          'enableFeedback',
          value: enableFeedback,
          ifFalse: 'feedback disabled',
          defaultValue: true,
        ),
      );
  }
}

/// The state for a [Tooltip] widget.
///
/// This class manages the tooltip's visibility, animations, and positioning.
/// It handles both mouse hover and touch interactions.
class TooltipState extends State<Tooltip> with SingleTickerProviderStateMixin {
  static const double _defaultVerticalOffset = 24;
  static const bool _defaultPreferBelow = true;
  static const EdgeInsetsGeometry _defaultMargin = EdgeInsetsDirectional.zero;
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);
  static const Duration _defaultShowDuration = Duration(milliseconds: 1500);
  static const Duration _defaultHoverShowDuration = Duration.zero;
  static const Duration _defaultWaitDuration = Duration.zero;
  static const TooltipTriggerMode _defaultTriggerMode =
      TooltipTriggerMode.longPress;
  static const bool _defaultEnableFeedback = true;

  // From InheritedWidgets - cached in didChangeDependencies
  late bool _visible;
  late TooltipThemeData _tooltipTheme;

  late AnimationController _controller;
  OverlayEntry? _entry;
  Timer? _dismissTimer;
  Timer? _showTimer;
  late bool _mouseIsConnected;
  bool _pressActivated = false;

  Offset? _mousePosition;
  late bool _isConcealed;
  late bool _forceRemoval;

  Duration get _showDuration =>
      _tooltipTheme.showDuration ?? _defaultShowDuration;
  Duration get _hoverShowDuration => _defaultHoverShowDuration;
  Duration get _waitDuration =>
      _tooltipTheme.waitDuration ?? _defaultWaitDuration;
  TooltipTriggerMode get _triggerMode =>
      widget.triggerMode ?? _defaultTriggerMode;
  bool get _enableFeedback => widget.enableFeedback ?? _defaultEnableFeedback;

  /// The plain text message for this tooltip.
  ///
  /// This value will either come from [widget.message] or [widget.richMessage].
  String get _tooltipMessage =>
      widget.message ?? widget.richMessage!.toPlainText();

  @override
  void initState() {
    super.initState();
    _isConcealed = false;
    _forceRemoval = false;
    _mouseIsConnected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
    // Listen to see when a mouse is added.
    RendererBinding.instance.mouseTracker.addListener(
      _handleMouseTrackerChange,
    );
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance.pointerRouter.addGlobalRoute(
      _handleGlobalPointerEvent,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TooltipVisibility.of(context);
    _tooltipTheme = TooltipTheme.of(context);
  }

  // Forces a rebuild if a mouse has been added or removed.
  void _handleMouseTrackerChange() {
    if (!mounted) {
      return;
    }
    final mouseIsConnected =
        RendererBinding.instance.mouseTracker.mouseIsConnected;
    if (mouseIsConnected != _mouseIsConnected) {
      setState(() {
        _mouseIsConnected = mouseIsConnected;
      });
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    // If this tip is concealed, don't remove it, even if it is dismissed, so that we can
    // reveal it later, unless it has explicitly been hidden with _dismissTooltip.
    if (status == AnimationStatus.dismissed &&
        (_forceRemoval || !_isConcealed)) {
      _removeEntry();
    }
  }

  Future<void> _dismissTooltip({bool immediately = false}) async {
    _showTimer?.cancel();
    _showTimer = null;
    if (immediately) {
      _removeEntry();
      return;
    }
    // So it will be removed when it's done reversing, regardless of whether it is
    // still concealed or not.
    _forceRemoval = true;
    if (_pressActivated) {
      _dismissTimer ??= Timer(_showDuration, _controller.reverse);
    } else {
      _dismissTimer ??= Timer(_hoverShowDuration, _controller.reverse);
    }
    _pressActivated = false;
  }

  void _showTooltip({bool immediately = false}) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (immediately) {
      ensureTooltipVisible();
      return;
    }
    _showTimer ??= Timer(_waitDuration, ensureTooltipVisible);
  }

  void _concealTooltip() {
    if (_isConcealed || _forceRemoval) {
      // Already concealed, or it's being removed.
      return;
    }
    _isConcealed = true;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (_entry != null) {
      _entry!.remove();
    }
    _controller.reverse();
  }

  void _revealTooltip() {
    if (!_isConcealed) {
      // Already uncovered.
      return;
    }
    _isConcealed = false;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (!_entry!.mounted) {
      Overlay.of(context, debugRequiredFor: widget).insert(_entry!);
    }
    SemanticsService.tooltip(_tooltipMessage);
    _controller.forward(from: 0);
  }

  /// Shows the tooltip if it is not already visible.
  ///
  /// Returns `false` when the tooltip shouldn't be shown or when the tooltip
  /// was already visible.
  bool ensureTooltipVisible() {
    if (!_visible) return false;
    _showTimer?.cancel();
    _showTimer = null;
    _forceRemoval = false;
    if (_isConcealed) {
      if (_mouseIsConnected) {
        Tooltip._concealOtherTooltips(this);
      }
      _revealTooltip();
      return true;
    }
    if (_entry != null) {
      // Stop trying to hide, if we were.
      _dismissTimer?.cancel();
      _dismissTimer = null;
      _controller.forward();
      return false; // Already visible.
    }
    _createNewEntry();
    _controller.forward(from: 0);
    return true;
  }

  static final Set<TooltipState> _mouseIn = <TooltipState>{};

  void _handleMouseEnter() {
    _showTooltip();
  }

  void _handleMouseExit({bool immediately = false}) {
    _mousePosition = null;
    // If the tip is currently covered, we can just remove it without waiting.
    _dismissTooltip(immediately: _isConcealed || immediately);
  }

  void _createNewEntry() {
    final overlayState = Overlay.of(
      context,
      rootOverlay: true,
      debugRequiredFor: widget,
    );

    final box = context.findRenderObject()! as RenderBox;
    Offset target;
    if (_mouseIsConnected &&
        widget.useMousePosition &&
        _mousePosition != null) {
      target = _mousePosition!;
    } else {
      target = box.localToGlobal(
        box.size.center(Offset.zero),
        ancestor: overlayState.context.findRenderObject(),
      );
    }

    // Merge widget style with cached theme
    final tooltipTheme = _tooltipTheme.merge(widget.style);

    // Compute default decoration based on current theme
    final theme = FluentTheme.of(context);
    final defaultTextStyle = theme.typography.body!;
    final defaultDecoration = BoxDecoration(
      color: theme.menuColor,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: theme.resources.surfaceStrokeColorFlyout),
    );

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _TooltipOverlay(
        richMessage: widget.richMessage ?? TextSpan(text: widget.message),
        padding: tooltipTheme.padding ?? EdgeInsetsDirectional.zero,
        margin: tooltipTheme.margin ?? _defaultMargin,
        decoration: tooltipTheme.decoration ?? defaultDecoration,
        textStyle: tooltipTheme.textStyle ?? defaultTextStyle,
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        verticalOffset: tooltipTheme.verticalOffset ?? _defaultVerticalOffset,
        preferBelow: tooltipTheme.preferBelow ?? _defaultPreferBelow,
        displayHorizontally: widget.displayHorizontally,
        maxWidth: tooltipTheme.maxWidth,
      ),
    );
    _entry = OverlayEntry(builder: (_) => overlay);
    _isConcealed = false;
    overlayState.insert(_entry!);
    SemanticsService.tooltip(_tooltipMessage);
    if (_mouseIsConnected) {
      // Hovered tooltips shouldn't show more than one at once. For example, a chip with
      // a delete icon shouldn't show both the delete icon tooltip and the chip tooltip
      // at the same time.
      Tooltip._concealOtherTooltips(this);
    }
    assert(!Tooltip._openedTooltips.contains(this));
    Tooltip._openedTooltips.add(this);
  }

  void _removeEntry() {
    Tooltip._openedTooltips.remove(this);
    _mouseIn.remove(this);
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (!_isConcealed) {
      _entry?.remove();
    }
    _isConcealed = false;
    _entry = null;
    if (_mouseIsConnected) {
      Tooltip._revealLastTooltip();
    }
  }

  void _handleGlobalPointerEvent(PointerEvent event) {
    if (_entry == null) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _handleMouseExit();
    } else if (event is PointerDownEvent) {
      _handleMouseExit(immediately: true);
    }
  }

  @override
  void deactivate() {
    if (_entry != null) {
      _dismissTooltip(immediately: true);
    }
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _removeEntry();
    GestureBinding.instance.pointerRouter.removeGlobalRoute(
      _handleGlobalPointerEvent,
    );
    RendererBinding.instance.mouseTracker.removeListener(
      _handleMouseTrackerChange,
    );
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _pressActivated = true;
    final tooltipCreated = ensureTooltipVisible();
    if (tooltipCreated && _enableFeedback) {
      if (_triggerMode == TooltipTriggerMode.longPress) {
        Feedback.forLongPress(context);
      } else {
        Feedback.forTap(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If message is empty then no need to create a tooltip overlay to show
    // the empty black container so just return the wrapped child as is or
    // empty container if child is not specified.
    if (_tooltipMessage.isEmpty) {
      return widget.child ?? const SizedBox();
    }
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasDirectionality(context));

    final excludeFromSemantics = widget.excludeFromSemantics;
    Widget result = Semantics(
      label: excludeFromSemantics ? null : _tooltipMessage,
      child: widget.child,
    );

    // Only check for gestures if tooltip should be visible.
    if (_visible) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: (_triggerMode == TooltipTriggerMode.longPress)
            ? _handlePress
            : null,
        onTap: (_triggerMode == TooltipTriggerMode.tap) ? _handlePress : null,
        excludeFromSemantics: true,
        child: result,
      );
      // Only check for hovering if there is a mouse connected.
      if (_mouseIsConnected) {
        result = MouseRegion(
          onEnter: (_) => _handleMouseEnter(),
          onHover: (event) {
            _mousePosition = event.position;
          },
          onExit: (_) => _handleMouseExit(),
          child: result,
        );
      }
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
  /// Creates a theme that controls how descendant [Tooltip]s should look like.
  const TooltipTheme({required this.data, required super.child, super.key});

  /// The properties for descendant [Tooltip] widgets.
  final TooltipThemeData data;

  /// Creates a theme that merges the nearest [TooltipTheme] with [data].
  static Widget merge({
    required TooltipThemeData data,
    required Widget child,
    Key? key,
  }) {
    return Builder(
      builder: (context) {
        return TooltipTheme(
          key: key,
          data: TooltipTheme.of(context).merge(data),
          child: child,
        );
      },
    );
  }

  /// Returns the closest [TooltipThemeData] which encloses the given context.
  ///
  /// Resolution order:
  /// 1. Defaults from [TooltipThemeData.standard]
  /// 2. Global theme from [FluentThemeData.tooltipTheme]
  /// 3. Local [TooltipTheme] ancestor
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TooltipThemeData theme = TooltipTheme.of(context);
  /// ```
  static TooltipThemeData of(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<TooltipTheme>();
    return TooltipThemeData.standard(
      theme,
    ).merge(theme.tooltipTheme).merge(inheritedTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TooltipTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TooltipTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for [Tooltip] widgets.
///
/// This class defines the visual appearance of tooltips, including their
/// size, positioning, colors, and timing behavior.
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
  /// if [FluentThemeData.brightness] is [Brightness.dark], and [Colors.white] if it is
  /// [Brightness.light].
  final Decoration? decoration;

  /// The length of time that a pointer must hover over a tooltip's widget before
  /// the tooltip will be shown.
  ///
  /// Once the pointer leaves the widget, the tooltip will immediately disappear.
  ///
  /// Defaults to 1 second.
  final Duration? waitDuration;

  /// The length of time that the tooltip will be shown after a long press is released.
  ///
  /// Defaults to 1.5 seconds.
  final Duration? showDuration;

  /// The style to use for the message of the tooltip.
  ///
  /// If null, [Typography.caption] is used
  final TextStyle? textStyle;

  /// If non-null, the maximum width of the tooltip text before it wraps.
  ///
  /// Defaults to double.infinity.
  ///
  /// If the tooltip text is longer than this width, it will wrap to the next line.
  final double? maxWidth;

  /// Creates a theme data for [Tooltip] widgets.
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
    this.maxWidth,
  });

  /// Creates the standard [TooltipThemeData] based on the given [theme].
  factory TooltipThemeData.standard(FluentThemeData theme) {
    return TooltipThemeData(
      height: 32,
      verticalOffset: 24,
      preferBelow: false,
      margin: EdgeInsetsDirectional.zero,
      padding: () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.macOS:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            return const EdgeInsetsDirectional.fromSTEB(8, 5, 8, 7);
          default:
            return const EdgeInsetsDirectional.symmetric(horizontal: 16);
        }
      }(),
      showDuration: const Duration(milliseconds: 1500),
      waitDuration: const Duration(seconds: 1),
      textStyle: theme.typography.caption,
      decoration: () {
        final radius = BorderRadius.circular(4);
        final shadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(1, 1),
            blurRadius: 10,
          ),
        ];
        if (theme.brightness == Brightness.light) {
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

  /// Linearly interpolates between two [TooltipThemeData] objects.
  ///
  /// The [t] argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning [a], and 1.0 meaning
  /// that the interpolation has finished, returning [b].
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
      showDuration: lerpDuration(
        a?.showDuration ?? Duration.zero,
        b?.showDuration ?? Duration.zero,
        t,
      ),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      verticalOffset: lerpDouble(a?.verticalOffset, b?.verticalOffset, t),
      waitDuration: lerpDuration(
        a?.waitDuration ?? Duration.zero,
        b?.waitDuration ?? Duration.zero,
        t,
      ),
      maxWidth: lerpDouble(a?.maxWidth, b?.maxWidth, t),
    );
  }

  /// Merges this [TooltipThemeData] with another, with the other taking
  /// precedence.
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
      maxWidth: style.maxWidth ?? maxWidth,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('verticalOffset', verticalOffset))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin))
      ..add(
        FlagProperty(
          'preferBelow',
          value: preferBelow,
          ifFalse: 'prefer above',
        ),
      )
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration))
      ..add(DiagnosticsProperty<Duration>('waitDuration', waitDuration))
      ..add(DiagnosticsProperty<Duration>('showDuration', showDuration))
      ..add(DiagnosticsProperty<TextStyle>('textStyle', textStyle))
      ..add(DoubleProperty('maxWidth', maxWidth));
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
    required this.horizontal,
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

  /// Whether the tooltip is in horizontal mode
  final bool horizontal;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (horizontal) {
      return horizontalPositionDependentBox(
        size: size,
        childSize: childSize,
        target: target,
        horizontalOffset: verticalOffset,
        preferLeft: preferBelow,
      );
    } else {
      return positionDependentBox(
        size: size,
        childSize: childSize,
        target: target,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
      );
    }
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
    required this.richMessage,
    required this.animation,
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    this.displayHorizontally = false,
    this.maxWidth,
  });

  final InlineSpan richMessage;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Animation<double> animation;
  final Offset target;
  final double verticalOffset;
  final bool preferBelow;
  final bool displayHorizontally;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final Widget result = IgnorePointer(
      child: FadeTransition(
        opacity: animation,
        child: DefaultTextStyle.merge(
          style: theme.typography.body,
          child: Container(
            decoration: decoration,
            padding: padding,
            margin: margin,
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text.rich(richMessage, style: textStyle),
            ),
          ),
        ),
      ),
    );
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _TooltipPositionDelegate(
          target: target,
          verticalOffset: verticalOffset,
          preferBelow: preferBelow,
          horizontal: displayHorizontally,
        ),
        child: result,
      ),
    );
  }
}
