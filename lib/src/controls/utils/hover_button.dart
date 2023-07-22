import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/rendering.dart';

typedef ButtonStateWidgetBuilder = Widget Function(
  BuildContext,
  Set<ButtonStates> state,
);

class _HoverButtonInherited extends InheritedWidget {
  const _HoverButtonInherited({
    required super.child,
    required this.states,
  });

  final Set<ButtonStates> states;

  static _HoverButtonInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_HoverButtonInherited>()!;
  }

  static _HoverButtonInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_HoverButtonInherited>();
  }

  @override
  bool updateShouldNotify(_HoverButtonInherited oldWidget) {
    return states != oldWidget.states;
  }
}

/// Base widget for any widget that requires input.
class HoverButton extends StatefulWidget {
  /// Creates a hover button.
  const HoverButton({
    super.key,
    required this.builder,
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

  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  final VoidCallback? onPressed;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapCancel;

  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;

  /// The gestures that this widget will attempt to recognize.
  ///
  /// This should be a map from [GestureRecognizer] subclasses to
  /// [GestureRecognizerFactory] subclasses specialized with the same type.
  ///
  /// This value can be late-bound at layout time using
  /// [RawGestureDetectorState.replaceGestureRecognizers].
  final Map<Type, GestureRecognizerFactory> gestures;

  /// When the button is focused and is actioned, with either the enter or space
  /// keys
  ///
  /// [focusEnabled] must not be `false` for this to work
  final VoidCallback? onFocusTap;

  final ButtonStateWidgetBuilder builder;

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

  static _HoverButtonInherited of(BuildContext context) {
    return _HoverButtonInherited.of(context);
  }

  static _HoverButtonInherited? maybeOf(BuildContext context) {
    return _HoverButtonInherited.maybeOf(context);
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
    Future<void> handleActionTap() async {
      if (!enabled) return;
      setState(() => _pressing = true);
      widget.onFocusTap?.call();
      widget.onPressed?.call();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _pressing = false);
    }

    defaultActions = {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => handleActionTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => handleActionTap(),
      ),
    };

    _actionMap = <Type, Action<Intent>>{
      ...defaultActions,
      if (widget.customActions != null) ...widget.customActions!,
    };
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

  Set<ButtonStates> get states {
    if (!enabled) return {ButtonStates.disabled};

    return {
      if (_pressing) ButtonStates.pressing,
      if (_hovering) ButtonStates.hovering,
      if (_shouldShowFocus) ButtonStates.focused,
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget w = GestureDetector(
      behavior: widget.hitTestBehavior,
      onTap: enabled ? widget.onPressed : null,
      onTapDown: (_) {
        if (!enabled) return;
        if (mounted) setState(() => _pressing = true);
        widget.onTapDown?.call();
      },
      onTapUp: (_) async {
        if (!enabled) return;
        widget.onTapUp?.call();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _pressing = false);
      },
      onTapCancel: () {
        if (!enabled) return;
        widget.onTapCancel?.call();
        if (mounted) setState(() => _pressing = false);
      },
      onLongPress: enabled ? widget.onLongPress : null,
      onLongPressStart: widget.onLongPressStart != null
          ? (_) {
              if (!enabled) return;
              widget.onLongPressStart?.call();
              if (mounted) setState(() => _pressing = true);
            }
          : null,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (_) {
              if (!enabled) return;
              widget.onLongPressEnd?.call();
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
        child: w,
      );
    } else {
      w = MouseRegion(
        cursor: widget.cursor ?? MouseCursor.defer,
        onEnter: (e) {
          if (mounted) setState(() => _hovering = true);
        },
        onExit: (e) {
          if (mounted) setState(() => _hovering = false);
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

    w = _HoverButtonInherited(
      states: states,
      child: w,
    );
    return w;
  }
}

enum ButtonStates { disabled, hovering, pressing, focused, none }

// typedef ButtonState<T> = T Function(Set<ButtonStates>);

/// Signature for the function that returns a value of type `T` based on a given
/// set of states.
typedef ButtonStateResolver<T> = T Function(Set<ButtonStates> states);

abstract class ButtonState<T> {
  T resolve(Set<ButtonStates> states);

  static ButtonState<T> all<T>(T value) => _AllButtonState(value);

  static ButtonState<T> resolveWith<T>(ButtonStateResolver<T> callback) {
    return _ButtonState(callback);
  }

  static ButtonState<T?>? lerp<T>(
    ButtonState<T?>? a,
    ButtonState<T?>? b,
    double t,
    T? Function(T?, T?, double) lerpFunction,
  ) {
    if (a == null && b == null) return null;
    return _LerpProperties<T>(a, b, t, lerpFunction);
  }

  static T forStates<T>(
    Set<ButtonStates> states, {
    required T disabled,
    required T none,
    T? pressed,
    T? hovering,
    T? focused,
  }) {
    if (states.contains(ButtonStates.disabled)) return disabled;
    if (pressed != null && states.contains(ButtonStates.pressing)) {
      return pressed;
    }
    if (hovering != null && states.contains(ButtonStates.hovering)) {
      return hovering;
    }
    if (states.contains(ButtonStates.focused)) {
      return focused ?? pressed ?? none;
    }

    return none;
  }
}

class _ButtonState<T> extends ButtonState<T> {
  _ButtonState(this._resolve);

  final ButtonStateResolver<T> _resolve;

  @override
  T resolve(Set<ButtonStates> states) => _resolve(states);
}

class _AllButtonState<T> extends ButtonState<T> {
  _AllButtonState(this._value);

  final T _value;

  @override
  T resolve(states) => _value;
}

class _LerpProperties<T> implements ButtonState<T?> {
  const _LerpProperties(this.a, this.b, this.t, this.lerpFunction);

  final ButtonState<T?>? a;
  final ButtonState<T?>? b;
  final double t;
  final T? Function(T?, T?, double) lerpFunction;

  @override
  T? resolve(Set<ButtonStates> states) {
    final resolvedA = a?.resolve(states);
    final resolvedB = b?.resolve(states);
    return lerpFunction(resolvedA, resolvedB, t);
  }
}

extension ButtonStatesExtension on Set<ButtonStates> {
  bool get isFocused => contains(ButtonStates.focused);
  bool get isDisabled => contains(ButtonStates.disabled);
  bool get isPressing => contains(ButtonStates.pressing);
  bool get isHovering => contains(ButtonStates.hovering);
  bool get isNone => isEmpty;
}
