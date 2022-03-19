import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';

/// A specialized kind of [SingleChildScrollView] that only scrolls
/// horizontally, and allows the mouse wheel to control scrolling.
class HorizontalScrollView extends StatefulWidget {
  final Widget child;
  final ScrollPhysics? scrollPhysics;

  /// Whether or not the mouse wheel can be used to scroll
  /// horizontally. On desktop platforms under a default Flutter
  /// configuration, this may be the only way to scroll horizontally
  /// unless the user has a trackpad.
  final bool mouseWheelScrolls;

  /// If this widget is contained in another widget that can scroll vertically,
  /// when a mouse wheel event is received it will also trigger a vertical
  /// scroll. Specify the scroll controller for this parent widget that
  /// controls the vertical scrolling and it will offset the vertical scroll
  /// on a mouse wheel event, so that it does not vertically scroll at all.
  final ScrollController? parentVerticalScrollController;

  const HorizontalScrollView({
    Key? key,
    required this.child,
    this.scrollPhysics,
    this.mouseWheelScrolls = true,
    this.parentVerticalScrollController,
  }) : super(key: key);

  @override
  _HorizontalScrollViewState createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<HorizontalScrollView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: widget.mouseWheelScrolls
          ? (event) {
              if (event is PointerScrollEvent) {
                _controller.animateTo(_controller.offset + event.scrollDelta.dy,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.ease);
                if (widget.parentVerticalScrollController != null &&
                    widget
                        .parentVerticalScrollController!.positions.isNotEmpty) {
                  widget.parentVerticalScrollController!.jumpTo(widget
                          .parentVerticalScrollController!
                          .positions
                          .last
                          .pixels -
                      event.scrollDelta.dy);
                }
              }
            }
          : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: widget.scrollPhysics ?? const ClampingScrollPhysics(),
        controller: _controller,
        child: widget.child,
      ),
    );
  }
}
