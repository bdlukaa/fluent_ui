import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class HoverButton extends StatefulWidget {
  HoverButton({
    Key key,
    this.cursor,
    this.onPressed,
    this.onLongPress,
    this.builder,
    this.focusNode,
    this.margin,
    this.semanticsLabel,
  }) : super(key: key);

  final MouseCursor Function(ButtonStates) cursor;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  final Widget Function(BuildContext, ButtonStates state) builder;

  final FocusNode focusNode;

  final EdgeInsetsGeometry margin;
  final String semanticsLabel;

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  FocusNode node;

  @override
  void initState() {
    node = widget.focusNode ?? FocusNode();
    super.initState();
  }

  bool _hovering = false;
  bool _pressing = false;

  bool get isDisabled => widget.onPressed == null;

  ButtonStates get state => isDisabled
      ? ButtonStates.disabled
      : _pressing
          ? ButtonStates.pressing
          : _hovering
              ? ButtonStates.hovering
              : ButtonStates.none;

  void update(Function f) {
    if (isDisabled) return;
    if (!mounted) return f();
    if (_pressing)
      node.requestFocus();
    else
      node.unfocus();
    setState(f);
  }

  @override
  Widget build(BuildContext context) {
    Widget w = Focus(
      focusNode: node,
      child: MouseRegion(
        cursor: widget.cursor?.call(state) ?? buttonCursor(state),
        onEnter: (_) => update(() => _hovering = true),
        onHover: (_) => update(() => _hovering = true),
        onExit: (_) => update(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => update(() => _pressing = true),
          onTapUp: (_) async {
            if (isDisabled) return;
            await Future.delayed(Duration(milliseconds: 100));
            update(() => _pressing = false);
          },
          onTapCancel: () => update(() => _pressing = false),
          onLongPress: widget.onLongPress,
          onLongPressStart: (_) => update(() => _pressing = true),
          onLongPressEnd: (_) => update(() => _pressing = false),
          // onTapCancel: () => update(() => _pressing = false),
          child: widget.builder?.call(context, state) ?? SizedBox(),
        ),
      ),
    );
    if (widget.margin != null) w = Padding(padding: widget.margin, child: w);
    if (widget.semanticsLabel != null)
      w = Semantics(
        label: widget.semanticsLabel,
        child: w,
      );
    return w;
  }
}

class ButtonStates {
  final String id;

  const ButtonStates._(this.id);

  static const ButtonStates disabled = ButtonStates._('disabled');
  static const ButtonStates hovering = ButtonStates._('hovering');
  static const ButtonStates pressing = ButtonStates._('pressing');
  static const ButtonStates none = ButtonStates._('none');

  bool get isDisabled => this == disabled;
  bool get isHovering => this == hovering;
  bool get isPressing => this == pressing;
  bool get isNone => this == none;
}

typedef ButtonState<T> = T Function(ButtonStates);

// Button color

Color checkedInputColor(Style style, ButtonStates state) {
  Color color = style.accentColor;
  if (state.isDisabled)
    return style.disabledColor;
  else if (state.isHovering)
    return color.withOpacity(0.70);
  else if (state.isPressing) return color.withOpacity(0.90);
  return color;
}

Color uncheckedInputColor(Style style, ButtonStates state) {
  if (state.isDisabled) return style.disabledColor;
  if (state.isPressing) return Colors.grey[70];
  if (state.isHovering) return Colors.grey[40];
  return Colors.transparent;
}

MouseCursor buttonCursor(ButtonStates state) {
  if (state.isDisabled)
    return SystemMouseCursors.forbidden;
  else if (state.isHovering || state.isPressing)
    return SystemMouseCursors.click;
  else
    return MouseCursor.defer;
}
