import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';

class HoverButton extends StatefulWidget {
  HoverButton({
    Key key,
    this.cursor,
    this.onPressed,
    this.builder,
  }) : super(key: key);

  final MouseCursor cursor;
  final Function onPressed;

  final Function(BuildContext, bool) builder;

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor ?? SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onHover: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _hovering = true),
        onTapUp: (_) => setState(() => _hovering = false),
        onTapCancel: () => setState(() => _hovering = false),
        child: widget.builder?.call(context, _hovering),
      ),
    );
  }
}
