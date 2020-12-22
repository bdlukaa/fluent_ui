import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class HoverButton extends StatefulWidget {
  HoverButton({
    Key key,
    this.cursor,
    this.onPressed,
    this.onLongPress,
    this.builder,
  }) : super(key: key);

  final MouseCursor Function(BuildContext, ButtonStates) cursor;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  final Widget Function(BuildContext, ButtonStates state) builder;

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
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
    setState(f);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
    );
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
}

typedef ButtonState<T> = T Function(ButtonStates);
