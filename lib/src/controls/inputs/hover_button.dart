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

  final MouseCursor Function(BuildContext, ButtonStates) cursor;
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
      : _hovering
          ? ButtonStates.hovering
          : _pressing
              ? ButtonStates.pressing
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
        cursor: widget.cursor?.call(context, state) ?? buttonCursor(state),
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

Color kDefaultButtonDisabledColor = Colors.grey[100].withOpacity(0.6);

Color checkedInputColor(
  Color from,
  ButtonStates state, {
  Color disabledColor,
}) {
  disabledColor ??= kDefaultButtonDisabledColor;
  Color color = from;
  if (state.isDisabled)
    color = disabledColor;
  else if (state.isHovering || state.isPressing) color = from.withOpacity(0.75);
  return color;
}

Color uncheckedInputColor(ButtonStates state) {
  if (state.isDisabled) return kDefaultButtonDisabledColor;
  if (state.isHovering || state.isPressing) return Colors.grey[40];
  return Colors.transparent;
}
