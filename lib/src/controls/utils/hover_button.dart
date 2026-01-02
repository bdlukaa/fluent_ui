import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// A builder function that creates a widget based on the current [WidgetState].
typedef WidgetStateWidgetBuilder =
    Widget Function(BuildContext, Set<WidgetState> state);

/// An inherited widget that provides access to [HoverButton] interaction states.
class HoverButtonInherited extends InheritedWidget {
  /// Creates a hover button inherited widget.
  const HoverButtonInherited({
    required super.child,
    required this.states,
    super.key,
  });

  /// The current interaction states of the button.
  final Set<WidgetState> states;

  /// Returns the closest [HoverButtonInherited] ancestor.
  ///
  /// Throws if no ancestor is found.
  static HoverButtonInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HoverButtonInherited>()!;
  }

  /// Returns the closest [HoverButtonInherited] ancestor, if any.
  static HoverButtonInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HoverButtonInherited>();
  }

  @override
  bool updateShouldNotify(HoverButtonInherited oldWidget) {
    return states != oldWidget.states;
  }
}

/// Base widget for any widget that requires input.
class HoverButton extends StatefulWidget {
  /// Creates a hover button.
  const HoverButton({
    required this.builder,
    super.key,
    this.cursor,
    this.onPressed,
    this.onLongPress,
    this.focusNode,
    this.margin,
    this.semanticLabel,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressEnd,
    this.onLongPressStart,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.gestures = const {},
    this.onFocusTap,
    this.onPointerEnter,
    this.onPointerExit,
    this.onFocusChange,
    this.autofocus = false,
    this.actionsEnabled = true,
    this.customActions,
    this.shortcuts,
    this.focusEnabled = true,
    this.forceEnabled = false,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  /// {@template fluent_ui.controls.inputs.HoverButton.mouseCursor}
  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// The [mouseCursor] defaults to [MouseCursor.defer], deferring the choice of
  /// cursor to the next region behind it in hit-test order.
  /// {@endtemplate}
  final MouseCursor? cursor;

  /// Called when a long press gesture is detected.
  final GestureLongPressCallback? onLongPress;

  /// Called when a long press gesture starts.
  final GestureLongPressStartCallback? onLongPressStart;

  /// Called when a long press gesture ends.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Called when the button tap is released.
  final GestureTapUpCallback? onTapUp;

  /// Called when the button tap begins.
  final GestureTapDownCallback? onTapDown;

  /// Called when the button tap is cancelled.
  final GestureTapCancelCallback? onTapCancel;

  /// Called when a horizontal drag gesture starts.
  final GestureDragStartCallback? onHorizontalDragStart;

  /// Called during a horizontal drag gesture.
  final GestureDragUpdateCallback? onHorizontalDragUpdate;

  /// Called when a horizontal drag gesture ends.
  final GestureDragEndCallback? onHorizontalDragEnd;

  /// The gestures that this widget will attempt to recognize.
  ///
  /// This should be a map from [GestureRecognizer] subclasses to
  /// [GestureRecognizerFactory] subclasses specialized with the same type.
  ///
  /// This value can be late-bound at layout time using
  /// [RawGestureDetectorState.replaceGestureRecognizers].
  ///
  /// See also:
  ///
  ///   * [RawGestureDetector.gestures], which this value is passed to.
  final Map<Type, GestureRecognizerFactory> gestures;

  /// When the button is focused and is actioned, with either the enter or space
  /// keys.
  ///
  /// [focusEnabled] must not be `false` for this to work
  final VoidCallback? onFocusTap;

  /// Called when the pointer enters the button area.
  final PointerEnterEventListener? onPointerEnter;

  /// Called when the pointer exits the button area.
  final PointerExitEventListener? onPointerExit;

  /// The builder for the button content based on the current states.
  final WidgetStateWidgetBuilder builder;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// The margin created around this button. The margin is added
  /// around the [Semantics] widget, if any.
  final EdgeInsetsGeometry? margin;

  /// {@template fluent_ui.controls.inputs.HoverButton.semanticLabel}
  /// Semantic label for the input.
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver).
  /// This label does not show in the UI.
  ///
  ///  * [SemanticsProperties.label], which is set to [semanticLabel] in the
  ///    underlying	 [Semantics] widget.
  ///
  /// If null, no [Semantics] widget is added to the tree
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Called when the button focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Whether actions are enabled
  ///
  /// Default actions:
  ///  * Execute [onPressed] with Enter and Space
  ///
  /// See also:
  ///
  ///  * [customActions], which lets you execute custom actions
  final bool actionsEnabled;

  /// Custom actions that will be executed around the subtree of this widget.
  ///
  /// See also:
  ///
  ///  * [actionsEnabled], which controls if actions are enabled or not
  final Map<Type, Action<Intent>>? customActions;

  /// {@macro flutter.widgets.shortcuts.shortcuts}
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Whether the focusing is enabled.
  ///
  /// If `false`, actions and shortcurts will not work, regardless of what is
  /// set on [actionsEnabled].
  final bool focusEnabled;

  /// Whether the hover button should be always enabled.
  ///
  /// If `true`, the button will be considered active even if [onPressed] is not
  /// provided
  final bool forceEnabled;

  /// How this gesture detector should behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.opaque]
  final HitTestBehavior hitTestBehavior;

  @override
  State<HoverButton> createState() => _HoverButtonState();

  /// Returns the closest [HoverButtonInherited] ancestor.
  static HoverButtonInherited of(BuildContext context) {
    return HoverButtonInherited.of(context);
  }

  /// Returns the closest [HoverButtonInherited] ancestor, if any.
  static HoverButtonInherited? maybeOf(BuildContext context) {
    return HoverButtonInherited.maybeOf(context);
  }
}

class _HoverButtonState extends State<HoverButton> {
  late FocusNode node;

