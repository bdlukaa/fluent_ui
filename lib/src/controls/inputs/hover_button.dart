import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef ButtonStateWidgetBuilder = Widget Function(
    BuildContext, ButtonStates state);

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
    this.cursor,
    this.onPressed,
    this.onLongPress,
    this.builder,
    this.focusNode,
    this.margin,
    this.semanticLabel,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressEnd,
    this.onLongPressStart,
    this.autofocus = false,
    this.ignoreFocusManager = false,
  }) : super(key: key);

  /// The cursor of this hover button. If null, [MouseCursor.defer] is used
  final MouseCursor Function(ButtonStates)? cursor;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  final VoidCallback? onPressed;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapCancel;

  final ButtonStateWidgetBuilder? builder;

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

  /// If true, a [Focus] will not be added to the tree. `ButtonStates.focused`
  /// will never be called. Keyboard shortcuts will also never be called.
  ///
  /// It's usually used when two [HoverButton]s are provided on the widget tree.
  final bool ignoreFocusManager;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

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
      update(() => _pressing = true);
      widget.onPressed?.call();
      await Future.delayed(Duration(milliseconds: 100));
      update(() => _pressing = false);
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

  bool get enabled =>
      widget.onPressed != null ||
      widget.onTapUp != null ||
      widget.onTapDown != null ||
      widget.onTapDown != null ||
      widget.onLongPress != null ||
      widget.onLongPressStart != null ||
      widget.onLongPressEnd != null;

  ButtonStates get state => !enabled
      ? ButtonStates.disabled
      : _pressing
          ? ButtonStates.pressing
          : _hovering
              ? ButtonStates.hovering
              : _showHighlight
                  ? ButtonStates.focused
                  : ButtonStates.none;

  void update(void Function() f) {
    if (!enabled) return;
    if (!mounted) return f();
    if (_pressing)
      node.requestFocus();
    else
      node.unfocus();
    setState(f);
  }

  bool _showHighlight = false;

  @override
  Widget build(BuildContext context) {
    Widget w = MouseRegion(
      opaque: false,
      cursor: widget.cursor?.call(state) ?? buttonCursor(state),
      onEnter: (_) => update(() => _hovering = true),
      onHover: (_) => update(() => _hovering = true),
      onExit: (_) => update(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: (_) {
          update(() => _pressing = true);
          widget.onTapDown?.call();
        },
        onTapUp: (_) async {
          widget.onTapUp?.call();
          if (!enabled) return;
          await Future.delayed(Duration(milliseconds: 100));
          update(() => _pressing = false);
        },
        onTapCancel: () {
          widget.onTapCancel?.call();
          update(() => _pressing = false);
        },
        onLongPress: widget.onLongPress,
        onLongPressStart: (_) {
          widget.onLongPressStart?.call();
          update(() => _pressing = true);
        },
        onLongPressEnd: (_) {
          widget.onLongPressEnd?.call();
          update(() => _pressing = false);
        },
        child: widget.builder?.call(context, state) ?? SizedBox(),
      ),
    );
    if (!widget.ignoreFocusManager)
      w = FocusableActionDetector(
        focusNode: node,
        autofocus: widget.autofocus,
        enabled: enabled,
        actions: _actionMap,
        onShowFocusHighlight: (v) => setState(() => _showHighlight = v),
        child: w,
      );
    if (widget.semanticLabel != null) {
      w = MergeSemantics(
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: enabled,
          focusable: true,
          focused: node.hasFocus,
          child: w,
        ),
      );
    }
    if (widget.margin != null) w = Padding(padding: widget.margin!, child: w);
    return w;
  }
}

@immutable
class ButtonStates with Diagnosticable {
  final String id;

  const ButtonStates._(this.id);

  static const ButtonStates disabled = ButtonStates._('disabled');
  static const ButtonStates hovering = ButtonStates._('hovering');
  static const ButtonStates pressing = ButtonStates._('pressing');
  static const ButtonStates focused = ButtonStates._('focused');
  static const ButtonStates none = ButtonStates._('none');

  bool get isDisabled => this == disabled;
  bool get isHovering => this == hovering;
  bool get isPressing => this == pressing;
  bool get isFocused => this == focused;
  bool get isNone => this == none;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('state', id));
  }
}

typedef ButtonState<T> = T Function(ButtonStates);

// Button color

Color checkedInputColor(ThemeData style, ButtonStates state) {
  Color color = style.accentColor;
  if (state.isDisabled)
    return style.disabledColor;
  else if (state.isHovering)
    return color.withOpacity(0.70);
  else if (state.isPressing) return color.withOpacity(0.90);
  return color;
}

Color uncheckedInputColor(ThemeData style, ButtonStates state) {
  if (style.brightness == Brightness.light) {
    if (state.isDisabled) return style.disabledColor;
    if (state.isPressing) return Colors.grey[70]!;
    if (state.isHovering) return Colors.grey[40]!;
    return Colors.grey[40]!.withOpacity(0);
  } else {
    if (state.isDisabled) return style.disabledColor;
    if (state.isPressing) return Colors.grey[130]!;
    if (state.isHovering) return Colors.grey[150]!;
    return Colors.grey[150]!.withOpacity(0);
  }
}

MouseCursor buttonCursor(ButtonStates state) {
  if (state.isHovering || state.isPressing)
    return SystemMouseCursors.click;
  else
    return MouseCursor.defer;
}
