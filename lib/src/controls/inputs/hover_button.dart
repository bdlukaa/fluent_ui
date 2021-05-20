import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef ButtonStateWidgetBuilder = Widget Function(
  BuildContext,
  List<ButtonStates> state,
);

/// Base widget for any widget that requires input. It
/// provides a [builder] callback to build the child with
/// the current input state: none, hovering, pressing or
/// focused.
///
/// It's used by the following widgets:
/// - [Button]
/// - [Checkbox]
/// - [ComboBox]
/// - [DatePicker]
/// - [IconButton]
/// - [RadioButton]
/// - [TabView]'s [Tab]
/// - [TappableListTile]
/// - [TimePicker]
/// - [ToggleSwitch]
class HoverButton extends StatefulWidget {
  /// Creates a hover button.
  const HoverButton({
    Key? key,
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
    this.onFocusChange,
    this.autofocus = false,
  }) : super(key: key);

  /// The cursor of this hover button. If null, [MouseCursor.defer] is used
  final MouseCursor Function(List<ButtonStates>)? cursor;
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

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  late FocusNode node;

  late Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    node = widget.focusNode ?? _createFocusNode();
    void _handleActionTap() async {
      if (!enabled) return;
      setState(() => _pressing = true);
      widget.onPressed?.call();
      await Future.delayed(Duration(milliseconds: 100));
      setState(() => _pressing = false);
    }

    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleActionTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleActionTap(),
      ),
    };
  }

  @override
  void didUpdateWidget(HoverButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      node = widget.focusNode ?? _createFocusNode();
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
      widget.onPressed != null ||
      widget.onTapUp != null ||
      widget.onTapDown != null ||
      widget.onTapDown != null ||
      widget.onLongPress != null ||
      widget.onLongPressStart != null ||
      widget.onLongPressEnd != null;

  List<ButtonStates> get states {
    if (!enabled) return [ButtonStates.disabled];
    return [
      if (_pressing) ButtonStates.pressing,
      if (_hovering) ButtonStates.hovering,
      if (_shouldShowFocus) ButtonStates.focused,
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget w = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: (_) {
        if (mounted) setState(() => _pressing = true);
        widget.onTapDown?.call();
      },
      onTapUp: (_) async {
        widget.onTapUp?.call();
        if (!enabled) return;
        await Future.delayed(Duration(milliseconds: 100));
        if (mounted) setState(() => _pressing = false);
      },
      onTapCancel: () {
        widget.onTapCancel?.call();
        if (mounted) setState(() => _pressing = false);
      },
      onLongPress: widget.onLongPress,
      onLongPressStart: (_) {
        widget.onLongPressStart?.call();
        if (mounted) setState(() => _pressing = true);
      },
      onLongPressEnd: (_) {
        widget.onLongPressEnd?.call();
        if (mounted) setState(() => _pressing = false);
      },
      onHorizontalDragStart: widget.onHorizontalDragStart,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      child: widget.builder(context, states),
    );
    w = FocusableActionDetector(
      mouseCursor: widget.cursor?.call(states) ??
          context.maybeTheme?.inputMouseCursor.call(states) ??
          MouseCursor.defer,
      focusNode: node,
      autofocus: widget.autofocus,
      enabled: enabled,
      actions: _actionMap,
      onFocusChange: widget.onFocusChange,
      onShowFocusHighlight: (v) {
        if (mounted) setState(() => _shouldShowFocus = v);
      },
      onShowHoverHighlight: (v) {
        if (mounted) setState(() => _hovering = v);
      },
      child: w,
    );
    if (widget.semanticLabel != null) {
      w = MergeSemantics(
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: enabled,
          focusable: enabled,
          focused: node.hasFocus,
          child: w,
        ),
      );
    }
    if (widget.margin != null) w = Padding(padding: widget.margin!, child: w);
    return w;
  }
}

enum ButtonStates { disabled, hovering, pressing, focused, none }

typedef ButtonState<T> = T Function(List<ButtonStates>);

extension ButtonStatesExtension on List<ButtonStates> {
  bool get isFocused => contains(ButtonStates.focused);
  bool get isDisabled => contains(ButtonStates.disabled);
  bool get isPressing => contains(ButtonStates.pressing);
  bool get isHovering => contains(ButtonStates.hovering);
  bool get isNone => isEmpty;
}