  late Map<Type, Action<Intent>> _actionMap;
  late Map<Type, Action<Intent>> defaultActions;

  @override
  void initState() {
    super.initState();
    node = widget.focusNode ?? _createFocusNode();

    defaultActions = {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (intent) => handleActionTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (intent) => handleActionTap(),
      ),
    };

    _actionMap = <Type, Action<Intent>>{
      ...defaultActions,
      if (widget.customActions != null) ...widget.customActions!,
    };
  }

  Future<void> handleActionTap() async {
    if (!enabled) return;
    final theme = FluentTheme.of(context);
    setState(() => _pressing = true);
    widget.onFocusTap?.call();
    widget.onPressed?.call();
    await Future<void>.delayed(theme.fastAnimationDuration);
    if (mounted) setState(() => _pressing = false);
  }

  @override
  void didUpdateWidget(HoverButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      node = widget.focusNode ?? node;
    }

    if (widget.customActions != oldWidget.customActions) {
      _actionMap = <Type, Action<Intent>>{
        ...defaultActions,
        if (widget.customActions != null) ...widget.customActions!,
      };
    }
  }

  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void dispose() {
    if (widget.focusNode == null) node.dispose();
    super.dispose();
  }

  bool _hovering = false;
  bool _pressing = false;
  bool _shouldShowFocus = false;

  bool get enabled =>
      widget.forceEnabled ||
      widget.onPressed != null ||
      widget.onTapUp != null ||
      widget.onTapDown != null ||
      widget.onTapDown != null ||
      widget.onLongPress != null ||
      widget.onLongPressStart != null ||
      widget.onLongPressEnd != null ||
      widget.onHorizontalDragStart != null ||
      widget.onHorizontalDragUpdate != null ||
      widget.onHorizontalDragEnd != null;

  Set<WidgetState> get states {
    if (!enabled) return {WidgetState.disabled};

    return {
      if (_pressing) WidgetState.pressed,
      if (_hovering) WidgetState.hovered,
      if (_shouldShowFocus) WidgetState.focused,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    Widget w = GestureDetector(
      behavior: widget.hitTestBehavior,
      onTap: enabled ? widget.onPressed : null,
      onTapDown: (d) {
        if (!enabled) return;
        if (mounted) setState(() => _pressing = true);
        widget.onTapDown?.call(d);
      },
      onTapUp: (d) async {
        if (!enabled) return;
        widget.onTapUp?.call(d);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _pressing = false);
      },
      onTapCancel: () {
        if (!enabled) return;
        widget.onTapCancel?.call();
        if (mounted) setState(() => _pressing = false);
      },
      onLongPress: enabled ? widget.onLongPress : null,
      onLongPressStart: widget.onLongPressStart != null
          ? (d) {
              if (!enabled) return;
              widget.onLongPressStart?.call(d);
              if (mounted) setState(() => _pressing = true);
            }
          : null,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (d) {
              if (!enabled) return;
              widget.onLongPressEnd?.call(d);
              if (mounted) setState(() => _pressing = false);
            }
          : null,
      onHorizontalDragStart: widget.onHorizontalDragStart,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      child: widget.builder(context, states),
    );
    w = RawGestureDetector(gestures: widget.gestures, child: w);
    if (widget.focusEnabled) {
      w = FocusableActionDetector(
        mouseCursor: widget.cursor ?? MouseCursor.defer,
        focusNode: node,
        autofocus: widget.autofocus,
        enabled: enabled,
        shortcuts: widget.shortcuts,
        actions: widget.actionsEnabled ? _actionMap : {},
        onFocusChange: widget.onFocusChange,
        onShowFocusHighlight: (v) {
          if (mounted) setState(() => _shouldShowFocus = v);
        },
        onShowHoverHighlight: (v) {
          if (mounted) setState(() => _hovering = v);
        },
        child: MouseRegion(
          onEnter: widget.onPointerEnter,
          onExit: widget.onPointerExit,
          child: w,
        ),
      );
    } else {
      w = MouseRegion(
        cursor: widget.cursor ?? MouseCursor.defer,
        onEnter: (e) {
          if (mounted) setState(() => _hovering = true);
          widget.onPointerEnter?.call(e);
        },
        onExit: (e) {
          if (mounted) setState(() => _hovering = false);
          widget.onPointerExit?.call(e);
        },
        child: w,
      );
    }
    w = MergeSemantics(
      child: Semantics(
        label: widget.semanticLabel,
        enabled: enabled,
        focusable: enabled && node.canRequestFocus,
        focused: node.hasFocus,
        child: w,
      ),
    );
    if (widget.margin != null) w = Padding(padding: widget.margin!, child: w);

    return HoverButtonInherited(states: states, child: w);
  }
}

