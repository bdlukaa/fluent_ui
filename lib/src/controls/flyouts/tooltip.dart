import 'dart:ui' show lerpDouble;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
    this.enableTapToDismiss = true,
    this.onTriggered,
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

  /// {@macro flutter.widgets.ProxyWidget.child}
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

  /// {@macro flutter.widgets.RawTooltip.triggerMode}
  ///
  /// If null, defaults to [TooltipTriggerMode.longPress].
  final TooltipTriggerMode? triggerMode;

  /// {@macro flutter.widgets.RawTooltip.enableFeedback}
  ///
  /// When null, defaults to true.
  final bool? enableFeedback;

  /// {@macro flutter.widgets.RawTooltip.enableTapToDismiss}
  final bool enableTapToDismiss;

  /// {@macro flutter.widgets.RawTooltip.onTriggered}
  final TooltipTriggeredCallback? onTriggered;

  /// {@macro flutter.widgets.RawTooltip.dismissAllToolTips}
  static bool dismissAllToolTips() => RawTooltip.dismissAllToolTips();

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
      )
      ..add(
        DiagnosticsProperty<TooltipTriggeredCallback>(
          'onTriggered',
          onTriggered,
          defaultValue: null,
        ),
      );
  }
}

/// Contains the state for a [Tooltip].
///
/// This class can be used to programmatically show the Tooltip, see the
/// [ensureTooltipVisible] method.
class TooltipState extends State<Tooltip> with SingleTickerProviderStateMixin {
  static const double _defaultVerticalOffset = 24;
  static const bool _defaultPreferBelow = true;
  static const EdgeInsetsGeometry _defaultMargin = EdgeInsetsDirectional.zero;
  static const Duration _defaultShowDuration = Duration(milliseconds: 1500);
  static const Duration _defaultWaitDuration = Duration.zero;
  static const TooltipTriggerMode _defaultTriggerMode =
      TooltipTriggerMode.longPress;
  static const bool _defaultEnableFeedback = true;

  static const AnimationStyle _animationStyle = AnimationStyle(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    reverseDuration: Duration(milliseconds: 75),
  );

  final GlobalKey<RawTooltipState> _tooltipKey = GlobalKey<RawTooltipState>();

  // From InheritedWidgets - cached in didChangeDependencies
  late bool _visible;
  late TooltipThemeData _tooltipTheme;

  Offset? _mousePosition;

  Duration get _showDuration =>
      _tooltipTheme.showDuration ?? _defaultShowDuration;
  Duration get _waitDuration =>
      _tooltipTheme.waitDuration ?? _defaultWaitDuration;
  TooltipTriggerMode get _triggerMode =>
      widget.triggerMode ?? _defaultTriggerMode;
  bool get _enableFeedback => widget.enableFeedback ?? _defaultEnableFeedback;
  bool get _mouseIsConnected =>
      RendererBinding.instance.mouseTracker.mouseIsConnected;

  /// The plain text message for this tooltip.
  ///
  /// This value will either come from [widget.message] or [widget.richMessage].
  String get _tooltipMessage =>
      widget.message ?? widget.richMessage!.toPlainText();

  /// {@macro flutter.widgets.RawTooltipState.ensureTooltipVisible}
  bool ensureTooltipVisible() {
    if (!_visible) return false;
    return _tooltipKey.currentState?.ensureTooltipVisible() ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TooltipVisibility.of(context);
    _cacheTooltipTheme(context);
  }

  @override
  void didUpdateWidget(Tooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style) {
      _cacheTooltipTheme(context);
    }
  }

  void _cacheTooltipTheme(BuildContext context) {
    _tooltipTheme = TooltipTheme.of(context).merge(widget.style);
  }

  void _handleMouseHover(PointerHoverEvent event) {
    _mousePosition = event.position;
  }

  void _handleMouseExit(PointerExitEvent event) {
    _mousePosition = null;
  }

  Offset _computePosition(TooltipPositionContext context) {
    final effectiveVerticalOffset =
        _tooltipTheme.verticalOffset ?? _defaultVerticalOffset;
    final effectivePreferBelow =
        _tooltipTheme.preferBelow ?? _defaultPreferBelow;

    // When useMousePosition is true and a mouse is connected, use the
    // current mouse position instead of the widget's center.
    final effectiveTarget =
        (_mouseIsConnected && widget.useMousePosition && _mousePosition != null)
        ? _mousePosition!
        : context.target;

    if (widget.displayHorizontally) {
      return horizontalPositionDependentBox(
        size: context.overlaySize,
        childSize: context.tooltipSize,
        target: effectiveTarget,
        horizontalOffset: effectiveVerticalOffset,
        preferLeft: effectivePreferBelow,
      );
    }
    return positionDependentBox(
      size: context.overlaySize,
      childSize: context.tooltipSize,
      target: effectiveTarget,
      verticalOffset: effectiveVerticalOffset,
      preferBelow: effectivePreferBelow,
    );
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

    final theme = FluentTheme.of(context);
    final defaultTextStyle = theme.typography.body!;
    final defaultDecoration = BoxDecoration(
      color: theme.menuColor,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: theme.resources.surfaceStrokeColorFlyout),
    );

    final excludeFromSemantics = widget.excludeFromSemantics;
    Widget child = Semantics(
      label: excludeFromSemantics ? null : _tooltipMessage,
      child: widget.child,
    );

    // Only check for gestures if tooltip should be visible.
    if (_visible) {
      // Track mouse position for useMousePosition feature.
      child = MouseRegion(
        onHover: _handleMouseHover,
        onExit: _handleMouseExit,
        child: child,
      );

      child = RawTooltip(
        key: _tooltipKey,
        semanticsTooltip: excludeFromSemantics ? null : _tooltipMessage,
        tooltipBuilder: (context, animation) {
          return FadeTransition(
            opacity: animation,
            child: _TooltipContent(
              richMessage: widget.richMessage ?? TextSpan(text: widget.message),
              padding: _tooltipTheme.padding ?? EdgeInsetsDirectional.zero,
              margin: _tooltipTheme.margin ?? _defaultMargin,
              decoration: _tooltipTheme.decoration ?? defaultDecoration,
              textStyle: _tooltipTheme.textStyle ?? defaultTextStyle,
              maxWidth: _tooltipTheme.maxWidth,
            ),
          );
        },
        hoverDelay: _waitDuration,
        touchDelay: _showDuration,
        dismissDelay: Duration.zero,
        triggerMode: _triggerMode,
        enableFeedback: _enableFeedback,
        enableTapToDismiss: widget.enableTapToDismiss,
        onTriggered: widget.onTriggered,
        animationStyle: _animationStyle,
        positionDelegate: _computePosition,
        ignorePointer: true,
        child: child,
      );
    }

    return child;
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
      height: (32 + theme.visualDensity.baseSizeAdjustment.dy).clamp(
        0.0,
        double.infinity,
      ),
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

/// The content widget for a [Tooltip]'s overlay.
class _TooltipContent extends StatelessWidget {
  const _TooltipContent({
    required this.richMessage,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    this.maxWidth,
  });

  final InlineSpan richMessage;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: FluentTheme.of(context).typography.body!,
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
    );
  }
}
