import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';

/// A specialized kind of [SingleChildScrollView] that only scrolls
/// horizontally, and allows the mouse wheel to control scrolling.
/// If vertical scrolling is indeed necessary, can set [scrollDirection]
/// to [Axis.vertical] also.
class HorizontalScrollView extends StatefulWidget {
  final Widget child;
  final ScrollPhysics? scrollPhysics;

  /// Whether or not the mouse wheel can be used to scroll
  /// horizontally. On desktop platforms under a default Flutter
  /// configuration, this may be the only way to scroll horizontally
  /// unless the user has a trackpad.
  final bool mouseWheelScrolls;

  /// The default is [Axis.horizontal], just like the file name.
  /// However, as the demand develops, expanding this attribute
  /// that does not match the file name.
  final Axis scrollDirection;

  const HorizontalScrollView({
    super.key,
    required this.child,
    this.scrollPhysics,
    this.mouseWheelScrolls = true,
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<HorizontalScrollView> createState() => _HorizontalScrollViewState();
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
              // Do not capture any other type of mouse pointer signals
              if (event is PointerScrollEvent) {
                // Make sure we capture this pointer scroll event so that
                // any scrollable widgets higher up in the hierarchy do not
                // handle the event also.
                GestureBinding.instance.pointerSignalResolver.register(event,
                    (event) {
                  if (event is PointerScrollEvent) {
                    // Use animateTo for a smoother behavior when there are
                    // attempts to scroll beyond the boundaries (it will not
                    // jump beyond the boundaries and then "rebound" like jumpTo
                    // would do if used here).
                    _controller.animateTo(
                      _controller.offset + event.scrollDelta.dy,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease,
                    );
                  }
                });
              }
            }
          : null,
      child: SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics ?? const ClampingScrollPhysics(),
        controller: _controller,
        child: widget.child,
      ).hideVerticalScrollbar(context),
    );
  }
}