/// Extension methods for [Set<WidgetState>] to easily check interaction states.
extension WidgetStateExtension on Set<WidgetState> {
  /// Checks whether the widget is focused.
  bool get isFocused => contains(WidgetState.focused);

  /// Checks whether the widget is disabled.
  bool get isDisabled => contains(WidgetState.disabled);

  /// Checks whether the widget is pressed.
  bool get isPressed => contains(WidgetState.pressed);

  /// Checks whether the widget is hovered.
  bool get isHovered => contains(WidgetState.hovered);

  /// Checks whether the widget is in its default state.
  bool get isNone => isEmpty;

  /// Checks whether the widget is in any of the provided states.
  bool isAnyOf(Iterable<WidgetState> states) {
    return any((state) => states.contains(state));
  }

  /// Checks whether the widget is in all of the provided states.
  bool isAllOf(Iterable<WidgetState> states) {
    return containsAll(states);
  }

  /// Returns the value for the provided states.
  static T forStates<T>(
    Set<WidgetState> states, {
    required T disabled,
    required T none,
    T? pressed,
    T? hovering,
    T? focused,
  }) {
    if (states.contains(WidgetState.disabled)) return disabled;
    if (pressed != null && states.contains(WidgetState.pressed)) {
      return pressed;
    }
    if (hovering != null && states.contains(WidgetState.hovered)) {
      return hovering;
    }
    if (states.contains(WidgetState.focused)) {
      return focused ?? pressed ?? none;
    }

    return none;
  }
}
